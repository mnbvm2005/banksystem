package banksystem.dao;

import banksystem.model.FinancialProduct;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class FinancialProductDao {
    public List<FinancialProduct> findAllAvailable() {
        String sql = "SELECT * FROM financial_products WHERE status = 'ON_SALE' ORDER BY product_id";
        List<FinancialProduct> products = new ArrayList<FinancialProduct>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return products;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                products.add(mapProduct(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }

        return products;
    }

    private FinancialProduct mapProduct(ResultSet rs) throws SQLException {
        FinancialProduct product = new FinancialProduct();
        product.setId(rs.getInt("product_id"));
        product.setProductCode(rs.getString("product_code"));
        product.setProductName(rs.getString("product_name"));
        product.setProductType(rs.getString("product_type"));
        product.setRiskLevel(rs.getString("risk_level"));
        product.setExpectedAnnualRate(rs.getBigDecimal("expected_rate"));
        product.setMinAmount(rs.getBigDecimal("min_amount"));
        product.setTermDays(rs.getInt("period_days"));
        product.setStatus("ON_SALE".equals(rs.getString("status")) ? 1 : 0);
        return product;
    }
}
