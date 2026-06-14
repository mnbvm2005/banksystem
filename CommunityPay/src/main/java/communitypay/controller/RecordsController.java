package communitypay.controller;

import communitypay.dao.UtilityBillDao;
import communitypay.model.CommunityUser;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class RecordsController extends HttpServlet {
    private final UtilityBillDao billDao = new UtilityBillDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        CommunityUser user = CommunityAuth.requireUser(request, response);
        if (user == null) return;
        CommunityAuth.exposeUser(request, user);
        request.setAttribute("records", billDao.findRecordsByResidentNo(user.getResidentNo()));
        request.setAttribute("activeMenu", "records");
        request.getRequestDispatcher("/views/records.jsp").forward(request, response);
    }
}
