package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.model.Account;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class AccountController extends BaseController {
    private final AccountDao accountDao = new AccountDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<Account> accounts = accountDao.findByUserId(user.getId());
        request.setAttribute("accounts", accounts);
        request.getRequestDispatcher("/views/user/account.jsp").forward(request, response);
    }
}
