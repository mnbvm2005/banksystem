package banksystem.controller;

import banksystem.dao.LoginDeviceDao;
import banksystem.dao.SecurityEventDao;
import banksystem.model.LoginDevice;
import banksystem.model.SecurityEvent;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class SecurityController extends BaseController {
    private final LoginDeviceDao loginDeviceDao = new LoginDeviceDao();
    private final SecurityEventDao securityEventDao = new SecurityEventDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        boolean admin = hasRole(request, "ADMIN");
        List<LoginDevice> devices = loginDeviceDao.findVisible(user.getId(), admin);
        List<SecurityEvent> events = securityEventDao.findVisible(user.getId(), admin);
        request.setAttribute("securityAdminView", Boolean.valueOf(admin));
        request.setAttribute("loginDevices", devices);
        request.setAttribute("securityEvents", events);
        request.getRequestDispatcher("/views/user/security.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        boolean admin = hasRole(request, "ADMIN");
        String action = request.getParameter("action");
        try {
            if ("trust-device".equals(action)) {
                int deviceId = Integer.parseInt(request.getParameter("deviceId"));
                int trustedFlag = "1".equals(request.getParameter("trustedFlag")) ? 1 : 0;
                loginDeviceDao.updateTrustedFlag(deviceId, user.getId(), admin, trustedFlag);
            } else if ("handle-event".equals(action)) {
                int eventId = Integer.parseInt(request.getParameter("eventId"));
                int handledFlag = "1".equals(request.getParameter("handledFlag")) ? 1 : 0;
                securityEventDao.updateHandledFlag(eventId, user.getId(), admin, handledFlag);
            }
            response.sendRedirect(request.getContextPath() + "/security");
        } catch (SQLException e) {
            throw new ServletException("Failed to update security settings.", e);
        }
    }
}
