package banksystem.dao;

import banksystem.model.InvestmentOrder;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class InvestmentOrderDao {
    public int add(Connection connection, InvestmentOrder order) throws SQLException {
        String sql = "INSERT INTO investment_orders "
                + "(order_no, user_id, account_id, product_id, order_type, amount, status, order_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, order.getOrderNo());
            ps.setInt(2, order.getUserId());
            ps.setInt(3, order.getAccountId());
            ps.setInt(4, order.getProductId());
            ps.setString(5, order.getOrderType());
            ps.setBigDecimal(6, order.getOrderAmount());
            ps.setString(7, order.getOrderStatus());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }
}
