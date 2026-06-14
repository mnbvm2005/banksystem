package banksystem.dao;

import banksystem.model.UserRole;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserRoleDao {
    public List<UserRole> findAll() {
        List<UserRole> rows = new ArrayList<UserRole>();
        String sql = "SELECT * FROM user_roles ORDER BY user_role_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                UserRole row = new UserRole();
                row.setUserRoleId(rs.getInt("user_role_id"));
                row.setUserId(rs.getInt("user_id"));
                row.setRoleId(rs.getInt("role_id"));
                row.setAssignTime(rs.getTimestamp("assign_time"));
                rows.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    public void replaceUserRole(int userId, int roleId) throws SQLException {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try {
            connection.setAutoCommit(false);
            try (PreparedStatement deletePs = connection.prepareStatement("DELETE FROM user_roles WHERE user_id = ?")) {
                deletePs.setInt(1, userId);
                deletePs.executeUpdate();
            }
            try (PreparedStatement insertPs = connection.prepareStatement(
                    "INSERT INTO user_roles(user_id, role_id, assign_time) VALUES (?, ?, NOW())")) {
                insertPs.setInt(1, userId);
                insertPs.setInt(2, roleId);
                insertPs.executeUpdate();
            }
            connection.commit();
        } catch (SQLException e) {
            connection.rollback();
            throw e;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }
}
