<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // ★ 개발/테스트 전용 - 실제 배포 시 삭제 ★
    // 로그인 없이 상품 등록 테스트를 위해 임시 세션 생성
    session.setAttribute("userId", "testSeller");
    session.setAttribute("role", "user");

    String redirect = request.getParameter("to");
    if (redirect == null || redirect.isEmpty()) {
        redirect = request.getContextPath() + "/views/board/productRegister.jsp";
    }
    response.sendRedirect(redirect);
%>
