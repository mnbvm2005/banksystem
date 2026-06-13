package banksystem.dao;

import banksystem.model.Payee;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PayeeDao {
    public List<Payee> findByUserId(int userId) {
        String sql = "SELECT * FROM payees WHERE user_id = ? ORDER BY last_transfer_time DESC, payee_id DESC";
        List<Payee> payees = new ArrayList<Payee>();
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return payees;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) payees.add(mapPayee(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return payees;
    }

    public Payee findByUserIdAndAccountNo(int userId, String accountNo) {
        String sql = "SELECT * FROM payees WHERE user_id = ? AND payee_account_no = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return null;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, accountNo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapPayee(rs) : null;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public void save(Connection connection, Payee payee) throws SQLException {
        String sql = "INSERT INTO payees(user_id, payee_name, payee_account_no, payee_bank_name, verified_status, last_transfer_time, create_time) "
                + "VALUES (?, ?, ?, ?, ?, NOW(), NOW()) "
                + "ON DUPLICATE KEY UPDATE payee_name = VALUES(payee_name), payee_bank_name = VALUES(payee_bank_name), last_transfer_time = NOW()";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, payee.getUserId());
            ps.setString(2, payee.getPayeeName());
            ps.setString(3, payee.getPayeeAccountNo());
            ps.setString(4, payee.getPayeeBankName());
            ps.setString(5, payee.getVerifiedStatus() == null ? "UNVERIFIED" : payee.getVerifiedStatus());
            ps.executeUpdate();
        }
    }

    private Payee mapPayee(ResultSet rs) throws SQLException {
        Payee payee = new Payee();
        payee.setPayeeId(rs.getInt("payee_id"));
        payee.setUserId(rs.getInt("user_id"));
        payee.setPayeeName(rs.getString("payee_name"));
        payee.setPayeeAccountNo(rs.getString("payee_account_no"));
        payee.setPayeeBankName(rs.getString("payee_bank_name"));
        payee.setVerifiedStatus(rs.getString("verified_status"));
        payee.setLastTransferTime(rs.getTimestamp("last_transfer_time"));
        payee.setCreateTime(rs.getTimestamp("create_time"));
        return payee;
    }
}
