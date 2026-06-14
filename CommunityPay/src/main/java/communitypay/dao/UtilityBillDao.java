package communitypay.dao;

import communitypay.model.UtilityBill;
import communitypay.util.CommunityDb;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class UtilityBillDao {
    public List<UtilityBill> findAll() {
        List<UtilityBill> bills = new ArrayList<UtilityBill>();
        String sql = "SELECT * FROM utility_bills ORDER BY FIELD(status, 'UNPAID', 'PAYING', 'OVERDUE', 'FAILED', 'PAID'), bill_id";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) bills.add(map(rs));
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
        return bills;
    }

    public List<UtilityBill> findByResidentNo(String residentNo) {
        List<UtilityBill> bills = new ArrayList<UtilityBill>();
        String sql = "SELECT * FROM utility_bills WHERE resident_no = ? "
                + "ORDER BY FIELD(status, 'UNPAID', 'FAILED', 'PAYING', 'OVERDUE', 'PAID'), due_date, bill_id";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, residentNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) bills.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
        return bills;
    }

    public List<UtilityBill> findRecordsByResidentNo(String residentNo) {
        List<UtilityBill> bills = new ArrayList<UtilityBill>();
        String sql = "SELECT * FROM utility_bills WHERE resident_no = ? AND status IN ('PAID', 'FAILED', 'PAYING') "
                + "ORDER BY COALESCE(paid_time, create_time) DESC, bill_id DESC";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, residentNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) bills.add(map(rs));
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
        return bills;
    }

    public UtilityBill findByBillNo(String billNo) {
        String sql = "SELECT * FROM utility_bills WHERE bill_no = ?";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, billNo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
    }

    public UtilityBill findByBillNoAndResidentNo(String billNo, String residentNo) {
        String sql = "SELECT * FROM utility_bills WHERE bill_no = ? AND resident_no = ?";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, billNo);
            ps.setString(2, residentNo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
    }

    public void markPaying(String billNo, String payToken) {
        String sql = "UPDATE utility_bills SET status = 'PAYING', bank_pay_token = ? WHERE bill_no = ?";
        update(sql, payToken, billNo);
    }

    public void markResult(String billNo, String status, Integer transactionId) {
        String sql = "UPDATE utility_bills SET status = ?, bank_transaction_id = ?, paid_time = CASE WHEN ? = 'PAID' THEN NOW() ELSE paid_time END WHERE bill_no = ?";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            if (transactionId == null) ps.setNull(2, java.sql.Types.INTEGER); else ps.setInt(2, transactionId);
            ps.setString(3, status);
            ps.setString(4, billNo);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
    }

    private void update(String sql, String first, String second) {
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, first);
            ps.setString(2, second);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
    }

    private UtilityBill map(ResultSet rs) throws SQLException {
        UtilityBill bill = new UtilityBill();
        bill.setBillId(rs.getInt("bill_id"));
        bill.setBillNo(rs.getString("bill_no"));
        bill.setResidentName(rs.getString("resident_name"));
        bill.setResidentNo(rs.getString("resident_no"));
        bill.setBillType(rs.getString("bill_type"));
        bill.setProviderName(rs.getString("provider_name"));
        bill.setCustomerNo(rs.getString("customer_no"));
        bill.setPeriod(rs.getString("period"));
        bill.setAmount(rs.getBigDecimal("amount"));
        bill.setDueDate(rs.getDate("due_date"));
        bill.setStatus(rs.getString("status"));
        bill.setBankPayToken(rs.getString("bank_pay_token"));
        int transactionId = rs.getInt("bank_transaction_id");
        bill.setBankTransactionId(rs.wasNull() ? null : Integer.valueOf(transactionId));
        return bill;
    }
}
