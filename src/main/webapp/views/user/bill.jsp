<%@ page import="banksystem.model.Account" %>
<%@ page import="banksystem.model.Bill" %>
<%@ page import="banksystem.model.BillItem" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    Bill bill = (Bill) request.getAttribute("bill");
    Integer selectedAccountId = (Integer) request.getAttribute("selectedAccountId");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String billType = (String) request.getAttribute("billType");
    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    BigDecimal incomeTotal = bill == null || bill.getIncomeTotal() == null ? BigDecimal.ZERO : bill.getIncomeTotal();
    BigDecimal expenseTotal = bill == null || bill.getExpenseTotal() == null ? BigDecimal.ZERO : bill.getExpenseTotal();
    String incomeTotalText = moneyFormat.format(incomeTotal);
    String expenseTotalText = moneyFormat.format(expenseTotal);
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
</head>
<body class="app-body ambient-page bill-query-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="bill-query-hero">
        <h1>Bill Query</h1>
        <p>Query ledger entries by account and date range.</p>
    </section>

    <section class="bill-query-filter-card">
        <form class="bill-query-form" action="${pageContext.request.contextPath}/bill" method="get">
            <div class="bill-query-field bill-query-field-account">
                <label for="accountId">Account</label>
                <div class="bill-query-control">
                    <span class="bill-query-control-icon"><i class="bi bi-person"></i></span>
                    <select id="accountId" name="accountId">
                    <% if (accounts != null) { for (Account account : accounts) { %>
                        <option value="<%= account.getId() %>" <%= selectedAccountId != null && selectedAccountId == account.getId() ? "selected" : "" %>><%= account.getAccountNo() %></option>
                    <% }} %>
                    </select>
                </div>
            </div>
            <div class="bill-query-field">
                <label for="billType">Type</label>
                <div class="bill-query-control">
                    <span class="bill-query-control-icon"><i class="bi bi-calendar2-week"></i></span>
                    <select id="billType" name="billType">
                        <option value="DAY" <%= "DAY".equals(billType) ? "selected" : "" %>>Day</option>
                        <option value="MONTH" <%= "MONTH".equals(billType) ? "selected" : "" %>>Month</option>
                        <option value="YEAR" <%= "YEAR".equals(billType) ? "selected" : "" %>>Year</option>
                    </select>
                </div>
            </div>
            <div class="bill-query-field">
                <label for="startDate">Start</label>
                <div class="bill-query-control">
                    <span class="bill-query-control-icon"><i class="bi bi-calendar2-week"></i></span>
                    <input type="date" id="startDate" name="startDate" value="<%= startDate == null ? "" : startDate %>">
                </div>
            </div>
            <div class="bill-query-field">
                <label for="endDate">End</label>
                <div class="bill-query-control">
                    <span class="bill-query-control-icon"><i class="bi bi-calendar2-week"></i></span>
                    <input type="date" id="endDate" name="endDate" value="<%= endDate == null ? "" : endDate %>">
                </div>
            </div>
            <button class="bill-query-submit" type="submit"><i class="bi bi-search"></i><span>Query</span></button>
        </form>
    </section>

    <% if (bill == null) { %>
    <section class="bill-query-table-card">
        <div class="empty-state"><h3>No bill data</h3><p>Please select an account and query again.</p></div>
    </section>
    <% } else { %>
    <section class="bill-query-summary-grid">
        <div class="bill-query-stat-stack">
            <article class="bill-query-stat-card">
                <span class="bill-query-stat-icon"><i class="bi bi-wallet2"></i></span>
                <div>
                    <span>Income Total</span>
                    <strong>￥<%= incomeTotalText %></strong>
                </div>
            </article>
            <article class="bill-query-stat-card">
                <span class="bill-query-stat-icon"><i class="bi bi-receipt"></i></span>
                <div>
                    <span>Expense Total</span>
                    <strong>￥<%= expenseTotalText %></strong>
                </div>
            </article>
        </div>
        <article class="bill-query-chart-card">
            <h2>Income vs Expense</h2>
            <canvas id="billFlowChart" height="150" data-income="<%= incomeTotal %>" data-expense="<%= expenseTotal %>"></canvas>
        </article>
    </section>

    <section class="bill-query-table-card">
        <table class="bill-query-table">
            <thead>
            <tr>
                <th><span class="bill-query-table-icon"><i class="bi bi-clipboard2-text"></i></span>Time</th>
                <th>Direction</th>
                <th>Amount</th>
            </tr>
            </thead>
            <tbody>
            <% if (bill.getItems() != null) { for (BillItem item : bill.getItems()) { %>
            <tr>
                <td><%= item.getItemTime() %></td>
                <td><%= item.getDirection() %></td>
                <td>￥<%= item.getAmount() == null ? "0.00" : moneyFormat.format(item.getAmount()) %></td>
            </tr>
            <% }} %>
            </tbody>
        </table>
    </section>
    <% } %>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
