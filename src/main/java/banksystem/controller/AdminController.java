package banksystem.controller;

import banksystem.dao.AccountDao;
import banksystem.dao.AccountDailySummaryDao;
import banksystem.dao.AccountStatusHistoryDao;
import banksystem.dao.AuthRecordDao;
import banksystem.dao.BankBranchDao;
import banksystem.dao.LoginDeviceDao;
import banksystem.dao.NotificationDao;
import banksystem.dao.OperationLogDao;
import banksystem.dao.RoleDao;
import banksystem.dao.SecurityEventDao;
import banksystem.dao.TransactionApprovalDao;
import banksystem.dao.TransactionCategoryDao;
import banksystem.dao.TransactionLimitRuleDao;
import banksystem.dao.TransactionRiskScoreDao;
import banksystem.dao.TransactionValidationDao;
import banksystem.dao.UserDao;
import banksystem.dao.UserRoleDao;
import banksystem.model.Account;
import banksystem.model.AccountStatusHistory;
import banksystem.model.Notification;
import banksystem.model.OperationLog;
import banksystem.model.SecurityEvent;
import banksystem.model.User;
import banksystem.sqloperation.GetMySQLConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

public class AdminController extends BaseController {
    private final UserDao userDao = new UserDao();
    private final RoleDao roleDao = new RoleDao();
    private final UserRoleDao userRoleDao = new UserRoleDao();
    private final AccountDao accountDao = new AccountDao();
    private final BankBranchDao bankBranchDao = new BankBranchDao();
    private final AccountStatusHistoryDao accountStatusHistoryDao = new AccountStatusHistoryDao();
    private final TransactionLimitRuleDao limitRuleDao = new TransactionLimitRuleDao();
    private final TransactionCategoryDao categoryDao = new TransactionCategoryDao();
    private final AuthRecordDao authRecordDao = new AuthRecordDao();
    private final LoginDeviceDao loginDeviceDao = new LoginDeviceDao();
    private final SecurityEventDao securityEventDao = new SecurityEventDao();
    private final OperationLogDao operationLogDao = new OperationLogDao();
    private final TransactionValidationDao validationDao = new TransactionValidationDao();
    private final TransactionRiskScoreDao riskScoreDao = new TransactionRiskScoreDao();
    private final TransactionApprovalDao approvalDao = new TransactionApprovalDao();
    private final AccountDailySummaryDao summaryDao = new AccountDailySummaryDao();
    private final NotificationDao notificationDao = new NotificationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAnyRole(request, response, "ADMIN")) {
            return;
        }
        loadAdminData(request);
        request.getRequestDispatcher("/views/user/admin_center.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAnyRole(request, response, "ADMIN")) {
            return;
        }
        String action = request.getParameter("action");
        try {
            if ("update-role".equals(action)) {
                userRoleDao.replaceUserRole(Integer.parseInt(request.getParameter("userId")),
                        Integer.parseInt(request.getParameter("roleId")));
            } else if ("toggle-account-status".equals(action)) {
                toggleAccountStatus(request);
            } else if ("save-limit-rule".equals(action)) {
                limitRuleDao.saveRule(
                        Integer.parseInt(request.getParameter("roleId")),
                        normalize(request.getParameter("transactionType")).toUpperCase(),
                        new BigDecimal(request.getParameter("singleLimit")),
                        new BigDecimal(request.getParameter("dailyLimit")),
                        new BigDecimal(request.getParameter("approvalThreshold"))
                );
            } else if ("save-category".equals(action)) {
                String categoryIdText = normalize(request.getParameter("categoryId"));
                Integer categoryId = categoryIdText.length() == 0 ? null : Integer.valueOf(Integer.parseInt(categoryIdText));
                categoryDao.saveCategory(
                        categoryId,
                        normalize(request.getParameter("categoryCode")).toUpperCase(),
                        normalize(request.getParameter("categoryName")),
                        normalize(request.getParameter("incomeExpenseType")).toUpperCase(),
                        normalize(request.getParameter("description"))
                );
            }
            response.sendRedirect(request.getContextPath() + "/admin");
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage() == null ? "Admin action failed." : e.getMessage());
            loadAdminData(request);
            request.getRequestDispatcher("/views/user/admin_center.jsp").forward(request, response);
        }
    }

    private void toggleAccountStatus(HttpServletRequest request) throws SQLException {
        User adminUser = getLoginUser(request);
        int accountId = Integer.parseInt(request.getParameter("accountId"));
        String targetStatus = normalize(request.getParameter("targetStatus")).toUpperCase();
        String reason = normalize(request.getParameter("reason"));
        if (!"NORMAL".equals(targetStatus) && !"FROZEN".equals(targetStatus)) {
            throw new IllegalArgumentException("Invalid account status.");
        }
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try {
            connection.setAutoCommit(false);
            Account account = accountDao.findByIdForUpdate(connection, accountId);
            if (account == null) {
                throw new IllegalArgumentException("Account not found.");
            }
            String oldStatus = account.getAccountStatus();
            if (!targetStatus.equals(oldStatus)) {
                accountDao.updateStatus(connection, accountId, targetStatus);

                AccountStatusHistory history = new AccountStatusHistory();
                history.setAccountId(accountId);
                history.setOldStatus(oldStatus);
                history.setNewStatus(targetStatus);
                history.setChangeReason(reason.length() == 0 ? "Updated in Admin Center" : reason);
                history.setChangedBy(adminUser.getId());
                accountStatusHistoryDao.add(connection, history);

                OperationLog log = new OperationLog();
                log.setUserId(adminUser.getId());
                log.setOperationType("ACCOUNT_STATUS");
                log.setObjectType("ACCOUNT");
                log.setObjectId(accountId);
                log.setOperationResult("SUCCESS");
                log.setIpAddress(request.getRemoteAddr());
                log.setOperationContent("Account status changed from " + oldStatus + " to " + targetStatus);
                operationLogDao.add(connection, log);

                if ("FROZEN".equals(targetStatus)) {
                    SecurityEvent event = new SecurityEvent();
                    event.setUserId(account.getUserId());
                    event.setEventType("ACCOUNT_FROZEN");
                    event.setRiskLevel("MEDIUM");
                    event.setDescription("Account was frozen by admin.");
                    event.setIpAddress(request.getRemoteAddr());
                    event.setHandledFlag(0);
                    securityEventDao.add(connection, event);
                }

                Notification notification = new Notification();
                notification.setUserId(account.getUserId());
                notification.setTitle("Account Status Updated");
                notification.setContent("Your account " + account.getAccountNo() + " status is now " + targetStatus + ".");
                notification.setNotificationType("SYSTEM");
                notificationDao.add(connection, notification);
            }
            connection.commit();
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private void loadAdminData(HttpServletRequest request) {
        request.setAttribute("adminUsers", userDao.findAll());
        request.setAttribute("adminRoles", roleDao.findAll());
        request.setAttribute("adminUserRoles", userRoleDao.findAll());
        request.setAttribute("adminAccounts", accountDao.findAll());
        request.setAttribute("adminBranches", bankBranchDao.findAll());
        request.setAttribute("adminStatusHistories", accountStatusHistoryDao.findAll());
        request.setAttribute("adminLimitRules", limitRuleDao.findAllActive());
        request.setAttribute("adminCategories", categoryDao.findAll());
        request.setAttribute("adminAuthRecords", authRecordDao.findAll());
        request.setAttribute("adminLoginDevices", loginDeviceDao.findVisible(0, true));
        request.setAttribute("adminSecurityEvents", securityEventDao.findVisible(0, true));
        request.setAttribute("adminOperationLogs", operationLogDao.findVisible(0, true));
        request.setAttribute("adminValidations", validationDao.findAll());
        request.setAttribute("adminRiskScores", riskScoreDao.findVisible(0, true));
        request.setAttribute("adminApprovals", approvalDao.findAll());
        request.setAttribute("adminDailySummaries", summaryDao.findVisible(0, true));
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }
}
