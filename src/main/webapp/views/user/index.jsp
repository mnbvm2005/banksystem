<%@ page import="banksystem.model.Account" %>
<%@ page import="banksystem.model.Transaction" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    BigDecimal totalBalance = (BigDecimal) request.getAttribute("totalBalance");
    if (totalBalance == null) {
        totalBalance = BigDecimal.ZERO;
    }
    BigDecimal monthlyInflow = (BigDecimal) request.getAttribute("monthlyInflow");
    if (monthlyInflow == null) {
        monthlyInflow = BigDecimal.ZERO;
    }
    BigDecimal monthlyOutflow = (BigDecimal) request.getAttribute("monthlyOutflow");
    if (monthlyOutflow == null) {
        monthlyOutflow = BigDecimal.ZERO;
    }
    List<Transaction> recentTransactions = (List<Transaction>) request.getAttribute("recentTransactions");
    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd", Locale.US);
    String totalBalanceText = moneyFormat.format(totalBalance);
    String monthlyInflowText = moneyFormat.format(monthlyInflow);
    String monthlyOutflowText = moneyFormat.format(monthlyOutflow);
    int accountCount = accounts == null ? 0 : accounts.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
</head>
<body class="app-body">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero">
        <div>
            <h1>Executive Overview</h1>
            <p>Welcome back, <%= displayName %>. Your account position is secure and operational.</p>
        </div>
        <a class="btn btn-primary-gradient premium-action" href="${pageContext.request.contextPath}/transfer">
            <i class="bi bi-send"></i>Make a Transfer
        </a>
    </section>

    <section class="metric-grid">
        <div class="card-kpi metric-card">
            <span><i class="bi bi-bank icon-shell"></i>Total Assets</span>
            <strong>¥<%= totalBalanceText %></strong>
            <small><em class="trend-badge positive">Secure</em>All accounts combined</small>
        </div>
        <div class="card-kpi metric-card">
            <span><i class="bi bi-grid icon-shell"></i>Accounts</span>
            <strong><%= accountCount %></strong>
            <small><em class="trend-badge">Active</em>Linked accounts</small>
        </div>
        <div class="card-kpi metric-card">
            <span><i class="bi bi-arrow-down-circle icon-shell"></i>Monthly Inflow</span>
            <strong class="amount-positive">¥<%= monthlyInflowText %></strong>
            <small><em class="trend-badge positive">Income</em>Based on transactions</small>
        </div>
        <div class="card-kpi metric-card">
            <span><i class="bi bi-arrow-up-circle icon-shell"></i>Monthly Outflow</span>
            <strong class="amount-negative">¥<%= monthlyOutflowText %></strong>
            <small><em class="trend-badge negative">Expense</em>Based on transactions</small>
        </div>
    </section>

    <section class="dashboard-mosaic">
        <div class="panel account-summary-card">
            <div class="panel-heading">
                <h2>Account Summary</h2>
                <a href="${pageContext.request.contextPath}/account">View all accounts <i class="bi bi-arrow-right"></i></a>
            </div>
            <%
                if (accounts == null || accounts.isEmpty()) {
            %>
            <div class="empty-state compact">
                <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-account.svg" alt="">
                <h3>No accounts</h3>
                <p>No account data is available.</p>
            </div>
            <%
                } else {
                    for (Account account : accounts) {
                        String accountNo = account.getAccountNo();
                        String accountTail = accountNo == null || accountNo.length() < 4 ? "----" : accountNo.substring(accountNo.length() - 4);
                        String accountBalanceText = account.getBalance() == null ? "0.00" : moneyFormat.format(account.getBalance());
            %>
            <div class="summary-row">
                <span class="summary-icon"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-account.svg" alt=""></span>
                <div>
                    <strong><%= account.getAccountType() %></strong>
                    <small>•••• <%= accountTail %></small>
                </div>
                <b>¥<%= accountBalanceText %></b>
            </div>
            <%
                    }
                }
            %>
            <div class="summary-total">
                <span>Total (<%= accountCount %> Accounts)</span>
                <strong>¥<%= totalBalanceText %></strong>
            </div>
        </div>
        <div class="panel chart-card">
            <div class="panel-heading">
                <h2>Total Assets Over Time</h2>
                <label class="chart-range-control" aria-label="Total assets range">
                    <select class="js-chart-range" data-target="cashflowChart">
                        <option value="month">This Month</option>
                        <option value="quarter">Last 3 Months</option>
                        <option value="year">This Year</option>
                    </select>
                    <i class="bi bi-chevron-down"></i>
                </label>
            </div>
            <canvas id="cashflowChart" height="150"></canvas>
        </div>
        <div class="panel recent-card">
            <div class="panel-heading">
                <h2>Recent Transactions</h2>
                <a href="${pageContext.request.contextPath}/transactions">View all transactions <i class="bi bi-arrow-right"></i></a>
            </div>
            <div class="recent-table js-recent-pager" data-page-size="3">
                <div class="recent-head">
                    <span>Date</span><span>Description</span><span>Account</span><span>Amount</span><span>Status</span>
                </div>
                <%
                    if (recentTransactions == null || recentTransactions.isEmpty()) {
                %>
                <div class="recent-row js-recent-row">
                    <span>--</span>
                    <strong>No transactions yet<small>Ledger activity will appear here</small></strong>
                    <span>All accounts</span>
                    <b>--</b>
                    <em class="badge-soft-primary">Empty</em>
                </div>
                <%
                    } else {
                        for (Transaction transaction : recentTransactions) {
                            String type = transaction.getTransactionType();
                            boolean outgoing = "WITHDRAW".equals(type) || "PAYMENT".equals(type) || "INVEST_BUY".equals(type) || "TRANSFER".equals(type);
                            String dateText = transaction.getCreateTime() == null ? "--" : dateFormat.format(transaction.getCreateTime());
                            String description = transaction.getDescription() == null ? type : transaction.getDescription();
                            String accountNo = outgoing ? transaction.getFromAccountNo() : transaction.getToAccountNo();
                            if (accountNo == null || accountNo.trim().length() == 0) {
                                accountNo = transaction.getFromAccountNo() != null ? transaction.getFromAccountNo() : transaction.getToAccountNo();
                            }
                            String accountTail = accountNo == null || accountNo.length() < 4 ? "----" : accountNo.substring(accountNo.length() - 4);
                            String amountText = moneyFormat.format(transaction.getAmount() == null ? BigDecimal.ZERO : transaction.getAmount());
                            String status = transaction.getStatus() == null ? "SUCCESS" : transaction.getStatus();
                            String statusText = "SUCCESS".equals(status) ? "Completed" : status.substring(0, 1) + status.substring(1).toLowerCase();
                %>
                <div class="recent-row muted-row js-recent-row">
                    <span><%= dateText %></span>
                    <strong><%= description %><small><%= type %></small></strong>
                    <span>•••• <%= accountTail %></span>
                    <b class="<%= outgoing ? "amount-negative" : "amount-positive" %>"><%= outgoing ? "-" : "+" %>¥<%= amountText %></b>
                    <em class="<%= "SUCCESS".equals(status) ? "badge-soft-success" : "badge-soft-primary" %>"><%= statusText %></em>
                </div>
                <%
                        }
                    }
                %>
            </div>
            <div class="recent-pager" aria-label="Recent transactions pagination">
                <button type="button" class="recent-page-btn js-recent-prev" aria-label="Previous recent transactions"><i class="bi bi-chevron-left"></i></button>
                <span class="js-recent-page">1 / 1</span>
                <button type="button" class="recent-page-btn js-recent-next" aria-label="Next recent transactions"><i class="bi bi-chevron-right"></i></button>
            </div>
        </div>
        <div class="panel quick-actions-panel">
            <div class="panel-heading">
                <h2>Quick Actions</h2>
            </div>
            <div class="quick-grid">
                <a class="quick-card" href="${pageContext.request.contextPath}/deposit"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-success.svg" alt=""><strong>Deposit</strong></a>
                <a class="quick-card" href="${pageContext.request.contextPath}/transfer"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-transfer.svg" alt=""><strong>Make a Transfer</strong></a>
                <a class="quick-card" href="${pageContext.request.contextPath}/payment"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-pending.svg" alt=""><strong>Pay a Bill</strong></a>
                <a class="quick-card" href="http://localhost:8080/CommunityPay/bills"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-calendar.svg" alt=""><strong>打开上财小区生活缴费</strong></a>
                <a class="quick-card" href="${pageContext.request.contextPath}/notifications"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-shield.svg" alt=""><strong>Notifications</strong></a>
                <a class="quick-card" href="${pageContext.request.contextPath}/logs"><img src="${pageContext.request.contextPath}/statics/assets/icons/icon-filter.svg" alt=""><strong>Logs</strong></a>
            </div>
        </div>
        <div class="panel chart-card asset-mix-card">
            <div class="panel-heading">
                <div><h2>Asset Allocation</h2><p class="panel-subtitle">Primary balance versus reserve capacity.</p></div>
            </div>
            <canvas id="assetChart" height="170" data-total="<%= totalBalance %>" data-accounts="<%= accountCount %>"></canvas>
        </div>
        <div class="panel insight-panel">
            <div class="insight-icon"><i class="bi bi-shield-lock"></i></div>
            <div>
                <h2>Security Advisory</h2>
                <p>Do not share passwords, verification codes, or card details. Review beneficiary information before every transfer.</p>
            </div>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
