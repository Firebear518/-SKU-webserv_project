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

@WebServlet("/user/login")
public class UserLoginServlet extends HttpServlet {
    
    // 🌟 불필요한 DB_URL, DB_USER, DB_PASS 상수는 삭제되었습니다.

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        String userId   = request.getParameter("userId");
        String password = request.getParameter("password");
        
        String sql = "SELECT userId, userName, status FROM users WHERE userId = ? AND password = ?";
        
        try {
            // 🌟 Class.forName 삭제 및 DBUtil.getConnection() 적용
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                
                pstmt.setString(1, userId);
                pstmt.setString(2, password);
                
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        String status = rs.getString("status");

                        // BAN 체크
                        if ("영구 정지".equals(status)) {
                            response.sendRedirect(request.getContextPath() + "/views/user/banned.jsp");
                            return;
                        }

                        // 로그인 성공 → 세션 저장
                        HttpSession session = request.getSession();
                        session.setAttribute("userId",     rs.getString("userId"));
                        session.setAttribute("userName",   rs.getString("userName"));
                        session.setAttribute("userStatus", status); // ← 추가

                        response.sendRedirect(request.getContextPath() + "/index.jsp");
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