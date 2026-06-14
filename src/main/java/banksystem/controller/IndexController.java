package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.TransactionDao;
import banksystem.model.Account;
import banksystem.model.Transaction;
import banksystem.model.User;

import javax.servlet.ServletException;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

public class IndexController extends BaseController {
    private final AccountDao accountDao = new AccountDao();
    private final TransactionDao transactionDao = new TransactionDao();

    @Override
    protected void doGet(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<Account> accounts = accountDao.findByUserId(user.getId());
        List<Transaction> transactions = transactionDao.findByUserId(user.getId());
        BigDecimal totalBalance = BigDecimal.ZERO;
        for (Account account : accounts) {
            if (account.getBalance() != null) {
                totalBalance = totalBalance.add(account.getBalance());
            }
        }

        BigDecimal monthlyInflow = BigDecimal.ZERO;
        BigDecimal monthlyOutflow = BigDecimal.ZERO;
        Calendar monthStart = Calendar.getInstance();
        monthStart.set(Calendar.DAY_OF_MONTH, 1);
        monthStart.set(Calendar.HOUR_OF_DAY, 0);
        monthStart.set(Calendar.MINUTE, 0);
        monthStart.set(Calendar.SECOND, 0);
        monthStart.set(Calendar.MILLISECOND, 0);
        List<Transaction> recentTransactions = new ArrayList<Transaction>();
        for (Transaction transaction : transactions) {
            if (recentTransactions.size() < 5) {
                recentTransactions.add(transaction);
            }
            if (transaction.getCreateTime() == null || transaction.getCreateTime().before(monthStart.getTime())) {
                continue;
            }
            if (transaction.getStatus() != null && !"SUCCESS".equals(transaction.getStatus())) {
                continue;
            }
            BigDecimal amount = transaction.getAmount() == null ? BigDecimal.ZERO : transaction.getAmount();
            String type = transaction.getTransactionType();
            if ("DEPOSIT".equals(type) || "INVEST_REDEEM".equals(type)) {
                monthlyInflow = monthlyInflow.add(amount);
            } else if ("WITHDRAW".equals(type) || "PAYMENT".equals(type) || "INVEST_BUY".equals(type) || "TRANSFER".equals(type)) {
                monthlyOutflow = monthlyOutflow.add(amount);
            }
        }

        request.setAttribute("accounts", accounts);
        request.setAttribute("totalBalance", totalBalance);
        request.setAttribute("monthlyInflow", monthlyInflow);
        request.setAttribute("monthlyOutflow", monthlyOutflow);
        request.setAttribute("recentTransactions", recentTransactions);
        request.getRequestDispatcher("/views/user/index.jsp").forward(request, response);
    }
}
