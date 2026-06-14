<%@ page import="banksystem.model.InvestmentHolding" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<InvestmentHolding> holdings = (List<InvestmentHolding>) request.getAttribute("holdings");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Holding - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero"><div><p class="eyebrow">Holding</p><h1>Investment Holding</h1><p>Backend reserved view for investment holdings.</p></div></section>
    <section class="panel">
        <div class="panel-heading"><div><h2>Holdings</h2><p class="panel-subtitle">Records come from investment_holdings.</p></div></div>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead><tr><th>Product</th><th>Amount</th><th>Income</th><th>Status</th><th>Purchase Time</th></tr></thead>
                <tbody>
                <% if (holdings != null) { for (InvestmentHolding holding : holdings) { %>
                <tr><td><%= holding.getProductName() %></td><td>￥<%= holding.getHoldingAmount() %></td><td>￥<%= holding.getCurrentIncome() %></td><td><%= holding.getHoldingStatus() %></td><td><%= holding.getPurchaseTime() %></td></tr>
                <% }} %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
