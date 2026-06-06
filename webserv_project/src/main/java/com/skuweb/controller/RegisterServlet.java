package com.skuweb.controller;

import java.sql.*; 

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet implementation class RegisterServlet
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RegisterServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		response.getWriter().append("Served at: ").append(request.getContextPath());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8"); // 한글 깨짐 방지
	    
	    String uid = request.getParameter("user_id");
	    String pwd = request.getParameter("password");
	    String email = request.getParameter("email"); 
	 // 1. DB 연결 (JDBC 활용)
	    String url = "jdbc:mysql://localhost:3306/auction_db?serverTimezone=UTC";
	    String dbId = "root";
	    String dbPw = "ASDasd336699@"; // 본인의 비밀번호로 수정!

	    try {
	        Class.forName("com.mysql.cj.jdbc.Driver");
	        Connection conn = DriverManager.getConnection(url, dbId, dbPw);
	        
	        // 2. SQL 쿼리 작성 (INSERT)
	        String sql = "INSERT INTO users (user_id, password, email) VALUES (?, ?, ?)";
	        PreparedStatement pstmt = conn.prepareStatement(sql);
	        pstmt.setString(1, uid);
	        pstmt.setString(2, pwd);
	        pstmt.setString(3, email);
	        
	        // 3. 실행
	        pstmt.executeUpdate();
	        
	        System.out.println("회원가입 성공!");
	     // 회원가입 성공 후 이동할 페이지 (예: 로그인 화면)
	        response.sendRedirect("login.jsp");
	        
	        // 4. 정리
	        pstmt.close(); 
	        conn.close();
	    } catch (Exception e) {
	        e.printStackTrace(); 
	    }
		doGet(request, response);
	}
}

