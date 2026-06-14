package banksystem.dao;

import banksystem.model.User;
import banksystem.sqloperation.GetMySQLConnection;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDao {
    private static final SecureRandom RANDOM = new SecureRandom();

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

    public User createCustomer(Connection connection, String username, String realName, String phone,
                               String email, String password) throws SQLException {
        String salt = "SALT_" + Long.toHexString(System.nanoTime()).toUpperCase();
        String userNo = "U" + System.currentTimeMillis();
        String passwordHash = sha256(password + salt);
        String sql = "INSERT INTO users(user_no, username, real_name, id_card_hash, id_card_masked, phone, email, "
                + "password_hash, password_salt, status, register_time, last_login_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'NORMAL', NOW(), NULL)";
        int userId;
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, userNo);
            ps.setString(2, username);
            ps.setString(3, realName);
            ps.setString(4, sha256(username + phone));
            ps.setString(5, "Not provided");
            ps.setString(6, phone);
            ps.setString(7, email);
            ps.setString(8, passwordHash);
            ps.setString(9, salt);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (!keys.next()) {
                    throw new SQLException("Failed to read generated user id.");
                }
                userId = keys.getInt(1);
            }
        }

        assignCustomerRole(connection, userId);
        createDefaultAccount(connection, userId);
        User user = findById(connection, userId);
        user.setRoleCodes(findRoleCodes(connection, userId));
        return user;
    }

    public User findById(Connection connection, int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }
        return null;
    }

    public boolean existsByUsernameOrPhone(String username, String phone) {
        String sql = "SELECT 1 FROM users WHERE username = ? OR phone = ? LIMIT 1";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return true;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, phone);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        } finally {
            GetMySQLConnection.closeConnection(connection);
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

    private void assignCustomerRole(Connection connection, int userId) throws SQLException {
        String sql = "INSERT INTO user_roles(user_id, role_id) "
                + "SELECT ?, role_id FROM roles WHERE role_code = 'CUSTOMER' LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }

    private void createDefaultAccount(Connection connection, int userId) throws SQLException {
        String accountNo = "6222" + String.format("%010d", Math.abs(RANDOM.nextInt(1000000000))) + String.format("%04d", userId % 10000);
        String sql = "INSERT INTO accounts(user_id, branch_id, account_no, account_type, currency, balance, "
                + "available_balance, frozen_amount, status, open_time) "
                + "VALUES (?, (SELECT branch_id FROM bank_branches ORDER BY branch_id LIMIT 1), ?, 'SAVING', 'CNY', "
                + "0.00, 0.00, 0.00, 'NORMAL', NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, accountNo);
            ps.executeUpdate();
        }
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
