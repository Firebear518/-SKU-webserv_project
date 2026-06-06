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

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";   // 본인 MySQL 계정으로 변경
    private static final String DB_PASS = "ASDasd336699@";        // 본인 MySQL 비밀번호로 변경

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String userId   = request.getParameter("userId");
        String password = request.getParameter("password");

        String sql = "SELECT userId, userName FROM users WHERE userId = ? AND password = ?";

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {

                pstmt.setString(1, userId);
                pstmt.setString(2, password);

                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        // ✅ 로그인 성공 → 세션에 저장
                        HttpSession session = request.getSession();
                        session.setAttribute("loginUserId",   rs.getString("userId"));
                        session.setAttribute("loginUserName", rs.getString("userName"));

                        // 메인 페이지로 이동 (원하는 경로로 변경)
                        response.sendRedirect(request.getContextPath() + "/index.jsp");
                    } else {
                        // ❌ 아이디/비밀번호 불일치
                        response.sendRedirect(request.getContextPath()
                                + "/views/user/login.jsp?error=invalid");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath()
                    + "/views/user/login.jsp?error=server");
        }
    }
    }