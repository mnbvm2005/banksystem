<%@ page import="banksystem.model.TransactionCategory" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<TransactionCategory> transactionCategories = (List<TransactionCategory>) request.getAttribute("transactionCategories");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Categories - BankSystem</title>
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
            <p class="eyebrow">Reference Data</p>
            <h1>Categories</h1>
            <p>Review category codes that classify ledger entries and budget buckets.</p>
        </div>
    </section>
    <section class="panel">
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Code</th><th>Name</th><th>Direction</th><th>Description</th></tr></thead>
                <tbody>
                <% if (transactionCategories != null && !transactionCategories.isEmpty()) {
                    for (TransactionCategory category : transactionCategories) { %>
                <tr>
                    <td><%= category.getCategoryCode() %></td>
                    <td><%= category.getCategoryName() %></td>
                    <td><%= category.getIncomeExpenseType() %></td>
                    <td><%= category.getDescription() %></td>
                </tr>
                <% }} else { %>
                <tr><td colspan="4" class="text-center text-muted py-4">No category records found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
