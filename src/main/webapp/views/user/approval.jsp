<%@ page import="banksystem.model.TransactionApproval" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<TransactionApproval> approvals = (List<TransactionApproval>) request.getAttribute("approvals");
    Boolean canApproveValue = (Boolean) request.getAttribute("canApprove");
    boolean canApprove = canApproveValue != null && canApproveValue.booleanValue();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Approval - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero"><div><p class="eyebrow">Approval</p><h1>Large Transaction Approval</h1><p>Prototype route for pending transaction approval.</p></div></section>
    <section class="panel">
        <% if (!canApprove) { %>
        <div class="alert alert-modern alert-info mb-4">
            <i class="bi bi-info-circle"></i>
            Read-only view. Approval actions are available only to admin or approver roles.
        </div>
        <% } %>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead><tr><th>Approval ID</th><th>Transaction ID</th><th>Status</th><th>Comment</th><th>Action</th></tr></thead>
                <tbody>
                <% if (approvals != null) { for (TransactionApproval approval : approvals) { %>
                <tr>
                    <td><%= approval.getApprovalId() %></td>
                    <td><%= approval.getTransactionId() %></td>
                    <td><%= approval.getApprovalStatus() %></td>
                    <td><%= approval.getApprovalComment() == null ? "" : approval.getApprovalComment() %></td>
                    <td>
                        <% if (canApprove) { %>
                        <form class="d-flex gap-2" action="${pageContext.request.contextPath}/approval" method="post">
                            <input type="hidden" name="approvalId" value="<%= approval.getApprovalId() %>">
                            <input type="hidden" name="transactionId" value="<%= approval.getTransactionId() %>">
                            <input class="form-control form-control-sm" type="text" name="comment" placeholder="Comment">
                            <button class="btn btn-sm btn-success" type="submit" name="status" value="APPROVED">Approve</button>
                            <button class="btn btn-sm btn-outline-danger" type="submit" name="status" value="REJECTED">Reject</button>
                        </form>
                        <% } else { %>
                        <span class="text-muted">No approval permission</span>
                        <% } %>
                    </td>
                </tr>
                <% }} else { %>
                <tr>
                    <td colspan="5" class="text-center text-muted py-4">No pending approval records.</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
