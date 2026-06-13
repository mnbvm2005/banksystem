<%@ page import="banksystem.model.Transaction" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    String success = request.getParameter("success");
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
</head>
<body class="app-body">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero">
        <div>
            <p class="eyebrow">Transaction Records</p>
            <h1>Transactions</h1>
            <p>Review account activity in reverse chronological order.</p>
        </div>
    </section>
    <%
        if ("transfer".equals(success)) {
    %>
    <div class="alert alert-success alert-modern"><i class="bi bi-check-circle"></i>Transfer completed. Transaction records have been updated.</div>
    <%
        }
    %>
    <section class="analytics-strip mb-4">
        <article class="panel chart-panel">
            <div class="panel-heading">
                <div><h2>Transaction Mix</h2><p class="panel-subtitle">Distribution based on visible ledger rows.</p></div>
            </div>
            <canvas id="transactionTypeChart" height="130"></canvas>
        </article>
        <article class="panel chart-panel">
            <div class="panel-heading">
                <div><h2>Flow Direction</h2><p class="panel-subtitle">Inbound and outbound movement at a glance.</p></div>
            </div>
            <canvas id="transactionDirectionChart" height="130"></canvas>
        </article>
    </section>

    <section class="panel">
        <div class="panel-heading">
            <h2>Transaction Ledger</h2>
        </div>
        <div class="filter-bar">
            <div class="table-tools">
                <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-search.svg" alt="">
                <input class="form-control form-control-sm js-table-search" type="search" placeholder="Search type, account, or notes" data-target="#transactionTable">
            </div>
            <select class="form-select form-select-sm" aria-label="Transaction type filter">
                <option>All Types</option>
                <option>Transfer In</option>
                <option>Transfer Out</option>
            </select>
            <button class="btn btn-light btn-sm" type="button">
                <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-calendar.svg" alt="">Date
            </button>
            <button class="btn btn-light btn-sm" type="button">Reset</button>
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
                <th>Date</th>
                <th>Type</th>
                <th class="text-end">Amount</th>
                <th>Counterparty</th>
                <th>Balance After</th>
                <th>Notes</th>
                <th>Trace</th>
            </tr>
            </thead>
            <tbody>
            <%
                for (Transaction transaction : transactions) {
                    String type = transaction.getTransactionType();
                    boolean isOutgoingTransaction = "TRANSFER_OUT".equals(type) || "WITHDRAW".equals(type);
                    String opposite = isOutgoingTransaction ? transaction.getToAccountNo() : transaction.getFromAccountNo();
                    if (opposite == null) {
                        opposite = "-";
                    }
                    String typeName = "TRANSFER_OUT".equals(type) ? "Transfer Out"
                            : "TRANSFER_IN".equals(type) ? "Transfer In"
                            : "DEPOSIT".equals(type) ? "Deposit"
                            : "WITHDRAW".equals(type) ? "Withdraw" : type;
                    String typeBadgeClass = isOutgoingTransaction ? "badge-soft-warning" : "badge-soft-success";
                    String typeIconClass = isOutgoingTransaction ? "bi-arrow-up-right" : "bi-arrow-down-left";
                    String amountClass = isOutgoingTransaction ? "amount-out" : "amount-in";
                    String amountSign = isOutgoingTransaction ? "-" : "+";
            %>
            <tr>
                <td><%= transaction.getTransactionTime() %></td>
                <td><span class="<%= typeBadgeClass %>"><i class="bi <%= typeIconClass %>"></i><%= typeName %></span></td>
                <td class="amount text-end <%= amountClass %>"><%= amountSign %>￥<%= transaction.getAmount() %></td>
                <td><%= opposite %></td>
                <td>￥<%= transaction.getBalanceAfter() %></td>
                <td><%= transaction.getDescription() == null ? "" : transaction.getDescription() %></td>
                <td><a class="btn btn-light btn-sm" href="${pageContext.request.contextPath}/blackbox?transactionId=<%= transaction.getId() %>"><i class="bi bi-diagram-3"></i>Trace</a></td>
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
