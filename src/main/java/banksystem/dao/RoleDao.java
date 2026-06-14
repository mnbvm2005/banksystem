package banksystem.dao;

import banksystem.model.Role;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RoleDao {
    public List<Role> findAll() {
        List<Role> rows = new ArrayList<Role>();
        String sql = "SELECT * FROM roles ORDER BY role_id ASC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Role role = new Role();
                role.setRoleId(rs.getInt("role_id"));
                role.setRoleCode(rs.getString("role_code"));
                role.setRoleName(rs.getString("role_name"));
                role.setDescription(rs.getString("description"));
                rows.add(role);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }
}
