<%@ page import="banksystem.model.OperationLog" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<OperationLog> logs = (List<OperationLog>) request.getAttribute("logs");
    Map<String, String> logContentMap = new HashMap<String, String>();
    logContentMap.put("用户登录成功", "User signed in successfully");
    logContentMap.put("用户存款 100 元", "User deposited CNY 100");
    logContentMap.put("用户转账 500 元给李安娜", "User transferred CNY 500 to Li Anna");
    logContentMap.put("用户申购理财产品 1000 元", "User purchased a wealth product for CNY 1,000");
    logContentMap.put("工资入账 1200 元", "Salary income of CNY 1,200 was posted");
    logContentMap.put("手机话费缴费 180 元", "Mobile bill payment of CNY 180 was completed");
    logContentMap.put("房租分摊转账 420 元给李安娜", "Rent split transfer of CNY 420 to Li Anna was completed");
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
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
                    String operationContent = log.getOperationContent();
                    String displayContent = logContentMap.containsKey(operationContent) ? logContentMap.get(operationContent) : operationContent;
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
