<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>上财小区生活缴费登录</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/community.css">
</head>
<body class="cp-login-body">
<main class="cp-login-shell">
    <section class="cp-login-hero">
        <div class="cp-brand large"><div class="cp-brand-mark"><i class="bi bi-house-door"></i></div><div><strong>上财小区</strong><small>生活缴费平台</small></div></div>
        <h1>上财小区生活缴费</h1>
        <p>连接 BankSystem，演示外部生活缴费平台接入银行支付的完整流程。</p>
    </section>
    <section class="cp-card cp-login-card">
        <h2>住户登录</h2>
        <p>演示账号：xg1 / 123456</p>
        <% if (error != null && error.length() > 0) { %><div class="cp-alert"><%= error %></div><% } %>
        <form method="post" action="${pageContext.request.contextPath}/login">
            <label>账号<input name="username" value="xg1" required></label>
            <label>密码<input name="password" type="password" value="123456" required></label>
            <button class="cp-submit-btn" type="submit"><i class="bi bi-box-arrow-in-right"></i>登录</button>
        </form>
    </section>
</main>
</body>
</html>
