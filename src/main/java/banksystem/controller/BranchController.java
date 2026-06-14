package banksystem.controller;

import banksystem.dao.BankBranchDao;
import banksystem.model.BankBranch;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class BranchController extends BaseController {
    private final BankBranchDao bankBranchDao = new BankBranchDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        List<BankBranch> branches = bankBranchDao.findAll();
        request.setAttribute("branches", branches);
        request.getRequestDispatcher("/views/user/branches.jsp").forward(request, response);
    }
}
