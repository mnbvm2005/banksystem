<%@ page import="banksystem.model.OperationLog" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<OperationLog> logs = (List<OperationLog>) request.getAttribute("logs");
    Integer logTotal = (Integer) request.getAttribute("logTotal");
    Integer logSuccess = (Integer) request.getAttribute("logSuccess");
    Integer logFailed = (Integer) request.getAttribute("logFailed");
    String operationType = (String) request.getAttribute("operationType");
    String result = (String) request.getAttribute("result");
    String keyword = (String) request.getAttribute("keyword");
    Boolean adminLogView = (Boolean) request.getAttribute("adminLogView");
    boolean adminView = adminLogView != null && adminLogView.booleanValue();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Logs - BankSystem</title>
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
            <p class="eyebrow"><%= adminView ? "Admin Audit" : "My Audit" %></p>
            <h1>Operation Logs</h1>
            <p><%= adminView ? "Review operation records across the platform." : "Review your own banking activity and security events." %></p>
        </div>
    </section>

    <section class="log-summary-grid">
        <article class="panel log-summary-card">
            <span><i class="bi bi-journal-text"></i></span>
            <div><small>Total Logs</small><strong><%= logTotal == null ? 0 : logTotal %></strong></div>
        </article>
        <article class="panel log-summary-card">
            <span><i class="bi bi-check2-circle"></i></span>
            <div><small>Success</small><strong><%= logSuccess == null ? 0 : logSuccess %></strong></div>
        </article>
        <article class="panel log-summary-card">
            <span><i class="bi bi-exclamation-triangle"></i></span>
            <div><small>Failed</small><strong><%= logFailed == null ? 0 : logFailed %></strong></div>
        </article>
    </section>

    <section class="panel log-filter-panel">
        <form class="row g-3 align-items-end" action="${pageContext.request.contextPath}/logs" method="get">
            <div class="col-md-3">
                <label class="form-label" for="operationType">Type</label>
                <select class="form-select" id="operationType" name="operationType">
                    <option value="" <%= operationType == null || operationType.length() == 0 ? "selected" : "" %>>All types</option>
                    <option value="LOGIN" <%= "LOGIN".equals(operationType) ? "selected" : "" %>>Login</option>
                    <option value="LOGOUT" <%= "LOGOUT".equals(operationType) ? "selected" : "" %>>Logout</option>
                    <option value="REGISTER" <%= "REGISTER".equals(operationType) ? "selected" : "" %>>Register</option>
                    <option value="TRANSFER" <%= "TRANSFER".equals(operationType) ? "selected" : "" %>>Transfer</option>
                    <option value="PAYMENT" <%= "PAYMENT".equals(operationType) ? "selected" : "" %>>Payment</option>
                    <option value="DEPOSIT" <%= "DEPOSIT".equals(operationType) ? "selected" : "" %>>Deposit</option>
                    <option value="WITHDRAW" <%= "WITHDRAW".equals(operationType) ? "selected" : "" %>>Withdraw</option>
                    <option value="APPROVAL" <%= "APPROVAL".equals(operationType) ? "selected" : "" %>>Approval</option>
                    <option value="ADMIN" <%= "ADMIN".equals(operationType) ? "selected" : "" %>>Admin</option>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label" for="result">Result</label>
                <select class="form-select" id="result" name="result">
                    <option value="" <%= result == null || result.length() == 0 ? "selected" : "" %>>All results</option>
                    <option value="SUCCESS" <%= "SUCCESS".equals(result) ? "selected" : "" %>>Success</option>
                    <option value="FAILED" <%= "FAILED".equals(result) ? "selected" : "" %>>Failed</option>
                </select>
            </div>
            <div class="col-md-4">
                <label class="form-label" for="keyword">Keyword</label>
                <input class="form-control" id="keyword" name="keyword" value="<%= keyword == null ? "" : keyword %>" placeholder="Search description, target, or IP">
            </div>
            <div class="col-md-2 d-grid">
                <button class="btn btn-primary-gradient" type="submit"><i class="bi bi-search"></i>Filter</button>
            </div>
        </form>
    </section>

    <section class="panel">
        <div class="panel-heading">
            <h2>Recent Records</h2>
        </div>
        <% if (logs == null || logs.isEmpty()) { %>
        <div class="empty-state compact">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-search.svg" alt="">
            <h3>No logs found</h3>
            <p>No operation records match the current filters.</p>
        </div>
        <% } else { %>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead>
                <tr>
                    <th>Time</th>
                    <th>Type</th>
                    <th>Target</th>
                    <th>Description</th>
                    <th>IP</th>
                    <th>Result</th>
                </tr>
                </thead>
                <tbody>
                <% for (OperationLog log : logs) { %>
                <tr>
                    <td><%= log.getOperationTime() == null ? "-" : log.getOperationTime() %></td>
                    <td><span class="badge-soft-primary"><%= log.getOperationType() %></span></td>
                    <td><%= log.getObjectType() == null ? "-" : log.getObjectType() %><%= log.getObjectId() == null ? "" : "#" + log.getObjectId() %></td>
                    <td><%= log.getOperationContent() == null ? "-" : log.getOperationContent() %></td>
                    <td><%= log.getIpAddress() == null ? "-" : log.getIpAddress() %></td>
                    <td><span class="<%= "SUCCESS".equals(log.getOperationResult()) ? "badge-soft-success" : "badge-soft-danger" %>"><%= log.getOperationResult() %></span></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
