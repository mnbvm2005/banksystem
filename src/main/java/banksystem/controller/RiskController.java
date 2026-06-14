package banksystem.controller;

import banksystem.dao.RiskAssessmentDao;
import banksystem.dao.TransactionLimitRuleDao;
import banksystem.dao.TransactionRiskScoreDao;
import banksystem.model.RiskAssessment;
import banksystem.model.TransactionLimitRule;
import banksystem.model.TransactionRiskScore;
import banksystem.model.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class RiskController extends BaseController {
    private final RiskAssessmentDao riskAssessmentDao = new RiskAssessmentDao();
    private final TransactionRiskScoreDao riskScoreDao = new TransactionRiskScoreDao();
    private final TransactionLimitRuleDao limitRuleDao = new TransactionLimitRuleDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = getLoginUser(request, response);
        if (user == null) {
            return;
        }
        boolean admin = hasRole(request, "ADMIN");
        List<RiskAssessment> assessments = riskAssessmentDao.findVisible(user.getId(), admin);
        List<TransactionRiskScore> riskScores = riskScoreDao.findVisible(user.getId(), admin);
        List<TransactionLimitRule> limitRules = limitRuleDao.findAllActive();
        request.setAttribute("riskAssessments", assessments);
        request.setAttribute("riskScores", riskScores);
        request.setAttribute("limitRules", limitRules);
        request.setAttribute("riskAdminView", Boolean.valueOf(admin));
        request.getRequestDispatcher("/views/user/risk.jsp").forward(request, response);
    }
}
