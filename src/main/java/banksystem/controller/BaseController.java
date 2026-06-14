package banksystem.controller;

import banksystem.model.User;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public abstract class BaseController extends HttpServlet {
    protected User getLoginUser(javax.servlet.http.HttpServletRequest request) {
        User user = (User) request.getSession().getAttribute("loginUser");
        if (user == null) {
            user = (User) request.getSession().getAttribute("user");
        }
        return user;
    }

    protected User getLoginUser(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws IOException {
        if (!requireLogin(request, response)) {
            return null;
        }
        return getLoginUser(request);
    }

    protected Integer getLoginUserId(javax.servlet.http.HttpServletRequest request) {
        Object value = request.getSession().getAttribute("userId");
        if (value instanceof Integer) {
            return (Integer) value;
        }
        User user = getLoginUser(request);
        return user == null ? null : user.getUserId();
    }

    @SuppressWarnings("unchecked")
    protected List<String> getRoleCodes(javax.servlet.http.HttpServletRequest request) {
        Object value = request.getSession().getAttribute("roleCodes");
        if (value instanceof List) {
            return (List<String>) value;
        }
        User user = getLoginUser(request);
        if (user != null && user.getRoleCodes() != null) {
            return user.getRoleCodes();
        }
        return new ArrayList<String>();
    }

    protected boolean requireLogin(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws IOException {
        User user = getLoginUser(request);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        if (!user.isNormal()) {
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/login?error=status");
            return false;
        }
        return true;
    }

    protected boolean hasRole(javax.servlet.http.HttpServletRequest request, String roleCode) {
        return getRoleCodes(request).contains(roleCode);
    }

    protected boolean hasAnyRole(javax.servlet.http.HttpServletRequest request, String... roleCodes) {
        List<String> required = Arrays.asList(roleCodes);
        for (String owned : getRoleCodes(request)) {
            if (required.contains(owned)) {
                return true;
            }
        }
        return false;
    }

    protected boolean requireRole(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, String roleCode) throws IOException {
        return requireAnyRole(request, response, roleCode);
    }

    protected boolean requireAnyRole(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response, String... roleCodes) throws IOException {
        if (!requireLogin(request, response)) {
            return false;
        }
        if (!hasAnyRole(request, roleCodes)) {
            response.sendError(javax.servlet.http.HttpServletResponse.SC_FORBIDDEN);
            return false;
        }
        return true;
    }

    protected String trim(String value) {
        return value == null ? "" : value.trim();
    }

    protected String detectBrowser(HttpServletRequest request) {
        String userAgent = safeUserAgent(request);
        if (userAgent.contains("Edg/")) {
            return "Edge";
        }
        if (userAgent.contains("Chrome/")) {
            return "Chrome";
        }
        if (userAgent.contains("Safari/") && !userAgent.contains("Chrome/")) {
            return "Safari";
        }
        if (userAgent.contains("Firefox/")) {
            return "Firefox";
        }
        return "Unknown Browser";
    }

    protected String detectOs(HttpServletRequest request) {
        String userAgent = safeUserAgent(request);
        if (userAgent.contains("Mac OS X")) {
            return "macOS";
        }
        if (userAgent.contains("Windows")) {
            return "Windows";
        }
        if (userAgent.contains("Android")) {
            return "Android";
        }
        if (userAgent.contains("iPhone") || userAgent.contains("iPad")) {
            return "iOS";
        }
        if (userAgent.contains("Linux")) {
            return "Linux";
        }
        return "Unknown OS";
    }

    protected String buildDeviceName(HttpServletRequest request) {
        return detectBrowser(request) + " on " + detectOs(request);
    }

    protected String buildDeviceFingerprint(HttpServletRequest request) {
        String raw = request.getRemoteAddr() + "|" + safeUserAgent(request);
        return sha256(raw).substring(0, 32);
    }

    private String safeUserAgent(HttpServletRequest request) {
        String userAgent = request.getHeader("User-Agent");
        return userAgent == null ? "unknown-agent" : userAgent;
    }

    private String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("The current JRE does not support SHA-256.", e);
        }
    }
}
