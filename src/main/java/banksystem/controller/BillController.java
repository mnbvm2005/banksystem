package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.BillDao;
import banksystem.model.Account;
import banksystem.model.Bill;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

public class BillController extends BaseController {
    private final AccountDao accountDao = new AccountDao();
    private final BillDao billDao = new BillDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<Account> accounts = accountDao.findByUserId(user.getId());
        request.setAttribute("accounts", accounts);
        if (!accounts.isEmpty()) {
            int accountId = parseAccountId(request.getParameter("accountId"), accounts.get(0).getId());
            LocalDate end = parseDate(request.getParameter("endDate"), LocalDate.now());
            LocalDate start = parseDate(request.getParameter("startDate"), end.minusMonths(1));
            String billType = request.getParameter("billType");
            if (billType == null || billType.trim().length() == 0) {
                billType = "MONTH";
            }
            Bill bill = billDao.buildBill(accountId, billType, Date.valueOf(start), Date.valueOf(end));
            request.setAttribute("bill", bill);
            request.setAttribute("selectedAccountId", accountId);
            request.setAttribute("startDate", start.toString());
            request.setAttribute("endDate", end.toString());
            request.setAttribute("billType", billType);
        }
        request.getRequestDispatcher("/views/user/bill.jsp").forward(request, response);
    }

    private int parseAccountId(String text, int defaultValue) {
        try {
            return Integer.parseInt(text);
        } catch (Exception e) {
            return defaultValue;
        }
    }

    private LocalDate parseDate(String text, LocalDate defaultValue) {
        try {
            if (text == null || text.trim().length() == 0) {
                return defaultValue;
            }
            return LocalDate.parse(text);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
