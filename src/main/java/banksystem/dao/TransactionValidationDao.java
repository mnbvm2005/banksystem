package banksystem.dao;

import banksystem.model.TransactionValidation;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

public class TransactionValidationDao {
    public void add(Connection connection, TransactionValidation validation) throws SQLException {
        String sql = "INSERT INTO transaction_validations "
                + "(transaction_id, account_status_ok, balance_ok, amount_ok, limit_ok, validation_result, fail_reason, validation_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            setNullableInt(ps, 1, validation.getTransactionId());
            ps.setInt(2, validation.isAccountStatusValid() ? 1 : 0);
            ps.setInt(3, validation.isBalanceSufficient() ? 1 : 0);
            ps.setInt(4, validation.isAmountValid() ? 1 : 0);
            ps.setInt(5, validation.isTargetAccountValid() ? 1 : 0);
            ps.setString(6, validation.getValidationResult());
            ps.setString(7, validation.getRejectReason());
            ps.executeUpdate();
        }
    }

    private void setNullableInt(PreparedStatement ps, int index, Integer value) throws SQLException {
        if (value == null) {
            ps.setNull(index, Types.INTEGER);
        } else {
            ps.setInt(index, value);
        }
    }
}
