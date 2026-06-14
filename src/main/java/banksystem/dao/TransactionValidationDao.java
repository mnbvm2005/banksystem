package banksystem.dao;

import banksystem.model.TransactionValidation;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

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

    public List<TransactionValidation> findAll() {
        List<TransactionValidation> rows = new ArrayList<TransactionValidation>();
        String sql = "SELECT * FROM transaction_validations ORDER BY validation_time DESC, validation_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                TransactionValidation row = new TransactionValidation();
                row.setValidationId(rs.getInt("validation_id"));
                int transactionId = rs.getInt("transaction_id");
                row.setTransactionId(rs.wasNull() ? null : Integer.valueOf(transactionId));
                row.setAccountStatusValid(rs.getInt("account_status_ok") == 1);
                row.setBalanceSufficient(rs.getInt("balance_ok") == 1);
                row.setAmountValid(rs.getInt("amount_ok") == 1);
                row.setTargetAccountValid(rs.getInt("limit_ok") == 1);
                row.setValidationResult(rs.getString("validation_result"));
                row.setRejectReason(rs.getString("fail_reason"));
                row.setValidationTime(rs.getTimestamp("validation_time"));
                rows.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }
}
