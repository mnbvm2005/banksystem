package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.AccountStatusHistoryDao;
import banksystem.model.Account;
import banksystem.model.AccountStatusHistory;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class AccountController extends BaseController {
    private final AccountDao accountDao = new AccountDao();
    private final AccountStatusHistoryDao accountStatusHistoryDao = new AccountStatusHistoryDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<Account> accounts = accountDao.findByUserId(user.getId());
        List<AccountStatusHistory> recentStatusHistories = accountStatusHistoryDao.findRecentByUserId(user.getId(), 6);
        request.setAttribute("accounts", accounts);
        request.setAttribute("recentStatusHistories", recentStatusHistories);
        request.getRequestDispatcher("/views/user/account.jsp").forward(request, response);
    }
}
