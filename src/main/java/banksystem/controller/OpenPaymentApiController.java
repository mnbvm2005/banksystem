package banksystem.controller;

import banksystem.dao.OpenPaymentDao;
import banksystem.model.ExternalPaymentOrder;
import banksystem.model.MerchantApp;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class OpenPaymentApiController extends BaseController {
    private final OpenPaymentDao openPaymentDao = new OpenPaymentDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();
        String body = readBody(request);
        ApiAuthResult auth = verify(request, "POST", path, body);
        if (!auth.ok) {
            writeJson(response, 401, "{\"success\":false,\"message\":\"" + escape(auth.message) + "\"}");
            return;
        }

        if (!"/api/open/payment/create".equals(path)) {
            writeJson(response, 404, "{\"success\":false,\"message\":\"Not found\"}");
            return;
        }

        Map<String, String> params = parseForm(body);
        try {
            ExternalPaymentOrder order = new ExternalPaymentOrder();
            order.setMerchantId(auth.merchant.getMerchantId());
            order.setBillNo(required(params, "billNo"));
            order.setExternalUserName(required(params, "externalUserName"));
            order.setExternalUserNo(required(params, "externalUserNo"));
            order.setBankLoginAccount(required(params, "bankLoginAccount"));
            order.setBillType(required(params, "billType"));
            order.setProviderName(required(params, "providerName"));
            order.setCustomerNo(required(params, "customerNo"));
            order.setPeriod(required(params, "period"));
            order.setAmount(new BigDecimal(required(params, "amount")));
            order.setSubject(value(params, "subject", order.getBillType() + " payment"));
            order.setReturnUrl(required(params, "returnUrl"));
            order.setPayToken("PT" + UUID.randomUUID().toString().replace("-", ""));
            ExternalPaymentOrder saved = openPaymentDao.createOrFindOrder(order);
            String payUrl = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                    + request.getContextPath() + "/bankpay/checkout?payToken=" + saved.getPayToken();
            writeJson(response, 200, "{\"success\":true,\"payToken\":\"" + saved.getPayToken()
                    + "\",\"payUrl\":\"" + escape(payUrl) + "\"}");
        } catch (Exception e) {
            openPaymentDao.addApiLog(auth.accessKey, "POST", path, auth.nonce, auth.timestamp,
                    sha256Hex(body), "FAILED", "400", e.getMessage());
            writeJson(response, 400, "{\"success\":false,\"message\":\"" + escape(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        if (!"/api/open/payment/status".equals(path)) {
            writeJson(response, 404, "{\"success\":false,\"message\":\"Not found\"}");
            return;
        }
        ApiAuthResult auth = verify(request, "GET", path, "");
        if (!auth.ok) {
            writeJson(response, 401, "{\"success\":false,\"message\":\"" + escape(auth.message) + "\"}");
            return;
        }
        String billNo = trim(request.getParameter("billNo"));
        ExternalPaymentOrder order = openPaymentDao.findByBillNo(auth.merchant.getMerchantId(), billNo);
        if (order == null) {
            writeJson(response, 404, "{\"success\":false,\"message\":\"Order not found\"}");
            return;
        }
        writeJson(response, 200, "{\"success\":true,\"billNo\":\"" + escape(order.getBillNo())
                + "\",\"status\":\"" + order.getStatus() + "\",\"bankTransactionId\":\""
                + (order.getBankTransactionId() == null ? "" : order.getBankTransactionId()) + "\"}");
    }

    private ApiAuthResult verify(HttpServletRequest request, String method, String path, String body) {
        ApiAuthResult result = new ApiAuthResult();
        result.accessKey = trim(request.getHeader("X-FC-AK"));
        result.nonce = trim(request.getHeader("X-FC-Nonce"));
        String timestampText = trim(request.getHeader("X-FC-Timestamp"));
        String signature = trim(request.getHeader("X-FC-Signature"));
        try {
            result.timestamp = Long.parseLong(timestampText);
            result.merchant = openPaymentDao.findMerchantByAccessKey(result.accessKey);
            if (result.merchant == null || !"ACTIVE".equals(result.merchant.getStatus())) {
                return fail(result, method, path, body, "Merchant unavailable");
            }
            long now = System.currentTimeMillis();
            if (Math.abs(now - result.timestamp) > 5L * 60L * 1000L) {
                return fail(result, method, path, body, "Timestamp expired");
            }
            if (result.nonce.length() == 0 || openPaymentDao.nonceExists(result.accessKey, result.nonce)) {
                return fail(result, method, path, body, "Nonce invalid");
            }
            String canonical = method + "\n" + path + "\n" + result.timestamp + "\n" + result.nonce + "\n" + sha256Hex(body);
            String expected = hmacSha256(result.merchant.getSecretKey(), canonical);
            if (!expected.equalsIgnoreCase(signature)) {
                return fail(result, method, path, body, "Signature invalid");
            }
            result.ok = true;
            openPaymentDao.addApiLog(result.accessKey, method, path, result.nonce, result.timestamp,
                    sha256Hex(body), "SUCCESS", "200", null);
            return result;
        } catch (Exception e) {
            return fail(result, method, path, body, e.getMessage());
        }
    }

    private ApiAuthResult fail(ApiAuthResult result, String method, String path, String body, String message) {
        result.ok = false;
        result.message = message == null ? "Auth failed" : message;
        openPaymentDao.addApiLog(result.accessKey, method, path, result.nonce, result.timestamp,
                sha256Hex(body), "FAILED", "401", result.message);
        return result;
    }

    private String readBody(HttpServletRequest request) throws IOException {
        StringBuilder body = new StringBuilder();
        try (BufferedReader reader = request.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                body.append(line);
            }
        }
        return body.toString();
    }

    private Map<String, String> parseForm(String body) throws IOException {
        Map<String, String> params = new HashMap<String, String>();
        if (body == null || body.length() == 0) return params;
        String[] pairs = body.split("&");
        for (String pair : pairs) {
            int index = pair.indexOf('=');
            String key = index < 0 ? pair : pair.substring(0, index);
            String value = index < 0 ? "" : pair.substring(index + 1);
            params.put(URLDecoder.decode(key, "UTF-8"), URLDecoder.decode(value, "UTF-8"));
        }
        return params;
    }

    private String required(Map<String, String> params, String key) {
        String value = params.get(key);
        if (value == null || value.trim().length() == 0) {
            throw new IllegalArgumentException(key + " is required.");
        }
        return value.trim();
    }

    private String value(Map<String, String> params, String key, String fallback) {
        String value = params.get(key);
        return value == null || value.trim().length() == 0 ? fallback : value.trim();
    }

    private void writeJson(HttpServletResponse response, int status, String body) throws IOException {
        response.setStatus(status);
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write(body);
    }

    private String sha256Hex(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest((value == null ? "" : value).getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private String hmacSha256(String secret, String value) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] bytes = mac.doFinal(value.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private String escape(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private static class ApiAuthResult {
        boolean ok;
        String message;
        String accessKey;
        String nonce;
        long timestamp;
        MerchantApp merchant;
    }
}
