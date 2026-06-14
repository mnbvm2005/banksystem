package communitypay.controller;

import communitypay.dao.CommunityUserDao;
import communitypay.model.CommunityUser;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginController extends HttpServlet {
    private final CommunityUserDao userDao = new CommunityUserDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String username = trim(request.getParameter("username"));
        String password = trim(request.getParameter("password"));
        CommunityUser user = userDao.findByUsername(username);
        if (user == null || !password.equals(user.getPasswordHash())) {
            request.setAttribute("error", "账号或密码错误。");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        HttpSession session = request.getSession();
        session.setAttribute("communityUser", user);
        session.setAttribute("residentName", user.getResidentName());
        session.setAttribute("residentNo", user.getResidentNo());
        session.setAttribute("bankLoginAccount", user.getBankLoginAccount());
        response.sendRedirect(request.getContextPath() + "/bills");
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
