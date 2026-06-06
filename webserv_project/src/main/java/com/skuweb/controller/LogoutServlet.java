package com.skuweb.controller;


import jakarta.servlet.http.HttpSession; 
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet implementation class LogoutServlet
 */
@WebServlet("/LogoutServlet")

public class LogoutServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 현재 세션을 가져옴
        HttpSession session = request.getSession(false); 
        
        // 2. 세션이 있다면 삭제 (로그아웃 처리)
        if (session != null) {
            session.invalidate(); 
        }
        
        // 3. 다시 로그인 페이지나 메인 페이지로 이동
        response.sendRedirect("login.jsp");
    }
} 
