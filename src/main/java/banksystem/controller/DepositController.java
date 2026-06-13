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

public class DepositController extends MoneyOperationController {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        loadAccountsAndForward(request, response, user.getId(), "/views/user/deposit.jsp");
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
            deposit(user, accountId, amount, request);
            response.sendRedirect(request.getContextPath() + "/transactions?success=deposit");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            loadAccountsAndForward(request, response, user.getId(), "/views/user/deposit.jsp");
        } catch (SQLException e) {
            throw new ServletException("Deposit failed due to a database error.", e);
        }
    }

    private void deposit(User user, int accountId, BigDecimal amount, HttpServletRequest request) throws SQLException {
        Connection connection = openTransaction();
        try {
            Account account = accountDao.findByIdAndUserIdForUpdate(connection, accountId, user.getId());
            if (account == null) {
                throw new IllegalArgumentException("The account does not exist or does not belong to the current user.");
            }
            if (!account.isNormal()) {
                throw new IllegalArgumentException("The account status does not allow deposit.");
            }
            BigDecimal balanceBefore = account.getBalance();
            BigDecimal balanceAfter = balanceBefore.add(amount);
            accountDao.updateBalance(connection, account.getId(), balanceAfter);

            int transactionId = transactionDao.add(connection, buildTransaction(
                    createTransactionNo("DP"), null, account.getId(), "DEPOSIT",
                    amount, balanceAfter, "Cash deposit"));
            ledgerEntryDao.add(connection, buildLedgerEntry(transactionId, account.getId(), "IN",
                    amount, balanceBefore, balanceAfter, "Deposit credit"));
            transactionValidationDao.add(connection, buildValidation(transactionId, true, true, true, true, null));
            operationLogDao.add(connection, buildLog(user.getId(), "DEPOSIT", "TRANSACTION",
                    transactionId, "Deposit completed. Amount " + amount, "SUCCESS", request));
            notificationDao.add(connection, buildNotification(user.getId(), "Deposit successful",
                    "Your deposit of " + amount + " has been completed.", "TRANSACTION"));
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
