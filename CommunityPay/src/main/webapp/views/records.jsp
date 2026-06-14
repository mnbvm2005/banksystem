<%@ page import="communitypay.model.UtilityBill" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    private String displayType(String type) {
        if ("ELECTRICITY".equals(type)) return "电费";
        if ("WATER".equals(type)) return "水费";
        if ("GAS".equals(type)) return "燃气费";
        if ("PHONE".equals(type)) return "通信费";
        if ("PROPERTY".equals(type)) return "物业费";
        return type;
    }
    private String statusText(String status) {
        if ("PAID".equals(status)) return "已缴费";
        if ("PAYING".equals(status)) return "支付中";
        if ("FAILED".equals(status)) return "支付失败";
        return status;
    }
%>
<%
    List<UtilityBill> records = (List<UtilityBill>) request.getAttribute("records");
    String residentName = (String) request.getAttribute("residentName");
    String residentNo = (String) request.getAttribute("residentNo");
    DecimalFormat money = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>缴费记录</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/community.css">
</head>
<body>
<div class="cp-app">
    <aside class="cp-sidebar">
        <div class="cp-brand"><div class="cp-brand-mark"><i class="bi bi-house-door"></i></div><div><strong>上财小区</strong><small>生活缴费平台</small></div></div>
        <nav class="cp-menu">
            <a href="${pageContext.request.contextPath}/bills"><i class="bi bi-receipt"></i>待缴账单</a>
            <a class="active" href="${pageContext.request.contextPath}/records"><i class="bi bi-clock-history"></i>缴费记录</a>
            <a href="${pageContext.request.contextPath}/api"><i class="bi bi-diagram-3"></i>API 接入</a>
        </nav>
        <div class="cp-resident"><strong><%= residentName %></strong><span>住户号：<%= residentNo %></span></div>
    </aside>
    <main class="cp-main">
        <header class="cp-topbar"><div><h1>缴费记录</h1><p>查看当前住户已缴费、支付中和支付失败记录。</p></div></header>
        <section class="cp-card cp-bill-panel">
            <div class="cp-card-head"><h2>历史记录</h2><p>数据来自 community_pay.utility_bills。</p></div>
            <div class="bill-list">
                <% if (records != null && !records.isEmpty()) { for (UtilityBill bill : records) { %>
                <article class="bill-row compact">
                    <div class="bill-main"><span class="bill-icon"><i class="bi bi-receipt"></i></span><div><strong><%= displayType(bill.getBillType()) %></strong><span><%= bill.getProviderName() %></span></div></div>
                    <div class="bill-detail"><span>户号/房号：<b><%= bill.getCustomerNo() %></b></span><span>账期：<b><%= bill.getPeriod() %></b></span></div>
                    <div class="bill-pay"><strong class="amount">¥<%= money.format(bill.getAmount()) %></strong><span class="status-pill status-<%= bill.getStatus().toLowerCase() %>"><%= statusText(bill.getStatus()) %></span></div>
                </article>
                <% }} else { %>
                <div class="cp-empty">暂无缴费记录。</div>
                <% } %>
            </div>
        </section>
    </main>
</div>
</body>
</html>
