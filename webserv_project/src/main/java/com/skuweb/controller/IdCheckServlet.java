package com.skuweb.controller;

import java.io.IOException;
import com.skuweb.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/user/checkId")
public class IdCheckServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ 이 두 줄 추가
        response.setContentType("text/plain;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String userId = request.getParameter("userId");
        System.out.println("서버가 받은 아이디 값: [" + userId + "]");

        UserDAO dao = new UserDAO();
        boolean isDuplicate = dao.isIdDuplicate(userId);

        // ✅ flush 추가
        response.getWriter().write(String.valueOf(isDuplicate));
        response.getWriter().flush();
    }
}