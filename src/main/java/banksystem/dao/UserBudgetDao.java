package banksystem.dao;

import banksystem.model.UserBudget;
import banksystem.sqloperation.GetMySQLConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserBudgetDao {
    public List<UserBudget> findByUserIdAndMonth(int userId, String month) {
        String sql = "SELECT * FROM user_budgets WHERE user_id = ? AND budget_month = ? ORDER BY category_id";
        List<UserBudget> budgets = new ArrayList<UserBudget>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return budgets;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, month);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    budgets.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return budgets;
    }

    public List<UserBudget> findCurrentMonthByUserId(int userId) {
        String sql = "SELECT * FROM user_budgets WHERE user_id = ? AND budget_month = DATE_FORMAT(CURDATE(), '%Y-%m') ORDER BY category_id";
        List<UserBudget> budgets = new ArrayList<UserBudget>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return budgets;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    budgets.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return budgets;
    }

    public void upsertBudget(int userId, int categoryId, String budgetMonth,
                             BigDecimal budgetAmount, BigDecimal warningThreshold) throws SQLException {
        String sql = "INSERT INTO user_budgets(user_id, category_id, budget_month, budget_amount, used_amount, warning_threshold, create_time) "
                + "VALUES (?, ?, ?, ?, 0.00, ?, NOW()) "
                + "ON DUPLICATE KEY UPDATE budget_amount = VALUES(budget_amount), warning_threshold = VALUES(warning_threshold)";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, categoryId);
            ps.setString(3, budgetMonth);
            ps.setBigDecimal(4, budgetAmount);
            ps.setBigDecimal(5, warningThreshold);
            ps.executeUpdate();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private UserBudget mapRow(ResultSet rs) throws SQLException {
        UserBudget budget = new UserBudget();
        budget.setBudgetId(rs.getInt("budget_id"));
        budget.setUserId(rs.getInt("user_id"));
        budget.setCategoryId(rs.getInt("category_id"));
        budget.setBudgetMonth(rs.getString("budget_month"));
        budget.setBudgetAmount(rs.getBigDecimal("budget_amount"));
        budget.setUsedAmount(rs.getBigDecimal("used_amount"));
        budget.setWarningThreshold(rs.getBigDecimal("warning_threshold"));
        budget.setCreateTime(rs.getTimestamp("create_time"));
        return budget;
    }
}
