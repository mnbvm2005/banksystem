<%@ page import="communitypay.model.ApiConfig" %>
<%@ page import="communitypay.model.PaymentEvent" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    ApiConfig apiConfig = (ApiConfig) request.getAttribute("config");
    List<PaymentEvent> events = (List<PaymentEvent>) request.getAttribute("events");
    String secretMasked = (String) request.getAttribute("secretMasked");
    String residentName = (String) request.getAttribute("residentName");
    String residentNo = (String) request.getAttribute("residentNo");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>API 接入</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/community.css">
</head>
<body>
<div class="cp-app">
    <aside class="cp-sidebar">
        <div class="cp-brand"><div class="cp-brand-mark"><i class="bi bi-house-door"></i></div><div><strong>上财小区</strong><small>生活缴费平台</small></div></div>
        <nav class="cp-menu">
            <a href="${pageContext.request.contextPath}/bills"><i class="bi bi-receipt"></i>待缴账单</a>
            <a href="${pageContext.request.contextPath}/records"><i class="bi bi-clock-history"></i>缴费记录</a>
            <a class="active" href="${pageContext.request.contextPath}/api"><i class="bi bi-diagram-3"></i>API 接入</a>
        </nav>
        <div class="cp-resident"><strong><%= residentName %></strong><span>住户号：<%= residentNo %></span></div>
    </aside>
    <main class="cp-main">
        <header class="cp-topbar"><div><h1>API 接入</h1><p>上财小区生活缴费系统与 BankSystem 的开放支付接入信息。</p></div></header>
        <section class="cp-layout api-layout">
            <div class="cp-card cp-side-card">
                <div class="cp-card-head clean"><h2>接入配置</h2></div>
                <div class="cp-config-list">
                    <div><span>平台名称</span><strong><%= apiConfig == null ? "" : apiConfig.getPlatformName() %></strong></div>
                    <div><span>access_key</span><strong><%= apiConfig == null ? "" : apiConfig.getAccessKey() %></strong></div>
                    <div><span>secret_key</span><strong><%= secretMasked %></strong></div>
                    <div><span>bank_api_base</span><strong><%= apiConfig == null ? "" : apiConfig.getBankApiBase() %></strong></div>
                    <div><span>签名算法</span><strong>HMAC-SHA256(method + path + timestamp + nonce + bodyHash)</strong></div>
                </div>
            </div>
            <div class="cp-card cp-side-card">
                <div class="cp-card-head clean"><h2>最近事件</h2></div>
                <div class="cp-event-list">
                    <% if (events != null && !events.isEmpty()) { for (PaymentEvent event : events) { %>
                    <div class="cp-event"><strong><%= event.getEventType() %></strong><span><%= event.getBillNo() %> · <%= event.getEventContent() %></span></div>
                    <% }} else { %>
                    <div class="cp-empty">暂无支付事件。</div>
                    <% } %>
                </div>
            </div>
        </section>
    </main>
</div>
</body>
</html>
