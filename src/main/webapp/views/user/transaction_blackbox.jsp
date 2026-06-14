<%@ page import="banksystem.model.TransactionBlackBox" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    TransactionBlackBox blackBox = (TransactionBlackBox) request.getAttribute("blackBox");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Transaction Black Box - BankSystem</title>
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero">
        <div>
            <p class="eyebrow">Transaction Black Box</p>
            <h1>Trace Evidence</h1>
            <p>A single evidence view for transaction records, ledger movement, validation, risk, approval, and audit logs.</p>
        </div>
    </section>
    <% if (blackBox == null) { %>
    <div class="empty-state"><h3>No trace found</h3><p>No black-box evidence is available for this transaction.</p></div>
    <% } else { %>
    <section class="blackbox-status panel mb-4">
        <div>
            <span class="eyebrow">Current Status</span>
            <h2><%= blackBox.getTransactionStatus() %></h2>
            <p><%= blackBox.getTransactionNo() %> · <%= blackBox.getTransactionType() %> · <%= blackBox.getCreateTime() %></p>
        </div>
        <strong>￥<%= blackBox.getAmount() %></strong>
    </section>
    <div class="row g-3 blackbox-grid">
        <div class="col-lg-4">
            <article class="panel h-100">
                <div class="panel-heading"><h2>Transaction Record</h2></div>
                <p><strong><%= blackBox.getTransactionNo() %></strong></p>
                <p><span class="badge-soft-primary"><%= blackBox.getTransactionType() %></span></p>
                <p>Amount: ￥<%= blackBox.getAmount() %></p>
                <p>Status: <span class="badge-soft-success"><%= blackBox.getTransactionStatus() %></span></p>
                <p>Initiator: <%= blackBox.getRealName() %> (<%= blackBox.getUsername() %>)</p>
                <p>Created: <%= blackBox.getCreateTime() %></p>
            </article>
        </div>
        <div class="col-lg-8">
            <article class="panel h-100">
                <div class="panel-heading"><h2>Fund Movement</h2></div>
                <p><%= blackBox.getLedgerTrace() == null ? "No ledger entry is available." : blackBox.getLedgerTrace() %></p>
            </article>
        </div>
        <div class="col-md-4">
            <article class="panel h-100">
                <div class="panel-heading"><h2>Validation</h2></div>
                <p>Result: <%= blackBox.getValidationResult() == null ? "-" : blackBox.getValidationResult() %></p>
            </article>
        </div>
        <div class="col-md-4">
            <article class="panel h-100">
                <div class="panel-heading"><h2>Risk Score</h2></div>
                <canvas id="blackboxRiskChart" height="120" data-score="<%= blackBox.getRiskScore() %>"></canvas>
                <p>Risk level: <%= blackBox.getRiskLevel() %></p>
                <p><%= blackBox.getRiskReason() == null ? "" : blackBox.getRiskReason() %></p>
            </article>
        </div>
        <div class="col-md-4">
            <article class="panel h-100">
                <div class="panel-heading"><h2>Approval & Logs</h2></div>
                <p>Approval required: <%= blackBox.isNeedApproval() ? "Yes" : "No" %></p>
                <p>Approval status: <%= blackBox.getApprovalStatus() == null ? "-" : blackBox.getApprovalStatus() %></p>
                <p>Audit log count: <%= blackBox.getOperationLogCount() %></p>
            </article>
        </div>
    </div>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
