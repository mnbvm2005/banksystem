package banksystem.dao;

import banksystem.model.LoginDevice;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LoginDeviceDao {
    public List<LoginDevice> findVisible(int userId, boolean admin) {
        List<LoginDevice> rows = new ArrayList<LoginDevice>();
        String sql = admin
                ? "SELECT * FROM login_devices ORDER BY last_login_time DESC, device_id DESC"
                : "SELECT * FROM login_devices WHERE user_id = ? ORDER BY last_login_time DESC, device_id DESC";
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

    public void updateTrustedFlag(int deviceId, int userId, boolean admin, int trustedFlag) throws SQLException {
        String sql = admin
                ? "UPDATE login_devices SET trusted_flag = ? WHERE device_id = ?"
                : "UPDATE login_devices SET trusted_flag = ? WHERE device_id = ? AND user_id = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, trustedFlag);
            ps.setInt(2, deviceId);
            if (!admin) {
                ps.setInt(3, userId);
            }
            ps.executeUpdate();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public void upsertLoginDevice(Connection connection, int userId, String deviceFingerprint,
                                  String deviceName, String browser, String os) throws SQLException {
        String updateSql = "UPDATE login_devices SET device_name = ?, browser = ?, os = ?, last_login_time = NOW() "
                + "WHERE user_id = ? AND device_fingerprint = ?";
        try (PreparedStatement updatePs = connection.prepareStatement(updateSql)) {
            updatePs.setString(1, deviceName);
            updatePs.setString(2, browser);
            updatePs.setString(3, os);
            updatePs.setInt(4, userId);
            updatePs.setString(5, deviceFingerprint);
            int updated = updatePs.executeUpdate();
            if (updated > 0) {
                return;
            }
        }
        String insertSql = "INSERT INTO login_devices(user_id, device_fingerprint, device_name, browser, os, trusted_flag, first_login_time, last_login_time) "
                + "VALUES (?, ?, ?, ?, ?, 0, NOW(), NOW())";
        try (PreparedStatement insertPs = connection.prepareStatement(insertSql)) {
            insertPs.setInt(1, userId);
            insertPs.setString(2, deviceFingerprint);
            insertPs.setString(3, deviceName);
            insertPs.setString(4, browser);
            insertPs.setString(5, os);
            insertPs.executeUpdate();
        }
    }

    private LoginDevice mapRow(ResultSet rs) throws SQLException {
        LoginDevice row = new LoginDevice();
        row.setDeviceId(rs.getInt("device_id"));
        row.setUserId(rs.getInt("user_id"));
        row.setDeviceFingerprint(rs.getString("device_fingerprint"));
        row.setDeviceName(rs.getString("device_name"));
        row.setBrowser(rs.getString("browser"));
        row.setOs(rs.getString("os"));
        row.setTrustedFlag(rs.getInt("trusted_flag"));
        row.setFirstLoginTime(rs.getTimestamp("first_login_time"));
        row.setLastLoginTime(rs.getTimestamp("last_login_time"));
        return row;
    }
}
