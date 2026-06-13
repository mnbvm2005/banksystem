package banksystem.dao;

import banksystem.model.PaymentRecord;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class PaymentRecordDao {
    public void add(Connection connection, PaymentRecord record) throws SQLException {
        String sql = "INSERT INTO payment_records "
                + "(transaction_id, account_id, payment_type, customer_no, provider_name, amount, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, record.getTransactionId());
            ps.setInt(2, record.getAccountId());
            ps.setString(3, record.getPaymentType());
            ps.setString(4, record.getPaymentNo());
            ps.setString(5, record.getServiceProvider());
            ps.setBigDecimal(6, record.getPaymentAmount());
            ps.setString(7, record.getPaymentStatus());
            ps.executeUpdate();
        }
    }
}
