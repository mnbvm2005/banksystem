package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.LedgerEntryDao;
import banksystem.dao.NotificationDao;
import banksystem.dao.OperationLogDao;
import banksystem.dao.PayeeDao;
import banksystem.dao.SecurityEventDao;
import banksystem.dao.TransactionDao;
import banksystem.dao.TransactionLimitRuleDao;
import banksystem.dao.TransactionRiskScoreDao;
import banksystem.dao.TransferRecordDao;
import banksystem.dao.UserDao;
import banksystem.model.Account;
import banksystem.model.LedgerEntry;
import banksystem.model.Notification;
import banksystem.model.OperationLog;
import banksystem.model.Payee;
import banksystem.model.SecurityEvent;
import banksystem.model.Transaction;
import banksystem.model.TransactionLimitRule;
import banksystem.model.TransactionRiskScore;
import banksystem.model.TransferRecord;
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

public class TransferController extends BaseController {
    private final AccountDao accountDao = new AccountDao();
    private final TransactionDao transactionDao = new TransactionDao();
    private final LedgerEntryDao ledgerEntryDao = new LedgerEntryDao();
    private final TransferRecordDao transferRecordDao = new TransferRecordDao();
    private final OperationLogDao operationLogDao = new OperationLogDao();
    private final NotificationDao notificationDao = new NotificationDao();
    private final UserDao userDao = new UserDao();
    private final PayeeDao payeeDao = new PayeeDao();
    private final TransactionLimitRuleDao transactionLimitRuleDao = new TransactionLimitRuleDao();
    private final TransactionRiskScoreDao transactionRiskScoreDao = new TransactionRiskScoreDao();
    private final SecurityEventDao securityEventDao = new SecurityEventDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        loadTransferPage(request, response, user);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        String toAccountNo = request.getParameter("toAccountNo");
        String amountText = request.getParameter("amount");
        String remark = request.getParameter("remark");

        try {
            BigDecimal amount = new BigDecimal(amountText);
            if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                request.setAttribute("error", "转账金额必须大于 0。");
                loadTransferPage(request, response, user);
                return;
            }

            transfer(user, toAccountNo, amount, remark, request);
            response.sendRedirect(request.getContextPath() + "/transactions?success=transfer");
        } catch (NumberFormatException e) {
            request.setAttribute("error", "转账金额格式不正确。");
            loadTransferPage(request, response, user);
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            loadTransferPage(request, response, user);
        } catch (SQLException e) {
            throw new ServletException("Transfer failed due to a database error.", e);
        }
    }

    private void transfer(User user, String toAccountNo, BigDecimal amount, String remark,
                          HttpServletRequest request) throws SQLException {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new IllegalArgumentException("Database connection failed. Please check connection settings.");
        }

        try {
            connection.setAutoCommit(false);
            Account fromAccount = accountDao.findMainAccountByUserId(user.getId());
            if (fromAccount == null) {
                throw new IllegalArgumentException("当前用户没有可用付款账户，无法转账。");
            }

            fromAccount = accountDao.findByIdForUpdate(connection, fromAccount.getId());
            Account toAccount = accountDao.findByAccountNoForUpdate(connection, toAccountNo);
            TransactionLimitRule limitRule = resolveLimitRule(request, "TRANSFER");
            enforceLimitRule(limitRule, amount);
            if (fromAccount != null && !fromAccount.isNormal()) {
                securityEventDao.add(connection, buildSecurityEvent(user.getId(), "FROZEN_ACCOUNT_TRANSFER", "HIGH",
                        "A frozen account attempted to transfer funds.",
                        request.getRemoteAddr(), buildDeviceFingerprint(request)));
                throw new IllegalArgumentException("付款账户状态异常，无法转账。");
            }
            validateTransfer(fromAccount, toAccount, amount);
            Payee existingPayee = payeeDao.findByUserIdAndAccountNo(user.getId(), toAccountNo);

            BigDecimal fromBalanceBefore = fromAccount.getBalance();
            BigDecimal toBalanceBefore = toAccount.getBalance();
            BigDecimal fromBalance = fromAccount.getBalance().subtract(amount);
            BigDecimal toBalance = toAccount.getBalance().add(amount);
            accountDao.updateBalance(connection, fromAccount.getId(), fromBalance);
            accountDao.updateBalance(connection, toAccount.getId(), toBalance);

            String transactionNo = createTransactionNo();
            int outTransactionId = transactionDao.add(connection, buildTransaction(
                    transactionNo + "O", fromAccount.getId(), toAccount.getId(),
                    "TRANSFER_OUT", amount, fromBalance, normalizeRemark(remark, "Transfer debit")));
            int inTransactionId = transactionDao.add(connection, buildTransaction(
                    transactionNo + "I", fromAccount.getId(), toAccount.getId(),
                    "TRANSFER_IN", amount, toBalance, normalizeRemark(remark, "Transfer credit")));

            ledgerEntryDao.add(connection, buildLedgerEntry(outTransactionId, fromAccount.getId(), "OUT",
                    amount, fromBalanceBefore, fromBalance, normalizeRemark(remark, "Transfer debit")));
            ledgerEntryDao.add(connection, buildLedgerEntry(inTransactionId, toAccount.getId(), "IN",
                    amount, toBalanceBefore, toBalance, normalizeRemark(remark, "Transfer credit")));

            TransferRecord transferRecord = new TransferRecord();
            transferRecord.setTransactionId(outTransactionId);
            transferRecord.setFromAccountId(fromAccount.getId());
            transferRecord.setToAccountId(toAccount.getId());
            transferRecord.setPayerAccountNo(fromAccount.getAccountNo());
            transferRecord.setPayeeAccountNo(toAccount.getAccountNo());
            User payeeUser = userDao.findById(toAccount.getUserId());
            transferRecord.setPayeeName(payeeUser == null ? "" : payeeUser.getRealName());
            transferRecord.setToBankName("FinCloud Bank");
            transferRecord.setTransferType("INNER");
            transferRecord.setNewPayee(false);
            transferRecord.setTransferStatus("SUCCESS");
            transferRecordDao.add(connection, transferRecord);
            writeRiskScore(connection, outTransactionId, amount, limitRule, existingPayee != null);

            Payee savedPayee = new Payee();
            savedPayee.setUserId(user.getId());
            savedPayee.setPayeeName(transferRecord.getPayeeName());
            savedPayee.setPayeeAccountNo(toAccount.getAccountNo());
            savedPayee.setPayeeBankName(transferRecord.getToBankName());
            savedPayee.setVerifiedStatus("VERIFIED");
            payeeDao.save(connection, savedPayee);

            operationLogDao.add(connection, buildLog(user.getId(), "TRANSFER", "TRANSACTION",
                    outTransactionId, "Transfer completed. Amount " + amount + " to " + toAccount.getAccountNo(),
                    "SUCCESS", request));
            notificationDao.add(connection, buildNotification(user.getId(), "TRANSFER", outTransactionId,
                    "Transfer successful. Amount " + amount));
            notificationDao.add(connection, buildNotification(toAccount.getUserId(), "TRANSFER", inTransactionId,
                    "Incoming transfer received. Amount " + amount));

            connection.commit();
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

    private void validateTransfer(Account fromAccount, Account toAccount, BigDecimal amount) {
        if (toAccount == null) {
            throw new IllegalArgumentException("收款账户不存在，转账失败。");
        }
        if (fromAccount.getId() == toAccount.getId()) {
            throw new IllegalArgumentException("不能向自己的同一账户转账。");
        }
        if (!fromAccount.isNormal() || !toAccount.isNormal()) {
            throw new IllegalArgumentException("付款账户或收款账户状态异常，无法转账。");
        }
        if (fromAccount.getAvailableBalance().compareTo(amount) < 0) {
            throw new IllegalArgumentException("余额不足，当前账户可用余额不足以完成本次转账。");
        }
    }

    private Transaction buildTransaction(String transactionNo, int fromAccountId, int toAccountId,
                                         String type, BigDecimal amount, BigDecimal balanceAfter,
                                         String description) {
        Transaction transaction = new Transaction();
        transaction.setTransactionNo(transactionNo);
        transaction.setFromAccountId(fromAccountId);
        transaction.setToAccountId(toAccountId);
        transaction.setTransactionType(type);
        transaction.setAmount(amount);
        transaction.setBalanceAfter(balanceAfter);
        transaction.setDescription(description);
        return transaction;
    }

    private LedgerEntry buildLedgerEntry(int transactionId, int accountId, String direction,
                                         BigDecimal amount, BigDecimal balanceBefore,
                                         BigDecimal balanceAfter, String remark) {
        LedgerEntry entry = new LedgerEntry();
        entry.setTransactionId(transactionId);
        entry.setAccountId(accountId);
        entry.setDirection(direction);
        entry.setAmount(amount);
        entry.setBalanceBefore(balanceBefore);
        entry.setBalanceAfter(balanceAfter);
        entry.setRemark(remark);
        return entry;
    }

    private OperationLog buildLog(Integer userId, String operationType, String objectType,
                                  Integer objectId, String content, String result,
                                  HttpServletRequest request) {
        OperationLog log = new OperationLog();
        log.setUserId(userId);
        log.setOperationType(operationType);
        log.setObjectType(objectType);
        log.setObjectId(objectId);
        log.setOperationContent(content);
        log.setOperationResult(result);
        log.setIpAddress(request.getRemoteAddr());
        return log;
    }

    private Notification buildNotification(int userId, String relatedType, int relatedId, String content) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setRelatedType(relatedType);
        notification.setRelatedId(relatedId);
        notification.setNotificationType("TRANSACTION");
        notification.setNotificationContent(content);
        notification.setSendStatus("SENT");
        return notification;
    }

    private String normalizeRemark(String remark, String defaultValue) {
        if (remark == null || remark.trim().length() == 0) {
            return defaultValue;
        }
        return remark.trim();
    }

    private String createTransactionNo() {
        return "TX" + new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());
    }

    private void loadTransferPage(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        List<Account> accounts = accountDao.findByUserId(user.getId());
        List<Payee> payees = payeeDao.findByUserId(user.getId());
        request.setAttribute("accounts", accounts);
        request.setAttribute("payees", payees);
        request.getRequestDispatcher("/views/user/transfer.jsp").forward(request, response);
    }

    private TransactionLimitRule resolveLimitRule(HttpServletRequest request, String transactionType) {
        for (String roleCode : getRoleCodes(request)) {
            TransactionLimitRule rule = transactionLimitRuleDao.findActiveRule(roleCode, transactionType);
            if (rule != null) {
                return rule;
            }
        }
        return transactionLimitRuleDao.findActiveRule("CUSTOMER", transactionType);
    }

    private void enforceLimitRule(TransactionLimitRule rule, BigDecimal amount) {
        if (rule != null && amount.compareTo(rule.getSingleLimit()) > 0) {
            throw new IllegalArgumentException("Transfer amount exceeds the single transaction limit.");
        }
    }

    private void writeRiskScore(Connection connection, int transactionId, BigDecimal amount,
                                TransactionLimitRule rule, boolean knownPayee) throws SQLException {
        int score = knownPayee ? 12 : 28;
        int ruleHitCount = 0;
        String level = "LOW";
        String reason = knownPayee ? "VERIFIED_PAYEE" : "NEW_COUNTERPARTY";
        if (rule != null && amount.compareTo(rule.getApprovalThreshold()) >= 0) {
            score = Math.max(score, 72);
            ruleHitCount = 1;
            level = "HIGH";
            reason = "APPROVAL_THRESHOLD_REACHED";
        } else if (amount.compareTo(new BigDecimal("10000")) >= 0) {
            score = Math.max(score, 48);
            level = "MEDIUM";
            reason = "LARGE_AMOUNT";
        }
        TransactionRiskScore riskScore = new TransactionRiskScore();
        riskScore.setTransactionId(transactionId);
        riskScore.setRiskScore(score);
        riskScore.setRiskLevel(level);
        riskScore.setRiskReason(reason);
        riskScore.setRuleHitCount(ruleHitCount);
        transactionRiskScoreDao.add(connection, riskScore);
    }

    private SecurityEvent buildSecurityEvent(int userId, String eventType, String riskLevel,
                                             String description, String ipAddress, String deviceFingerprint) {
        SecurityEvent event = new SecurityEvent();
        event.setUserId(userId);
        event.setEventType(eventType);
        event.setRiskLevel(riskLevel);
        event.setDescription(description);
        event.setIpAddress(ipAddress);
        event.setDeviceFingerprint(deviceFingerprint);
        event.setHandledFlag(0);
        return event;
    }

    private void rollback(Connection connection) {
        if (connection != null) {
            try {
                connection.rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
