package banksystem.dao;

import banksystem.model.TransactionBlackBox;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class TransactionBlackBoxDao {
    public TransactionBlackBox findByTransactionId(int transactionId) {
        String sql = "SELECT * FROM v_transaction_black_box WHERE transaction_id = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return null;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, transactionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    TransactionBlackBox box = new TransactionBlackBox();
                    box.setTransactionId(rs.getInt("transaction_id"));
                    box.setTransactionNo(rs.getString("transaction_no"));
                    box.setUsername(rs.getString("username"));
                    box.setRealName(rs.getString("real_name"));
                    box.setTransactionType(rs.getString("transaction_type"));
                    box.setAmount(rs.getBigDecimal("amount"));
                    box.setTransactionStatus(rs.getString("transaction_status"));
                    box.setRiskLevel(rs.getString("risk_level"));
                    box.setNeedApproval(rs.getInt("need_approval") == 1);
                    box.setCreateTime(rs.getTimestamp("create_time"));
                    box.setLedgerTrace(rs.getString("ledger_trace"));
                    box.setValidationResult(rs.getString("validation_result"));
                    box.setRiskScore(rs.getInt("risk_score"));
                    box.setRiskReason(rs.getString("risk_reason"));
                    box.setApprovalStatus(rs.getString("approval_status"));
                    box.setOperationLogCount(rs.getInt("operation_log_count"));
                    return box;
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
