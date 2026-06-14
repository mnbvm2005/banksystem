package banksystem.controller;

import banksystem.dao.SavedQueryDao;
import banksystem.model.SavedQuery;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

public class SavedQueryController extends BaseController {
    private final SavedQueryDao savedQueryDao = new SavedQueryDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/transactions#savedQueries");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        String action = request.getParameter("action");
        try {
            if ("delete".equals(action)) {
                int queryId = Integer.parseInt(request.getParameter("queryId"));
                savedQueryDao.deleteByIdAndUserId(queryId, user.getId());
            } else {
                String queryName = normalize(request.getParameter("queryName"));
                String queryType = normalizeType(request.getParameter("queryType"));
                String queryCondition = normalize(request.getParameter("queryCondition"));
                if (queryName.length() == 0) {
                    throw new IllegalArgumentException("Query name is required.");
                }
                savedQueryDao.add(user.getId(), queryName, queryType, queryCondition);
            }
            response.sendRedirect(request.getContextPath() + "/saved-queries");
        } catch (IllegalArgumentException e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        } catch (SQLException e) {
            throw new ServletException("Failed to maintain saved queries.", e);
        }
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim();
    }

    private String normalizeType(String value) {
        String type = normalize(value).toUpperCase();
        if ("ACCOUNT".equals(type) || "BILL".equals(type) || "TRANSACTION".equals(type)) {
            return type;
        }
        return "TRANSACTION";
    }
}
