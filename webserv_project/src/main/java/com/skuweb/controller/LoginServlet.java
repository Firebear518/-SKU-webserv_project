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

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String uid = request.getParameter("user_id");
        String pass = request.getParameter("password");

        // DB 연결 정보
        String url = "jdbc:mysql://localhost:3306/auction_db";
        String dbId = "jinwoo";
        String dbPass = "1234";
        String sql = "SELECT * FROM users WHERE user_id = ? AND password = ?";

        // try-with-resources 구문: 여기서 선언하면 자동으로 close() 됩니다.
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(url, dbId, dbPass);
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                pstmt.setString(1, uid);
                pstmt.setString(2, pass);
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        HttpSession session = request.getSession();
                        session.setAttribute("userId", rs.getString("user_id"));
                        session.setAttribute("role", rs.getInt("is_admin") == 1 ? "admin" : "user");
                        response.sendRedirect("index.jsp");
                    } else {
                        response.getWriter().println("<script>alert('로그인 실패'); history.back();</script>");
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("<script>alert('서버 오류 발생'); history.back();</script>");
        }
    }
} 