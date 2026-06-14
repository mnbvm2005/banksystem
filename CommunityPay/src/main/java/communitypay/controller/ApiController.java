package communitypay.controller;

import communitypay.dao.ApiConfigDao;
import communitypay.dao.PaymentEventDao;
import communitypay.model.ApiConfig;
import communitypay.model.CommunityUser;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class ApiController extends HttpServlet {
    private final ApiConfigDao configDao = new ApiConfigDao();
    private final PaymentEventDao eventDao = new PaymentEventDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        CommunityUser user = CommunityAuth.requireUser(request, response);
        if (user == null) return;
        ApiConfig config = configDao.findActive();
        CommunityAuth.exposeUser(request, user);
        request.setAttribute("config", config);
        request.setAttribute("secretMasked", mask(config == null ? "" : config.getSecretKey()));
        request.setAttribute("events", eventDao.findRecent(8));
        request.setAttribute("activeMenu", "api");
        request.getRequestDispatcher("/views/api.jsp").forward(request, response);
    }

    private String mask(String value) {
        if (value == null || value.length() <= 8) return "****";
        return value.substring(0, 4) + "****" + value.substring(value.length() - 4);
    }
}
