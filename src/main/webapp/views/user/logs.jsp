<%@ page import="banksystem.model.OperationLog" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<OperationLog> logs = (List<OperationLog>) request.getAttribute("logs");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Logs - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero"><div><p class="eyebrow">Logs</p><h1>Operation Logs</h1><p>Query key backend operation records for the current user.</p></div></section>
    <section class="panel">
        <div class="table-responsive">
            <table class="table align-middle">
                <thead><tr><th>Time</th><th>Type</th><th>Object</th><th>Content</th><th>Result</th></tr></thead>
                <tbody>
                <% if (logs != null) { for (OperationLog log : logs) { %>
                <%
                    String displayContent = log.getOperationContent();
                %>
                <tr><td><%= log.getOperationTime() %></td><td><%= log.getOperationType() %></td><td><%= log.getObjectType() %>#<%= log.getObjectId() %></td><td><%= displayContent %></td><td><%= log.getOperationResult() %></td></tr>
                <% }} %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
