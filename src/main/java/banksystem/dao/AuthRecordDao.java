package banksystem.dao;

import banksystem.model.AuthRecord;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

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
            ps.setString(6, null);
            ps.setString(7, record.getFailureReason());
            ps.executeUpdate();
        }
    }
}
