package banksystem.controller;

import banksystem.dao.TransactionCategoryDao;
import banksystem.model.TransactionCategory;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class CategoryController extends BaseController {
    private final TransactionCategoryDao transactionCategoryDao = new TransactionCategoryDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        List<TransactionCategory> categories = transactionCategoryDao.findAll();
        request.setAttribute("transactionCategories", categories);
        request.getRequestDispatcher("/views/user/categories.jsp").forward(request, response);
    }
}
