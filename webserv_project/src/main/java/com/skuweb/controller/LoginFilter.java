package com.skuweb.controller;


 
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*") // 모든 페이지에 대해 필터 적용
public class LoginFilter implements Filter {
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
	    HttpServletRequest req = (HttpServletRequest) request;
	    HttpServletResponse res = (HttpServletResponse) response;
	    HttpSession session = req.getSession(false);
	    String uri = req.getRequestURI();

	    // 1. 관리자 페이지 접근 제어
	    if (uri.contains("admin.jsp")) {
	        String role = (session != null) ? (String) session.getAttribute("role") : null;
	        if (!"admin".equals(role)) {
	            res.sendRedirect("index.jsp");
	            return; // 리다이렉트 후 반드시 종료
	        }
	        chain.doFilter(request, response); // 관리자면 통과
	        return;
	    }

	    // 2. 로그인 예외 페이지 체크
	    boolean isLoginPage = uri.endsWith("login.jsp") || uri.endsWith("register.jsp") 
	                       || uri.endsWith("LoginServlet") || uri.endsWith("RegisterServlet");

	 // 기존 33번 줄 부분을 아래 코드로 완전히 교체해 보세요.
	 // 3. 로그인 상태 체크
	 if (isLoginPage) {
	     chain.doFilter(request, response);
	 } else if (session != null && session.getAttribute("userId") != null) {
	     chain.doFilter(request, response);
	 } else {
	     res.sendRedirect("login.jsp");
	 }
	}
}
