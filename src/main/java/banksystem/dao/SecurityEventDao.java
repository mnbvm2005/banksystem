package banksystem.dao;

import banksystem.model.SecurityEvent;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SecurityEventDao {
    public List<SecurityEvent> findVisible(int userId, boolean admin) {
        List<SecurityEvent> rows = new ArrayList<SecurityEvent>();
        String sql = admin
                ? "SELECT * FROM security_events ORDER BY create_time DESC, event_id DESC"
                : "SELECT * FROM security_events WHERE user_id = ? ORDER BY create_time DESC, event_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (!admin) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    public void updateHandledFlag(int eventId, int userId, boolean admin, int handledFlag) throws SQLException {
        String sql = admin
                ? "UPDATE security_events SET handled_flag = ? WHERE event_id = ?"
                : "UPDATE security_events SET handled_flag = ? WHERE event_id = ? AND user_id = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, handledFlag);
            ps.setInt(2, eventId);
            if (!admin) {
                ps.setInt(3, userId);
            }
            ps.executeUpdate();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public void add(Connection connection, SecurityEvent event) throws SQLException {
        String sql = "INSERT INTO security_events(user_id, event_type, risk_level, description, ip_address, device_fingerprint, handled_flag, create_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (event.getUserId() <= 0) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, event.getUserId());
            }
            ps.setString(2, event.getEventType());
            ps.setString(3, event.getRiskLevel());
            ps.setString(4, event.getDescription());
            ps.setString(5, event.getIpAddress());
            ps.setString(6, event.getDeviceFingerprint());
            ps.setInt(7, event.getHandledFlag());
            ps.executeUpdate();
        }
    }

    private SecurityEvent mapRow(ResultSet rs) throws SQLException {
        SecurityEvent row = new SecurityEvent();
        row.setEventId(rs.getInt("event_id"));
        row.setUserId(rs.getInt("user_id"));
        row.setEventType(rs.getString("event_type"));
        row.setRiskLevel(rs.getString("risk_level"));
        row.setDescription(rs.getString("description"));
        row.setIpAddress(rs.getString("ip_address"));
        row.setDeviceFingerprint(rs.getString("device_fingerprint"));
        row.setHandledFlag(rs.getInt("handled_flag"));
        row.setCreateTime(rs.getTimestamp("create_time"));
        return row;
    }
}
