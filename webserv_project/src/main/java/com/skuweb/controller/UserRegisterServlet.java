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

@WebServlet("/user/register")
public class UserRegisterServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "ASDasd336699@";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userId            = request.getParameter("userId");
        String userName          = request.getParameter("userName");
        String password          = request.getParameter("password");
        String userPhone         = request.getParameter("userPhone");
        String userAddress       = request.getParameter("userAddress");
        String userAddressDetail = request.getParameter("userAddressDetail");

        String sql = "INSERT INTO users (userId, password, userName, userPhone, userAddress, userAddressDetail) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, userId);
                pstmt.setString(2, password);
                pstmt.setString(3, userName);
                pstmt.setString(4, userPhone);
                pstmt.setString(5, userAddress);
                pstmt.setString(6, userAddressDetail);
                pstmt.executeUpdate();
            }

            // 가입 성공 → 로그인 페이지로 이동
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/user/register.jsp?error=server");
        }
    }
}

