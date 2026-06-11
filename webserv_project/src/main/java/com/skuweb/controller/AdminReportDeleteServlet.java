package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// 🌟 DBUtil 임포트 추가
import util.DBUtil;

@WebServlet("/admin/deleteProduct")
public class AdminReportDeleteServlet extends HttpServlet {

    // 🌟 불필요한 DB_URL, DB_USER, DB_PASS 상수는 삭제되었습니다.

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 관리자 세션 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/admin/adminLogin.jsp");
            return;
        }

        String productId = request.getParameter("productId");

        // 🌟 Class.forName 삭제 및 DBUtil.getConnection() 적용
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(
                     "DELETE FROM products WHERE product_id = ?")) {

            pstmt.setInt(1, Integer.parseInt(productId));
            pstmt.executeUpdate();

            response.sendRedirect(request.getContextPath() + "/views/admin/adminInspection.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/admin/adminInspection.jsp?error=server");
        }
    }
}
