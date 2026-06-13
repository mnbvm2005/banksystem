package banksystem.dao;

import banksystem.model.TransactionLimitRule;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TransactionLimitRuleDao {
    public TransactionLimitRule findActiveRule(String roleCode, String transactionType) {
        String sql = "SELECT tlr.* FROM transaction_limit_rules tlr "
                + "LEFT JOIN roles r ON tlr.role_id = r.role_id "
                + "WHERE tlr.transaction_type = ? AND tlr.status = 'ACTIVE' "
                + "AND (r.role_code = ? OR tlr.role_id IS NULL) "
                + "ORDER BY CASE WHEN r.role_code = ? THEN 0 ELSE 1 END LIMIT 1";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return null;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, transactionType);
            ps.setString(2, roleCode);
            ps.setString(3, roleCode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TransactionLimitRule rule = new TransactionLimitRule();
                    rule.setRuleId(rs.getInt("rule_id"));
                    rule.setRoleId(rs.getInt("role_id"));
                    rule.setTransactionType(rs.getString("transaction_type"));
                    rule.setSingleLimit(rs.getBigDecimal("single_limit"));
                    rule.setDailyLimit(rs.getBigDecimal("daily_limit"));
                    rule.setApprovalThreshold(rs.getBigDecimal("approval_threshold"));
                    rule.setStatus(rs.getString("status"));
                    rule.setCreateTime(rs.getTimestamp("create_time"));
                    return rule;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return null;
    }
}
