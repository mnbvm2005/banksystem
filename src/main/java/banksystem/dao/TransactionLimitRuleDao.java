package banksystem.dao;

import banksystem.model.TransactionLimitRule;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

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

    public List<TransactionLimitRule> findAllActive() {
        List<TransactionLimitRule> rows = new ArrayList<TransactionLimitRule>();
        String sql = "SELECT * FROM transaction_limit_rules WHERE status = 'ACTIVE' ORDER BY transaction_type, rule_id";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TransactionLimitRule rule = new TransactionLimitRule();
                rule.setRuleId(rs.getInt("rule_id"));
                rule.setRoleId(rs.getInt("role_id"));
                rule.setTransactionType(rs.getString("transaction_type"));
                rule.setSingleLimit(rs.getBigDecimal("single_limit"));
                rule.setDailyLimit(rs.getBigDecimal("daily_limit"));
                rule.setApprovalThreshold(rs.getBigDecimal("approval_threshold"));
                rule.setStatus(rs.getString("status"));
                rule.setCreateTime(rs.getTimestamp("create_time"));
                rows.add(rule);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    public void saveRule(int roleId, String transactionType, java.math.BigDecimal singleLimit,
                         java.math.BigDecimal dailyLimit, java.math.BigDecimal approvalThreshold) throws SQLException {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try {
            int existingRuleId = 0;
            try (PreparedStatement findPs = connection.prepareStatement(
                    "SELECT rule_id FROM transaction_limit_rules WHERE role_id = ? AND transaction_type = ? ORDER BY rule_id DESC LIMIT 1")) {
                findPs.setInt(1, roleId);
                findPs.setString(2, transactionType);
                try (ResultSet rs = findPs.executeQuery()) {
                    if (rs.next()) {
                        existingRuleId = rs.getInt("rule_id");
                    }
                }
            }
            if (existingRuleId > 0) {
                try (PreparedStatement updatePs = connection.prepareStatement(
                        "UPDATE transaction_limit_rules SET single_limit = ?, daily_limit = ?, approval_threshold = ?, status = 'ACTIVE' WHERE rule_id = ?")) {
                    updatePs.setBigDecimal(1, singleLimit);
                    updatePs.setBigDecimal(2, dailyLimit);
                    updatePs.setBigDecimal(3, approvalThreshold);
                    updatePs.setInt(4, existingRuleId);
                    updatePs.executeUpdate();
                }
            } else {
                try (PreparedStatement insertPs = connection.prepareStatement(
                        "INSERT INTO transaction_limit_rules(role_id, transaction_type, single_limit, daily_limit, approval_threshold, status, create_time) VALUES (?, ?, ?, ?, ?, 'ACTIVE', NOW())")) {
                    insertPs.setInt(1, roleId);
                    insertPs.setString(2, transactionType);
                    insertPs.setBigDecimal(3, singleLimit);
                    insertPs.setBigDecimal(4, dailyLimit);
                    insertPs.setBigDecimal(5, approvalThreshold);
                    insertPs.executeUpdate();
                }
            }
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }
}
