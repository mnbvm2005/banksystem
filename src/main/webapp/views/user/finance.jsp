<%@ page import="banksystem.model.Account" %>
<%@ page import="banksystem.model.FinancialProduct" %>
<%@ page import="banksystem.model.RiskAssessment" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<FinancialProduct> products = (List<FinancialProduct>) request.getAttribute("products");
    List<Account> accounts = (List<Account>) request.getAttribute("accounts");
    RiskAssessment latestRiskAssessment = (RiskAssessment) request.getAttribute("latestRiskAssessment");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Finance - BankSystem</title>
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
            <p class="eyebrow">Wealth Management</p>
            <h1>Finance</h1>
            <p>Browse available products, rates, risk levels, and investment terms.</p>
        </div>
    </section>
    <section class="risk-banner">
        <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-warning.svg" alt="">
        <div>
            <strong>Investment products involve risk.</strong>
            <p>Purchases are checked against your risk profile, available balance, and product minimum amount.</p>
        </div>
    </section>
    <% if (error != null && error.length() > 0) { %>
    <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
    <% } %>
    <section class="panel mb-4">
        <div class="panel-heading"><h2>Risk Assessment</h2></div>
        <% if (latestRiskAssessment == null) { %>
        <div class="empty-state compact">
            <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-warning.svg" alt="">
            <h3>No valid risk assessment</h3>
            <p>Please complete a risk assessment before purchasing wealth products.</p>
            <a class="btn btn-light btn-sm" href="${pageContext.request.contextPath}/risk">Open Risk Profile</a>
        </div>
        <% } else { %>
        <div class="d-flex flex-wrap gap-4 align-items-center">
            <div><span class="text-muted d-block">Score</span><strong><%= latestRiskAssessment.getScore() %></strong></div>
            <div><span class="text-muted d-block">Level</span><strong><%= latestRiskAssessment.getRiskLevel() %></strong></div>
            <div><span class="text-muted d-block">Valid Until</span><strong><%= latestRiskAssessment.getValidUntil() %></strong></div>
            <a class="btn btn-light btn-sm ms-auto" href="${pageContext.request.contextPath}/risk">View Details</a>
        </div>
        <% } %>
    </section>
    <section>
        <%
            if (products == null || products.isEmpty()) {
        %>
        <div class="panel">
            <div class="empty-state">
                <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-finance.svg" alt="">
                <h3>No products available</h3>
                <p>No finance products are available. Please confirm demo product data has been imported.</p>
                <a class="btn btn-light btn-sm" href="${pageContext.request.contextPath}/index">Back to Dashboard</a>
            </div>
        </div>
        <%
            } else {
        %>
        <div class="product-grid">
            <%
                for (FinancialProduct product : products) {
                    String riskLevel = product.getRiskLevel();
                    String productName = product.getProductName();
                    String productType = product.getProductType();
                    String riskBadgeClass = "badge-soft-primary";
                    String statusText = product.getStatus() == 1 ? "Available" : "Paused";
                    String statusBadgeClass = product.getStatus() == 1 ? "badge-soft-success" : "badge-soft-warning";
                    if ("LOW".equals(riskLevel)) {
                        riskBadgeClass = "badge-soft-success";
                    } else if ("MEDIUM".equals(riskLevel)) {
                        riskBadgeClass = "badge-soft-warning";
                    } else if ("HIGH".equals(riskLevel)) {
                        riskBadgeClass = "badge-soft-danger";
                    }
            %>
            <article class="product-card">
                <div class="product-top">
                    <span><%= product.getProductCode() %></span>
                    <em class="<%= riskBadgeClass %>"><%= product.getRiskLevel() %></em>
                </div>
                <h2><%= productName %></h2>
                <p><%= productType %></p>
                <div class="rate"><%= product.getExpectedAnnualRate() %>%</div>
                <div class="product-meta">
                    <span>Min ￥<%= product.getMinAmount() %></span>
                    <span><%= product.getTermDays() %> days</span>
                </div>
                <div class="product-meta mt-3">
                    <span class="<%= statusBadgeClass %>"><%= statusText %></span>
                </div>
                <button class="btn btn-light btn-sm mt-3" type="button" data-bs-toggle="modal" data-bs-target="#productModal<%= product.getId() %>">
                    <i class="bi bi-file-earmark-text"></i>Details
                </button>
            </article>
            <div class="modal fade" id="productModal<%= product.getId() %>" tabindex="-1" aria-labelledby="productTitle<%= product.getId() %>" aria-hidden="true">
                <div class="modal-dialog modal-dialog-centered">
                    <div class="modal-content bank-modal">
                        <div class="modal-header">
                            <h2 class="modal-title fs-5" id="productTitle<%= product.getId() %>"><%= productName %></h2>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div class="product-detail-rate"><%= product.getExpectedAnnualRate() %>%</div>
                            <p>Product Type: <%= productType %></p>
                            <p>Product Code: <%= product.getProductCode() %></p>
                            <p>Term: <%= product.getTermDays() %> days</p>
                            <p>Minimum Amount: ￥<%= product.getMinAmount() %></p>
                            <p>Risk Level: <span class="<%= riskBadgeClass %>"><%= product.getRiskLevel() %></span></p>
                            <p>Suitable For: users whose risk profile is at least <%= product.getRiskLevel() %>.</p>
                            <p>Risk Notice: expected return is prototype data and does not represent a real promise.</p>
                            <% if (latestRiskAssessment == null) { %>
                            <div class="alert alert-warning alert-modern"><i class="bi bi-shield-exclamation"></i>Please complete a risk assessment before purchase.</div>
                            <% } else if (accounts == null || accounts.isEmpty()) { %>
                            <div class="alert alert-warning alert-modern"><i class="bi bi-wallet2"></i>No payment account is available.</div>
                            <% } else { %>
                            <form action="${pageContext.request.contextPath}/finance" method="post" class="mt-3">
                                <input type="hidden" name="productId" value="<%= product.getId() %>">
                                <div class="form-group">
                                    <label for="financeAccount<%= product.getId() %>">Payment Account</label>
                                    <select class="form-select" id="financeAccount<%= product.getId() %>" name="accountId" required>
                                        <% for (Account account : accounts) { %>
                                        <option value="<%= account.getId() %>"><%= account.getAccountNo() %> - ￥<%= account.getBalance() %></option>
                                        <% } %>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="financeAmount<%= product.getId() %>">Purchase Amount</label>
                                    <input class="form-control amount-input" id="financeAmount<%= product.getId() %>" name="amount" type="number"
                                           min="<%= product.getMinAmount() %>" step="0.01" value="<%= product.getMinAmount() %>" required>
                                </div>
                                <button class="btn btn-primary-gradient w-100" type="submit">
                                    <i class="bi bi-check2-circle"></i>Confirm Purchase
                                </button>
                            </form>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <%
                }
            %>
        </div>
        <%
            }
        %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
