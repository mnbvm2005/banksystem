<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String sidebarCurrentPath = request.getServletPath();
    java.util.List<String> sidebarRoleCodes = (java.util.List<String>) session.getAttribute("roleCodes");
    if (sidebarRoleCodes == null) {
        sidebarRoleCodes = new java.util.ArrayList<String>();
    }
    boolean sidebarAdmin = sidebarRoleCodes.contains("ADMIN");
    boolean sidebarApprover = sidebarRoleCodes.contains("APPROVER") || sidebarAdmin;
%>
<aside class="sidebar">
    <div class="sidebar-title logo-area">
        <div class="brand-logo-combo">
            <img class="brand-logo-icon" src="${pageContext.request.contextPath}/statics/assets/logo/logo-icon-refined-gold.svg" alt="BankSystem">
            <span class="brand-logo-divider"></span>
            <div class="brand-logo-text">
                <strong><span>BankSystem</span></strong>
                <small><span>Personal Banking Console</span></small>
            </div>
        </div>
        <img class="sidebar-logo-mark" src="${pageContext.request.contextPath}/statics/assets/logo/logo-mark-square.svg" alt="BankSystem">
    </div>
    <nav class="sidebar-menu">
        <span class="sidebar-section">Core</span>
        <a class="<%= "/index".equals(sidebarCurrentPath) || "/dashboard".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/dashboard">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-dashboard.svg" alt=""><span>Dashboard</span>
        </a>
        <a class="<%= "/account".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/account">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-account.svg" alt=""><span>Accounts</span>
        </a>
        <a class="<%= "/transactions".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/transactions">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-transactions.svg" alt=""><span>Transactions</span>
        </a>
        <span class="sidebar-section">Money</span>
        <a class="<%= "/transfer".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/transfer">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-transfer.svg" alt=""><span>Transfer</span>
        </a>
        <a class="<%= "/payment".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/payment">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-pending.svg" alt=""><span>Payment</span>
        </a>
        <a class="<%= "/bill".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/bill">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-calendar.svg" alt=""><span>Bills</span>
        </a>
        <span class="sidebar-section">Insights</span>
        <a class="<%= "/finance".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/finance">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-finance.svg" alt=""><span>Finance</span>
        </a>
        <a class="<%= "/holding".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/holding">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-account.svg" alt=""><span>Holdings</span>
        </a>
        <a class="<%= "/notifications".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/notifications">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-shield.svg" alt=""><span>Notifications</span>
        </a>
        <% if (sidebarApprover) { %>
        <a class="<%= "/approval".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/approval">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-pending.svg" alt=""><span>Approval Center</span>
        </a>
        <% } %>
        <% if (sidebarAdmin) { %>
        <a class="<%= "/admin".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/admin">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-filter.svg" alt=""><span>Admin Center</span>
        </a>
        <% } %>
        <a class="<%= "/logs".equals(sidebarCurrentPath) ? "active" : "" %>" href="${pageContext.request.contextPath}/logs">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-filter.svg" alt=""><span>Logs</span>
        </a>
    </nav>
    <div class="sidebar-note">
        <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-shield.svg" alt="">
        <span>Security Center<br>Local banking prototype</span>
    </div>
</aside>
<div class="dashboard-main">
