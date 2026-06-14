<%@ page import="banksystem.model.Transaction" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    String success = request.getParameter("success");
    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    DecimalFormat integerFormat = new DecimalFormat("#,##0");
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy hh:mm a", Locale.US);
    Integer totalTransactionsValue = (Integer) request.getAttribute("totalTransactions");
    Integer pendingReviewValue = (Integer) request.getAttribute("pendingReview");
    BigDecimal totalInflowValue = (BigDecimal) request.getAttribute("totalInflow");
    BigDecimal totalOutflowValue = (BigDecimal) request.getAttribute("totalOutflow");
    int transactionCount = totalTransactionsValue == null ? (transactions == null ? 0 : transactions.size()) : totalTransactionsValue;
    int pendingCount = pendingReviewValue == null ? 0 : pendingReviewValue;
    BigDecimal totalInflow = totalInflowValue == null ? BigDecimal.ZERO : totalInflowValue;
    BigDecimal totalOutflow = totalOutflowValue == null ? BigDecimal.ZERO : totalOutflowValue;
    int inflowCount = 0;
    int outflowCount = 0;
    int internalCount = 0;
    if (transactions != null) {
        for (Transaction transaction : transactions) {
            String type = transaction.getTransactionType();
            String status = transaction.getStatus();
            boolean isPending = "PENDING".equals(status) || "APPROVING".equals(status);
            boolean isInternal = "TRANSFER".equals(type);
            boolean isOutflow = "WITHDRAW".equals(type) || "PAYMENT".equals(type) || "INVEST_BUY".equals(type) || "TRANSFER".equals(type);
            if (isPending) {
                pendingCount++;
            }
            if (isInternal) {
                internalCount++;
            }
            if (isOutflow) {
                outflowCount++;
            } else {
                inflowCount++;
            }
        }
    }
    int overviewTotal = Math.max(inflowCount + outflowCount + internalCount, 1);
    BigDecimal inflowPct = new BigDecimal(inflowCount).multiply(new BigDecimal("100")).divide(new BigDecimal(overviewTotal), 1, RoundingMode.HALF_UP);
    BigDecimal outflowPct = new BigDecimal(outflowCount).multiply(new BigDecimal("100")).divide(new BigDecimal(overviewTotal), 1, RoundingMode.HALF_UP);
    BigDecimal internalPct = new BigDecimal(internalCount).multiply(new BigDecimal("100")).divide(new BigDecimal(overviewTotal), 1, RoundingMode.HALF_UP);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Transactions - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/transactions-fix.css?v=20260614-tx-kpi">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="transaction-hero">
        <h1>Transactions</h1>
        <p>Monitor every movement across your accounts.</p>
    </section>
    <%
        if ("transfer".equals(success)) {
    %>
    <div class="alert alert-success alert-modern"><i class="bi bi-check-circle"></i>Transfer completed. Transaction records have been updated.</div>
    <%
        }
    %>
    <section class="tx-kpi-grid">
        <article class="tx-kpi-card">
            <div class="tx-kpi-text">
                <div class="tx-kpi-label">Total Transactions</div>
                <div class="tx-kpi-value"><%= integerFormat.format(transactionCount) %></div>
                <div class="tx-kpi-subtitle">visible records</div>
            </div>
            <div class="tx-kpi-icon"><i class="bi bi-receipt-cutoff"></i></div>
        </article>
        <article class="tx-kpi-card">
            <div class="tx-kpi-text">
                <div class="tx-kpi-label">Total Inflow</div>
                <div class="tx-kpi-value">¥<%= moneyFormat.format(totalInflow) %></div>
                <div class="tx-kpi-subtitle">inbound ledger amount</div>
            </div>
            <div class="tx-kpi-icon"><i class="bi bi-arrow-down"></i></div>
        </article>
        <article class="tx-kpi-card">
            <div class="tx-kpi-text">
                <div class="tx-kpi-label">Total Outflow</div>
                <div class="tx-kpi-value">¥<%= moneyFormat.format(totalOutflow) %></div>
                <div class="tx-kpi-subtitle">outbound ledger amount</div>
            </div>
            <div class="tx-kpi-icon"><i class="bi bi-arrow-up"></i></div>
        </article>
        <article class="tx-kpi-card">
            <div class="tx-kpi-text">
                <div class="tx-kpi-label">Pending Review</div>
                <div class="tx-kpi-value"><%= integerFormat.format(pendingCount) %></div>
                <div class="tx-kpi-subtitle">awaiting action</div>
            </div>
            <div class="tx-kpi-icon"><i class="bi bi-clock-history"></i></div>
        </article>
    </section>

    <section class="transaction-control-grid">
        <div class="transaction-filter-panel">
            <div class="transaction-filter-row">
                <label>Date Range
                    <button type="button">05/12/2025 - 06/12/2025 <i class="bi bi-calendar3"></i></button>
                </label>
                <label>Type
                    <select class="form-select form-select-sm js-transaction-filter" data-filter="type" aria-label="Transaction type filter">
                        <option>All Types</option>
                        <option>Deposit</option>
                        <option>Transfer</option>
                        <option>Payment</option>
                        <option>Investment</option>
                    </select>
                </label>
                <label>Status
                    <select class="form-select form-select-sm js-transaction-filter" data-filter="status" aria-label="Transaction status filter">
                        <option>All Statuses</option>
                        <option>Success</option>
                        <option>Approving</option>
                        <option>Failed</option>
                    </select>
                </label>
                <label>Account
                    <select class="form-select form-select-sm js-transaction-filter" data-filter="account" aria-label="Account filter">
                        <option>All Accounts</option>
                    </select>
                </label>
            </div>
            <div class="transaction-search-row">
                <div class="table-tools">
                    <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-search.svg" alt="">
                    <input class="form-control form-control-sm js-table-search js-transaction-search" type="search" placeholder="Search by transaction ID, counterparty, or reference..." data-target="#transactionTable">
                </div>
                <button class="transaction-clear" type="button">Clear</button>
                <button class="transaction-export" type="button"><i class="bi bi-download"></i>Export <i class="bi bi-chevron-down"></i></button>
            </div>
        </div>
        <aside class="transaction-overview-panel">
            <h2>Transaction Overview <i class="bi bi-info-circle" tabindex="0" data-bs-toggle="tooltip" data-bs-title="Shows the share of inflow, outflow, and internal transfer records in the current result set."></i></h2>
            <div class="transaction-overview-body">
                <canvas id="transactionTypeChart" height="132"
                        data-inflow="<%= inflowCount %>"
                        data-outflow="<%= outflowCount %>"
                        data-internal="<%= internalCount %>"></canvas>
                <div class="transaction-overview-legend">
                    <div><span class="legend-dot dot-black"></span><b>Inflow</b><em><%= inflowPct %>%</em><strong><%= integerFormat.format(inflowCount) %></strong></div>
                    <div><span class="legend-dot dot-gold"></span><b>Outflow</b><em><%= outflowPct %>%</em><strong><%= integerFormat.format(outflowCount) %></strong></div>
                    <div><span class="legend-dot dot-cream"></span><b>Internal</b><em><%= internalPct %>%</em><strong><%= integerFormat.format(internalCount) %></strong></div>
                    <a href="#transactionTable">View full analytics <i class="bi bi-chevron-right"></i></a>
                </div>
            </div>
        </aside>
    </section>

    <section class="transaction-ledger-panel">
        <div class="transaction-ledger-heading">
            <h2>Transaction Ledger <i class="bi bi-info-circle" tabindex="0" data-bs-toggle="tooltip" data-bs-title="Lists every visible transaction with status, risk level, amount, date, and black box details."></i></h2>
        </div>
        <%
            if (transactions == null || transactions.isEmpty()) {
        %>
        <div class="empty-state">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-transactions.svg" alt="">
            <h3>No transactions yet</h3>
            <p>After the first transfer, account activity will appear here.</p>
            <a class="btn btn-primary-gradient btn-sm" href="${pageContext.request.contextPath}/transfer">Make Transfer</a>
        </div>
        <%
            } else {
        %>
        <div class="table-responsive">
        <table class="table modern-table align-middle" id="transactionTable">
            <thead>
            <tr>
                <th>Transaction ID</th>
                <th>Type</th>
                <th>Account</th>
                <th>Counterparty</th>
                <th class="text-end">Amount</th>
                <th>Status</th>
                <th>Risk</th>
                <th>Date</th>
                <th>Action</th>
            </tr>
            </thead>
            <tbody>
            <%
                for (Transaction transaction : transactions) {
                    String type = transaction.getTransactionType();
                    String status = transaction.getStatus() == null ? "SUCCESS" : transaction.getStatus();
                    String risk = transaction.getRiskLevel() == null ? "LOW" : transaction.getRiskLevel();
                    BigDecimal amountValue = transaction.getAmount() == null ? BigDecimal.ZERO : transaction.getAmount();
                    boolean isOutgoingTransaction = "WITHDRAW".equals(type) || "PAYMENT".equals(type) || "INVEST_BUY".equals(type) || "TRANSFER".equals(type);
                    String accountNo = isOutgoingTransaction ? transaction.getFromAccountNo() : transaction.getToAccountNo();
                    if (accountNo == null || accountNo.trim().length() == 0) {
                        accountNo = transaction.getFromAccountNo() != null ? transaction.getFromAccountNo() : transaction.getToAccountNo();
                    }
                    String accountTail = accountNo == null || accountNo.length() < 4 ? "----" : accountNo.substring(accountNo.length() - 4);
                    String accountLabel = ("DEPOSIT".equals(type) || "PAYMENT".equals(type)) ? "Operating Account" : "Primary Account";
                    String opposite = isOutgoingTransaction ? transaction.getToAccountNo() : transaction.getFromAccountNo();
                    if (opposite == null) {
                        opposite = "-";
                    }
                    String typeName = "TRANSFER".equals(type) ? "Wire Transfer"
                            : "DEPOSIT".equals(type) ? "Deposit"
                            : "PAYMENT".equals(type) ? "Payment"
                            : "INVEST_BUY".equals(type) ? "Investment Buy"
                            : "WITHDRAW".equals(type) ? "Withdraw"
                            : type;
                    String typeFilter = isOutgoingTransaction ? "Outflow" : "Inflow";
                    String amountClass = isOutgoingTransaction ? "amount-out" : "amount-in";
                    String amountIcon = isOutgoingTransaction ? "bi-arrow-down" : "bi-arrow-up";
                    String dateText = transaction.getTransactionTime() == null ? "-" : dateFormat.format(transaction.getTransactionTime());
                    String statusClass = "SUCCESS".equals(status) ? "ledger-status-success" : "FAILED".equals(status) ? "ledger-status-failed" : "ledger-status-pending";
            %>
            <tr data-type="<%= typeFilter %>" data-status="<%= status.substring(0, 1) + status.substring(1).toLowerCase() %>" data-account="<%= accountLabel %>">
                <td><%= transaction.getTransactionNo() %></td>
                <td data-filter-value="<%= typeFilter %>"><span class="ledger-type"><%= typeName %></span></td>
                <td><%= accountLabel %> •••• <%= accountTail %></td>
                <td><%= opposite %></td>
                <td class="amount text-end <%= amountClass %>">¥<%= moneyFormat.format(amountValue) %> <i class="bi <%= amountIcon %>"></i></td>
                <td><span class="ledger-status <%= statusClass %>"><%= status.substring(0, 1) + status.substring(1).toLowerCase() %></span></td>
                <td><%= risk.substring(0, 1) + risk.substring(1).toLowerCase() %></td>
                <td><%= dateText %></td>
                <td><a class="ledger-action" href="${pageContext.request.contextPath}/blackbox?transactionId=<%= transaction.getId() %>"><i class="bi bi-box-seam"></i>Black Box</a></td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>
        </div>
        <div class="transaction-pagination">
            <span>Showing 1 to <%= transactionCount %> of <%= integerFormat.format(transactionCount) %> results</span>
            <div>
                <button type="button" aria-label="First page"><i class="bi bi-chevron-double-left"></i></button>
                <button type="button" aria-label="Previous page"><i class="bi bi-chevron-left"></i></button>
                <button class="active" type="button">1</button>
                <button type="button">2</button>
                <button type="button">3</button>
                <span>...</span>
                <button type="button" aria-label="Next page"><i class="bi bi-chevron-right"></i></button>
                <button type="button" aria-label="Last page"><i class="bi bi-chevron-double-right"></i></button>
            </div>
            <label>Rows per page <select><option>10</option><option>25</option></select></label>
        </div>
        <%
            }
        %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
