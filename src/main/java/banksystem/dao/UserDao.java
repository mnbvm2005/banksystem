package banksystem.dao;

import banksystem.model.User;
import banksystem.sqloperation.GetMySQLConnection;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserDao {
    public boolean canConnect() {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return false;
        }
        GetMySQLConnection.closeConnection(connection);
        return true;
    }

    public User login(String accountOrPhone, String password) {
        User user = findByUsernameOrPhone(accountOrPhone);
        if (user == null) {
            return null;
        }
        String inputHash = sha256(password + user.getPasswordSalt());
        if (!inputHash.equalsIgnoreCase(user.getPasswordHash())) {
            return null;
        }
        user.setRoleCodes(findRoleCodes(user.getUserId()));
        return user;
    }

    public User findByUsernameOrPhone(String accountOrPhone) {
        String sql = "SELECT * FROM users WHERE username = ? OR phone = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return null;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, accountOrPhone);
            ps.setString(2, accountOrPhone);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapUser(rs);
                    user.setRoleCodes(findRoleCodes(connection, user.getUserId()));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return null;
    }

    public User findById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return null;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = mapUser(rs);
                    user.setRoleCodes(findRoleCodes(connection, user.getUserId()));
                    return user;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return null;
    }

    public void updateLastLoginTime(Connection connection, int userId) throws SQLException {
        String sql = "UPDATE users SET last_login_time = NOW() WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    public List<String> findRoleCodes(int userId) {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return new ArrayList<String>();
        }
        try {
            return findRoleCodes(connection, userId);
        } catch (SQLException e) {
            e.printStackTrace();
            return new ArrayList<String>();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private List<String> findRoleCodes(Connection connection, int userId) throws SQLException {
        String sql = "SELECT r.role_code FROM user_roles ur JOIN roles r ON ur.role_id = r.role_id WHERE ur.user_id = ?";
        List<String> roleCodes = new ArrayList<String>();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    roleCodes.add(rs.getString("role_code"));
                }
            }
        }
        return roleCodes;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUserNo(rs.getString("user_no"));
        user.setUsername(rs.getString("username"));
        user.setRealName(rs.getString("real_name"));
        user.setIdCardHash(rs.getString("id_card_hash"));
        user.setIdCardMasked(rs.getString("id_card_masked"));
        user.setPhone(rs.getString("phone"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setPasswordSalt(rs.getString("password_salt"));
        user.setStatus(rs.getString("status"));
        user.setRegisterTime(rs.getTimestamp("register_time"));
        user.setLastLoginTime(rs.getTimestamp("last_login_time"));
        return user;
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("The current JRE does not support SHA-256.", e);
        }
    }
}
