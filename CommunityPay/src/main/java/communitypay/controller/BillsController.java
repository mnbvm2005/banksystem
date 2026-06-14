package communitypay.controller;

import communitypay.dao.UtilityBillDao;
import communitypay.model.CommunityUser;
import communitypay.model.UtilityBill;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

public class BillsController extends HttpServlet {
    private final UtilityBillDao billDao = new UtilityBillDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        CommunityUser user = CommunityAuth.requireUser(request, response);
        if (user == null) return;
        List<UtilityBill> bills = billDao.findByResidentNo(user.getResidentNo());
        int unpaid = 0;
        int paid = 0;
        int dueSoon = 0;
        BigDecimal monthDue = BigDecimal.ZERO;
        for (UtilityBill bill : bills) {
            if ("PAID".equals(bill.getStatus())) {
                paid++;
            } else {
                unpaid++;
                dueSoon++;
                if (bill.getAmount() != null) monthDue = monthDue.add(bill.getAmount());
            }
        }
        CommunityAuth.exposeUser(request, user);
        request.setAttribute("bills", bills);
        request.setAttribute("unpaidCount", Integer.valueOf(unpaid));
        request.setAttribute("paidCount", Integer.valueOf(paid));
        request.setAttribute("monthDue", monthDue);
        request.setAttribute("dueSoon", Integer.valueOf(dueSoon));
        request.setAttribute("activeMenu", "bills");
        request.getRequestDispatcher("/views/bills.jsp").forward(request, response);
    }
}
