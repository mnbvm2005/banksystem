package banksystem.controller;

import banksystem.dao.TransactionCategoryDao;
import banksystem.dao.UserBudgetDao;
import banksystem.model.TransactionCategory;
import banksystem.model.User;
import banksystem.model.UserBudget;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.YearMonth;
import java.util.List;

public class BudgetController extends BaseController {
    private final UserBudgetDao userBudgetDao = new UserBudgetDao();
    private final TransactionCategoryDao categoryDao = new TransactionCategoryDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/bill#budget");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        try {
            String month = normalizeMonth(request.getParameter("budgetMonth"));
            int categoryId = Integer.parseInt(request.getParameter("categoryId"));
            BigDecimal budgetAmount = new BigDecimal(request.getParameter("budgetAmount"));
            BigDecimal warningThreshold = new BigDecimal(request.getParameter("warningThreshold"));
            if (budgetAmount.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Budget amount must be greater than 0.");
            }
            if (warningThreshold.compareTo(BigDecimal.ZERO) <= 0 || warningThreshold.compareTo(BigDecimal.ONE) > 0) {
                throw new IllegalArgumentException("Warning threshold must be between 0 and 1.");
            }
            userBudgetDao.upsertBudget(user.getId(), categoryId, month, budgetAmount, warningThreshold);
            response.sendRedirect(request.getContextPath() + "/budgets?month=" + month);
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage() == null ? "Failed to save budget." : e.getMessage());
            doGet(request, response);
        }
    }

    private String normalizeMonth(String value) {
        try {
            if (value == null || value.trim().length() == 0) {
                return YearMonth.now().toString();
            }
            return YearMonth.parse(value.trim()).toString();
        } catch (Exception e) {
            return YearMonth.now().toString();
        }
    }
}
