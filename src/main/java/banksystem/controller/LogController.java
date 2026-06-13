package banksystem.controller;

import banksystem.dao.OperationLogDao;
import banksystem.model.OperationLog;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class LogController extends BaseController {
    private final OperationLogDao operationLogDao = new OperationLogDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        List<OperationLog> logs = operationLogDao.findVisible(user.getId(), hasRole(request, "ADMIN"));
        request.setAttribute("logs", logs);
        request.getRequestDispatcher("/views/user/logs.jsp").forward(request, response);
    }
}
