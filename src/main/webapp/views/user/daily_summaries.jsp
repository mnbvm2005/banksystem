<%@ page import="banksystem.model.AccountDailySummary" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<AccountDailySummary> dailySummaries = (List<AccountDailySummary>) request.getAttribute("dailySummaries");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Daily Summaries - BankSystem</title>
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
            <p class="eyebrow">Daily Ledger</p>
            <h1>Daily Summaries</h1>
            <p>Review opening balance, inflow, outflow, and closing balance per account day.</p>
        </div>
    </section>
    <section class="panel">
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Account ID</th><th>Date</th><th>Opening</th><th>Income</th><th>Expense</th><th>Closing</th><th>Transactions</th></tr></thead>
                <tbody>
                <% if (dailySummaries != null && !dailySummaries.isEmpty()) {
                    for (AccountDailySummary summary : dailySummaries) { %>
                <tr>
                    <td><%= summary.getAccountId() %></td>
                    <td><%= summary.getSummaryDate() == null ? "-" : summary.getSummaryDate() %></td>
                    <td>¥<%= summary.getOpeningBalance() %></td>
                    <td>¥<%= summary.getIncomeTotal() %></td>
                    <td>¥<%= summary.getExpenseTotal() %></td>
                    <td>¥<%= summary.getClosingBalance() %></td>
                    <td><%= summary.getTransactionCount() %></td>
                </tr>
                <% }} else { %>
                <tr><td colspan="7" class="text-center text-muted py-4">No daily summaries found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
