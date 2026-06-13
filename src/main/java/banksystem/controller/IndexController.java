package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.model.Account;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

public class IndexController extends BaseController {
    private final AccountDao accountDao = new AccountDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<Account> accounts = accountDao.findByUserId(user.getId());
        BigDecimal totalBalance = BigDecimal.ZERO;
        for (Account account : accounts) {
            if (account.getBalance() != null) {
                totalBalance = totalBalance.add(account.getBalance());
            }
        }

        request.setAttribute("accounts", accounts);
        request.setAttribute("totalBalance", totalBalance);
        request.getRequestDispatcher("/views/user/index.jsp").forward(request, response);
    }
}
