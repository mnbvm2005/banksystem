package banksystem.dao;

import banksystem.model.InvestmentHolding;
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

public class InvestmentHoldingDao {
    public int add(Connection connection, InvestmentHolding holding) throws SQLException {
        String sql = "INSERT INTO investment_holdings "
                + "(user_id, account_id, product_id, order_id, holding_amount, profit_amount, "
                + "holding_status, buy_time) VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, holding.getUserId());
            ps.setInt(2, holding.getAccountId());
            ps.setInt(3, holding.getProductId());
            if (holding.getOrderId() == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, holding.getOrderId());
            }
            ps.setBigDecimal(5, holding.getHoldingAmount());
            ps.setBigDecimal(6, holding.getCurrentIncome() == null ? BigDecimal.ZERO : holding.getCurrentIncome());
            ps.setString(7, holding.getHoldingStatus());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<InvestmentHolding> findByUserId(int userId) {
        String sql = "SELECT h.*, p.product_name FROM investment_holdings h "
                + "LEFT JOIN financial_products p ON h.product_id = p.product_id "
                + "WHERE h.user_id = ? ORDER BY h.buy_time DESC, h.holding_id DESC";
        List<InvestmentHolding> holdings = new ArrayList<InvestmentHolding>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return holdings;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    InvestmentHolding holding = new InvestmentHolding();
                    holding.setHoldingId(rs.getInt("holding_id"));
                    holding.setUserId(rs.getInt("user_id"));
                    holding.setAccountId(rs.getInt("account_id"));
                    holding.setProductId(rs.getInt("product_id"));
                    int orderId = rs.getInt("order_id");
                    holding.setOrderId(rs.wasNull() ? null : orderId);
                    holding.setHoldingAmount(rs.getBigDecimal("holding_amount"));
                    holding.setCurrentIncome(rs.getBigDecimal("profit_amount"));
                    holding.setHoldingStatus(rs.getString("holding_status"));
                    holding.setPurchaseTime(rs.getTimestamp("buy_time"));
                    holding.setProductName(rs.getString("product_name"));
                    holdings.add(holding);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return holdings;
    }
}
