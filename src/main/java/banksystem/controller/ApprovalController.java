package banksystem.controller;

import banksystem.dao.OperationLogDao;
import banksystem.dao.TransactionApprovalDao;
import banksystem.dao.TransactionDao;
import banksystem.model.OperationLog;
import banksystem.model.TransactionApproval;
import banksystem.model.User;
import banksystem.sqloperation.GetMySQLConnection;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public class ApprovalController extends BaseController {
    private final TransactionApprovalDao approvalDao = new TransactionApprovalDao();
    private final TransactionDao transactionDao = new TransactionDao();
    private final OperationLogDao operationLogDao = new OperationLogDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requireAnyRole(request, response, "ADMIN", "APPROVER")) {
            return;
        }
        boolean canApprove = true;
        List<TransactionApproval> approvals = approvalDao.findPending();
        request.setAttribute("canApprove", Boolean.valueOf(canApprove));
        request.setAttribute("approvals", approvals);
        request.getRequestDispatcher("/views/user/approval.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!requireAnyRole(request, response, "ADMIN", "APPROVER")) {
            return;
        }
        User user = getLoginUser(request);

        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new ServletException("Database connection failed.");
        }
        try {
            connection.setAutoCommit(false);
            int approvalId = Integer.parseInt(request.getParameter("approvalId"));
            int transactionId = Integer.parseInt(request.getParameter("transactionId"));
            String status = request.getParameter("status");
            String comment = request.getParameter("comment");
            if (!"APPROVED".equals(status) && !"REJECTED".equals(status)) {
                status = "PENDING";
            }
            approvalDao.updateStatus(connection, approvalId, user.getId(), status, comment);
            transactionDao.updateStatus(connection, transactionId, status);

            OperationLog log = new OperationLog();
            log.setUserId(user.getId());
            log.setOperationType("APPROVAL");
            log.setObjectType("TRANSACTION");
            log.setObjectId(transactionId);
            log.setOperationContent("Large transaction approval: " + status);
            log.setOperationResult("SUCCESS");
            log.setIpAddress(request.getRemoteAddr());
            operationLogDao.add(connection, log);
            connection.commit();
            response.sendRedirect(request.getContextPath() + "/approval");
        } catch (SQLException e) {
            rollback(connection);
            throw new ServletException("Approval operation failed.", e);
        } catch (RuntimeException e) {
            rollback(connection);
            throw e;
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private void rollback(Connection connection) {
        try {
            connection.rollback();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
