<%@ page import="banksystem.model.Account" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Transfer - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero">
        <div>
            <p class="eyebrow">Transfer</p>
            <h1>Transfer</h1>
            <p>Enter beneficiary account, amount, and reference information.</p>
        </div>
    </section>

    <section class="transfer-layout transfer-centered">
    <div class="panel transfer-panel">
        <div class="panel-heading">
            <div>
                <h2>Transfer Details</h2>
                <p class="panel-subtitle">Verify beneficiary and transfer amount before submission.</p>
            </div>
        </div>
        <%
            if (error != null && error.length() > 0) {
        %>
        <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
        <%
            }
        %>
        <%
            if (accounts == null || accounts.isEmpty()) {
        %>
        <div class="empty-state">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-transfer.svg" alt="">
            <h3>No payment account available</h3>
            <p>This user has no account available for transfer. Please confirm demo account data.</p>
            <a class="btn btn-light btn-sm" href="${pageContext.request.contextPath}/account">View Accounts</a>
        </div>
        <%
            } else {
                Account mainAccount = accounts.get(0);
        %>
        <div class="pay-account">
            <span>Default Payment Account</span>
            <strong><%= mainAccount.getAccountNo() %></strong>
            <b>￥<%= mainAccount.getBalance() %></b>
        </div>
        <form action="${pageContext.request.contextPath}/transfer" method="post" id="transferForm" data-confirm-transfer="true">
            <div class="form-step">
                <span>Step 1</span>
                <strong>Beneficiary Account</strong>
            </div>
            <div class="form-group">
                <label for="fromAccountNo">From Account</label>
                <input class="form-control" type="text" id="fromAccountNo" value="<%= mainAccount.getAccountNo() %>" readonly>
            </div>
            <div class="form-group">
                <label for="toAccountNo">Beneficiary Account</label>
                <input class="form-control" type="text" id="toAccountNo" name="toAccountNo" placeholder="Enter beneficiary account number" required>
                <div class="form-text">Please verify the beneficiary account number before submission.</div>
            </div>
            <div class="form-step">
                <span>Step 2</span>
                <strong>Transfer Amount</strong>
            </div>
            <div class="form-group">
                <label for="amount">Amount</label>
                <div class="money-field">
                    <input class="form-control amount-input" type="number" id="amount" name="amount" min="0.01" step="0.01" placeholder="0.00" required>
                </div>
                <div class="form-text">Amount must be greater than 0 and within the available balance.</div>
            </div>
            <div class="form-step">
                <span>Step 3</span>
                <strong>Reference & Confirmation</strong>
            </div>
            <div class="form-group">
                <label for="remark">Reference</label>
                <input class="form-control" type="text" id="remark" name="remark" placeholder="Enter transfer reference">
            </div>
            <div class="form-actions">
                <button class="btn btn-primary-gradient" type="submit"><i class="bi bi-check2-circle"></i>Confirm Transfer</button>
                <a class="btn btn-light" href="${pageContext.request.contextPath}/transactions"><i class="bi bi-receipt"></i>Transactions</a>
            </div>
        </form>
        <%
            }
        %>
    </div>
    <aside class="panel safety-card">
        <span class="badge-soft-primary"><i class="bi bi-shield-check"></i>Security Advisory</span>
        <h2>Verify beneficiary details before transfer</h2>
        <p>The system will validate amount, balance, and account status before updating balances and ledger records.</p>
        <ul>
            <li>Confirm the beneficiary account carefully</li>
            <li>Do not transfer to unfamiliar accounts</li>
            <li>The system never asks for verification codes</li>
            <li>Review large transfers one more time</li>
        </ul>
    </aside>
    </section>

    <div class="modal fade" id="transferConfirmModal" tabindex="-1" aria-labelledby="transferConfirmTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content bank-modal">
                <div class="modal-header">
                    <h2 class="modal-title fs-5" id="transferConfirmTitle">Confirm Transfer</h2>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="modal-icon"><i class="bi bi-shield-check"></i></div>
                    <p id="transferConfirmText">Please confirm transfer details.</p>
                    <small>Backend balance, status, and transaction validation will still be performed.</small>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary-gradient" id="transferConfirmSubmit">Confirm</button>
                </div>
            </div>
        </div>
    </div>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
