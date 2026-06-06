package com.skuweb.controller;

import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;

@WebFilter("/*")
public class UserLoginFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  request  = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();
        String ctx = request.getContextPath();

        boolean isPublic =
        	    uri.equals(ctx + "/")                          ||
        	    uri.contains("/views/user/login.jsp")          ||
        	    uri.contains("/views/user/register.jsp")       ||
        	    uri.contains("/views/admin/adminLogin.jsp")    ||
        	    uri.contains("/views/board/productList.jsp")   ||
        	    uri.contains("/views/board/productDetail.jsp") ||
        	    uri.contains("/index.jsp")                     ||
        	    uri.equals(ctx + "/user/login")                ||  // ← 수정
        	    uri.equals(ctx + "/admin/login")               ||  // ← 추가
        	    uri.equals(ctx + "/logout")                    ||
        	    uri.equals(ctx + "/register")                  ||
        	    uri.contains("/views/common/")                 ||
        	    uri.contains("/css/")                          ||
        	    uri.contains("/js/")                           ||
        	    uri.contains("/images/")                       ||
        	    uri.endsWith(".css")                           ||
        	    uri.endsWith(".js")                            ||
        	    uri.endsWith(".png")                           ||
        	    uri.endsWith(".jpg");
        if (isPublic) {
            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        boolean loggedIn = (session != null) &&
                           (session.getAttribute("userId") != null ||
                            session.getAttribute("adminId") != null);

        if (!loggedIn) {
            response.sendRedirect(ctx + "/views/user/login.jsp");
            return;
        }

        chain.doFilter(req, res);
    }
}
