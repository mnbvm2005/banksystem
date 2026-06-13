package banksystem.controller;

import banksystem.dao.InvestmentHoldingDao;
import banksystem.model.InvestmentHolding;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class HoldingController extends BaseController {
    private final InvestmentHoldingDao holdingDao = new InvestmentHoldingDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        List<InvestmentHolding> holdings = holdingDao.findByUserId(user.getId());
        request.setAttribute("holdings", holdings);
        request.getRequestDispatcher("/views/user/holding.jsp").forward(request, response);
    }
}
