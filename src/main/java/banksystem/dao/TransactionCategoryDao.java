package banksystem.dao;

import banksystem.model.TransactionCategory;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransactionCategoryDao {
    public List<TransactionCategory> findAll() {
        List<TransactionCategory> rows = new ArrayList<TransactionCategory>();
        String sql = "SELECT * FROM transaction_categories ORDER BY category_id ASC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TransactionCategory row = new TransactionCategory();
                row.setCategoryId(rs.getInt("category_id"));
                row.setCategoryCode(rs.getString("category_code"));
                row.setCategoryName(rs.getString("category_name"));
                row.setIncomeExpenseType(rs.getString("income_expense_type"));
                row.setDescription(rs.getString("description"));
                rows.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    public void saveCategory(Integer categoryId, String categoryCode, String categoryName,
                             String incomeExpenseType, String description) throws SQLException {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try {
            if (categoryId == null) {
                String sql = "INSERT INTO transaction_categories(category_code, category_name, income_expense_type, description) VALUES (?, ?, ?, ?)";
                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setString(1, categoryCode);
                    ps.setString(2, categoryName);
                    ps.setString(3, incomeExpenseType);
                    ps.setString(4, description);
                    ps.executeUpdate();
                }
            } else {
                String sql = "UPDATE transaction_categories SET category_code = ?, category_name = ?, income_expense_type = ?, description = ? WHERE category_id = ?";
                try (PreparedStatement ps = connection.prepareStatement(sql)) {
                    ps.setString(1, categoryCode);
                    ps.setString(2, categoryName);
                    ps.setString(3, incomeExpenseType);
                    ps.setString(4, description);
                    ps.setInt(5, categoryId.intValue());
                    ps.executeUpdate();
                }
            }
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }
}
