<%@ page import="banksystem.model.Account" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    BigDecimal totalBalance = BigDecimal.ZERO;
    DecimalFormat accountMoneyFormat = new DecimalFormat("#,##0.00");
    int accountCount = accounts == null ? 0 : accounts.size();
    if (accounts != null) {
        for (Account item : accounts) {
            if (item.getBalance() != null) {
                totalBalance = totalBalance.add(item.getBalance());
            }
        }
    }
    String totalBalanceText = accountMoneyFormat.format(totalBalance);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Accounts - BankSystem</title>
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
            <p class="eyebrow">Account Center</p>
            <h1>Accounts</h1>
            <p>Review balances, account types, status, and reserved profile information.</p>
        </div>
    </section>

    <section class="account-summary panel">
        <div>
            <span>Total Assets</span>
            <strong>¥<%= totalBalanceText %></strong>
            <p><%= accountCount %> linked accounts. Balances reflect current database records.</p>
        </div>
        <i class="bi bi-bank2"></i>
    </section>

    <section class="security-grid">
        <div class="panel security-card">
            <span class="security-card-icon" style="--security-icon: url('${pageContext.request.contextPath}/statics/assets/icons/icon-user.svg');"></span>
            <div>
                <span>Identity Status</span>
                <strong>Verified</strong>
            </div>
        </div>
        <div class="panel security-card">
            <span class="security-card-icon" style="--security-icon: url('${pageContext.request.contextPath}/statics/assets/icons/icon-shield.svg');"></span>
            <div>
                <span>Account Status</span>
                <strong>Monitored</strong>
            </div>
        </div>
        <div class="panel security-card">
            <span class="security-card-icon" style="--security-icon: url('${pageContext.request.contextPath}/statics/assets/icons/icon-account.svg');"></span>
            <div>
                <span>Linked Accounts</span>
                <strong><%= accountCount %></strong>
            </div>
        </div>
    </section>

    <section class="account-card-grid">
        <%
            if (accounts == null || accounts.isEmpty()) {
        %>
        <div class="panel">
            <div class="empty-state">
                <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-account.svg" alt="">
                <h3>No accounts found</h3>
                <p>No account records are available for this user. Please confirm demo data has been imported.</p>
                <a class="btn btn-light btn-sm" href="${pageContext.request.contextPath}/index">Back to Dashboard</a>
            </div>
        </div>
        <%
            } else {
                for (Account account : accounts) {
                    String accountNo = account.getAccountNo();
                    String maskedNo = accountNo;
                    String accountBalanceText = account.getBalance() == null ? "0.00" : accountMoneyFormat.format(account.getBalance());
                    if (accountNo != null && accountNo.length() > 8) {
                        maskedNo = accountNo.substring(0, 4) + " **** **** " + accountNo.substring(accountNo.length() - 4);
                    }
        %>
        <article class="account-balance-card">
            <div class="account-card-top">
                <span><%= account.getAccountType() %></span>
                <em class="<%= account.getStatus() == 1 ? "badge-soft-success" : "badge-soft-warning" %>"><%= account.getStatus() == 1 ? "Active" : "Frozen" %></em>
            </div>
            <div class="balance-label">Available Balance</div>
            <div class="balance-value">¥<%= accountBalanceText %></div>
            <div class="account-info-grid">
                <div>
                    <span>Account No.</span>
                    <strong><%= maskedNo %></strong>
                </div>
                <div>
                    <span>Bank</span>
                    <strong><%= account.getBankName() %></strong>
                </div>
                <div>
                    <span>Currency</span>
                    <strong><%= account.getCurrency() %></strong>
                </div>
                <div>
                    <span>Reserved Phone</span>
                    <strong><%= account.getReservedPhone() %></strong>
                </div>
            </div>
        </article>
        <%
                }
            }
        %>
    </section>

    <section class="panel mt-3">
        <div class="panel-heading">
            <h2>Account Details</h2>
        </div>
        <%
            if (accounts == null || accounts.isEmpty()) {
        %>
        <div class="empty-state compact">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-search.svg" alt="">
            <h3>No account details</h3>
            <p>The account table will appear after account records are available.</p>
        </div>
        <%
            } else {
        %>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead>
                <tr>
                    <th>Account No.</th>
                    <th>Type</th>
                    <th>Balance</th>
                    <th>Status</th>
                    <th>Bank</th>
                    <th>Opened At</th>
                </tr>
                </thead>
                <tbody>
                <%
                    for (Account account : accounts) {
                        String accountBalanceText = account.getBalance() == null ? "0.00" : accountMoneyFormat.format(account.getBalance());
                %>
                <tr>
                    <td><%= account.getAccountNo() %></td>
                    <td><%= account.getAccountType() %></td>
                    <td class="amount text-end">¥<%= accountBalanceText %></td>
                    <td><span class="<%= account.getStatus() == 1 ? "badge-soft-success" : "badge-soft-warning" %>"><%= account.getStatus() == 1 ? "Active" : "Frozen" %></span></td>
                    <td><%= account.getBankName() %></td>
                    <td><%= account.getOpenedAt() == null ? "-" : account.getOpenedAt() %></td>
                </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
        <%
            }
        %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
