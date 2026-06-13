package banksystem.controller;

import banksystem.dao.NotificationDao;
import banksystem.model.Notification;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class NotificationController extends BaseController {
    private final NotificationDao notificationDao = new NotificationDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) return;
        List<Notification> notifications = notificationDao.findVisible(user.getUserId(), hasRole(request, "ADMIN"));
        request.setAttribute("notifications", notifications);
        request.getRequestDispatcher("/views/user/notifications.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) return;
        try {
            int notificationId = Integer.parseInt(request.getParameter("notificationId"));
            notificationDao.markRead(notificationId, user.getUserId(), hasRole(request, "ADMIN"));
        } catch (Exception ignored) {
        }
        response.sendRedirect(request.getContextPath() + "/notifications");
    }
}
