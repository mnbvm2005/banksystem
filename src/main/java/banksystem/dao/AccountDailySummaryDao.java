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
    public List<AccountDailySummary> findAll() {
        List<AccountDailySummary> rows = new ArrayList<AccountDailySummary>();
        String sql = "SELECT * FROM account_daily_summaries ORDER BY summary_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                rows.add(new AccountDailySummary());
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }
}
