package banksystem.dao;

import banksystem.model.Notification;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NotificationDao {
    public void add(Connection connection, Notification notification) throws SQLException {
        String sql = "INSERT INTO notifications "
                + "(user_id, title, content, notification_type, is_read, create_time) "
                + "VALUES (?, ?, ?, ?, 0, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notification.getUserId());
            ps.setString(2, notification.getTitle() == null ? defaultTitle(notification) : notification.getTitle());
            ps.setString(3, notification.getContent());
            ps.setString(4, notification.getNotificationType() == null ? "SYSTEM" : notification.getNotificationType());
            ps.executeUpdate();
        }
    }

    public List<Notification> findVisible(int userId, boolean admin) {
        String sql = "SELECT * FROM notifications " + (admin ? "" : "WHERE user_id = ? ")
                + "ORDER BY create_time DESC, notification_id DESC";
        List<Notification> notifications = new ArrayList<Notification>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return notifications;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (!admin) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    notifications.add(mapNotification(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return notifications;
    }

    public boolean markRead(int notificationId, int userId, boolean admin) {
        String sql = "UPDATE notifications SET is_read = 1, read_time = NOW() WHERE notification_id = ?"
                + (admin ? "" : " AND user_id = ?");
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return false;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, notificationId);
            if (!admin) {
                ps.setInt(2, userId);
            }
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private Notification mapNotification(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setNotificationId(rs.getInt("notification_id"));
        notification.setUserId(rs.getInt("user_id"));
        notification.setTitle(rs.getString("title"));
        notification.setContent(rs.getString("content"));
        notification.setNotificationType(rs.getString("notification_type"));
        notification.setRead(rs.getInt("is_read") == 1);
        notification.setCreateTime(rs.getTimestamp("create_time"));
        notification.setReadTime(rs.getTimestamp("read_time"));
        return notification;
    }

    private String defaultTitle(Notification notification) {
        String content = notification.getContent();
        if (content == null || content.trim().length() == 0) {
            return "System Notification";
        }
        return content.length() > 20 ? content.substring(0, 20) : content;
    }
}
