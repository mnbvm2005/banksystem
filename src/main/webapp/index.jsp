<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String loginUrl = request.getContextPath() + "/login";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="0;url=<%= loginUrl %>">
    <title>Entering BankSystem</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
</head>
<body class="login-body">
<div class="login-box text-center">
    <div class="brand-mark mx-auto mb-3">B</div>
    <h1 class="h4 fw-bold">Entering BankSystem</h1>
    <p class="text-muted mb-4">If the page does not redirect automatically, use the button below.</p>
    <a class="btn btn-primary-gradient" href="<%= loginUrl %>">Open Sign In</a>
</div>
</body>
</html>
