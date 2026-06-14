package banksystem.controller;

import banksystem.model.Account;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

public class WithdrawController extends MoneyOperationController {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        loadAccountsAndForward(request, response, user.getId(), "/views/user/withdraw.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        try {
            int accountId = Integer.parseInt(request.getParameter("accountId"));
            BigDecimal amount = parsePositiveAmount(request.getParameter("amount"));
            withdraw(user, accountId, amount, request);
            response.sendRedirect(request.getContextPath() + "/transactions?success=withdraw");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            loadAccountsAndForward(request, response, user.getId(), "/views/user/withdraw.jsp");
        } catch (SQLException e) {
            throw new ServletException("Withdrawal failed due to a database error.", e);
        }
    }

    private void withdraw(User user, int accountId, BigDecimal amount, HttpServletRequest request) throws SQLException {
        Connection connection = openTransaction();
        try {
            Account account = accountDao.findByIdAndUserIdForUpdate(connection, accountId, user.getId());
            if (account == null) {
                throw new IllegalArgumentException("The account does not exist or does not belong to the current user.");
            }
            enforceLimitRule(resolveLimitRule(request, "WITHDRAW"), amount, "Withdrawal");
            if (!account.isNormal()) {
                writeFrozenSecurityEvent(connection, user.getId(), "WITHDRAW", request);
                throw new IllegalArgumentException("The account status does not allow withdrawal.");
            }
            if (account.getAvailableBalance().compareTo(amount) < 0) {
                throw new IllegalArgumentException("Insufficient available balance.");
            }
            BigDecimal balanceBefore = account.getBalance();
            BigDecimal balanceAfter = balanceBefore.subtract(amount);
            accountDao.updateBalance(connection, account.getId(), balanceAfter);

            int transactionId = transactionDao.add(connection, buildTransaction(
                    createTransactionNo("WD"), account.getId(), null, "WITHDRAW",
                    amount, balanceAfter, "Cash withdrawal"));
            ledgerEntryDao.add(connection, buildLedgerEntry(transactionId, account.getId(), "OUT",
                    amount, balanceBefore, balanceAfter, "Withdrawal debit"));
            transactionValidationDao.add(connection, buildValidation(transactionId, true, true, true, true, null));
            operationLogDao.add(connection, buildLog(user.getId(), "WITHDRAW", "TRANSACTION",
                    transactionId, "Withdrawal completed. Amount " + amount, "SUCCESS", request));
            notificationDao.add(connection, buildNotification(user.getId(), "Withdrawal successful",
                    "Your withdrawal of " + amount + " has been completed.", "TRANSACTION"));
            connection.commit();
        } catch (SQLException e) {
            rollback(connection);
            throw e;
        } catch (RuntimeException e) {
            rollback(connection);
            throw e;
        } finally {
            close(connection);
        }
    }
}
