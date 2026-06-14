package communitypay.util;

import communitypay.model.ApiConfig;
import communitypay.model.CommunityUser;
import communitypay.model.UtilityBill;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

public class BankOpenPaymentClient {
    public BankCreateResult createPayment(ApiConfig config, UtilityBill bill, CommunityUser user, String returnUrl) {
        try {
            String path = "/api/open/payment/create";
            String body = formBody(bill, user, returnUrl);
            long timestamp = System.currentTimeMillis();
            String nonce = UUID.randomUUID().toString().replace("-", "");
            String canonical = "POST\n" + path + "\n" + timestamp + "\n" + nonce + "\n" + sha256Hex(body);
            String signature = hmacSha256(config.getSecretKey(), canonical);

            URL url = new URL(config.getBankApiBase() + path);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setConnectTimeout(5000);
            connection.setReadTimeout(5000);
            connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8");
            connection.setRequestProperty("X-FC-AK", config.getAccessKey());
            connection.setRequestProperty("X-FC-Timestamp", String.valueOf(timestamp));
            connection.setRequestProperty("X-FC-Nonce", nonce);
            connection.setRequestProperty("X-FC-Signature", signature);
            try (OutputStream os = connection.getOutputStream()) {
                os.write(body.getBytes(StandardCharsets.UTF_8));
            }
            int code = connection.getResponseCode();
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    code >= 200 && code < 300 ? connection.getInputStream() : connection.getErrorStream(), StandardCharsets.UTF_8));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) response.append(line);
            BankCreateResult result = new BankCreateResult();
            result.success = code >= 200 && code < 300 && response.indexOf("\"success\":true") >= 0;
            result.payToken = extract(response.toString(), "payToken");
            result.payUrl = extract(response.toString(), "payUrl");
            result.rawResponse = response.toString();
            return result;
        } catch (Exception e) {
            BankCreateResult result = new BankCreateResult();
            result.success = false;
            result.rawResponse = e.getMessage();
            return result;
        }
    }

    public BankStatusResult queryStatus(ApiConfig config, String billNo) {
        try {
            String path = "/api/open/payment/status";
            long timestamp = System.currentTimeMillis();
            String nonce = UUID.randomUUID().toString().replace("-", "");
            String canonical = "GET\n" + path + "\n" + timestamp + "\n" + nonce + "\n" + sha256Hex("");
            String signature = hmacSha256(config.getSecretKey(), canonical);
            URL url = new URL(config.getBankApiBase() + path + "?billNo=" + URLEncoder.encode(billNo, "UTF-8"));
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(5000);
            connection.setReadTimeout(5000);
            connection.setRequestProperty("X-FC-AK", config.getAccessKey());
            connection.setRequestProperty("X-FC-Timestamp", String.valueOf(timestamp));
            connection.setRequestProperty("X-FC-Nonce", nonce);
            connection.setRequestProperty("X-FC-Signature", signature);
            int code = connection.getResponseCode();
            BufferedReader reader = new BufferedReader(new InputStreamReader(
                    code >= 200 && code < 300 ? connection.getInputStream() : connection.getErrorStream(), StandardCharsets.UTF_8));
            StringBuilder response = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) response.append(line);
            BankStatusResult result = new BankStatusResult();
            result.success = code >= 200 && code < 300 && response.indexOf("\"success\":true") >= 0;
            result.status = extract(response.toString(), "status");
            result.bankTransactionId = extract(response.toString(), "bankTransactionId");
            result.rawResponse = response.toString();
            return result;
        } catch (Exception e) {
            BankStatusResult result = new BankStatusResult();
            result.success = false;
            result.rawResponse = e.getMessage();
            return result;
        }
    }

    private String formBody(UtilityBill bill, CommunityUser user, String returnUrl) throws Exception {
        Map<String, String> params = new LinkedHashMap<String, String>();
        params.put("billNo", bill.getBillNo());
        params.put("externalUserName", user.getResidentName());
        params.put("externalUserNo", user.getResidentNo());
        params.put("bankLoginAccount", user.getBankLoginAccount());
        params.put("billType", bill.getBillType());
        params.put("providerName", bill.getProviderName());
        params.put("customerNo", bill.getCustomerNo());
        params.put("period", bill.getPeriod());
        params.put("amount", money(bill.getAmount()));
        params.put("subject", displayType(bill.getBillType()) + " " + bill.getPeriod());
        params.put("returnUrl", returnUrl);
        StringBuilder body = new StringBuilder();
        for (Map.Entry<String, String> entry : params.entrySet()) {
            if (body.length() > 0) body.append('&');
            body.append(URLEncoder.encode(entry.getKey(), "UTF-8"));
            body.append('=');
            body.append(URLEncoder.encode(entry.getValue(), "UTF-8"));
        }
        return body.toString();
    }

    private String money(BigDecimal value) {
        return value == null ? "0.00" : value.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString();
    }

    private String displayType(String type) {
        if ("ELECTRICITY".equals(type)) return "电费";
        if ("WATER".equals(type)) return "水费";
        if ("GAS".equals(type)) return "燃气费";
        if ("PHONE".equals(type)) return "通信费";
        if ("PROPERTY".equals(type)) return "物业费";
        return type;
    }

    private String sha256Hex(String value) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        byte[] bytes = digest.digest(value.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private String hmacSha256(String secret, String value) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] bytes = mac.doFinal(value.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    private String extract(String json, String key) {
        String pattern = "\"" + key + "\":\"";
        int start = json.indexOf(pattern);
        if (start < 0) return "";
        start += pattern.length();
        int end = json.indexOf('"', start);
        return end < 0 ? "" : json.substring(start, end).replace("\\/", "/");
    }

    public static class BankCreateResult {
        public boolean success;
        public String payToken;
        public String payUrl;
        public String rawResponse;
    }

    public static class BankStatusResult {
        public boolean success;
        public String status;
        public String bankTransactionId;
        public String rawResponse;
    }
}
