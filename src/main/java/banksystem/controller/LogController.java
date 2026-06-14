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
        boolean admin = hasRole(request, "ADMIN");
        String operationType = trim(request.getParameter("operationType"));
        String result = trim(request.getParameter("result"));
        String keyword = trim(request.getParameter("keyword"));
        List<OperationLog> logs = operationLogDao.findVisible(user.getId(), admin, operationType, result, keyword, 80);
        request.setAttribute("logs", logs);
        request.setAttribute("logTotal", Integer.valueOf(operationLogDao.countVisible(user.getId(), admin)));
        request.setAttribute("logSuccess", Integer.valueOf(operationLogDao.countVisibleByResult(user.getId(), admin, "SUCCESS")));
        request.setAttribute("logFailed", Integer.valueOf(operationLogDao.countVisibleByResult(user.getId(), admin, "FAILED")));
        request.setAttribute("operationType", operationType);
        request.setAttribute("result", result);
        request.setAttribute("keyword", keyword);
        request.setAttribute("adminLogView", Boolean.valueOf(admin));
        request.getRequestDispatcher("/views/user/logs.jsp").forward(request, response);
    }
}
