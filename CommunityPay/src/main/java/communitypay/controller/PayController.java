package communitypay.controller;

import communitypay.dao.ApiConfigDao;
import communitypay.dao.PaymentEventDao;
import communitypay.dao.UtilityBillDao;
import communitypay.model.ApiConfig;
import communitypay.model.CommunityUser;
import communitypay.model.UtilityBill;
import communitypay.util.BankOpenPaymentClient;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class PayController extends HttpServlet {
    private final UtilityBillDao billDao = new UtilityBillDao();
    private final ApiConfigDao configDao = new ApiConfigDao();
    private final PaymentEventDao eventDao = new PaymentEventDao();
    private final BankOpenPaymentClient bankClient = new BankOpenPaymentClient();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String billNo = request.getParameter("billNo");
        CommunityUser user = CommunityAuth.requireUser(request, response);
        if (user == null) return;
        UtilityBill bill = billDao.findByBillNoAndResidentNo(billNo, user.getResidentNo());
        if (bill == null) {
            response.sendRedirect(request.getContextPath() + "/result?status=FAILED&billNo=");
            return;
        }
        if (!"UNPAID".equals(bill.getStatus()) && !"FAILED".equals(bill.getStatus()) && !"PAID".equals(bill.getStatus())) {
            response.sendRedirect(request.getContextPath() + "/result?billNo=" + bill.getBillNo() + "&status=FAILED");
            return;
        }
        ApiConfig config = configDao.findActive();
        String returnUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                + request.getContextPath() + "/result";
        BankOpenPaymentClient.BankCreateResult result = bankClient.createPayment(config, bill, user, returnUrl);
        if (!result.success) {
            eventDao.add(bill.getBillNo(), "CREATE_FAILED", result.rawResponse);
            response.sendRedirect(request.getContextPath() + "/result?billNo=" + bill.getBillNo() + "&status=FAILED");
            return;
        }
        billDao.markPaying(bill.getBillNo(), result.payToken);
        eventDao.add(bill.getBillNo(), "BANK_ORDER_CREATED", "payToken=" + result.payToken);
        request.setAttribute("bill", bill);
        request.setAttribute("payUrl", result.payUrl);
        request.getRequestDispatcher("/views/pay_redirect.jsp").forward(request, response);
    }
}
