<%@ page import="banksystem.model.RiskAssessment" %>
<%@ page import="banksystem.model.TransactionLimitRule" %>
<%@ page import="banksystem.model.TransactionRiskScore" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<RiskAssessment> riskAssessments = (List<RiskAssessment>) request.getAttribute("riskAssessments");
    List<TransactionRiskScore> riskScores = (List<TransactionRiskScore>) request.getAttribute("riskScores");
    List<TransactionLimitRule> limitRules = (List<TransactionLimitRule>) request.getAttribute("limitRules");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Risk - BankSystem</title>
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
            <p class="eyebrow">Risk Control</p>
            <h1>Risk Profile</h1>
            <p>Review customer suitability, transaction risk scores, and active limit rules.</p>
        </div>
    </section>
    <section class="panel">
        <div class="panel-heading"><h2>Risk Assessments</h2></div>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Assessment ID</th><th>Score</th><th>Risk Level</th><th>Valid Until</th><th>Created</th></tr></thead>
                <tbody>
                <% if (riskAssessments != null && !riskAssessments.isEmpty()) {
                    for (RiskAssessment assessment : riskAssessments) { %>
                <tr>
                    <td><%= assessment.getAssessmentId() %></td>
                    <td><%= assessment.getScore() %></td>
                    <td><span class="<%= "HIGH".equals(assessment.getRiskLevel()) ? "badge-soft-danger" : "MEDIUM".equals(assessment.getRiskLevel()) ? "badge-soft-warning" : "badge-soft-success" %>"><%= assessment.getRiskLevel() %></span></td>
                    <td><%= assessment.getValidUntil() == null ? "-" : assessment.getValidUntil() %></td>
                    <td><%= assessment.getCreateTime() == null ? "-" : assessment.getCreateTime() %></td>
                </tr>
                <% }} else { %>
                <tr><td colspan="5" class="text-center text-muted py-4">No risk assessments found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
    <section class="panel mt-3">
        <div class="panel-heading"><h2>Transaction Risk Scores</h2></div>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Transaction ID</th><th>Score</th><th>Risk Level</th><th>Rule Hits</th><th>Reason</th><th>Created</th></tr></thead>
                <tbody>
                <% if (riskScores != null && !riskScores.isEmpty()) {
                    for (TransactionRiskScore score : riskScores) { %>
                <tr>
                    <td><%= score.getTransactionId() %></td>
                    <td><%= score.getRiskScore() %></td>
                    <td><span class="<%= "HIGH".equals(score.getRiskLevel()) ? "badge-soft-danger" : "MEDIUM".equals(score.getRiskLevel()) ? "badge-soft-warning" : "badge-soft-success" %>"><%= score.getRiskLevel() %></span></td>
                    <td><%= score.getRuleHitCount() %></td>
                    <td><%= score.getRiskReason() %></td>
                    <td><%= score.getCreateTime() == null ? "-" : score.getCreateTime() %></td>
                </tr>
                <% }} else { %>
                <tr><td colspan="6" class="text-center text-muted py-4">No transaction risk scores found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
    <section class="panel mt-3">
        <div class="panel-heading"><h2>Active Limit Rules</h2></div>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Transaction Type</th><th>Single Limit</th><th>Daily Limit</th><th>Approval Threshold</th><th>Status</th></tr></thead>
                <tbody>
                <% if (limitRules != null && !limitRules.isEmpty()) {
                    for (TransactionLimitRule rule : limitRules) { %>
                <tr>
                    <td><%= rule.getTransactionType() %></td>
                    <td>¥<%= rule.getSingleLimit() %></td>
                    <td>¥<%= rule.getDailyLimit() %></td>
                    <td>¥<%= rule.getApprovalThreshold() %></td>
                    <td><span class="badge-soft-success"><%= rule.getStatus() %></span></td>
                </tr>
                <% }} else { %>
                <tr><td colspan="5" class="text-center text-muted py-4">No active limit rules found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
