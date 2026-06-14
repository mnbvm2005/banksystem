package communitypay.controller;

import communitypay.model.CommunityUser;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

final class CommunityAuth {
    private CommunityAuth() {
    }

    static CommunityUser requireUser(HttpServletRequest request, HttpServletResponse response) throws IOException {
        CommunityUser user = (CommunityUser) request.getSession().getAttribute("communityUser");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return user;
    }

    static void exposeUser(HttpServletRequest request, CommunityUser user) {
        request.setAttribute("residentName", user.getResidentName());
        request.setAttribute("residentNo", user.getResidentNo());
        request.setAttribute("bankLoginAccount", user.getBankLoginAccount());
    }
}
