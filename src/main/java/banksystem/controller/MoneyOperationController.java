package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.LedgerEntryDao;
import banksystem.dao.NotificationDao;
import banksystem.dao.OperationLogDao;
import banksystem.dao.SecurityEventDao;
import banksystem.dao.TransactionDao;
import banksystem.dao.TransactionLimitRuleDao;
import banksystem.dao.TransactionRiskScoreDao;
import banksystem.dao.TransactionValidationDao;
import banksystem.model.Account;
import banksystem.model.LedgerEntry;
import banksystem.model.Notification;
import banksystem.model.OperationLog;
import banksystem.model.SecurityEvent;
import banksystem.model.Transaction;
import banksystem.model.TransactionLimitRule;
import banksystem.model.TransactionRiskScore;
import banksystem.model.TransactionValidation;
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

public abstract class MoneyOperationController extends BaseController {
    protected final AccountDao accountDao = new AccountDao();
    protected final TransactionDao transactionDao = new TransactionDao();
    protected final LedgerEntryDao ledgerEntryDao = new LedgerEntryDao();
    protected final OperationLogDao operationLogDao = new OperationLogDao();
    protected final NotificationDao notificationDao = new NotificationDao();
    protected final TransactionValidationDao transactionValidationDao = new TransactionValidationDao();
    protected final SecurityEventDao securityEventDao = new SecurityEventDao();
    protected final TransactionLimitRuleDao transactionLimitRuleDao = new TransactionLimitRuleDao();
    protected final TransactionRiskScoreDao transactionRiskScoreDao = new TransactionRiskScoreDao();

    protected BigDecimal parsePositiveAmount(String amountText) {
        try {
            BigDecimal amount = new BigDecimal(amountText);
            if (amount.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Amount must be greater than 0.");
            }
            return amount;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid amount format.");
        }
    }

    protected void loadAccountsAndForward(HttpServletRequest request, HttpServletResponse response,
                                          int userId, String jspPath)
            throws ServletException, IOException {
        List<Account> accounts = accountDao.findByUserId(userId);
        request.setAttribute("accounts", accounts);
        request.getRequestDispatcher(jspPath).forward(request, response);
    }

    protected Connection openTransaction() {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new IllegalArgumentException("Database connection failed. Please check connection settings.");
        }
        try {
            connection.setAutoCommit(false);
        } catch (SQLException e) {
            GetMySQLConnection.closeConnection(connection);
            throw new IllegalArgumentException("Failed to start database transaction.");
        }
        return connection;
    }

    protected void rollback(Connection connection) {
        if (connection != null) {
            try {
                connection.rollback();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    protected void close(Connection connection) {
        GetMySQLConnection.closeConnection(connection);
    }

    protected String createTransactionNo(String prefix) {
        return prefix + new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());
    }

    protected Transaction buildTransaction(String transactionNo, Integer fromAccountId, Integer toAccountId,
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

    protected LedgerEntry buildLedgerEntry(int transactionId, int accountId, String direction,
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

    protected OperationLog buildLog(Integer userId, String operationType, String objectType,
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

    protected TransactionValidation buildValidation(int transactionId, boolean accountStatusOk,
                                                    boolean balanceOk, boolean amountOk,
                                                    boolean limitOk, String failReason) {
        TransactionValidation validation = new TransactionValidation();
        validation.setTransactionId(transactionId);
        validation.setAccountStatusValid(accountStatusOk);
        validation.setBalanceSufficient(balanceOk);
        validation.setAmountValid(amountOk);
        validation.setTargetAccountValid(limitOk);
        validation.setValidationResult(accountStatusOk && balanceOk && amountOk && limitOk ? "PASS" : "FAIL");
        validation.setRejectReason(failReason);
        return validation;
    }

    protected Notification buildNotification(int userId, String title, String content, String type) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setTitle(title);
        notification.setContent(content);
        notification.setNotificationType(type);
        return notification;
    }

    protected TransactionLimitRule resolveLimitRule(HttpServletRequest request, String transactionType) {
        for (String roleCode : getRoleCodes(request)) {
            TransactionLimitRule rule = transactionLimitRuleDao.findActiveRule(roleCode, transactionType);
            if (rule != null) {
                return rule;
            }
        }
        return transactionLimitRuleDao.findActiveRule("CUSTOMER", transactionType);
    }

    protected void enforceLimitRule(TransactionLimitRule rule, BigDecimal amount, String transactionType) {
        if (rule == null) {
            return;
        }
        if (amount.compareTo(rule.getSingleLimit()) > 0) {
            throw new IllegalArgumentException(transactionType + " amount exceeds the single transaction limit.");
        }
    }

    protected void writeFrozenSecurityEvent(Connection connection, int userId, String action,
                                            HttpServletRequest request) throws SQLException {
        securityEventDao.add(connection, buildSecurityEvent(userId, "FROZEN_ACCOUNT_" + action, "HIGH",
                "A frozen account attempted to perform " + action.toLowerCase() + ".", request));
    }

    protected SecurityEvent buildSecurityEvent(int userId, String eventType, String riskLevel,
                                               String description, HttpServletRequest request) {
        SecurityEvent event = new SecurityEvent();
        event.setUserId(userId);
        event.setEventType(eventType);
        event.setRiskLevel(riskLevel);
        event.setDescription(description);
        event.setIpAddress(request.getRemoteAddr());
        event.setDeviceFingerprint(buildDeviceFingerprint(request));
        event.setHandledFlag(0);
        return event;
    }

    protected void writeRiskScore(Connection connection, int transactionId, BigDecimal amount,
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

    protected String normalizeRemark(String remark, String defaultValue) {
        if (remark == null || remark.trim().length() == 0) {
            return defaultValue;
        }
        return remark.trim();
    }
}
