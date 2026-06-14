package banksystem.controller;

import banksystem.model.User;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
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
}
