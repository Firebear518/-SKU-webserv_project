package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
// 1. UserDAO import 추가 (패키지명은 본인 프로젝트에 맞게 수정하세요)
import com.skuweb.dao.UserDAO; 

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import util.DBUtil;

@WebServlet("/user/register")
public class UserRegisterServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

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

        // 2. 중복 체크 로직 추가
        UserDAO dao = new UserDAO();
        
        // DAO의 isIdDuplicate 메서드를 호출 (아래에서 정의할 메서드)
        if (dao.isIdDuplicate(userId)) {
            // 중복일 경우 메시지를 담아서 다시 회원가입 페이지로 되돌림
            request.setAttribute("errorMessage", "이미 존재하는 아이디입니다.");
            request.setAttribute("prevValues", request.getParameterMap()); // 입력했던 값 유지
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        // 중복이 아닐 경우 가입 진행
        String sql = "INSERT INTO users (userId, password, userName, userPhone, userAddress, userAddressDetail) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, password);
            pstmt.setString(3, userName);
            pstmt.setString(4, userPhone);
            pstmt.setString(5, userAddress);
            pstmt.setString(6, userAddressDetail);
            
            pstmt.executeUpdate();
            
            // 가입 성공 시 로그인 페이지로 이동
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/user/register.jsp?error=db_error");
        }
    }
}


