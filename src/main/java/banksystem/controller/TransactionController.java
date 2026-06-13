package banksystem.controller;

import banksystem.dao.TransactionDao;
import banksystem.model.Transaction;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class TransactionController extends BaseController {
    private final TransactionDao transactionDao = new TransactionDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<Transaction> transactions = transactionDao.findByUserId(user.getId(), hasRole(request, "ADMIN"));
        request.setAttribute("transactions", transactions);
        request.getRequestDispatcher("/views/user/transactions.jsp").forward(request, response);
    }
}
