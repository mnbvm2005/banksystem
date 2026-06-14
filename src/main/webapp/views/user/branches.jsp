<%@ page import="banksystem.model.BankBranch" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<BankBranch> branches = (List<BankBranch>) request.getAttribute("branches");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Branches - BankSystem</title>
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
            <p class="eyebrow">Reference Data</p>
            <h1>Branches</h1>
            <p>Review the configured branch master data used by account records.</p>
        </div>
    </section>
    <section class="panel">
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Code</th><th>Name</th><th>City</th><th>Address</th><th>Phone</th></tr></thead>
                <tbody>
                <% if (branches != null && !branches.isEmpty()) {
                    for (BankBranch branch : branches) { %>
                <tr>
                    <td><%= branch.getBranchCode() %></td>
                    <td><%= branch.getBranchName() %></td>
                    <td><%= branch.getCity() %></td>
                    <td><%= branch.getAddress() %></td>
                    <td><%= branch.getPhone() %></td>
                </tr>
                <% }} else { %>
                <tr><td colspan="5" class="text-center text-muted py-4">No branch records found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
