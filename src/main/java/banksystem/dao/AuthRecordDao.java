package banksystem.dao;

import banksystem.model.AuthRecord;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class AuthRecordDao {
    public void add(Connection connection, AuthRecord record) throws SQLException {
        String sql = "INSERT INTO auth_records "
                + "(user_id, auth_type, auth_result, login_account, ip_address, device_fingerprint, fail_reason, auth_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (record.getUserId() == null) {
                ps.setNull(1, Types.INTEGER);
            } else {
                ps.setInt(1, record.getUserId());
            }
            ps.setString(2, record.getAuthType());
            ps.setString(3, record.getAuthResult());
            ps.setString(4, record.getLoginAccount());
            ps.setString(5, record.getLoginIp());
            ps.setString(6, record.getDeviceFingerprint());
            ps.setString(7, record.getFailureReason());
            ps.executeUpdate();
        }
    }

    public List<AuthRecord> findAll() {
        List<AuthRecord> rows = new ArrayList<AuthRecord>();
        String sql = "SELECT * FROM auth_records ORDER BY auth_time DESC, auth_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                AuthRecord row = new AuthRecord();
                row.setAuthId(rs.getInt("auth_id"));
                int userId = rs.getInt("user_id");
                row.setUserId(rs.wasNull() ? null : Integer.valueOf(userId));
                row.setAuthType(rs.getString("auth_type"));
                row.setAuthResult(rs.getString("auth_result"));
                row.setLoginAccount(rs.getString("login_account"));
                row.setLoginIp(rs.getString("ip_address"));
                row.setDeviceFingerprint(rs.getString("device_fingerprint"));
                row.setFailureReason(rs.getString("fail_reason"));
                row.setAuthTime(rs.getTimestamp("auth_time"));
                rows.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    public int countRecentFailures(String loginAccount, String ipAddress, int minutes) {
        String sql = "SELECT COUNT(*) FROM auth_records "
                + "WHERE auth_result = 'FAILED' AND login_account = ? AND ip_address = ? "
                + "AND auth_time >= DATE_SUB(NOW(), INTERVAL ? MINUTE)";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return 0;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, loginAccount);
            ps.setString(2, ipAddress);
            ps.setInt(3, minutes);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return 0;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }
}
