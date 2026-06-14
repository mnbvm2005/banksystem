package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.BillDao;
import banksystem.dao.SavedQueryDao;
import banksystem.dao.UserBudgetDao;
import banksystem.model.Account;
import banksystem.model.Bill;
import banksystem.model.SavedQuery;
import banksystem.model.UserBudget;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

public class BillController extends BaseController {
    private final AccountDao accountDao = new AccountDao();
    private final BillDao billDao = new BillDao();
    private final UserBudgetDao userBudgetDao = new UserBudgetDao();
    private final SavedQueryDao savedQueryDao = new SavedQueryDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<Account> accounts = accountDao.findByUserId(user.getId());
        List<UserBudget> budgets = userBudgetDao.findCurrentMonthByUserId(user.getId());
        List<SavedQuery> savedQueries = savedQueryDao.findByUserIdAndType(user.getId(), "BILL");
        request.setAttribute("accounts", accounts);
        request.setAttribute("budgetCards", budgets);
        request.setAttribute("savedBillQueries", savedQueries);
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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        String action = trim(request.getParameter("action"));
        if (!"save-query".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/bill");
            return;
        }

        String queryName = trim(request.getParameter("queryName"));
        if (queryName.length() == 0) {
            queryName = "Bill Query Preset";
        }
        String condition = buildSavedCondition(request);
        try {
            savedQueryDao.add(user.getId(), queryName, "BILL", condition);
            response.sendRedirect(request.getContextPath() + "/bill#savedQueries");
        } catch (SQLException e) {
            throw new ServletException("Failed to save bill query preset.", e);
        }
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

    private String buildSavedCondition(HttpServletRequest request) {
        String period = trim(request.getParameter("billType"));
        String startDate = trim(request.getParameter("startDate"));
        String endDate = trim(request.getParameter("endDate"));
        String accountId = trim(request.getParameter("accountId"));
        if (period.length() == 0) {
            period = "MONTH";
        }
        return "period=" + period + ";start=" + startDate + ";end=" + endDate + ";accountId=" + accountId;
    }
}
