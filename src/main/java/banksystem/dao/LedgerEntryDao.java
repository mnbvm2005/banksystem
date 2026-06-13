package banksystem.dao;

import banksystem.model.LedgerEntry;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class LedgerEntryDao {
    public int add(Connection connection, LedgerEntry entry) throws SQLException {
        String sql = "INSERT INTO ledger_entries "
                + "(transaction_id, account_id, direction, amount, balance_before, balance_after, category_id, summary, entry_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, entry.getTransactionId());
            ps.setInt(2, entry.getAccountId());
            ps.setString(3, entry.getDirection());
            ps.setBigDecimal(4, entry.getAmount());
            ps.setBigDecimal(5, entry.getBalanceBefore());
            ps.setBigDecimal(6, entry.getBalanceAfter());
            if (entry.getCategoryId() == null) {
                ps.setNull(7, java.sql.Types.INTEGER);
            } else {
                ps.setInt(7, entry.getCategoryId());
            }
            ps.setString(8, entry.getRemark());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<LedgerEntry> findByAccountId(int accountId) {
        String sql = "SELECT * FROM ledger_entries WHERE account_id = ? ORDER BY entry_time DESC, entry_id DESC";
        List<LedgerEntry> entries = new ArrayList<LedgerEntry>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return entries;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    entries.add(mapEntry(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return entries;
    }

    private LedgerEntry mapEntry(ResultSet rs) throws SQLException {
        LedgerEntry entry = new LedgerEntry();
        entry.setEntryId(rs.getInt("entry_id"));
        entry.setTransactionId(rs.getInt("transaction_id"));
        entry.setAccountId(rs.getInt("account_id"));
        entry.setDirection(rs.getString("direction"));
        entry.setAmount(rs.getBigDecimal("amount"));
        entry.setBalanceBefore(rs.getBigDecimal("balance_before"));
        entry.setBalanceAfter(rs.getBigDecimal("balance_after"));
        int categoryId = rs.getInt("category_id");
        entry.setCategoryId(rs.wasNull() ? null : categoryId);
        entry.setEntryTime(rs.getTimestamp("entry_time"));
        entry.setRemark(rs.getString("summary"));
        return entry;
    }
}
