<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Sign In - BankSystem</title>
    <link rel="preconnect" href="https://rsms.me/">
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css">
</head>
<body class="login-body">
<div class="login-shell">
    <div class="login-brand">
        <div class="brand-wordmark login-wordmark">
            <strong>Bank<span>System</span></strong>
            <small>BANKSYSTEM CONSOLE</small>
        </div>
        <h1>BankSystem Console</h1>
        <p>Personal Banking Business Platform</p>
        <div class="login-visual">
            <div class="login-visual-card">
                <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-shield.svg" alt="">
                <span>Secure Access</span>
                <strong>Local Console</strong>
            </div>
            <div class="login-visual-card">
                <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-account.svg" alt="">
                <span>Portfolio View</span>
                <strong>Unified Workspace</strong>
            </div>
        </div>
    </div>
    <div class="login-box">
        <div class="login-card-title">
            <div>
                <h2>Welcome Back</h2>
                <p>Sign in to your BankSystem workspace</p>
            </div>
            <span>Secure</span>
        </div>
        <%
            String error = (String) request.getAttribute("error");
            if (error != null && error.length() > 0) {
        %>
        <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
        <%
            }
        %>
        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="form-group icon-field icon-user">
                <label for="account">Account</label>
                <input class="form-control" type="text" id="account" name="account" value="cuppy" placeholder="Enter username or phone" autocomplete="username" required>
            </div>
            <div class="form-group icon-field icon-lock">
                <label for="password">Password</label>
                <div class="password-field">
                    <input class="form-control" type="password" id="password" name="password" value="123456" placeholder="Enter password" autocomplete="current-password" required>
                    <button class="password-toggle" type="button" aria-label="Show or hide password"
                            data-eye="${pageContext.request.contextPath}/statics/assets/icons/icon-eye.svg"
                            data-eye-off="${pageContext.request.contextPath}/statics/assets/icons/icon-eye-off.svg">
                        <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-eye.svg" alt="">
                    </button>
                </div>
            </div>
            <button class="btn btn-primary-gradient btn-block" type="submit">
                <i class="bi bi-box-arrow-in-right"></i>Sign In
            </button>
        </form>
        <div class="login-hint">Demo credentials are prefilled: cuppy / 123456.</div>
        <div class="login-security">Please confirm this is the local lab environment. Do not save passwords on public devices.</div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/statics/js/app.js"></script>
</body>
</html>
