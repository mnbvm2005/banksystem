package banksystem.dao;

import banksystem.model.TransactionApproval;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

public class TransactionApprovalDao {
    public void add(Connection connection, TransactionApproval approval) throws SQLException {
        String sql = "INSERT INTO transaction_approvals "
                + "(transaction_id, approver_id, approval_status, approval_opinion, submit_time, approval_time) "
                + "VALUES (?, ?, ?, ?, NOW(), CASE WHEN ? IN ('APPROVED','REJECTED') THEN NOW() ELSE NULL END)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approval.getTransactionId());
            if (approval.getApproverId() == null) {
                ps.setNull(2, Types.INTEGER);
            } else {
                ps.setInt(2, approval.getApproverId());
            }
            ps.setString(3, approval.getApprovalStatus());
            ps.setString(4, approval.getApprovalComment());
            ps.setString(5, approval.getApprovalStatus());
            ps.executeUpdate();
        }
    }

    public List<TransactionApproval> findPending() {
        String sql = "SELECT * FROM transaction_approvals WHERE approval_status = 'PENDING' "
                + "ORDER BY submit_time DESC, approval_id DESC";
        List<TransactionApproval> approvals = new ArrayList<TransactionApproval>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return approvals;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TransactionApproval approval = new TransactionApproval();
                approval.setApprovalId(rs.getInt("approval_id"));
                approval.setTransactionId(rs.getInt("transaction_id"));
                int approverId = rs.getInt("approver_id");
                approval.setApproverId(rs.wasNull() ? null : approverId);
                approval.setApprovalStatus(rs.getString("approval_status"));
                approval.setApprovalComment(rs.getString("approval_opinion"));
                approval.setApprovalTime(rs.getTimestamp("submit_time"));
                approvals.add(approval);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return approvals;
    }

    public List<TransactionApproval> findAll() {
        String sql = "SELECT * FROM transaction_approvals ORDER BY submit_time DESC, approval_id DESC";
        List<TransactionApproval> approvals = new ArrayList<TransactionApproval>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return approvals;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TransactionApproval approval = new TransactionApproval();
                approval.setApprovalId(rs.getInt("approval_id"));
                approval.setTransactionId(rs.getInt("transaction_id"));
                int approverId = rs.getInt("approver_id");
                approval.setApproverId(rs.wasNull() ? null : approverId);
                approval.setApprovalStatus(rs.getString("approval_status"));
                approval.setApprovalComment(rs.getString("approval_opinion"));
                approval.setApprovalTime(rs.getTimestamp("submit_time"));
                approvals.add(approval);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return approvals;
    }

    public void updateStatus(Connection connection, int approvalId, int approverId,
                             String status, String comment) throws SQLException {
        String sql = "UPDATE transaction_approvals "
                + "SET approver_id = ?, approval_status = ?, approval_opinion = ?, approval_time = NOW() "
                + "WHERE approval_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, approverId);
            ps.setString(2, status);
            ps.setString(3, comment);
            ps.setInt(4, approvalId);
            ps.executeUpdate();
        }
    }
}
