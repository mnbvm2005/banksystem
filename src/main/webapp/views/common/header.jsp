<%@ page import="banksystem.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User loginUser = (User) session.getAttribute("user");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String topbarCurrentPath = request.getServletPath();
    String topbarPageTitle = "Dashboard";
    if ("/account".equals(topbarCurrentPath)) {
        topbarPageTitle = "Accounts";
    } else if ("/transactions".equals(topbarCurrentPath)) {
        topbarPageTitle = "Transactions";
    } else if ("/transfer".equals(topbarCurrentPath)) {
        topbarPageTitle = "Transfer";
    } else if ("/finance".equals(topbarCurrentPath)) {
        topbarPageTitle = "Finance";
    } else if ("/deposit".equals(topbarCurrentPath)) {
        topbarPageTitle = "Deposit";
    } else if ("/withdraw".equals(topbarCurrentPath)) {
        topbarPageTitle = "Withdraw";
    } else if ("/payment".equals(topbarCurrentPath)) {
        topbarPageTitle = "Payment";
    } else if ("/bill".equals(topbarCurrentPath)) {
        topbarPageTitle = "Bill";
    } else if ("/holding".equals(topbarCurrentPath)) {
        topbarPageTitle = "Holding";
    } else if ("/approval".equals(topbarCurrentPath)) {
        topbarPageTitle = "Approval";
    } else if ("/logs".equals(topbarCurrentPath)) {
        topbarPageTitle = "Operation Logs";
    } else if ("/admin".equals(topbarCurrentPath)) {
        topbarPageTitle = "Admin Center";
    }
    String displayName = loginUser.getRealName();
%>
<div class="dashboard-shell">
    <header class="topbar">
        <div class="topbar-brand">
            <button class="sidebar-toggle" type="button" aria-label="Toggle navigation">
                <i class="bi bi-list"></i>
            </button>
            <div>
                <strong><%= topbarPageTitle %></strong>
                <span>BankSystem Console</span>
            </div>
        </div>
        <div class="topbar-search">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-search.svg" alt="">
            <input class="js-global-search" type="search" placeholder="Search accounts, transactions, and more..." autocomplete="off">
            <div class="global-search-results" aria-live="polite"></div>
        </div>
        <div class="topbar-actions">
            <span class="security-chip"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-shield.svg" alt="">All Systems Operational</span>
            <span class="date-chip" id="currentDate">--</span>
            <span class="user-chip"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-user.svg" alt=""><%= displayName %></span>
            <a class="btn btn-outline-danger btn-sm" href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-box-arrow-right"></i>Sign out
            </a>
        </div>
    </header>
