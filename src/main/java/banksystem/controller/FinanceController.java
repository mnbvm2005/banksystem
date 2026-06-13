package banksystem.controller;

import banksystem.dao.FinancialProductDao;
import banksystem.model.FinancialProduct;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class FinanceController extends BaseController {
    private final FinancialProductDao financialProductDao = new FinancialProductDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }

        List<FinancialProduct> products = financialProductDao.findAllAvailable();
        request.setAttribute("products", products);
        request.getRequestDispatcher("/views/user/finance.jsp").forward(request, response);
    }
}
