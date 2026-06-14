package banksystem.dao;

import banksystem.model.AccountStatusHistory;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AccountStatusHistoryDao {
    public List<AccountStatusHistory> findAll() {
        List<AccountStatusHistory> rows = new ArrayList<AccountStatusHistory>();
        String sql = "SELECT * FROM account_status_histories ORDER BY history_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    public void add(Connection connection, AccountStatusHistory history) throws SQLException {
        String sql = "INSERT INTO account_status_histories(account_id, old_status, new_status, change_reason, changed_by, change_time) "
                + "VALUES (?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, history.getAccountId());
            ps.setString(2, history.getOldStatus());
            ps.setString(3, history.getNewStatus());
            ps.setString(4, history.getChangeReason());
            ps.setInt(5, history.getChangedBy());
            ps.executeUpdate();
        }
    }

    public List<AccountStatusHistory> findRecentByUserId(int userId, int limit) {
        List<AccountStatusHistory> rows = new ArrayList<AccountStatusHistory>();
        String sql = "SELECT h.* FROM account_status_histories h "
                + "JOIN accounts a ON h.account_id = a.account_id "
                + "WHERE a.user_id = ? ORDER BY h.change_time DESC, h.history_id DESC LIMIT ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    private AccountStatusHistory mapRow(ResultSet rs) throws SQLException {
        AccountStatusHistory row = new AccountStatusHistory();
        row.setHistoryId(rs.getInt("history_id"));
        row.setAccountId(rs.getInt("account_id"));
        row.setOldStatus(rs.getString("old_status"));
        row.setNewStatus(rs.getString("new_status"));
        row.setChangeReason(rs.getString("change_reason"));
        row.setChangedBy(rs.getInt("changed_by"));
        row.setChangeTime(rs.getTimestamp("change_time"));
        return row;
    }
}
