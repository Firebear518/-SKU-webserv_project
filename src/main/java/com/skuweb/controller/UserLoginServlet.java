package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user/login")
public class UserLoginServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "ASDasd336699@";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userId   = request.getParameter("userId");
        String password = request.getParameter("password");

        String sql = "SELECT userId, userName, status FROM users WHERE userId = ? AND password = ?";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, userId);
                pstmt.setString(2, password);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        // 로그인 성공 → 세션 저장
                        HttpSession session = request.getSession();
                        session.setAttribute("userId",   rs.getString("userId"));
                        session.setAttribute("userName", rs.getString("userName"));
                        
                        response.sendRedirect(request.getContextPath() + "/views/index.jsp");
                    } else {
                        // 아이디/비밀번호 불일치
                        response.sendRedirect(request.getContextPath() + "/views/user/login.jsp?error=invalid");
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp?error=server");
        }
    }
}
