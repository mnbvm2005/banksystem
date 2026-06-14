package banksystem.dao;

import banksystem.model.Transaction;
import banksystem.sqloperation.GetMySQLConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class TransactionDao {
    public int countVisible(int userId, boolean admin) {
        String sql = admin ? "SELECT COUNT(*) FROM transactions" : "SELECT COUNT(*) FROM transactions WHERE user_id = ?";
        return queryInt(sql, admin ? null : Integer.valueOf(userId));
    }

    public int countPendingReview(int userId, boolean admin) {
        String sql = admin
                ? "SELECT COUNT(*) FROM transactions WHERE status IN ('PENDING','APPROVING')"
                : "SELECT COUNT(*) FROM transactions WHERE user_id = ? AND status IN ('PENDING','APPROVING')";
        return queryInt(sql, admin ? null : Integer.valueOf(userId));
    }

    public BigDecimal sumLedgerAmount(int userId, boolean admin, String direction) {
        String sql = "SELECT COALESCE(SUM(le.amount), 0) "
                + "FROM ledger_entries le "
                + "JOIN accounts a ON le.account_id = a.account_id "
                + (admin ? "WHERE le.direction = ? " : "WHERE le.direction = ? AND a.user_id = ? ");
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return BigDecimal.ZERO;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, direction);
            if (!admin) {
                ps.setInt(2, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BigDecimal value = rs.getBigDecimal(1);
                    return value == null ? BigDecimal.ZERO : value;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return BigDecimal.ZERO;
    }

    public List<Transaction> findByUserId(int userId) {
        return findByUserId(userId, false);
    }

    public List<Transaction> findByUserId(int userId, boolean admin) {
        String sql = "SELECT t.*, "
                + "MIN(CASE WHEN le.direction = 'OUT' THEN a.account_no END) AS from_account_no, "
                + "MIN(CASE WHEN le.direction = 'IN' THEN a.account_no END) AS to_account_no, "
                + "MAX(CASE WHEN le.account_id IN (SELECT account_id FROM accounts WHERE user_id = t.user_id) THEN le.balance_after END) AS balance_after "
                + "FROM transactions t "
                + "LEFT JOIN ledger_entries le ON t.transaction_id = le.transaction_id "
                + "LEFT JOIN accounts a ON le.account_id = a.account_id "
                + (admin ? "" : "WHERE t.user_id = ? ")
                + "GROUP BY t.transaction_id ORDER BY t.create_time DESC, t.transaction_id DESC";
        List<Transaction> transactions = new ArrayList<Transaction>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return transactions;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (!admin) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapTransaction(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return transactions;
    }

    public int add(Connection connection, Transaction transaction) throws SQLException {
        String sql = "INSERT INTO transactions "
                + "(transaction_no, user_id, transaction_type, amount, status, channel, risk_level, need_approval, description, create_time, finish_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), CASE WHEN ? = 'SUCCESS' THEN NOW() ELSE NULL END)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, transaction.getTransactionNo());
            ps.setInt(2, transaction.getUserId() > 0 ? transaction.getUserId() : resolveUserId(connection, transaction));
            ps.setString(3, normalizeType(transaction.getTransactionType()));
            ps.setBigDecimal(4, transaction.getAmount());
            String status = transaction.getStatus() == null ? "SUCCESS" : transaction.getStatus();
            ps.setString(5, status);
            ps.setString(6, transaction.getChannel() == null ? "WEB" : transaction.getChannel());
            ps.setString(7, transaction.getRiskLevel() == null ? "LOW" : transaction.getRiskLevel());
            ps.setInt(8, transaction.isNeedApproval() ? 1 : 0);
            ps.setString(9, transaction.getDescription());
            ps.setString(10, status);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private int resolveUserId(Connection connection, Transaction transaction) throws SQLException {
        Integer accountId = transaction.getFromAccountId() != null ? transaction.getFromAccountId() : transaction.getToAccountId();
        if (accountId == null) {
            throw new SQLException("transactions.user_id is missing and cannot be inferred from account data.");
        }
        String sql = "SELECT user_id FROM accounts WHERE account_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        }
        throw new SQLException("The account does not exist. Unable to create the transaction record.");
    }

    public void updateStatus(Connection connection, int transactionId, String status) throws SQLException {
        String sql = "UPDATE transactions SET status = ?, finish_time = CASE WHEN ? IN ('SUCCESS','FAILED','REJECTED') THEN NOW() ELSE finish_time END WHERE transaction_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setInt(3, transactionId);
            ps.executeUpdate();
        }
    }

    private String normalizeType(String type) {
        if ("TRANSFER_OUT".equals(type) || "TRANSFER_IN".equals(type)) {
            return "TRANSFER";
        }
        return type;
    }

    private int queryInt(String sql, Integer userId) {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return 0;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (userId != null) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return 0;
    }

    private Integer getNullableInt(ResultSet rs, String columnName) throws SQLException {
        try {
            int value = rs.getInt(columnName);
            return rs.wasNull() ? null : value;
        } catch (SQLException e) {
            return null;
        }
    }

    private Transaction mapTransaction(ResultSet rs) throws SQLException {
        Transaction transaction = new Transaction();
        transaction.setTransactionId(rs.getInt("transaction_id"));
        transaction.setTransactionNo(rs.getString("transaction_no"));
        transaction.setUserId(rs.getInt("user_id"));
        transaction.setFromAccountId(getNullableInt(rs, "from_account_id"));
        transaction.setToAccountId(getNullableInt(rs, "to_account_id"));
        transaction.setFromAccountNo(safeString(rs, "from_account_no"));
        transaction.setToAccountNo(safeString(rs, "to_account_no"));
        transaction.setTransactionType(rs.getString("transaction_type"));
        transaction.setAmount(rs.getBigDecimal("amount"));
        transaction.setStatus(rs.getString("status"));
        transaction.setChannel(rs.getString("channel"));
        transaction.setRiskLevel(rs.getString("risk_level"));
        transaction.setNeedApproval(rs.getInt("need_approval") == 1);
        transaction.setBalanceAfter(rs.getBigDecimal("balance_after"));
        transaction.setDescription(rs.getString("description"));
        transaction.setCreateTime(rs.getTimestamp("create_time"));
        transaction.setFinishTime(rs.getTimestamp("finish_time"));
        return transaction;
    }

    private String safeString(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (SQLException e) {
            return null;
        }
    }
}
