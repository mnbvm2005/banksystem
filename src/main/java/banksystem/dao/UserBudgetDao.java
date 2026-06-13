package banksystem.dao;

import banksystem.model.UserBudget;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UserBudgetDao {
    public List<UserBudget> findCurrentMonthByUserId(int userId) {
        String sql = "SELECT * FROM user_budgets WHERE user_id = ? AND budget_month = DATE_FORMAT(CURDATE(), '%Y-%m') ORDER BY category_id";
        List<UserBudget> budgets = new ArrayList<UserBudget>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return budgets;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserBudget budget = new UserBudget();
                    budget.setBudgetId(rs.getInt("budget_id"));
                    budget.setUserId(rs.getInt("user_id"));
                    budget.setCategoryId(rs.getInt("category_id"));
                    budget.setBudgetMonth(rs.getString("budget_month"));
                    budget.setBudgetAmount(rs.getBigDecimal("budget_amount"));
                    budget.setUsedAmount(rs.getBigDecimal("used_amount"));
                    budget.setWarningThreshold(rs.getBigDecimal("warning_threshold"));
                    budget.setCreateTime(rs.getTimestamp("create_time"));
                    budgets.add(budget);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return budgets;
    }
}
