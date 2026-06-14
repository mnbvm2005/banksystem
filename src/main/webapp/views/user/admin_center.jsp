<%@ page import="banksystem.model.Account" %>
<%@ page import="banksystem.model.AccountDailySummary" %>
<%@ page import="banksystem.model.AccountStatusHistory" %>
<%@ page import="banksystem.model.AuthRecord" %>
<%@ page import="banksystem.model.BankBranch" %>
<%@ page import="banksystem.model.LoginDevice" %>
<%@ page import="banksystem.model.OperationLog" %>
<%@ page import="banksystem.model.Role" %>
<%@ page import="banksystem.model.SecurityEvent" %>
<%@ page import="banksystem.model.TransactionApproval" %>
<%@ page import="banksystem.model.TransactionCategory" %>
<%@ page import="banksystem.model.TransactionLimitRule" %>
<%@ page import="banksystem.model.TransactionRiskScore" %>
<%@ page import="banksystem.model.TransactionValidation" %>
<%@ page import="banksystem.model.User" %>
<%@ page import="banksystem.model.UserRole" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<User> adminUsers = (List<User>) request.getAttribute("adminUsers");
    List<Role> adminRoles = (List<Role>) request.getAttribute("adminRoles");
    List<UserRole> adminUserRoles = (List<UserRole>) request.getAttribute("adminUserRoles");
    List<Account> adminAccounts = (List<Account>) request.getAttribute("adminAccounts");
    List<BankBranch> adminBranches = (List<BankBranch>) request.getAttribute("adminBranches");
    List<AccountStatusHistory> adminStatusHistories = (List<AccountStatusHistory>) request.getAttribute("adminStatusHistories");
    List<TransactionLimitRule> adminLimitRules = (List<TransactionLimitRule>) request.getAttribute("adminLimitRules");
    List<TransactionCategory> adminCategories = (List<TransactionCategory>) request.getAttribute("adminCategories");
    List<AuthRecord> adminAuthRecords = (List<AuthRecord>) request.getAttribute("adminAuthRecords");
    List<LoginDevice> adminLoginDevices = (List<LoginDevice>) request.getAttribute("adminLoginDevices");
    List<SecurityEvent> adminSecurityEvents = (List<SecurityEvent>) request.getAttribute("adminSecurityEvents");
    List<OperationLog> adminOperationLogs = (List<OperationLog>) request.getAttribute("adminOperationLogs");
    List<TransactionValidation> adminValidations = (List<TransactionValidation>) request.getAttribute("adminValidations");
    List<TransactionRiskScore> adminRiskScores = (List<TransactionRiskScore>) request.getAttribute("adminRiskScores");
    List<TransactionApproval> adminApprovals = (List<TransactionApproval>) request.getAttribute("adminApprovals");
    List<AccountDailySummary> adminDailySummaries = (List<AccountDailySummary>) request.getAttribute("adminDailySummaries");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Center - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero">
        <div>
            <p class="eyebrow">Administration</p>
            <h1>Admin Center</h1>
            <p>Consolidated operational control across users, accounts, rules, security, diagnostics, and daily summaries.</p>
        </div>
    </section>
    <% if (error != null && error.length() > 0) { %>
    <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
    <% } %>

    <section class="panel">
        <ul class="nav nav-tabs mb-4" id="adminCenterTabs" role="tablist">
            <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-users" type="button">Users & Roles</button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-accounts" type="button">Account Control</button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-rules" type="button">Risk Rules</button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-security" type="button">Security Monitor</button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-logs" type="button">Audit Logs</button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-diagnostics" type="button">Transaction Diagnostics</button></li>
            <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-summary" type="button">Daily Summary</button></li>
        </ul>

        <div class="tab-content">
            <div class="tab-pane fade show active" id="tab-users">
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>User ID</th><th>Username</th><th>Real Name</th><th>Phone</th><th>Status</th><th>Role</th><th>Action</th></tr></thead>
                        <tbody>
                        <% if (adminUsers != null) { for (User user : adminUsers) {
                            int currentRoleId = 0;
                            if (adminUserRoles != null) {
                                for (UserRole userRole : adminUserRoles) {
                                    if (userRole.getUserId() == user.getUserId()) {
                                        currentRoleId = userRole.getRoleId();
                                        break;
                                    }
                                }
                            }
                        %>
                        <tr>
                            <td><%= user.getUserId() %></td>
                            <td><%= user.getUsername() %></td>
                            <td><%= user.getRealName() %></td>
                            <td><%= user.getPhone() %></td>
                            <td><%= user.getStatus() %></td>
                            <td><%= user.getRoleCodes() %></td>
                            <td>
                                <form class="d-flex gap-2" action="${pageContext.request.contextPath}/admin" method="post">
                                    <input type="hidden" name="action" value="update-role">
                                    <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                    <select class="form-select form-select-sm" name="roleId">
                                        <% if (adminRoles != null) { for (Role role : adminRoles) { %>
                                        <option value="<%= role.getRoleId() %>" <%= role.getRoleId() == currentRoleId ? "selected" : "" %>><%= role.getRoleCode() %></option>
                                        <% }} %>
                                    </select>
                                    <button class="btn btn-primary-gradient btn-sm" type="submit">Save</button>
                                </form>
                            </td>
                        </tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="tab-pane fade" id="tab-accounts">
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Account ID</th><th>User ID</th><th>Account No</th><th>Branch</th><th>Status</th><th>Balance</th><th>Action</th></tr></thead>
                        <tbody>
                        <% if (adminAccounts != null) { for (Account account : adminAccounts) { %>
                        <tr>
                            <td><%= account.getId() %></td>
                            <td><%= account.getUserId() %></td>
                            <td><%= account.getAccountNo() %></td>
                            <td><%= account.getBranchId() == null ? "-" : account.getBranchId() %></td>
                            <td><%= account.getStatus() %></td>
                            <td>¥<%= account.getBalance() %></td>
                            <td>
                                <form class="d-flex gap-2" action="${pageContext.request.contextPath}/admin" method="post">
                                    <input type="hidden" name="action" value="toggle-account-status">
                                    <input type="hidden" name="accountId" value="<%= account.getId() %>">
                                    <input type="hidden" name="targetStatus" value="<%= "FROZEN".equals(account.getStatus()) ? "NORMAL" : "FROZEN" %>">
                                    <input class="form-control form-control-sm" type="text" name="reason" placeholder="Reason">
                                    <button class="btn btn-outline-dark btn-sm" type="submit"><%= "FROZEN".equals(account.getStatus()) ? "Unfreeze" : "Freeze" %></button>
                                </form>
                            </td>
                        </tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
                <div class="table-responsive mt-4">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>History ID</th><th>Account ID</th><th>Old</th><th>New</th><th>Reason</th><th>Changed By</th><th>Time</th></tr></thead>
                        <tbody>
                        <% if (adminStatusHistories != null) { for (AccountStatusHistory history : adminStatusHistories) { %>
                        <tr>
                            <td><%= history.getHistoryId() %></td>
                            <td><%= history.getAccountId() %></td>
                            <td><%= history.getOldStatus() %></td>
                            <td><%= history.getNewStatus() %></td>
                            <td><%= history.getChangeReason() %></td>
                            <td><%= history.getChangedBy() %></td>
                            <td><%= history.getChangeTime() %></td>
                        </tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="tab-pane fade" id="tab-rules">
                <form class="row g-3 mb-4" action="${pageContext.request.contextPath}/admin" method="post">
                    <input type="hidden" name="action" value="save-limit-rule">
                    <div class="col-md-2"><label class="form-label">Role</label><select class="form-select" name="roleId"><% if (adminRoles != null) { for (Role role : adminRoles) { %><option value="<%= role.getRoleId() %>"><%= role.getRoleCode() %></option><% }} %></select></div>
                    <div class="col-md-2"><label class="form-label">Type</label><input class="form-control" type="text" name="transactionType" placeholder="TRANSFER" required></div>
                    <div class="col-md-2"><label class="form-label">Single Limit</label><input class="form-control" type="number" step="0.01" name="singleLimit" required></div>
                    <div class="col-md-2"><label class="form-label">Daily Limit</label><input class="form-control" type="number" step="0.01" name="dailyLimit" required></div>
                    <div class="col-md-2"><label class="form-label">Approval Threshold</label><input class="form-control" type="number" step="0.01" name="approvalThreshold" required></div>
                    <div class="col-md-2 d-flex align-items-end"><button class="btn btn-primary-gradient w-100" type="submit">Save Rule</button></div>
                </form>
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Type</th><th>Role ID</th><th>Single</th><th>Daily</th><th>Approval</th><th>Status</th></tr></thead>
                        <tbody>
                        <% if (adminLimitRules != null) { for (TransactionLimitRule rule : adminLimitRules) { %>
                        <tr><td><%= rule.getTransactionType() %></td><td><%= rule.getRoleId() %></td><td>¥<%= rule.getSingleLimit() %></td><td>¥<%= rule.getDailyLimit() %></td><td>¥<%= rule.getApprovalThreshold() %></td><td><%= rule.getStatus() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
                <form class="row g-3 mt-4" action="${pageContext.request.contextPath}/admin" method="post">
                    <input type="hidden" name="action" value="save-category">
                    <div class="col-md-2"><label class="form-label">Code</label><input class="form-control" type="text" name="categoryCode" required></div>
                    <div class="col-md-3"><label class="form-label">Name</label><input class="form-control" type="text" name="categoryName" required></div>
                    <div class="col-md-2"><label class="form-label">Direction</label><select class="form-select" name="incomeExpenseType"><option>IN</option><option>OUT</option><option>BOTH</option></select></div>
                    <div class="col-md-3"><label class="form-label">Description</label><input class="form-control" type="text" name="description"></div>
                    <div class="col-md-2 d-flex align-items-end"><button class="btn btn-primary-gradient w-100" type="submit">Save Category</button></div>
                </form>
                <div class="table-responsive mt-4">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Code</th><th>Name</th><th>Direction</th><th>Description</th></tr></thead>
                        <tbody>
                        <% if (adminCategories != null) { for (TransactionCategory category : adminCategories) { %>
                        <tr><td><%= category.getCategoryCode() %></td><td><%= category.getCategoryName() %></td><td><%= category.getIncomeExpenseType() %></td><td><%= category.getDescription() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="tab-pane fade" id="tab-security">
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Account</th><th>Type</th><th>Result</th><th>IP</th><th>Time</th></tr></thead>
                        <tbody>
                        <% if (adminAuthRecords != null) { for (AuthRecord record : adminAuthRecords) { %>
                        <tr><td><%= record.getLoginAccount() %></td><td><%= record.getAuthType() %></td><td><%= record.getAuthResult() %></td><td><%= record.getLoginIp() %></td><td><%= record.getAuthTime() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
                <div class="table-responsive mt-4">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Device</th><th>Browser</th><th>OS</th><th>Fingerprint</th><th>Trusted</th></tr></thead>
                        <tbody>
                        <% if (adminLoginDevices != null) { for (LoginDevice device : adminLoginDevices) { %>
                        <tr><td><%= device.getDeviceName() %></td><td><%= device.getBrowser() %></td><td><%= device.getOs() %></td><td><%= device.getDeviceFingerprint() %></td><td><%= device.getTrustedFlag() == 1 ? "Trusted" : "Untrusted" %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
                <div class="table-responsive mt-4">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Type</th><th>Risk</th><th>Description</th><th>IP</th><th>Handled</th><th>Time</th></tr></thead>
                        <tbody>
                        <% if (adminSecurityEvents != null) { for (SecurityEvent event : adminSecurityEvents) { %>
                        <tr><td><%= event.getEventType() %></td><td><%= event.getRiskLevel() %></td><td><%= event.getDescription() %></td><td><%= event.getIpAddress() %></td><td><%= event.getHandledFlag() == 1 ? "Handled" : "Open" %></td><td><%= event.getCreateTime() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="tab-pane fade" id="tab-logs">
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Log ID</th><th>User</th><th>Type</th><th>Target</th><th>Result</th><th>Description</th><th>Time</th></tr></thead>
                        <tbody>
                        <% if (adminOperationLogs != null) { for (OperationLog log : adminOperationLogs) { %>
                        <tr><td><%= log.getLogId() %></td><td><%= log.getUserId() %></td><td><%= log.getOperationType() %></td><td><%= log.getObjectType() %> #<%= log.getObjectId() %></td><td><%= log.getOperationResult() %></td><td><%= log.getOperationContent() %></td><td><%= log.getOperationTime() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="tab-pane fade" id="tab-diagnostics">
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Transaction</th><th>Validation</th><th>Fail Reason</th><th>Time</th></tr></thead>
                        <tbody>
                        <% if (adminValidations != null) { for (TransactionValidation validation : adminValidations) { %>
                        <tr><td><%= validation.getTransactionId() %></td><td><%= validation.getValidationResult() %></td><td><%= validation.getRejectReason() %></td><td><%= validation.getValidationTime() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
                <div class="table-responsive mt-4">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Transaction</th><th>Score</th><th>Level</th><th>Reason</th><th>Rule Hits</th></tr></thead>
                        <tbody>
                        <% if (adminRiskScores != null) { for (TransactionRiskScore score : adminRiskScores) { %>
                        <tr><td><%= score.getTransactionId() %></td><td><%= score.getRiskScore() %></td><td><%= score.getRiskLevel() %></td><td><%= score.getRiskReason() %></td><td><%= score.getRuleHitCount() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
                <div class="table-responsive mt-4">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Approval ID</th><th>Transaction</th><th>Status</th><th>Approver</th><th>Comment</th></tr></thead>
                        <tbody>
                        <% if (adminApprovals != null) { for (TransactionApproval approval : adminApprovals) { %>
                        <tr><td><%= approval.getApprovalId() %></td><td><%= approval.getTransactionId() %></td><td><%= approval.getApprovalStatus() %></td><td><%= approval.getApproverId() %></td><td><%= approval.getApprovalComment() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="tab-pane fade" id="tab-summary">
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Account ID</th><th>Date</th><th>Opening</th><th>Income</th><th>Expense</th><th>Closing</th><th>Transactions</th></tr></thead>
                        <tbody>
                        <% if (adminDailySummaries != null) { for (AccountDailySummary summary : adminDailySummaries) { %>
                        <tr><td><%= summary.getAccountId() %></td><td><%= summary.getSummaryDate() %></td><td>¥<%= summary.getOpeningBalance() %></td><td>¥<%= summary.getIncomeTotal() %></td><td>¥<%= summary.getExpenseTotal() %></td><td>¥<%= summary.getClosingBalance() %></td><td><%= summary.getTransactionCount() %></td></tr>
                        <% }} %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
