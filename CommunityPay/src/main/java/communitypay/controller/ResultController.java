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

public class ResultController extends HttpServlet {
    private final UtilityBillDao billDao = new UtilityBillDao();
    private final PaymentEventDao eventDao = new PaymentEventDao();
    private final ApiConfigDao configDao = new ApiConfigDao();
    private final BankOpenPaymentClient bankClient = new BankOpenPaymentClient();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String billNo = request.getParameter("billNo");
        CommunityUser user = CommunityAuth.requireUser(request, response);
        if (user == null) return;
        String status = request.getParameter("status");
        String transactionText = request.getParameter("bankTransactionId");
        Integer transactionId = null;
        try {
            if (transactionText != null && transactionText.length() > 0) transactionId = Integer.valueOf(transactionText);
        } catch (Exception ignored) {
        }
        UtilityBill owned = billDao.findByBillNoAndResidentNo(billNo, user.getResidentNo());
        if (owned != null) {
            ApiConfig config = configDao.findActive();
            BankOpenPaymentClient.BankStatusResult bankStatus = bankClient.queryStatus(config, billNo);
            if (bankStatus.success && "SUCCESS".equals(bankStatus.status)) {
                transactionId = parseTransactionId(bankStatus.bankTransactionId);
                billDao.markResult(billNo, "PAID", transactionId);
                eventDao.add(billNo, "PAY_SUCCESS", "bankTransactionId=" + bankStatus.bankTransactionId);
                status = "SUCCESS";
            } else if ("FAILED".equals(status)) {
                billDao.markResult(billNo, "FAILED", transactionId);
                eventDao.add(billNo, "PAY_FAILED", bankStatus.rawResponse);
            }
        }
        UtilityBill bill = billDao.findByBillNoAndResidentNo(billNo, user.getResidentNo());
        CommunityAuth.exposeUser(request, user);
        request.setAttribute("bill", bill);
        request.setAttribute("status", status);
        request.getRequestDispatcher("/views/result.jsp").forward(request, response);
    }

    private Integer parseTransactionId(String value) {
        try {
            if (value != null && value.length() > 0) return Integer.valueOf(value);
        } catch (Exception ignored) {
        }
        return null;
    }
}
