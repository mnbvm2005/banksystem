<%@ page import="banksystem.model.Account" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Deposit - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
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
            <p class="eyebrow">Deposit</p>
            <h1>Deposit</h1>
            <p>Post a cash deposit transaction into the selected account.</p>
        </div>
    </section>
    <section class="transfer-layout transfer-centered">
        <div class="panel transfer-panel">
            <div class="panel-heading">
                <div>
                    <h2>Deposit Details</h2>
                    <p class="panel-subtitle">The backend updates balance, transaction records, ledger entries, and operation logs.</p>
                </div>
            </div>
            <% if (error != null && error.length() > 0) { %>
            <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
            <% } %>
            <% if (accounts == null || accounts.isEmpty()) { %>
            <div class="empty-state"><h3>No account available</h3><p>Please import demo database first.</p></div>
            <% } else { %>
            <form action="${pageContext.request.contextPath}/deposit" method="post">
                <div class="form-group">
                    <label for="accountId">Deposit Account</label>
                    <select class="form-select" id="accountId" name="accountId" required>
                        <% for (Account account : accounts) { %>
                        <option value="<%= account.getId() %>"><%= account.getAccountNo() %> - ￥<%= account.getBalance() %></option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="amount">Amount</label>
                    <input class="form-control amount-input" type="number" id="amount" name="amount" min="0.01" step="0.01" required>
                </div>
                <div class="form-actions">
                    <button class="btn btn-primary-gradient" type="submit"><i class="bi bi-plus-circle"></i>Confirm Deposit</button>
                    <a class="btn btn-light" href="${pageContext.request.contextPath}/transactions"><i class="bi bi-receipt"></i>Transactions</a>
                </div>
            </form>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
