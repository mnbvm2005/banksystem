package banksystem.dao;

import banksystem.model.ExternalPaymentOrder;
import banksystem.model.MerchantApp;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class OpenPaymentDao {
    public MerchantApp findMerchantByAccessKey(String accessKey) {
        String sql = "SELECT * FROM merchant_apps WHERE access_key = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return null;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, accessKey);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    MerchantApp merchant = new MerchantApp();
                    merchant.setMerchantId(rs.getInt("merchant_id"));
                    merchant.setMerchantName(rs.getString("merchant_name"));
                    merchant.setAccessKey(rs.getString("access_key"));
                    merchant.setSecretKey(rs.getString("secret_key"));
                    merchant.setStatus(rs.getString("status"));
                    return merchant;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return null;
    }

    public boolean nonceExists(String accessKey, String nonce) {
        String sql = "SELECT 1 FROM api_request_logs WHERE access_key = ? AND request_nonce = ? LIMIT 1";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return true;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, accessKey);
            ps.setString(2, nonce);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return true;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public void addApiLog(String accessKey, String method, String path, String nonce, long timestamp,
                          String bodyHash, String verifyResult, String responseCode, String errorMessage) {
        String sql = "INSERT IGNORE INTO api_request_logs(access_key, request_method, request_path, request_nonce, "
                + "request_timestamp, request_body_hash, verify_result, response_code, error_message, create_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return;
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, accessKey);
            ps.setString(2, method);
            ps.setString(3, path);
            ps.setString(4, nonce);
            ps.setLong(5, timestamp);
            ps.setString(6, bodyHash);
            ps.setString(7, verifyResult);
            ps.setString(8, responseCode);
            ps.setString(9, errorMessage);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public ExternalPaymentOrder createOrFindOrder(ExternalPaymentOrder order) throws SQLException {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) throw new SQLException("Database connection failed.");
        try {
            ExternalPaymentOrder existing = findByBillNo(connection, order.getMerchantId(), order.getBillNo());
            if (existing != null) {
                if ("SUCCESS".equals(existing.getStatus())) {
                    order.setPayToken(generateToken());
                } else {
                updateOrderDetails(connection, existing.getOrderId(), order);
                existing = findByBillNo(connection, order.getMerchantId(), order.getBillNo());
                return existing;
                }
            }
            String sql = "INSERT INTO external_payment_orders(merchant_id, bill_no, pay_token, external_user_name, external_user_no, "
                    + "bank_login_account, bill_type, provider_name, customer_no, period, amount, subject, return_url, status, create_time) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'CREATED', NOW())";
            try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, order.getMerchantId());
                ps.setString(2, order.getBillNo());
                ps.setString(3, order.getPayToken());
                ps.setString(4, order.getExternalUserName());
                ps.setString(5, order.getExternalUserNo());
                ps.setString(6, order.getBankLoginAccount());
                ps.setString(7, order.getBillType());
                ps.setString(8, order.getProviderName());
                ps.setString(9, order.getCustomerNo());
                ps.setString(10, order.getPeriod());
                ps.setBigDecimal(11, order.getAmount());
                ps.setString(12, order.getSubject());
                ps.setString(13, order.getReturnUrl());
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) order.setOrderId(rs.getInt(1));
                }
            }
            order.setStatus("CREATED");
            return order;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public ExternalPaymentOrder findByToken(String payToken) {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return null;
        try {
            return findByToken(connection, payToken);
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public ExternalPaymentOrder findByBillNo(int merchantId, String billNo) {
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) return null;
        try {
            return findByBillNo(connection, merchantId, billNo);
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public void markSuccess(Connection connection, int orderId, int transactionId) throws SQLException {
        String sql = "UPDATE external_payment_orders SET status = 'SUCCESS', bank_transaction_id = ?, paid_time = NOW() WHERE order_id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, transactionId);
            ps.setInt(2, orderId);
            ps.executeUpdate();
        }
    }

    private void updateOrderDetails(Connection connection, int orderId, ExternalPaymentOrder order) throws SQLException {
        String sql = "UPDATE external_payment_orders SET external_user_name = ?, external_user_no = ?, bank_login_account = ?, "
                + "bill_type = ?, provider_name = ?, customer_no = ?, period = ?, amount = ?, subject = ?, return_url = ? "
                + "WHERE order_id = ? AND status <> 'SUCCESS'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, order.getExternalUserName());
            ps.setString(2, order.getExternalUserNo());
            ps.setString(3, order.getBankLoginAccount());
            ps.setString(4, order.getBillType());
            ps.setString(5, order.getProviderName());
            ps.setString(6, order.getCustomerNo());
            ps.setString(7, order.getPeriod());
            ps.setBigDecimal(8, order.getAmount());
            ps.setString(9, order.getSubject());
            ps.setString(10, order.getReturnUrl());
            ps.setInt(11, orderId);
            ps.executeUpdate();
        }
    }

    private ExternalPaymentOrder findByBillNo(Connection connection, int merchantId, String billNo) throws SQLException {
        String sql = "SELECT * FROM external_payment_orders WHERE merchant_id = ? AND bill_no = ? ORDER BY order_id DESC LIMIT 1";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            ps.setString(2, billNo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapOrder(rs) : null;
            }
        }
    }

    private String generateToken() {
        return "PT" + java.util.UUID.randomUUID().toString().replace("-", "");
    }

    private ExternalPaymentOrder findByToken(Connection connection, String payToken) throws SQLException {
        String sql = "SELECT * FROM external_payment_orders WHERE pay_token = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, payToken);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapOrder(rs) : null;
            }
        }
    }

    private ExternalPaymentOrder mapOrder(ResultSet rs) throws SQLException {
        ExternalPaymentOrder order = new ExternalPaymentOrder();
        order.setOrderId(rs.getInt("order_id"));
        order.setMerchantId(rs.getInt("merchant_id"));
        order.setBillNo(rs.getString("bill_no"));
        order.setPayToken(rs.getString("pay_token"));
        order.setExternalUserName(rs.getString("external_user_name"));
        order.setExternalUserNo(rs.getString("external_user_no"));
        order.setBankLoginAccount(rs.getString("bank_login_account"));
        order.setBillType(rs.getString("bill_type"));
        order.setProviderName(rs.getString("provider_name"));
        order.setCustomerNo(rs.getString("customer_no"));
        order.setPeriod(rs.getString("period"));
        order.setAmount(rs.getBigDecimal("amount"));
        order.setSubject(rs.getString("subject"));
        order.setReturnUrl(rs.getString("return_url"));
        order.setStatus(rs.getString("status"));
        int bankTransactionId = rs.getInt("bank_transaction_id");
        order.setBankTransactionId(rs.wasNull() ? null : Integer.valueOf(bankTransactionId));
        order.setCreateTime(rs.getTimestamp("create_time"));
        order.setPaidTime(rs.getTimestamp("paid_time"));
        return order;
    }
}
