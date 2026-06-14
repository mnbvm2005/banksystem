package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.FinancialProductDao;
import banksystem.dao.InvestmentHoldingDao;
import banksystem.dao.InvestmentOrderDao;
import banksystem.dao.LedgerEntryDao;
import banksystem.dao.NotificationDao;
import banksystem.dao.OperationLogDao;
import banksystem.dao.RiskAssessmentDao;
import banksystem.dao.TransactionDao;
import banksystem.dao.TransactionValidationDao;
import banksystem.model.Account;
import banksystem.model.FinancialProduct;
import banksystem.model.InvestmentHolding;
import banksystem.model.InvestmentOrder;
import banksystem.model.LedgerEntry;
import banksystem.model.Notification;
import banksystem.model.OperationLog;
import banksystem.model.RiskAssessment;
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
import java.time.LocalDate;
import java.util.Date;
import java.util.List;

public class FinanceController extends BaseController {
    private final AccountDao accountDao = new AccountDao();
    private final FinancialProductDao financialProductDao = new FinancialProductDao();
    private final RiskAssessmentDao riskAssessmentDao = new RiskAssessmentDao();
    private final TransactionDao transactionDao = new TransactionDao();
    private final LedgerEntryDao ledgerEntryDao = new LedgerEntryDao();
    private final InvestmentOrderDao investmentOrderDao = new InvestmentOrderDao();
    private final InvestmentHoldingDao investmentHoldingDao = new InvestmentHoldingDao();
    private final TransactionValidationDao validationDao = new TransactionValidationDao();
    private final OperationLogDao operationLogDao = new OperationLogDao();
    private final NotificationDao notificationDao = new NotificationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<FinancialProduct> products = financialProductDao.findAllAvailable();
        List<Account> accounts = accountDao.findByUserId(user.getId());
        RiskAssessment latestAssessment = riskAssessmentDao.findLatestByUserId(user.getId());
        request.setAttribute("products", products);
        request.setAttribute("accounts", accounts);
        request.setAttribute("latestRiskAssessment", latestAssessment);
        request.getRequestDispatcher("/views/user/finance.jsp").forward(request, response);
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
            int productId = Integer.parseInt(request.getParameter("productId"));
            int accountId = Integer.parseInt(request.getParameter("accountId"));
            BigDecimal amount = new BigDecimal(trim(request.getParameter("amount")));
            buyProduct(user, productId, accountId, amount, request);
            response.sendRedirect(request.getContextPath() + "/holding?success=finance");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (SQLException e) {
            throw new ServletException("Investment purchase failed.", e);
        }
    }

    private void buyProduct(User user, int productId, int accountId, BigDecimal amount,
                            HttpServletRequest request) throws SQLException {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Purchase amount must be greater than 0.");
        }
        FinancialProduct product = financialProductDao.findById(productId);
        if (product == null || product.getStatus() != 1) {
            throw new IllegalArgumentException("The selected product is not available.");
        }
        if (amount.compareTo(product.getMinAmount()) < 0) {
            throw new IllegalArgumentException("Purchase amount is below the product minimum.");
        }
        RiskAssessment assessment = riskAssessmentDao.findLatestByUserId(user.getId());
        if (assessment == null || assessment.getValidUntil() == null
                || assessment.getValidUntil().before(java.sql.Date.valueOf(LocalDate.now()))) {
            throw new IllegalArgumentException("Please complete a valid risk assessment before purchasing.");
        }
        if (riskRank(assessment.getRiskLevel()) < riskRank(product.getRiskLevel())) {
            throw new IllegalArgumentException("Your risk profile is below this product's risk level.");
        }

        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try {
            connection.setAutoCommit(false);
            Account account = accountDao.findByIdAndUserIdForUpdate(connection, accountId, user.getId());
            if (account == null) {
                throw new IllegalArgumentException("The selected payment account is not available.");
            }
            if (!account.isNormal()) {
                throw new IllegalArgumentException("The account status does not allow investment purchase.");
            }
            if (account.getAvailableBalance().compareTo(amount) < 0) {
                throw new IllegalArgumentException("Insufficient available balance.");
            }
            BigDecimal balanceBefore = account.getBalance();
            BigDecimal balanceAfter = balanceBefore.subtract(amount);
            accountDao.updateBalance(connection, account.getId(), balanceAfter);

            int transactionId = transactionDao.add(connection, buildTransaction(user.getId(), account.getId(),
                    product, amount, balanceAfter));
            ledgerEntryDao.add(connection, buildLedgerEntry(transactionId, account.getId(), amount,
                    balanceBefore, balanceAfter, product));
            validationDao.add(connection, buildValidation(transactionId));

            InvestmentOrder order = new InvestmentOrder();
            order.setOrderNo("IO" + new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
            order.setUserId(user.getId());
            order.setAccountId(account.getId());
            order.setProductId(product.getId());
            order.setTransactionId(Integer.valueOf(transactionId));
            order.setOrderType("BUY");
            order.setOrderAmount(amount);
            order.setOrderStatus("SUCCESS");
            int orderId = investmentOrderDao.add(connection, order);

            InvestmentHolding holding = new InvestmentHolding();
            holding.setUserId(user.getId());
            holding.setAccountId(account.getId());
            holding.setProductId(product.getId());
            holding.setOrderId(Integer.valueOf(orderId));
            holding.setHoldingAmount(amount);
            holding.setCurrentIncome(BigDecimal.ZERO);
            holding.setHoldingStatus("HOLDING");
            investmentHoldingDao.add(connection, holding);

            operationLogDao.add(connection, buildLog(user.getId(), transactionId, product, amount, request));
            notificationDao.add(connection, buildNotification(user.getId(), product, amount));
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

    private Transaction buildTransaction(int userId, int accountId, FinancialProduct product,
                                         BigDecimal amount, BigDecimal balanceAfter) {
        Transaction transaction = new Transaction();
        transaction.setTransactionNo("IB" + new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
        transaction.setUserId(userId);
        transaction.setFromAccountId(Integer.valueOf(accountId));
        transaction.setTransactionType("INVEST_BUY");
        transaction.setAmount(amount);
        transaction.setStatus("SUCCESS");
        transaction.setChannel("WEB");
        transaction.setRiskLevel(product.getRiskLevel());
        transaction.setNeedApproval(false);
        transaction.setBalanceAfter(balanceAfter);
        transaction.setDescription("Purchased " + product.getProductName());
        return transaction;
    }

    private LedgerEntry buildLedgerEntry(int transactionId, int accountId, BigDecimal amount,
                                         BigDecimal balanceBefore, BigDecimal balanceAfter,
                                         FinancialProduct product) {
        LedgerEntry entry = new LedgerEntry();
        entry.setTransactionId(transactionId);
        entry.setAccountId(accountId);
        entry.setDirection("OUT");
        entry.setAmount(amount);
        entry.setBalanceBefore(balanceBefore);
        entry.setBalanceAfter(balanceAfter);
        entry.setCategoryId(Integer.valueOf(6));
        entry.setRemark("Wealth product purchase: " + product.getProductName());
        return entry;
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

    private OperationLog buildLog(int userId, int transactionId, FinancialProduct product,
                                  BigDecimal amount, HttpServletRequest request) {
        OperationLog log = new OperationLog();
        log.setUserId(Integer.valueOf(userId));
        log.setOperationType("INVEST_BUY");
        log.setObjectType("TRANSACTION");
        log.setObjectId(Integer.valueOf(transactionId));
        log.setOperationContent("Investment purchase completed. Amount " + amount + " for " + product.getProductName());
        log.setOperationResult("SUCCESS");
        log.setIpAddress(request.getRemoteAddr());
        return log;
    }

    private Notification buildNotification(int userId, FinancialProduct product, BigDecimal amount) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setTitle("Investment purchase successful");
        notification.setContent("Purchased " + product.getProductName() + " for " + amount + ".");
        notification.setNotificationType("TRANSACTION");
        return notification;
    }

    private int riskRank(String riskLevel) {
        if ("HIGH".equals(riskLevel)) {
            return 3;
        }
        if ("MEDIUM".equals(riskLevel)) {
            return 2;
        }
        return 1;
    }

    private void rollback(Connection connection) {
        try {
            connection.rollback();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
