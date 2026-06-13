<%@ page import="banksystem.model.Account" %>
<%@ page import="banksystem.model.Bill" %>
<%@ page import="banksystem.model.BillItem" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    Bill bill = (Bill) request.getAttribute("bill");
    Integer selectedAccountId = (Integer) request.getAttribute("selectedAccountId");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String billType = (String) request.getAttribute("billType");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Bill - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
</head>
<body class="app-body">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero">
        <div><p class="eyebrow">Bill</p><h1>Bill Query</h1><p>Query ledger entries by account and date range.</p></div>
    </section>
    <section class="panel">
        <form class="row g-3" action="${pageContext.request.contextPath}/bill" method="get">
            <div class="col-md-3">
                <label class="form-label" for="accountId">Account</label>
                <select class="form-select" id="accountId" name="accountId">
                    <% if (accounts != null) { for (Account account : accounts) { %>
                    <option value="<%= account.getId() %>" <%= selectedAccountId != null && selectedAccountId == account.getId() ? "selected" : "" %>><%= account.getAccountNo() %></option>
                    <% }} %>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label" for="billType">Type</label>
                <select class="form-select" id="billType" name="billType">
                    <option value="DAY" <%= "DAY".equals(billType) ? "selected" : "" %>>Day</option>
                    <option value="MONTH" <%= "MONTH".equals(billType) ? "selected" : "" %>>Month</option>
                    <option value="YEAR" <%= "YEAR".equals(billType) ? "selected" : "" %>>Year</option>
                </select>
            </div>
            <div class="col-md-2"><label class="form-label" for="startDate">Start</label><input class="form-control" type="date" id="startDate" name="startDate" value="<%= startDate == null ? "" : startDate %>"></div>
            <div class="col-md-2"><label class="form-label" for="endDate">End</label><input class="form-control" type="date" id="endDate" name="endDate" value="<%= endDate == null ? "" : endDate %>"></div>
            <div class="col-md-2 d-flex align-items-end"><button class="btn btn-primary-gradient w-100" type="submit"><i class="bi bi-search"></i>Query</button></div>
        </form>
    </section>
    <section class="panel mt-4">
        <div class="panel-heading"><div><h2>Bill Summary</h2><p class="panel-subtitle">Dynamic prototype query from ledger entries.</p></div></div>
        <% if (bill == null) { %>
        <div class="empty-state"><h3>No bill data</h3><p>Please select an account and query again.</p></div>
        <% } else { %>
        <div class="row g-3 mb-4">
            <div class="col-md-6"><div class="stat-card"><span>Income Total</span><strong>￥<%= bill.getIncomeTotal() %></strong></div></div>
            <div class="col-md-6"><div class="stat-card"><span>Expense Total</span><strong>￥<%= bill.getExpenseTotal() %></strong></div></div>
        </div>
        <div class="chart-card-inline mb-4">
            <canvas id="billFlowChart" height="120" data-income="<%= bill.getIncomeTotal() %>" data-expense="<%= bill.getExpenseTotal() %>"></canvas>
        </div>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead><tr><th>Time</th><th>Direction</th><th>Amount</th></tr></thead>
                <tbody>
                <% if (bill.getItems() != null) { for (BillItem item : bill.getItems()) { %>
                <tr><td><%= item.getItemTime() %></td><td><%= item.getDirection() %></td><td>￥<%= item.getAmount() %></td></tr>
                <% }} %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
