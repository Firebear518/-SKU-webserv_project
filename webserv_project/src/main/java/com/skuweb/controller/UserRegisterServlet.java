package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// 🌟 팀원의 DBUtil을 쓸 수 있도록 import 추가!
import util.DBUtil;

@WebServlet("/user/register")
public class UserRegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // 🌟 기존 DB_URL, DB_USER, DB_PASS 상수는 깔끔하게 삭제됨!

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userId           = request.getParameter("userId");
        String userName          = request.getParameter("userName");
        String password          = request.getParameter("password");
        String userPhone         = request.getParameter("userPhone");
        String userAddress       = request.getParameter("userAddress");
        String userAddressDetail = request.getParameter("userAddressDetail");

        String sql = "INSERT INTO users (userId, password, userName, userPhone, userAddress, userAddressDetail) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try {
            // 🌟 Class.forName과 DriverManager 대신 DBUtil 활용!
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, userId);
                pstmt.setString(2, password);
                pstmt.setString(3, userName);
                pstmt.setString(4, userPhone);
                pstmt.setString(5, userAddress);
                pstmt.setString(6, userAddressDetail);
                
                pstmt.executeUpdate();
            }
            
            // 🌟 중복되어 있던 가입 성공 리다이렉트 코드를 한 줄만 남기고 정리!
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 다른 처리를 하거나, 알림 페이지로 포워딩할 수 있도록 예외 처리 유지
        }
    }
}


