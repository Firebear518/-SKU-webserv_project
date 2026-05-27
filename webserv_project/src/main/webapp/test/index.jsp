<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<body>
    <h1>환영합니다! 로그인이 성공했습니다.</h1>
    <p>이제 경매 서비스 기능을 구현할 차례입니다!</p>
    <h1>환영합니다, ${sessionScope.userId}님!</h1>

    <%-- 여기에 관리자 전용 버튼 코드를 넣으세요 --%>
    <%
        String role = (String) session.getAttribute("role");
        if ("admin".equals(role)) {
    %>
        <div style="margin: 20px; padding: 15px; border: 2px solid red; display: inline-block;">
            <h3>관리자 전용 메뉴</h3>
            <a href="admin.jsp">관리자 대시보드로 이동하기</a>
        </div>
    <%
        }
    %>

    <br>
    <a href="LogoutServlet">로그아웃 하기</a> 
</body>
</html>