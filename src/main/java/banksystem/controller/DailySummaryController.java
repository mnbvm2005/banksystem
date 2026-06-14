package banksystem.controller;

import banksystem.dao.AccountDailySummaryDao;
import banksystem.model.AccountDailySummary;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class DailySummaryController extends BaseController {
    private final AccountDailySummaryDao summaryDao = new AccountDailySummaryDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        boolean admin = hasRole(request, "ADMIN");
        List<AccountDailySummary> summaries = summaryDao.findVisible(user.getId(), admin);
        request.setAttribute("dailySummaries", summaries);
        request.setAttribute("dailySummaryAdminView", Boolean.valueOf(admin));
        request.getRequestDispatcher("/views/user/daily_summaries.jsp").forward(request, response);
    }
}
