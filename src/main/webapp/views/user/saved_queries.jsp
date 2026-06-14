<%@ page import="banksystem.model.SavedQuery" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<SavedQuery> savedQueries = (List<SavedQuery>) request.getAttribute("savedQueries");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Saved Queries - BankSystem</title>
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
            <p class="eyebrow">Search Presets</p>
            <h1>Saved Queries</h1>
            <p>Store frequently used account, bill, or transaction query conditions.</p>
        </div>
    </section>
    <% if (error != null && error.length() > 0) { %>
    <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
    <% } %>
    <section class="panel">
        <div class="panel-heading"><h2>Create Saved Query</h2></div>
        <form class="row g-3" action="${pageContext.request.contextPath}/saved-queries" method="post">
            <div class="col-md-3">
                <label class="form-label">Query Name</label>
                <input class="form-control" type="text" name="queryName" required>
            </div>
            <div class="col-md-3">
                <label class="form-label">Query Type</label>
                <select class="form-select" name="queryType">
                    <option value="TRANSACTION">Transaction</option>
                    <option value="BILL">Bill</option>
                    <option value="ACCOUNT">Account</option>
                </select>
            </div>
            <div class="col-md-6">
                <label class="form-label">Condition JSON / Notes</label>
                <input class="form-control" type="text" name="queryCondition" placeholder='{"period":"current_month","direction":"OUT"}'>
            </div>
            <div class="col-12">
                <button class="btn btn-primary-gradient" type="submit"><i class="bi bi-bookmark-plus"></i>Save Query</button>
            </div>
        </form>
    </section>
    <section class="panel mt-3">
        <div class="panel-heading"><h2>Saved Query Library</h2></div>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Name</th><th>Type</th><th>Condition</th><th>Created</th><th>Action</th></tr></thead>
                <tbody>
                <% if (savedQueries != null && !savedQueries.isEmpty()) {
                    for (SavedQuery query : savedQueries) { %>
                <tr>
                    <td><%= query.getQueryName() %></td>
                    <td><%= query.getQueryType() %></td>
                    <td><code><%= query.getQueryCondition() == null ? "" : query.getQueryCondition() %></code></td>
                    <td><%= query.getCreateTime() == null ? "-" : query.getCreateTime() %></td>
                    <td>
                        <form action="${pageContext.request.contextPath}/saved-queries" method="post">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="queryId" value="<%= query.getQueryId() %>">
                            <button class="btn btn-outline-danger btn-sm" type="submit"><i class="bi bi-trash"></i>Delete</button>
                        </form>
                    </td>
                </tr>
                <% }} else { %>
                <tr><td colspan="5" class="text-center text-muted py-4">No saved queries yet.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
