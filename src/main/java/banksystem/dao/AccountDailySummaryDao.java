package banksystem.dao;

import banksystem.model.AccountDailySummary;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AccountDailySummaryDao {
    public List<AccountDailySummary> findVisible(int userId, boolean admin) {
        List<AccountDailySummary> rows = new ArrayList<AccountDailySummary>();
        String sql = admin
                ? "SELECT ads.* FROM account_daily_summaries ads ORDER BY ads.summary_date DESC, ads.summary_id DESC"
                : "SELECT ads.* FROM account_daily_summaries ads "
                + "JOIN accounts a ON ads.account_id = a.account_id "
                + "WHERE a.user_id = ? ORDER BY ads.summary_date DESC, ads.summary_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (!admin) {
                ps.setInt(1, userId);
            }
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

    private AccountDailySummary mapRow(ResultSet rs) throws SQLException {
        AccountDailySummary row = new AccountDailySummary();
        row.setSummaryId(rs.getInt("summary_id"));
        row.setAccountId(rs.getInt("account_id"));
        row.setSummaryDate(rs.getDate("summary_date"));
        row.setOpeningBalance(rs.getBigDecimal("opening_balance"));
        row.setIncomeTotal(rs.getBigDecimal("income_total"));
        row.setExpenseTotal(rs.getBigDecimal("expense_total"));
        row.setClosingBalance(rs.getBigDecimal("closing_balance"));
        row.setTransactionCount(rs.getInt("transaction_count"));
        row.setCreateTime(rs.getTimestamp("create_time"));
        return row;
    }
}
