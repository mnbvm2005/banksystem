package banksystem.controller;

import banksystem.dao.PaymentRecordDao;
import banksystem.model.Account;
import banksystem.model.PaymentRecord;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

public class PaymentController extends MoneyOperationController {
    private final PaymentRecordDao paymentRecordDao = new PaymentRecordDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        loadAccountsAndForward(request, response, user.getId(), "/views/user/payment.jsp");
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
            String accountIdText = trim(request.getParameter("accountId"));
            if (accountIdText.length() == 0) {
                throw new IllegalArgumentException("当前用户没有可用付款账户，无法缴费。");
            }
            int accountId = Integer.parseInt(accountIdText);
            BigDecimal amount = parsePositiveAmount(request.getParameter("amount"));
            String paymentType = normalizePaymentType(request.getParameter("paymentType"));
            String paymentNo = normalizeRemark(request.getParameter("paymentNo"), "");
            String provider = normalizeRemark(request.getParameter("serviceProvider"), "Utility Service Center");
            if (paymentNo.length() == 0) {
                throw new IllegalArgumentException("请输入缴费户号。");
            }
            payment(user, accountId, amount, paymentType, paymentNo, provider, request);
            response.sendRedirect(request.getContextPath() + "/transactions?success=payment");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            loadAccountsAndForward(request, response, user.getId(), "/views/user/payment.jsp");
        } catch (SQLException e) {
            throw new ServletException("Payment failed due to a database error.", e);
        }
    }

    private void payment(User user, int accountId, BigDecimal amount, String paymentType,
                         String paymentNo, String provider, HttpServletRequest request) throws SQLException {
        Connection connection = openTransaction();
        try {
            Account account = accountDao.findByIdAndUserIdForUpdate(connection, accountId, user.getId());
            if (account == null) {
                throw new IllegalArgumentException("当前用户没有可用付款账户，无法缴费。");
            }
            enforceLimitRule(resolveLimitRule(request, "PAYMENT"), amount, "Payment");
            if (!account.isNormal()) {
                writeFrozenSecurityEvent(connection, user.getId(), "PAYMENT", request);
                throw new IllegalArgumentException("付款账户状态异常，无法缴费。");
            }
            if (account.getAvailableBalance().compareTo(amount) < 0) {
                throw new IllegalArgumentException("余额不足，当前账户可用余额不足以完成本次缴费。");
            }
            BigDecimal balanceBefore = account.getBalance();
            BigDecimal balanceAfter = balanceBefore.subtract(amount);
            accountDao.updateBalance(connection, account.getId(), balanceAfter);

            int transactionId = transactionDao.add(connection, buildTransaction(
                    createTransactionNo("PY"), account.getId(), null, "PAYMENT",
                    amount, balanceAfter, "Utility payment: " + paymentType));
            ledgerEntryDao.add(connection, buildLedgerEntry(transactionId, account.getId(), "OUT",
                    amount, balanceBefore, balanceAfter, "Payment debit: " + paymentNo));

            PaymentRecord record = new PaymentRecord();
            record.setTransactionId(transactionId);
            record.setAccountId(account.getId());
            record.setPaymentType(paymentType);
            record.setPaymentNo(paymentNo);
            record.setServiceProvider(provider);
            record.setPaymentAmount(amount);
            record.setPaymentStatus("SUCCESS");
            paymentRecordDao.add(connection, record);

            transactionValidationDao.add(connection, buildValidation(transactionId, true, true, true, true, null));
            operationLogDao.add(connection, buildLog(user.getId(), "PAYMENT", "TRANSACTION",
                    transactionId, "Payment submitted. Amount " + amount + ", customer no. " + paymentNo, "SUCCESS", request));
            notificationDao.add(connection, buildNotification(user.getId(), "Payment successful",
                    "Your payment of " + amount + " has been completed. Customer no. " + paymentNo + ".", "TRANSACTION"));
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

    private String normalizePaymentType(String paymentType) {
        String value = normalizeRemark(paymentType, "PHONE").toUpperCase();
        if ("WATER".equals(value) || "ELECTRICITY".equals(value) || "GAS".equals(value) || "PHONE".equals(value)) {
            return value;
        }
        return "PHONE";
    }
}
