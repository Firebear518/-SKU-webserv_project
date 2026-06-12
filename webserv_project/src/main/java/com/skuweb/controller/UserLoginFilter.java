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

        // 1. 로그인 없이 통과할 수 있는 퍼블릭 주소들
        boolean isPublic =
                uri.equals(ctx + "/")                          ||
                uri.contains("/views/user/login.jsp")          ||
                uri.contains("/views/user/register.jsp")       ||
                uri.contains("/views/user/banned.jsp")         ||
                uri.contains("/views/admin/adminLogin.jsp")    ||
                uri.contains("/views/board/productList.jsp")   ||
                uri.contains("/views/board/productDetail.jsp") ||
                uri.contains("/index.jsp")                     ||
                uri.equals(ctx + "/user/login")                ||
                uri.equals(ctx + "/admin/login")               ||
                uri.equals(ctx + "/logout")                    ||
                uri.equals(ctx + "/register")                  ||
                uri.equals(ctx + "/user/register")             ||
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

        // 2. 가려는 목적지가 관리자용 경로인지 확인 ("/admin" 또는 "/views/admin/")
        boolean isAdminPath = uri.contains("/admin") || uri.contains("/views/admin/");

        if (isAdminPath) {
            // [관리자 구역] 관리자 세션(adminId)이 없으면 무조건 관리자 로그인 페이지로 쫓아냄
            if (session == null || session.getAttribute("adminId") == null) {
                response.sendRedirect(ctx + "/views/admin/adminLogin.jsp");
                return;
            }
        } else {
            // [일반 구역] 일반 유저 세션(userId) 또는 관리자 세션(adminId) 둘 다 없으면 일반 로그인 페이지로
            boolean loggedIn = (session != null) &&
                               (session.getAttribute("userId") != null ||
                                session.getAttribute("adminId") != null);
            if (!loggedIn) {
                response.sendRedirect(ctx + "/views/user/login.jsp");
                return;
            }
        }

        // 3. BAN 체크 - 관리자는 영구 정지 체크에서 제외
        if (session != null && session.getAttribute("adminId") == null) {
            String userStatus = (String) session.getAttribute("userStatus");
            if ("영구 정지".equals(userStatus)) {
                session.invalidate(); // 세션 제거
                response.sendRedirect(ctx + "/views/user/banned.jsp");
                return;
            }
        }

        // 모든 검문을 무사히 통과했다면 원래 가려던 길 가게 해줌
        chain.doFilter(req, res);
    }
}
