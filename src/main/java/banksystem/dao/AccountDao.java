package banksystem.dao;

import banksystem.model.Account;
import banksystem.sqloperation.GetMySQLConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AccountDao {
    public List<Account> findByUserId(int userId) {
        String sql = "SELECT * FROM v_user_account_overview WHERE user_id = ? ORDER BY account_id";
        List<Account> accounts = new ArrayList<Account>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return accounts;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    accounts.add(mapOverview(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return accounts;
    }

    public List<Account> findAll() {
        String sql = "SELECT * FROM accounts ORDER BY account_id";
        List<Account> accounts = new ArrayList<Account>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return accounts;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                accounts.add(mapAccount(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return accounts;
    }

    public Account findMainAccountByUserId(int userId) {
        String sql = "SELECT * FROM accounts WHERE user_id = ? AND status = 'NORMAL' ORDER BY account_id LIMIT 1";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return null;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAccount(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return null;
    }

    public Account findByIdForUpdate(Connection connection, int id) throws SQLException {
        String sql = "SELECT * FROM accounts WHERE account_id = ? FOR UPDATE";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAccount(rs);
                }
            }
        }
        return null;
    }

    public Account findByIdAndUserIdForUpdate(Connection connection, int id, int userId) throws SQLException {
        String sql = "SELECT * FROM accounts WHERE account_id = ? AND user_id = ? FOR UPDATE";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAccount(rs);
                }
            }
        }
        return null;
    }

    public Account findByAccountNoForUpdate(Connection connection, String accountNo) throws SQLException {
        String sql = "SELECT * FROM accounts WHERE account_no = ? FOR UPDATE";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, accountNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapAccount(rs);
                }
            }
        }
        return null;
    }

    public boolean updateBalance(Connection connection, int accountId, BigDecimal balance) throws SQLException {
        String sql = "UPDATE accounts SET balance = ?, available_balance = ? WHERE account_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setBigDecimal(1, balance);
            ps.setBigDecimal(2, balance);
            ps.setInt(3, accountId);
            return ps.executeUpdate() == 1;
        }
    }

    public boolean updateStatus(Connection connection, int accountId, String status) throws SQLException {
        String sql = "UPDATE accounts SET status = ? WHERE account_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, accountId);
            return ps.executeUpdate() == 1;
        }
    }

    private Account mapOverview(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setAccountId(rs.getInt("account_id"));
        account.setUserId(rs.getInt("user_id"));
        account.setAccountNo(rs.getString("account_no"));
        account.setAccountType(rs.getString("account_type"));
        account.setCurrency(rs.getString("currency"));
        account.setBalance(rs.getBigDecimal("balance"));
        account.setAvailableBalance(rs.getBigDecimal("available_balance"));
        account.setFrozenAmount(rs.getBigDecimal("frozen_amount"));
        account.setStatus(rs.getString("account_status"));
        account.setBranchName(rs.getString("branch_name"));
        return account;
    }

    private Account mapAccount(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setAccountId(rs.getInt("account_id"));
        account.setUserId(rs.getInt("user_id"));
        int branchId = rs.getInt("branch_id");
        account.setBranchId(rs.wasNull() ? null : branchId);
        account.setAccountNo(rs.getString("account_no"));
        account.setAccountType(rs.getString("account_type"));
        account.setCurrency(rs.getString("currency"));
        account.setBalance(rs.getBigDecimal("balance"));
        account.setAvailableBalance(rs.getBigDecimal("available_balance"));
        account.setFrozenAmount(rs.getBigDecimal("frozen_amount"));
        account.setStatus(rs.getString("status"));
        account.setOpenTime(rs.getTimestamp("open_time"));
        return account;
    }
}
