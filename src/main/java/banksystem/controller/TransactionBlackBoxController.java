package banksystem.controller;

import banksystem.dao.TransactionBlackBoxDao;
import banksystem.model.TransactionBlackBox;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class TransactionBlackBoxController extends BaseController {
    private final TransactionBlackBoxDao blackBoxDao = new TransactionBlackBoxDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        int transactionId;
        try {
            transactionId = Integer.parseInt(request.getParameter("transactionId"));
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing transactionId.");
            return;
        }
        TransactionBlackBox blackBox = blackBoxDao.findByTransactionId(transactionId);
        request.setAttribute("blackBox", blackBox);
        request.getRequestDispatcher("/views/user/transaction_blackbox.jsp").forward(request, response);
    }
}
