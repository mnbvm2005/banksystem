<%@ page import="banksystem.model.Account" %>
<%@ page import="banksystem.model.ExternalPaymentOrder" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    ExternalPaymentOrder order = (ExternalPaymentOrder) request.getAttribute("openPaymentOrder");
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    String error = (String) request.getAttribute("error");
    Boolean accountMatched = (Boolean) request.getAttribute("accountMatched");
    boolean canPay = accountMatched == null || accountMatched.booleanValue();
    boolean hasAccounts = accounts != null && !accounts.isEmpty();
    if (!hasAccounts) canPay = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Open Payment Checkout - BankSystem</title>
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
            <p class="eyebrow">Open Payment</p>
            <h1>FinCloud Bank Checkout</h1>
            <p>Confirm the external utility bill and complete payment securely.</p>
        </div>
    </section>
    <section class="payment-centered-layout">
        <div class="panel transfer-panel">
            <div class="panel-heading">
                <div><h2>上财小区生活缴费</h2><p class="panel-subtitle"><%= order == null ? "" : order.getBillNo() %></p></div>
            </div>
            <% if (error != null && error.length() > 0) { %>
            <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
            <% } %>
            <% if (order == null) { %>
            <div class="empty-state compact"><h3>Payment order not found</h3><p>Please return to the external platform and try again.</p></div>
            <% } else { %>
            <div class="pay-account">
                <span><%= order.getExternalUserName() %> · 住户号 <%= order.getExternalUserNo() %></span>
                <strong><%= order.getBillType() %> · <%= order.getProviderName() %></strong>
                <span>户号/房号 <%= order.getCustomerNo() %> · 账期 <%= order.getPeriod() %></span>
                <b>￥<%= order.getAmount() %></b>
            </div>
            <% if (!canPay) { %>
            <div class="alert alert-danger alert-modern">
                <i class="bi bi-exclamation-triangle"></i>
                <%= hasAccounts ? "当前银行登录账号与上财小区绑定账号不一致，请切换账号后支付。" : "当前用户没有可用付款账户，无法完成缴费。" %>
            </div>
            <% } %>
            <form action="${pageContext.request.contextPath}/bankpay/confirm" method="post">
                <input type="hidden" name="payToken" value="<%= order.getPayToken() %>">
                <div class="form-group">
                    <label for="accountId">Payment Account</label>
                    <select class="form-select" id="accountId" name="accountId" required <%= canPay ? "" : "disabled" %>>
                        <% if (accounts != null) { for (Account account : accounts) { %>
                        <option value="<%= account.getId() %>"><%= account.getAccountNo() %> - ￥<%= account.getBalance() %></option>
                        <% }} %>
                    </select>
                    <% if (!hasAccounts) { %>
                    <div class="form-text text-danger">没有可用账户，请先导入或创建测试账户。</div>
                    <% } %>
                </div>
                <div class="form-actions">
                    <button class="btn btn-primary-gradient" type="submit" <%= canPay ? "" : "disabled" %>><i class="bi bi-shield-check"></i>Confirm Bank Payment</button>
                    <% if (!canPay) { %>
                    <a class="btn btn-outline-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right"></i>退出并切换银行账号</a>
                    <% } %>
                    <a class="btn btn-light" href="${pageContext.request.contextPath}/payment"><i class="bi bi-arrow-left"></i>Back</a>
                </div>
            </form>
            <% } %>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
