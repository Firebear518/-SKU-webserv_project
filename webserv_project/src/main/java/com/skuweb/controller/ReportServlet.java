package com.skuweb.controller;

import java.io.IOException;
import com.skuweb.dao.ReportDAO; // 생성한 DAO 임포트

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/report") 
public class ReportServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "로그인이 필요합니다.");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String reporterId     = (String) session.getAttribute("userId");
        String reportedUserId = request.getParameter("reportedUserId");
        String productIdStr   = request.getParameter("productId");
        String reportReason   = request.getParameter("reportReason");

        if (reportedUserId == null || productIdStr == null || reportReason == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "필수 정보가 누락되었습니다.");
            return;
        }

        try {
            int productId = Integer.parseInt(productIdStr);
            
            // 🌟 서블릿에서 직접 DB 통신을 지우고, 만들어둔 DAO를 호출합니다!
            ReportDAO dao = new ReportDAO();
            boolean isSuccess = dao.insertReport(reporterId, reportedUserId, productId, reportReason);

            if (isSuccess) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("success"); // 프론트엔드로 성공 메시지 전달
            } else {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "신고 처리 중 오류가 발생했습니다.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}