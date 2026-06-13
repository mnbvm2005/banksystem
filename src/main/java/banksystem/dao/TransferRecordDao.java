package banksystem.dao;

import banksystem.model.TransferRecord;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class TransferRecordDao {
    public void add(Connection connection, TransferRecord record) throws SQLException {
        String sql = "INSERT INTO transfer_records "
                + "(transaction_id, from_account_id, to_account_id, to_account_no, to_name, to_bank_name, transfer_type, is_new_payee, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, record.getTransactionId());
            ps.setInt(2, record.getFromAccountId());
            if (record.getToAccountId() == null) {
                ps.setNull(3, java.sql.Types.INTEGER);
            } else {
                ps.setInt(3, record.getToAccountId());
            }
            ps.setString(4, record.getPayeeAccountNo());
            ps.setString(5, record.getPayeeName());
            ps.setString(6, record.getToBankName());
            ps.setString(7, record.getTransferType());
            ps.setInt(8, record.isNewPayee() ? 1 : 0);
            ps.setString(9, record.getTransferStatus());
            ps.executeUpdate();
        }
    }
}
