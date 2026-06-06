package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager; 
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "ASDasd336699@";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 로그인 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        request.setCharacterEncoding("UTF-8");

        String reporterId    = (String) session.getAttribute("userId");
        String reportedUserId = request.getParameter("reportedUserId");
        String productIdStr  = request.getParameter("productId");
        String reportReason  = request.getParameter("reportReason");

        if (reportedUserId == null || productIdStr == null || reportReason == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement pstmt = conn.prepareStatement(
                     "INSERT INTO reports (reporter_id, reported_user_id, product_id, report_reason) " +
                     "VALUES (?, ?, ?, ?)")) {

                pstmt.setString(1, reporterId);
                pstmt.setString(2, reportedUserId);
                pstmt.setInt(3, Integer.parseInt(productIdStr));
                pstmt.setString(4, reportReason);
                pstmt.executeUpdate();
            }

            response.setStatus(HttpServletResponse.SC_OK);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}