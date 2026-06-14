package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.LedgerEntryDao;
import banksystem.dao.NotificationDao;
import banksystem.dao.OpenPaymentDao;
import banksystem.dao.OperationLogDao;
import banksystem.dao.PaymentRecordDao;
import banksystem.dao.TransactionDao;
import banksystem.dao.TransactionValidationDao;
import banksystem.model.Account;
import banksystem.model.ExternalPaymentOrder;
import banksystem.model.LedgerEntry;
import banksystem.model.Notification;
import banksystem.model.OperationLog;
import banksystem.model.PaymentRecord;
import banksystem.model.Transaction;
import banksystem.model.TransactionValidation;
import banksystem.model.User;
import banksystem.sqloperation.GetMySQLConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class BankPayController extends BaseController {
    private final OpenPaymentDao openPaymentDao = new OpenPaymentDao();
    private final AccountDao accountDao = new AccountDao();
    private final TransactionDao transactionDao = new TransactionDao();
    private final LedgerEntryDao ledgerEntryDao = new LedgerEntryDao();
    private final PaymentRecordDao paymentRecordDao = new PaymentRecordDao();
    private final TransactionValidationDao validationDao = new TransactionValidationDao();
    private final OperationLogDao operationLogDao = new OperationLogDao();
    private final NotificationDao notificationDao = new NotificationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) return;
        String payToken = trim(request.getParameter("payToken"));
        ExternalPaymentOrder order = openPaymentDao.findByToken(payToken);
        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/payment?error=openpay");
            return;
        }
        List<Account> accounts = accountDao.findByUserId(user.getId());
        boolean accountMatched = isBoundBankUser(user, order);
        request.setAttribute("openPaymentOrder", order);
        request.setAttribute("accounts", accounts);
        request.setAttribute("accountMatched", Boolean.valueOf(accountMatched));
        request.getRequestDispatcher("/views/user/bankpay_checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoginUser(request, response);
        if (user == null) return;
        String payToken = trim(request.getParameter("payToken"));
        try {
            ExternalPaymentOrder order = openPaymentDao.findByToken(payToken);
            if (order == null) {
                throw new IllegalArgumentException("支付订单不存在，请返回小区缴费页面重新发起。");
            }
            if (!isBoundBankUser(user, order)) {
                throw new IllegalArgumentException("当前银行登录账号与上财小区绑定账号不一致，请切换账号后支付。");
            }
            if ("SUCCESS".equals(order.getStatus())) {
                response.sendRedirect(buildReturnUrl(order, "SUCCESS", order.getBankTransactionId()));
                return;
            }
            String accountIdText = trim(request.getParameter("accountId"));
            if (accountIdText.length() == 0) {
                throw new IllegalArgumentException("当前用户没有可用付款账户，无法完成缴费。");
            }
            int accountId = Integer.parseInt(accountIdText);
            int transactionId = confirm(user, accountId, order, request);
            response.sendRedirect(buildReturnUrl(order, "SUCCESS", Integer.valueOf(transactionId)));
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (SQLException e) {
            throw new ServletException("Open payment confirmation failed.", e);
        }
    }

    private int confirm(User user, int accountId, ExternalPaymentOrder order, HttpServletRequest request) throws SQLException {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) throw new SQLException("Database connection failed.");
        try {
            connection.setAutoCommit(false);
            Account account = accountDao.findByIdAndUserIdForUpdate(connection, accountId, user.getId());
            if (account == null) throw new IllegalArgumentException("当前用户没有可用付款账户，无法完成缴费。");
            if (!account.isNormal()) throw new IllegalArgumentException("付款账户状态异常，无法完成缴费。");
            BigDecimal amount = order.getAmount();
            if (account.getAvailableBalance().compareTo(amount) < 0) throw new IllegalArgumentException("余额不足，当前账户可用余额不足以完成本次缴费。");

            BigDecimal before = account.getBalance();
            BigDecimal after = before.subtract(amount);
            accountDao.updateBalance(connection, account.getId(), after);
            int transactionId = transactionDao.add(connection, buildTransaction(user.getId(), account.getId(), order, after));
            ledgerEntryDao.add(connection, buildLedger(transactionId, account.getId(), order, before, after));
            paymentRecordDao.add(connection, buildPaymentRecord(transactionId, account.getId(), order));
            validationDao.add(connection, buildValidation(transactionId));
            operationLogDao.add(connection, buildLog(user.getId(), transactionId, order, request));
            notificationDao.add(connection, buildNotification(user.getId(), order));
            openPaymentDao.markSuccess(connection, order.getOrderId(), transactionId);
            connection.commit();
            return transactionId;
        } catch (SQLException e) {
            rollback(connection);
            throw e;
        } catch (RuntimeException e) {
            rollback(connection);
            throw e;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private boolean isBoundBankUser(User user, ExternalPaymentOrder order) {
        String bound = trim(order.getBankLoginAccount());
        if (bound.length() == 0) return true;
        return bound.equalsIgnoreCase(trim(user.getUsername())) || bound.equalsIgnoreCase(trim(user.getPhone()));
    }

    private Transaction buildTransaction(int userId, int accountId, ExternalPaymentOrder order, BigDecimal balanceAfter) {
        Transaction transaction = new Transaction();
        transaction.setTransactionNo("OP" + new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
        transaction.setUserId(userId);
        transaction.setFromAccountId(Integer.valueOf(accountId));
        transaction.setTransactionType("PAYMENT");
        transaction.setAmount(order.getAmount());
        transaction.setStatus("SUCCESS");
        transaction.setChannel("OPEN_API");
        transaction.setRiskLevel("LOW");
        transaction.setNeedApproval(false);
        transaction.setBalanceAfter(balanceAfter);
        transaction.setDescription("上财小区生活缴费: " + order.getSubject());
        return transaction;
    }

    private LedgerEntry buildLedger(int transactionId, int accountId, ExternalPaymentOrder order,
                                    BigDecimal before, BigDecimal after) {
        LedgerEntry entry = new LedgerEntry();
        entry.setTransactionId(transactionId);
        entry.setAccountId(accountId);
        entry.setDirection("OUT");
        entry.setAmount(order.getAmount());
        entry.setBalanceBefore(before);
        entry.setBalanceAfter(after);
        entry.setCategoryId(Integer.valueOf(5));
        entry.setRemark("Open payment debit: " + order.getBillNo());
        return entry;
    }

    private PaymentRecord buildPaymentRecord(int transactionId, int accountId, ExternalPaymentOrder order) {
        PaymentRecord record = new PaymentRecord();
        record.setTransactionId(transactionId);
        record.setAccountId(accountId);
        record.setPaymentType(normalizePaymentType(order.getBillType()));
        record.setPaymentNo(order.getCustomerNo());
        record.setServiceProvider(order.getProviderName());
        record.setPaymentAmount(order.getAmount());
        record.setPaymentStatus("SUCCESS");
        return record;
    }

    private String normalizePaymentType(String billType) {
        return "PROPERTY".equals(billType) ? "PHONE" : billType;
    }

    private TransactionValidation buildValidation(int transactionId) {
        TransactionValidation validation = new TransactionValidation();
        validation.setTransactionId(Integer.valueOf(transactionId));
        validation.setAccountStatusValid(true);
        validation.setBalanceSufficient(true);
        validation.setAmountValid(true);
        validation.setTargetAccountValid(true);
        validation.setValidationResult("PASS");
        return validation;
    }

    private OperationLog buildLog(int userId, int transactionId, ExternalPaymentOrder order, HttpServletRequest request) {
        OperationLog log = new OperationLog();
        log.setUserId(Integer.valueOf(userId));
        log.setOperationType("PAYMENT");
        log.setObjectType("TRANSACTION");
        log.setObjectId(Integer.valueOf(transactionId));
        log.setOperationContent("External community utility payment completed. Bill " + order.getBillNo());
        log.setOperationResult("SUCCESS");
        log.setIpAddress(request.getRemoteAddr());
        return log;
    }

    private Notification buildNotification(int userId, ExternalPaymentOrder order) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setTitle("生活缴费已完成");
        notification.setContent(order.getProviderName() + " " + order.getAmount() + " 已支付成功。");
        notification.setNotificationType("TRANSACTION");
        return notification;
    }

    private String buildReturnUrl(ExternalPaymentOrder order, String status, Integer transactionId) {
        String separator = order.getReturnUrl().contains("?") ? "&" : "?";
        return order.getReturnUrl() + separator + "billNo=" + order.getBillNo() + "&status=" + status
                + "&bankTransactionId=" + (transactionId == null ? "" : transactionId);
    }

    private void rollback(Connection connection) {
        try {
            connection.rollback();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
