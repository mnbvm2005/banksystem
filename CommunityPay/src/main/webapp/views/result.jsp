<%@ page import="communitypay.model.UtilityBill" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    UtilityBill bill = (UtilityBill) request.getAttribute("bill");
    String status = (String) request.getAttribute("status");
    boolean success = "SUCCESS".equals(status) || (bill != null && "PAID".equals(bill.getStatus()));
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>缴费结果 - 上财小区生活缴费系统</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/community.css">
</head>
<body>
<main class="cp-center">
    <section class="cp-card cp-result-card">
        <div class="cp-result-icon"><i class="bi <%= success ? "bi-check2-circle" : "bi-x-circle" %>"></i></div>
        <h1><%= success ? "缴费成功" : "缴费失败" %></h1>
        <p class="bill-meta"><%= success ? "银行支付已完成，生活缴费账单已更新。" : "本次缴费未完成，请返回账单页重试。" %></p>
        <% if (bill != null) { %>
        <div class="cp-summary">
            <div><span>账单号</span><strong><%= bill.getBillNo() %></strong></div>
            <div><span>缴费类型</span><strong><%= bill.getBillType() %></strong></div>
            <div><span>服务商</span><strong><%= bill.getProviderName() %></strong></div>
            <div><span>户号/房号</span><strong><%= bill.getCustomerNo() %></strong></div>
            <div><span>支付金额</span><strong>¥<%= bill.getAmount() %></strong></div>
            <div><span>银行交易号</span><strong><%= bill.getBankTransactionId() == null ? "-" : bill.getBankTransactionId() %></strong></div>
        </div>
        <% } %>
        <div style="display:flex; gap:12px; justify-content:center; flex-wrap:wrap">
            <a class="cp-secondary-btn" href="${pageContext.request.contextPath}/bills">返回待缴账单</a>
            <a class="cp-primary-btn" href="http://localhost:8080/BankSystem/transactions">进入银行系统查看交易</a>
        </div>
    </section>
</main>
</body>
</html>
