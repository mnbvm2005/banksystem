<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String authMode = (String) request.getAttribute("authMode");
    boolean registerMode = "register".equals(authMode);
    String registerUsername = (String) request.getAttribute("registerUsername");
    String registerRealName = (String) request.getAttribute("registerRealName");
    String registerPhone = (String) request.getAttribute("registerPhone");
    String registerEmail = (String) request.getAttribute("registerEmail");
%>
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
</head>
<body class="login-body <%= registerMode ? "auth-register-mode" : "auth-login-mode" %>">
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
	                <h2><%= registerMode ? "Create Account" : "Welcome Back" %></h2>
	                <p><%= registerMode ? "Register a new BankSystem workspace" : "Sign in to your BankSystem workspace" %></p>
	            </div>
	            <span><%= registerMode ? "Register" : "Secure" %></span>
	        </div>
	        <div class="auth-switch" role="tablist" aria-label="Authentication mode">
	            <a class="<%= registerMode ? "" : "active" %>" href="${pageContext.request.contextPath}/login">Sign In</a>
	            <a class="<%= registerMode ? "active" : "" %>" href="${pageContext.request.contextPath}/register">Register</a>
	        </div>
	        <%
	            String error = (String) request.getAttribute("error");
            if (error != null && error.length() > 0) {
        %>
        <div class="alert alert-danger alert-modern"><i class="bi bi-exclamation-triangle"></i><%= error %></div>
        <%
            }
        %>
	        <% if (!registerMode) { %>
	        <form class="auth-form auth-login-form" action="${pageContext.request.contextPath}/login" method="post">
	            <div class="form-group icon-field icon-user">
	                <label for="account">Account</label>
	                <input class="form-control" type="text" id="account" name="account" value="cuppy" placeholder="Enter username or phone" autocomplete="username" required>
            </div>
            <div class="form-group icon-field icon-lock">
                <label for="password">Password</label>
                <div class="password-field">
	                    <input class="form-control" type="password" id="password" name="password" value="123456" placeholder="Enter password" autocomplete="current-password" required>
	                    <button class="password-toggle" type="button" aria-label="Show or hide password"
	                            title="Show or hide password" data-bs-toggle="tooltip" data-bs-title="Show or hide password"
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
	        <% } else { %>
	        <form class="auth-form auth-register-form" action="${pageContext.request.contextPath}/register" method="post">
	            <div class="form-group icon-field icon-user">
	                <label for="username">Username</label>
	                <input class="form-control" type="text" id="username" name="username" value="<%= registerUsername == null ? "" : registerUsername %>" placeholder="Choose a username" autocomplete="username" required>
	            </div>
	            <div class="form-group icon-field icon-user">
	                <label for="realName">Display Name</label>
	                <input class="form-control" type="text" id="realName" name="realName" value="<%= registerRealName == null ? "" : registerRealName %>" placeholder="Enter your display name" autocomplete="name" required>
	            </div>
	            <div class="form-group icon-field icon-user">
	                <label for="phone">Phone</label>
	                <input class="form-control" type="tel" id="phone" name="phone" value="<%= registerPhone == null ? "" : registerPhone %>" placeholder="Enter phone number" autocomplete="tel" required>
	            </div>
	            <div class="form-group icon-field icon-user">
	                <label for="email">Email</label>
	                <input class="form-control" type="email" id="email" name="email" value="<%= registerEmail == null ? "" : registerEmail %>" placeholder="Enter email address" autocomplete="email">
	            </div>
	            <div class="form-group icon-field icon-lock">
	                <label for="registerPassword">Password</label>
	                <div class="password-field">
	                    <input class="form-control" type="password" id="registerPassword" name="password" placeholder="At least 6 characters" autocomplete="new-password" required>
	                    <button class="password-toggle" type="button" aria-label="Show or hide password"
	                            title="Show or hide password" data-bs-toggle="tooltip" data-bs-title="Show or hide password"
	                            data-eye="${pageContext.request.contextPath}/statics/assets/icons/icon-eye.svg"
	                            data-eye-off="${pageContext.request.contextPath}/statics/assets/icons/icon-eye-off.svg">
	                        <img src="${pageContext.request.contextPath}/statics/assets/icons/icon-eye.svg" alt="">
	                    </button>
	                </div>
	            </div>
	            <div class="form-group icon-field icon-lock">
	                <label for="confirmPassword">Confirm Password</label>
	                <input class="form-control" type="password" id="confirmPassword" name="confirmPassword" placeholder="Repeat password" autocomplete="new-password" required>
	            </div>
	            <button class="btn btn-primary-gradient btn-block" type="submit">
	                <i class="bi bi-person-plus"></i>Create Account
	            </button>
	        </form>
	        <div class="login-hint">A default CNY savings account will be created automatically.</div>
	        <% } %>
	        <div class="login-security">Please confirm this is the local lab environment. Do not save passwords on public devices.</div>
	    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/statics/js/app.js"></script>
</body>
</html>
