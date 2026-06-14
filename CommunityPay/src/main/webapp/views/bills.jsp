<%@ page import="communitypay.model.UtilityBill" %>
<%@ page import="java.math.BigDecimal" %>
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
    private String iconClass(String type) {
        if ("ELECTRICITY".equals(type)) return "bi-lightning-charge";
        if ("WATER".equals(type)) return "bi-droplet";
        if ("GAS".equals(type)) return "bi-fire";
        if ("PHONE".equals(type)) return "bi-wifi";
        if ("PROPERTY".equals(type)) return "bi-buildings";
        return "bi-receipt";
    }
    private String statusText(String status) {
        if ("PAID".equals(status)) return "已缴费";
        if ("PAYING".equals(status)) return "支付中";
        if ("OVERDUE".equals(status)) return "已逾期";
        if ("FAILED".equals(status)) return "支付失败";
        return "待缴费";
    }
%>
<%
    List<UtilityBill> bills = (List<UtilityBill>) request.getAttribute("bills");
    Integer unpaidCount = (Integer) request.getAttribute("unpaidCount");
    Integer paidCount = (Integer) request.getAttribute("paidCount");
    Integer dueSoon = (Integer) request.getAttribute("dueSoon");
    BigDecimal monthDue = (BigDecimal) request.getAttribute("monthDue");
    String residentName = (String) request.getAttribute("residentName");
    String residentNo = (String) request.getAttribute("residentNo");
    String bankLoginAccount = (String) request.getAttribute("bankLoginAccount");
    DecimalFormat money = new DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>上财小区生活缴费</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/community.css">
</head>
<body>
<div class="cp-app">
    <aside class="cp-sidebar">
        <div class="cp-brand"><div class="cp-brand-mark"><i class="bi bi-house-door"></i></div><div><strong>上财小区</strong><small>生活缴费平台</small></div></div>
        <nav class="cp-menu">
            <a class="active" href="${pageContext.request.contextPath}/bills"><i class="bi bi-receipt"></i>待缴账单</a>
            <a href="${pageContext.request.contextPath}/records"><i class="bi bi-clock-history"></i>缴费记录</a>
            <a href="${pageContext.request.contextPath}/api"><i class="bi bi-diagram-3"></i>API 接入</a>
        </nav>
        <div class="cp-resident"><strong><%= residentName %></strong><span>住户号：<%= residentNo %></span><span>绑定银行账号：<%= bankLoginAccount %></span></div>
    </aside>
    <main class="cp-main">
        <header class="cp-topbar">
            <div><h1>上财小区生活缴费</h1><p>你好，<%= residentName %>。住户号 <%= residentNo %>，可在此查看并缴纳生活账单。</p></div>
            <a class="cp-bank-btn" href="http://localhost:8080/BankSystem/"><i class="bi bi-bank"></i>跳转银行</a>
        </header>

        <section class="cp-stats">
            <div class="cp-card cp-stat"><div><span>待缴账单</span><strong><%= unpaidCount == null ? 0 : unpaidCount %></strong></div><i class="bi bi-receipt-cutoff cp-stat-icon"></i></div>
            <div class="cp-card cp-stat"><div><span>本月应缴</span><strong>¥<%= money.format(monthDue == null ? BigDecimal.ZERO : monthDue) %></strong></div><i class="bi bi-wallet2 cp-stat-icon"></i></div>
            <div class="cp-card cp-stat"><div><span>已缴账单</span><strong><%= paidCount == null ? 0 : paidCount %></strong></div><i class="bi bi-check2-circle cp-stat-icon"></i></div>
            <div class="cp-card cp-stat"><div><span>即将到期</span><strong><%= dueSoon == null ? 0 : dueSoon %></strong></div><i class="bi bi-calendar2-week cp-stat-icon"></i></div>
        </section>

        <section class="cp-layout">
            <div class="cp-card cp-bill-panel">
                <div class="cp-card-head"><h2>待缴账单</h2><p>请及时缴纳以下账单，避免逾期产生滞纳金。</p></div>
                <div class="bill-list">
                    <% if (bills != null) { for (UtilityBill bill : bills) { %>
                    <article class="bill-row">
                        <div class="bill-main">
                            <span class="bill-icon"><i class="bi <%= iconClass(bill.getBillType()) %>"></i></span>
                            <div><strong><%= displayType(bill.getBillType()) %></strong><span><%= bill.getProviderName() %></span></div>
                        </div>
                        <div class="bill-detail">
                            <span>户号/房号：<b><%= bill.getCustomerNo() %></b></span>
                            <span>账期：<b><%= bill.getPeriod() %></b></span>
                            <span>到期日：<b><%= bill.getDueDate() %></b></span>
                        </div>
                        <div class="bill-pay">
                            <strong class="amount">¥<%= money.format(bill.getAmount()) %></strong>
                            <span class="status-pill status-ready">可缴费</span>
                        </div>
                        <div class="bill-action">
                            <a class="cp-primary-btn" href="${pageContext.request.contextPath}/pay?billNo=<%= bill.getBillNo() %>">跳转缴费</a>
                        </div>
                    </article>
                    <% }} %>
                </div>
            </div>
            <aside class="cp-side-stack">
                <div class="cp-card cp-side-card">
                    <div class="cp-card-head clean"><h2>支付接入状态</h2></div>
                    <div class="cp-side-row"><i class="bi bi-shield-check"></i><div><strong>AK/SK 签名校验</strong><span>已启用</span></div></div>
                    <div class="cp-side-row"><i class="bi bi-arrow-left-right"></i><div><strong>支付结果回跳</strong><span>正常</span></div></div>
                    <div class="cp-side-row"><i class="bi bi-bank"></i><div><strong>银行接口</strong><span>已连接</span></div></div>
                </div>
                <div class="cp-card cp-side-card">
                    <div class="cp-card-head clean"><h2>缴费说明</h2></div>
                    <p class="bill-meta">请在到期日前完成缴费。缴费成功后，款项将直接到账至对应服务商。</p>
                    <p class="bill-meta">银行交易记录可在 BankSystem 的 Payment、Bill 与 Logs 中查看。</p>
                </div>
            </aside>
        </section>
    </main>
</div>
</body>
</html>
