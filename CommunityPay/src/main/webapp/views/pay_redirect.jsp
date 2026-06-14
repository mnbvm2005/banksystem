<%@ page import="communitypay.model.UtilityBill" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    UtilityBill bill = (UtilityBill) request.getAttribute("bill");
    String payUrl = (String) request.getAttribute("payUrl");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="1;url=<%= payUrl %>">
    <title>正在连接 FinCloud Bank 安全支付</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/community.css">
</head>
<body>
<main class="cp-center">
    <section class="cp-card cp-result-card">
        <div class="cp-result-icon"><i class="bi bi-bank"></i></div>
        <h1>正在连接 FinCloud Bank 安全支付</h1>
        <p class="bill-meta">系统正在为该生活账单创建银行支付通道，请稍候。</p>
        <% if (bill != null) { %>
        <div class="cp-summary">
            <div><span>缴费类型</span><strong><%= bill.getBillType() %></strong></div>
            <div><span>服务商</span><strong><%= bill.getProviderName() %></strong></div>
            <div><span>户号/房号</span><strong><%= bill.getCustomerNo() %></strong></div>
            <div><span>金额</span><strong>¥<%= bill.getAmount() %></strong></div>
        </div>
        <% } %>
        <p class="bill-meta">安全校验中：AK/SK 签名、订单防篡改、银行支付令牌</p>
        <a class="cp-primary-btn" href="<%= payUrl %>">立即进入银行支付</a>
    </section>
</main>
</body>
</html>
