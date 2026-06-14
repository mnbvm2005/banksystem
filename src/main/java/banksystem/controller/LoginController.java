package banksystem.controller;

import banksystem.dao.AuthRecordDao;
import banksystem.dao.UserDao;
import banksystem.model.AuthRecord;
import banksystem.model.User;
import banksystem.sqloperation.GetMySQLConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;

public class LoginController extends BaseController {
    private final UserDao userDao = new UserDao();
    private final AuthRecordDao authRecordDao = new AuthRecordDao();

    @Override
    protected void doGet(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response)
            throws ServletException, IOException {
        String servletPath = request.getServletPath();
        if ("/logout".equals(servletPath)) {
            request.getSession().invalidate();
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if ("/register".equals(servletPath)) {
            request.setAttribute("authMode", "register");
        }
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if ("/register".equals(request.getServletPath())) {
            register(request, response);
            return;
        }

        String account = trim(request.getParameter("account"));
        String password = trim(request.getParameter("password"));

        if (account.length() == 0 || password.length() == 0) {
            request.setAttribute("error", "Please enter your account and password.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        if (!userDao.canConnect()) {
            request.setAttribute("error", "Database connection failed. Please start MySQL and import fincloud_bank_pro first.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        User candidate = userDao.findByUsernameOrPhone(account);
        User loginUser = candidate == null ? null : userDao.login(account, password);
        String failReason = null;
        if (candidate == null || loginUser == null) {
            failReason = "Invalid account or password.";
        } else if (!loginUser.isNormal()) {
            failReason = "The user status is not NORMAL.";
            loginUser = null;
        }

        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            request.setAttribute("error", "Database connection failed. Please check connection settings.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        try {
            connection.setAutoCommit(false);
            if (loginUser == null) {
                writeAuthRecord(connection, candidate == null ? null : candidate.getUserId(), account,
                        "FAILED", failReason, request);
                connection.commit();
                request.setAttribute("error", failReason);
                request.getRequestDispatcher("/views/login.jsp").forward(request, response);
                return;
            }

            writeAuthRecord(connection, loginUser.getUserId(), account, "SUCCESS", null, request);
            userDao.updateLastLoginTime(connection, loginUser.getUserId());
            connection.commit();

            request.getSession().setAttribute("loginUser", loginUser);
            request.getSession().setAttribute("user", loginUser);
            request.getSession().setAttribute("userId", loginUser.getUserId());
            request.getSession().setAttribute("username", loginUser.getUsername());
            request.getSession().setAttribute("roleCodes", loginUser.getRoleCodes());
            response.sendRedirect(request.getContextPath() + "/index");
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ignored) {
            }
            throw new ServletException("Failed to write login audit record.", e);
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private void writeAuthRecord(Connection connection, Integer userId, String account, String result,
                                 String failReason, javax.servlet.http.HttpServletRequest request) throws SQLException {
        AuthRecord record = new AuthRecord();
        record.setUserId(userId);
        record.setLoginAccount(account);
        record.setAuthType("PASSWORD");
        record.setAuthResult(result);
        record.setFailureReason(failReason);
        record.setLoginIp(request.getRemoteAddr());
        authRecordDao.add(connection, record);
    }

    private void register(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response)
            throws ServletException, IOException {
        String username = trim(request.getParameter("username"));
        String realName = trim(request.getParameter("realName"));
        String phone = trim(request.getParameter("phone"));
        String email = trim(request.getParameter("email"));
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        request.setAttribute("authMode", "register");
        request.setAttribute("registerUsername", username);
        request.setAttribute("registerRealName", realName);
        request.setAttribute("registerPhone", phone);
        request.setAttribute("registerEmail", email);

        if (username.length() == 0 || realName.length() == 0 || phone.length() == 0
                || password.length() == 0 || confirmPassword.length() == 0) {
            request.setAttribute("error", "Please complete all required registration fields.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "The two passwords do not match.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        if (!userDao.canConnect()) {
            request.setAttribute("error", "Database connection failed. Please start MySQL and import fincloud_bank_pro first.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        if (userDao.existsByUsernameOrPhone(username, phone)) {
            request.setAttribute("error", "This username or phone number is already registered.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            request.setAttribute("error", "Database connection failed. Please check connection settings.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }

        try {
            connection.setAutoCommit(false);
            User user = userDao.createCustomer(connection, username, realName, phone, email, password);
            writeAuthRecord(connection, user.getUserId(), username, "SUCCESS", null, request);
            userDao.updateLastLoginTime(connection, user.getUserId());
            connection.commit();

            request.getSession().setAttribute("loginUser", user);
            request.getSession().setAttribute("user", user);
            request.getSession().setAttribute("userId", user.getUserId());
            request.getSession().setAttribute("username", user.getUsername());
            request.getSession().setAttribute("roleCodes", user.getRoleCodes());
            response.sendRedirect(request.getContextPath() + "/index");
        } catch (SQLException e) {
            try {
                connection.rollback();
            } catch (SQLException ignored) {
            }
            request.setAttribute("error", "Registration failed. Please check the submitted information and try again.");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
