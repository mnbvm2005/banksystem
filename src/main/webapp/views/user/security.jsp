<%@ page import="banksystem.model.LoginDevice" %>
<%@ page import="banksystem.model.SecurityEvent" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<LoginDevice> loginDevices = (List<LoginDevice>) request.getAttribute("loginDevices");
    List<SecurityEvent> securityEvents = (List<SecurityEvent>) request.getAttribute("securityEvents");
    boolean adminView = Boolean.TRUE.equals(request.getAttribute("securityAdminView"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Security - BankSystem</title>
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
            <p class="eyebrow">Security</p>
            <h1>Security Center</h1>
            <p>Review trusted devices and follow up on recorded security events.</p>
        </div>
    </section>
    <% if (adminView) { %>
    <div class="alert alert-modern alert-info mb-3"><i class="bi bi-info-circle"></i>Admin mode enabled. You are viewing all visible records.</div>
    <% } %>
    <section class="panel">
        <div class="panel-heading"><h2>Login Devices</h2></div>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Device</th><th>Browser</th><th>OS</th><th>Fingerprint</th><th>Trusted</th><th>Last Login</th><th>Action</th></tr></thead>
                <tbody>
                <% if (loginDevices != null && !loginDevices.isEmpty()) {
                    for (LoginDevice device : loginDevices) { %>
                <tr>
                    <td><%= device.getDeviceName() %></td>
                    <td><%= device.getBrowser() %></td>
                    <td><%= device.getOs() %></td>
                    <td><code><%= device.getDeviceFingerprint() %></code></td>
                    <td><span class="<%= device.getTrustedFlag() == 1 ? "badge-soft-success" : "badge-soft-warning" %>"><%= device.getTrustedFlag() == 1 ? "Trusted" : "Untrusted" %></span></td>
                    <td><%= device.getLastLoginTime() == null ? "-" : device.getLastLoginTime() %></td>
                    <td>
                        <form action="${pageContext.request.contextPath}/security" method="post">
                            <input type="hidden" name="action" value="trust-device">
                            <input type="hidden" name="deviceId" value="<%= device.getDeviceId() %>">
                            <input type="hidden" name="trustedFlag" value="<%= device.getTrustedFlag() == 1 ? 0 : 1 %>">
                            <button class="btn btn-sm <%= device.getTrustedFlag() == 1 ? "btn-outline-secondary" : "btn-primary-gradient" %>" type="submit"><%= device.getTrustedFlag() == 1 ? "Untrust" : "Trust" %></button>
                        </form>
                    </td>
                </tr>
                <% }} else { %>
                <tr><td colspan="7" class="text-center text-muted py-4">No login devices available.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
    <section class="panel mt-3">
        <div class="panel-heading"><h2>Security Events</h2></div>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Type</th><th>Risk</th><th>Description</th><th>IP</th><th>Device</th><th>Status</th><th>Action</th></tr></thead>
                <tbody>
                <% if (securityEvents != null && !securityEvents.isEmpty()) {
                    for (SecurityEvent event : securityEvents) { %>
                <tr>
                    <td><%= event.getEventType() %></td>
                    <td><span class="<%= "HIGH".equals(event.getRiskLevel()) ? "badge-soft-danger" : "MEDIUM".equals(event.getRiskLevel()) ? "badge-soft-warning" : "badge-soft-success" %>"><%= event.getRiskLevel() %></span></td>
                    <td><%= event.getDescription() %></td>
                    <td><%= event.getIpAddress() %></td>
                    <td><%= event.getDeviceFingerprint() %></td>
                    <td><span class="<%= event.getHandledFlag() == 1 ? "badge-soft-success" : "badge-soft-warning" %>"><%= event.getHandledFlag() == 1 ? "Handled" : "Open" %></span></td>
                    <td>
                        <form action="${pageContext.request.contextPath}/security" method="post">
                            <input type="hidden" name="action" value="handle-event">
                            <input type="hidden" name="eventId" value="<%= event.getEventId() %>">
                            <input type="hidden" name="handledFlag" value="<%= event.getHandledFlag() == 1 ? 0 : 1 %>">
                            <button class="btn btn-outline-dark btn-sm" type="submit"><%= event.getHandledFlag() == 1 ? "Reopen" : "Mark Handled" %></button>
                        </form>
                    </td>
                </tr>
                <% }} else { %>
                <tr><td colspan="7" class="text-center text-muted py-4">No security events found.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
