<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    int unreadCount = 0;
    String loginUserId = (String) session.getAttribute("userId");
    if (loginUserId != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection notiConn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8",
                "root", "ASDasd336699@");
            PreparedStatement notiPstmt = notiConn.prepareStatement(
                "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
            notiPstmt.setString(1, loginUserId);
            ResultSet notiRs = notiPstmt.executeQuery();
            if (notiRs.next()) unreadCount = notiRs.getInt(1);
            notiRs.close(); notiPstmt.close(); notiConn.close();
        } catch (Exception e) { }
    }
%>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold text-warning" href="${pageContext.request.contextPath}/index.jsp">
            <i class="bi bi-card-isomorphic"></i> 올댓카드 (All That Card)
        </a>

        <button class="navbar-dark navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/views/board/productList.jsp">
                        <i class="bi bi-list-ul"></i> 카드 경매장
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-info fw-semibold" href="${pageContext.request.contextPath}/views/board/productRegister.jsp">
                        <i class="bi bi-robot"></i> 상품등록
                    </a>
                </li>
            </ul>

            <ul class="navbar-nav mb-2 mb-lg-0">

                <c:if test="${empty sessionScope.userId}">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/user/login.jsp">
                            <i class="bi bi-box-arrow-in-right"></i> 로그인
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/user/register.jsp">
                            <i class="bi bi-person-plus"></i> 회원가입
                        </a>
                    </li>
                </c:if>

                <c:if test="${not empty sessionScope.userId}">
                    <!-- 🔔 알림 아이콘 -->
                    <li class="nav-item dropdown me-2">
                        <a class="nav-link position-relative" href="#" data-bs-toggle="dropdown">
                            <i class="bi bi-bell-fill text-warning fs-5"></i>
                            <% if (unreadCount > 0) { %>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger" style="font-size:0.6rem;">
                                <%= unreadCount %>
                            </span>
                            <% } %>
                        </a>
                        <div class="dropdown-menu dropdown-menu-end p-0 shadow" style="width:340px; max-height:400px; overflow-y:auto;">
                            <div class="p-3 border-bottom fw-bold text-dark bg-light">
                                <i class="bi bi-bell-fill text-warning"></i> 알림
                            </div>
                            <%
                                if (loginUserId != null) {
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        Connection notiConn2 = DriverManager.getConnection(
                                            "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8",
                                            "root", "ASDasd336699@");
                                        PreparedStatement notiPstmt2 = notiConn2.prepareStatement(
                                            "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 10");
                                        notiPstmt2.setString(1, loginUserId);
                                        ResultSet notiRs2 = notiPstmt2.executeQuery();
                                        boolean hasNoti = false;
                                        while (notiRs2.next()) {
                                            hasNoti = true;
                                            int notiId = notiRs2.getInt("noti_id");
                                            int auctionId = notiRs2.getInt("auction_id");
                                            String msg = notiRs2.getString("message");
                                            String type = notiRs2.getString("noti_type");
                                            boolean isRead = notiRs2.getInt("is_read") == 1;
                            %>
                            <div class="p-3 border-bottom" style="<%= isRead ? "background:#fff;" : "background:#fffde7;" %>">
                                <div class="small text-dark mb-1"><%= msg %></div>
                                <% if ("REJECT_CHOICE".equals(type) && !isRead) { %>
                                <div class="d-flex gap-2 mt-2">
                                    <a href="${pageContext.request.contextPath}/user/notiChoice?notiId=<%= notiId %>&auctionId=<%= auctionId %>&choice=RECEIVE"
                                       class="btn btn-sm btn-success px-3">수령하기</a>
                                    <a href="${pageContext.request.contextPath}/user/notiChoice?notiId=<%= notiId %>&auctionId=<%= auctionId %>&choice=RETURN"
                                       class="btn btn-sm btn-danger px-3">반품하기</a>
                                </div>
                                <% } %>
                            </div>
                            <%
                                        }
                                        if (!hasNoti) {
                            %>
                            <div class="p-4 text-center text-muted small">새로운 알림이 없습니다.</div>
                            <%
                                        }
                                        notiRs2.close(); notiPstmt2.close(); notiConn2.close();
                                    } catch (Exception e) { }
                                }
                            %>
                        </div>
                    </li>

                    <li class="nav-item">
                        <span class="nav-link text-white me-2">
                            <i class="bi bi-person-circle text-warning"></i> <strong>${sessionScope.userId}</strong>님 환영합니다
                        </span>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-warning fw-semibold" href="${pageContext.request.contextPath}/user/myPage">
                            <i class="bi bi-box-seam"></i> 내 상품 관리
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-white-50" href="${pageContext.request.contextPath}/views/user/myPageConfirm.jsp">
                            <i class="bi bi-person-gear"></i> 내 정보 관리
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link text-light-50" href="${pageContext.request.contextPath}/user/logout">
                            <i class="bi bi-box-arrow-left"></i> 로그아웃
                        </a>
                    </li>
                </c:if>

                <c:if test="${sessionScope.userRole eq 'ADMIN'}">
                    <li class="nav-item">
                        <a class="nav-link text-danger fw-bold" href="${pageContext.request.contextPath}/admin/dashboard">
                            <i class="bi bi-shield-lock"></i> 관리자 모드
                        </a>
                    </li>
                </c:if>

            </ul>
        </div>
    </div>
</nav>