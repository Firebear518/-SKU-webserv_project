package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// 🌟 DBUtil 임포트 추가
import util.DBUtil;

@WebServlet("/admin/login")
public class AdminLoginServlet extends HttpServlet {

    // 🌟 불필요한 DB_URL, DB_USER, DB_PASS 상수는 삭제되었습니다.

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String adminId   = request.getParameter("adminId");
        String adminPw   = request.getParameter("adminPw");

        String sql = "SELECT adminId, adminName FROM admin WHERE adminId = ? AND adminPw = ?";

        try {
            // 🌟 Class.forName 삭제 및 DBUtil.getConnection() 적용
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, adminId);
                pstmt.setString(2, adminPw);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        // 관리자 로그인 성공
                        HttpSession session = request.getSession();
                        session.setAttribute("adminId",   rs.getString("adminId"));
                        session.setAttribute("adminName", rs.getString("adminName"));

                        response.sendRedirect(request.getContextPath() + "/views/admin/adminInspection.jsp");
                    } else {
                        // 로그인 실패
                        response.sendRedirect(request.getContextPath() + "/views/admin/adminLogin.jsp?error=invalid");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/admin/adminLogin.jsp?error=server");
        }
    }
}
