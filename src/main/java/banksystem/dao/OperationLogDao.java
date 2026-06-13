package banksystem.dao;

import banksystem.model.OperationLog;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class OperationLogDao {
    public void add(Connection connection, OperationLog log) throws SQLException {
        String sql = "INSERT INTO operation_logs "
                + "(user_id, operation_type, target_type, target_id, result, ip_address, description, create_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setNullableInt(ps, 1, log.getUserId());
            ps.setString(2, log.getOperationType());
            ps.setString(3, log.getObjectType());
            setNullableInt(ps, 4, log.getObjectId());
            ps.setString(5, log.getOperationResult());
            ps.setString(6, log.getIpAddress());
            ps.setString(7, log.getOperationContent());
            ps.executeUpdate();
        }
    }

    public List<OperationLog> findByUserId(int userId) {
        String sql = "SELECT * FROM operation_logs WHERE user_id = ? ORDER BY create_time DESC, log_id DESC";
        List<OperationLog> logs = new ArrayList<OperationLog>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return logs;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OperationLog log = new OperationLog();
                    log.setLogId(rs.getInt("log_id"));
                    log.setUserId(rs.getInt("user_id"));
                    log.setOperationType(rs.getString("operation_type"));
                    log.setObjectType(rs.getString("target_type"));
                    log.setObjectId(rs.getInt("target_id"));
                    log.setOperationContent(rs.getString("description"));
                    log.setOperationResult(rs.getString("result"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setOperationTime(rs.getTimestamp("create_time"));
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return logs;
    }

    public List<OperationLog> findVisible(int userId, boolean admin) {
        String sql = "SELECT * FROM operation_logs " + (admin ? "" : "WHERE user_id = ? ")
                + "ORDER BY create_time DESC, log_id DESC";
        List<OperationLog> logs = new ArrayList<OperationLog>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return logs;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (!admin) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OperationLog log = new OperationLog();
                    log.setLogId(rs.getInt("log_id"));
                    log.setUserId(rs.getInt("user_id"));
                    log.setOperationType(rs.getString("operation_type"));
                    log.setObjectType(rs.getString("target_type"));
                    log.setObjectId(rs.getInt("target_id"));
                    log.setOperationContent(rs.getString("description"));
                    log.setOperationResult(rs.getString("result"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setOperationTime(rs.getTimestamp("create_time"));
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return logs;
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.INTEGER);
        } else {
            ps.setInt(index, value);
        }
    }
}
