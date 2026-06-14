package banksystem.dao;

import banksystem.model.TransactionRiskScore;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class TransactionRiskScoreDao {
    public void add(Connection connection, TransactionRiskScore score) throws SQLException {
        String sql = "INSERT INTO transaction_risk_scores(transaction_id, risk_score, risk_level, risk_reason, rule_hit_count, create_time) "
                + "VALUES (?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, score.getTransactionId());
            ps.setInt(2, score.getRiskScore());
            ps.setString(3, score.getRiskLevel());
            ps.setString(4, score.getRiskReason());
            ps.setInt(5, score.getRuleHitCount());
            ps.executeUpdate();
        }
    }

    public TransactionRiskScore findByTransactionId(int transactionId) {
        String sql = "SELECT * FROM transaction_risk_scores WHERE transaction_id = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return null;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TransactionRiskScore score = new TransactionRiskScore();
                    score.setRiskId(rs.getInt("risk_id"));
                    score.setTransactionId(rs.getInt("transaction_id"));
                    score.setRiskScore(rs.getInt("risk_score"));
                    score.setRiskLevel(rs.getString("risk_level"));
                    score.setRiskReason(rs.getString("risk_reason"));
                    score.setRuleHitCount(rs.getInt("rule_hit_count"));
                    score.setCreateTime(rs.getTimestamp("create_time"));
                    return score;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return null;
    }

    public List<TransactionRiskScore> findVisible(int userId, boolean admin) {
        List<TransactionRiskScore> rows = new ArrayList<TransactionRiskScore>();
        String sql = admin
                ? "SELECT trs.* FROM transaction_risk_scores trs ORDER BY trs.create_time DESC, trs.risk_id DESC"
                : "SELECT trs.* FROM transaction_risk_scores trs "
                + "JOIN transactions t ON trs.transaction_id = t.transaction_id "
                + "WHERE t.user_id = ? ORDER BY trs.create_time DESC, trs.risk_id DESC";
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
                    TransactionRiskScore score = new TransactionRiskScore();
                    score.setRiskId(rs.getInt("risk_id"));
                    score.setTransactionId(rs.getInt("transaction_id"));
                    score.setRiskScore(rs.getInt("risk_score"));
                    score.setRiskLevel(rs.getString("risk_level"));
                    score.setRiskReason(rs.getString("risk_reason"));
                    score.setRuleHitCount(rs.getInt("rule_hit_count"));
                    score.setCreateTime(rs.getTimestamp("create_time"));
                    rows.add(score);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }
}
