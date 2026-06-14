<%@ page import="banksystem.model.TransactionCategory" %>
<%@ page import="banksystem.model.UserBudget" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<UserBudget> budgets = (List<UserBudget>) request.getAttribute("budgets");
    List<TransactionCategory> categories = (List<TransactionCategory>) request.getAttribute("categories");
    String budgetMonth = (String) request.getAttribute("budgetMonth");
    String error = (String) request.getAttribute("error");
    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Budgets - BankSystem</title>
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
            <p class="eyebrow">Budget Control</p>
            <h1>Budgets</h1>
            <p>Maintain monthly spending limits by transaction category.</p>
        </div>
    </section>

    <% if (error != null && error.length() > 0) { %>
    <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
    <% } %>

    <section class="panel">
        <div class="panel-heading">
            <h2>Create or Update Budget</h2>
        </div>
        <form class="row g-3" action="${pageContext.request.contextPath}/budgets" method="post">
            <div class="col-md-3">
                <label class="form-label">Month</label>
                <input class="form-control" type="month" name="budgetMonth" value="<%= budgetMonth %>" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Category</label>
                <select class="form-select" name="categoryId" required>
                    <% if (categories != null) { for (TransactionCategory category : categories) {
                        if (!"OUT".equals(category.getIncomeExpenseType()) && !"BOTH".equals(category.getIncomeExpenseType())) {
                            continue;
                        }
                    %>
                    <option value="<%= category.getCategoryId() %>"><%= category.getCategoryName() %></option>
                    <% }} %>
                </select>
            </div>
            <div class="col-md-3">
                <label class="form-label">Budget Amount</label>
                <input class="form-control" type="number" min="0.01" step="0.01" name="budgetAmount" placeholder="1000.00" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Warning Threshold</label>
                <input class="form-control" type="number" min="0.01" max="1" step="0.01" name="warningThreshold" value="0.80" required>
            </div>
            <div class="col-12">
                <button class="btn btn-primary-gradient" type="submit"><i class="bi bi-save"></i>Save Budget</button>
            </div>
        </form>
    </section>

    <section class="panel mt-3">
        <div class="panel-heading">
            <h2>Monthly Budget Status</h2>
        </div>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead>
                <tr>
                    <th>Month</th>
                    <th>Category</th>
                    <th>Budget</th>
                    <th>Used</th>
                    <th>Remaining</th>
                    <th>Warning Line</th>
                </tr>
                </thead>
                <tbody>
                <% if (budgets != null && !budgets.isEmpty()) {
                    for (UserBudget budget : budgets) {
                        String categoryName = String.valueOf(budget.getCategoryId());
                        if (categories != null) {
                            for (TransactionCategory category : categories) {
                                if (category.getCategoryId() == budget.getCategoryId()) {
                                    categoryName = category.getCategoryName();
                                    break;
                                }
                            }
                        }
                        BigDecimal used = budget.getUsedAmount() == null ? BigDecimal.ZERO : budget.getUsedAmount();
                        BigDecimal total = budget.getBudgetAmount() == null ? BigDecimal.ZERO : budget.getBudgetAmount();
                        BigDecimal remaining = total.subtract(used);
                    %>
                <tr>
                    <td><%= budget.getBudgetMonth() %></td>
                    <td><%= categoryName %></td>
                    <td>¥<%= moneyFormat.format(total) %></td>
                    <td>¥<%= moneyFormat.format(used) %></td>
                    <td class="<%= remaining.compareTo(BigDecimal.ZERO) < 0 ? "text-danger" : "" %>">¥<%= moneyFormat.format(remaining) %></td>
                    <td><%= budget.getWarningThreshold() %></td>
                </tr>
                <% }} else { %>
                <tr><td colspan="6" class="text-center text-muted py-4">No budgets configured for this month.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
