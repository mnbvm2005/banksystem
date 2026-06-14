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

        boolean admin = hasRole(request, "ADMIN");
        List<Transaction> transactions = transactionDao.findByUserId(user.getId(), admin);
        request.setAttribute("transactions", transactions);
        request.setAttribute("totalTransactions", Integer.valueOf(transactionDao.countVisible(user.getId(), admin)));
        request.setAttribute("totalInflow", transactionDao.sumLedgerAmount(user.getId(), admin, "IN"));
        request.setAttribute("totalOutflow", transactionDao.sumLedgerAmount(user.getId(), admin, "OUT"));
        request.setAttribute("pendingReview", Integer.valueOf(transactionDao.countPendingReview(user.getId(), admin)));
        request.getRequestDispatcher("/views/user/transactions.jsp").forward(request, response);
    }
}
