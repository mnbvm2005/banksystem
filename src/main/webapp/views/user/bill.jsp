<%@ page import="banksystem.model.Account" %>
<%@ page import="banksystem.model.Bill" %>
<%@ page import="banksystem.model.BillItem" %>
<%@ page import="banksystem.model.SavedQuery" %>
<%@ page import="banksystem.model.UserBudget" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    private String describeBillQuery(String condition) {
        if (condition == null || condition.trim().length() == 0) {
            return "Saved bill filter";
        }
        String value = condition.trim();
        if (value.indexOf("{") >= 0) {
            String period = value.indexOf("current_month") >= 0 ? "Current month" : "Saved period";
            String direction = value.indexOf("\"OUT\"") >= 0 ? "Expense only" : value.indexOf("\"IN\"") >= 0 ? "Income only" : "All directions";
            return period + " · " + direction;
        }
        String[] parts = value.split(";");
        String period = "Saved period";
        String start = "";
        String end = "";
        String account = "";
        for (String part : parts) {
            if (part.startsWith("period=")) {
                period = normalizePeriod(part.substring(7));
            } else if (part.startsWith("start=")) {
                start = part.substring(6);
            } else if (part.startsWith("end=")) {
                end = part.substring(4);
            } else if (part.startsWith("accountId=")) {
                account = part.substring(10);
            }
        }
        String range = start.length() == 0 && end.length() == 0 ? "" : " · " + start + " to " + end;
        String accountText = account.length() == 0 ? "" : " · Account #" + account;
        return period + range + accountText;
    }

    private String normalizePeriod(String value) {
        if ("DAY".equalsIgnoreCase(value)) {
            return "Daily bill";
        }
        if ("YEAR".equalsIgnoreCase(value)) {
            return "Yearly bill";
        }
        return "Monthly bill";
    }
%>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    Bill bill = (Bill) request.getAttribute("bill");
    List<UserBudget> budgetCards = (List<UserBudget>) request.getAttribute("budgetCards");
    List<SavedQuery> savedBillQueries = (List<SavedQuery>) request.getAttribute("savedBillQueries");
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

    <section class="row g-3 mb-4">
        <div class="col-lg-7">
            <section class="panel h-100" id="budget">
                <div class="panel-heading"><h2>Budget Snapshot</h2></div>
                <div class="table-responsive">
                    <table class="table modern-table align-middle">
                        <thead><tr><th>Category ID</th><th>Budget</th><th>Used</th><th>Threshold</th></tr></thead>
                        <tbody>
                        <% if (budgetCards != null && !budgetCards.isEmpty()) { for (UserBudget budget : budgetCards) { %>
                        <tr><td><%= budget.getCategoryId() %></td><td>¥<%= moneyFormat.format(budget.getBudgetAmount()) %></td><td>¥<%= moneyFormat.format(budget.getUsedAmount()) %></td><td><%= budget.getWarningThreshold() %></td></tr>
                        <% }} else { %>
                        <tr><td colspan="4" class="text-center text-muted py-4">No current-month budget configured.</td></tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <div class="mt-3"><a class="btn btn-light btn-sm" href="${pageContext.request.contextPath}/budgets">Open Budget Maintenance</a></div>
            </section>
        </div>
        <div class="col-lg-5">
            <section class="panel h-100" id="savedQueries">
                <div class="panel-heading"><h2>My Query Presets</h2></div>
                <form class="saved-query-inline-form" action="${pageContext.request.contextPath}/bill" method="post">
                    <input type="hidden" name="action" value="save-query">
                    <input type="hidden" name="accountId" value="<%= selectedAccountId == null ? "" : selectedAccountId %>">
                    <input type="hidden" name="billType" value="<%= billType == null ? "MONTH" : billType %>">
                    <input type="hidden" name="startDate" value="<%= startDate == null ? "" : startDate %>">
                    <input type="hidden" name="endDate" value="<%= endDate == null ? "" : endDate %>">
                    <div class="input-group input-group-sm">
                        <input class="form-control" name="queryName" value="Current Bill Query" aria-label="Preset name">
                        <button class="btn btn-light" type="submit"><i class="bi bi-bookmark-plus"></i>Save Current Query</button>
                    </div>
                </form>
                <div class="d-grid gap-2">
                    <% if (savedBillQueries != null && !savedBillQueries.isEmpty()) { for (SavedQuery query : savedBillQueries) { %>
                    <div class="saved-query-card">
                        <span class="saved-query-icon"><i class="bi bi-bookmark-check"></i></span>
                        <div>
                            <strong><%= query.getQueryName() %></strong>
                            <div class="text-muted small"><%= describeBillQuery(query.getQueryCondition()) %></div>
                        </div>
                    </div>
                    <% }} else { %>
                    <div class="text-muted">No saved bill presets yet.</div>
                    <% } %>
                </div>
            </section>
        </div>
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
