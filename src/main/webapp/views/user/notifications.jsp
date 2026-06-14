<%@ page import="banksystem.model.Notification" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Notifications - BankSystem</title>
    <link rel="stylesheet" href="https://rsms.me/inter/inter.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/statics/css/style.css?v=20260614-bg">
</head>
<body class="app-body ambient-page">
<%@ include file="nav.jsp" %>
<main class="page">
    <section class="page-hero compact-hero"><div><p class="eyebrow">Notifications</p><h1>Notification Center</h1><p>Transaction, approval, security, and system messages in one polished inbox.</p></div></section>
    <section class="panel">
        <div class="panel-heading"><h2>Messages</h2></div>
        <% if (notifications == null || notifications.isEmpty()) { %>
        <div class="empty-state"><h3>No notifications</h3><p>Your inbox is clear.</p></div>
        <% } else { %>
        <div class="table-responsive">
            <table class="table modern-table align-middle">
                <thead><tr><th>Title</th><th>Content</th><th>Type</th><th>Status</th><th>Create Time</th><th>Read Time</th><th></th></tr></thead>
                <tbody>
                <% for (Notification notification : notifications) {
                    String notificationTitle = notification.getTitle();
                    String notificationContent = notification.getContent();
                %>
                <tr>
                    <td><%= notificationTitle %></td>
                    <td><%= notificationContent %></td>
                    <td><%= notification.getNotificationType() %></td>
                    <td><%= notification.isRead() ? "Read" : "Unread" %></td>
                    <td><%= notification.getCreateTime() %></td>
                    <td><%= notification.getReadTime() == null ? "-" : notification.getReadTime() %></td>
                    <td>
                        <% if (!notification.isRead()) { %>
                        <form action="${pageContext.request.contextPath}/notifications" method="post">
                            <input type="hidden" name="notificationId" value="<%= notification.getNotificationId() %>">
                            <button class="btn btn-light btn-sm" type="submit">Mark read</button>
                        </form>
                        <% } %>
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
</main>
<%@ include file="../common/footer.jsp" %>
</body>
</html>
