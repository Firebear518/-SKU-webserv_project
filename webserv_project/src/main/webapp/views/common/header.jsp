<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<%
    int unreadCount = 0;
    String loginUserId = (String) session.getAttribute("userId");
    String loginAdminId = (String) session.getAttribute("adminId"); // 🎯 관리자 세션 체크
    
    // 🎯 관리자가 아닐 때(일반 유저일 때)만 알림 DB를 조회하도록 철저히 분리
    if (loginUserId != null && loginAdminId == null) {
        try {
            Connection notiConn = DBUtil.getConnection();
            PreparedStatement notiPstmt = notiConn.prepareStatement(
                "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
            notiPstmt.setString(1, loginUserId);
            ResultSet notiRs = notiPstmt.executeQuery();
            if (notiRs.next()) unreadCount = notiRs.getInt(1);
            notiRs.close(); notiPstmt.close(); notiConn.close();
        } catch (Exception e) { 
            e.printStackTrace(); 
        }
    }
%>

<link href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" rel="stylesheet">
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
                    <a class="nav-link" href="${pageContext.request.contextPath}/board/list.do">
                        <i class="bi bi-list-ul"></i> 카드 경매장
                    </a>
                </li>
                <%-- 🎯 일반 유저에게만 '상품등록' 버튼 노출 --%>
                <c:if test="${not empty sessionScope.userId and empty sessionScope.adminId}">
                    <li class="nav-item">
                        <a class="nav-link text-info fw-semibold" href="${pageContext.request.contextPath}/views/board/productRegister.jsp">
                            <i class="bi bi-robot"></i> 상품등록
                        </a>
                    </li>
                </c:if>
            </ul>
            
            <ul class="navbar-nav mb-2 mb-lg-0">
                <c:choose>
                    <%-- 1️⃣ [우선순위 1] 관리자로 로그인한 상태 --%>
                    <c:when test="${not empty sessionScope.adminId}">
                        <li class="nav-item">
                            <span class="nav-link text-danger fw-bold me-2">
                                <i class="bi bi-shield-lock-fill"></i> <strong>관리자</strong>님 환영합니다
                            </span>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link text-warning fw-bold" href="${pageContext.request.contextPath}/views/admin/adminInspection.jsp">
                                <i class="bi bi-list-check"></i> 검수 센터 관리 장부
                            </a>
                        </li>
                    </c:when>

                    <%-- 2️⃣ [우선순위 2] 일반 유저로 로그인한 상태 --%>
                    <c:when test="${not empty sessionScope.userId}">
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
        if (loginUserId != null && loginAdminId == null) {
        	try {
                Connection notiConn2 = DBUtil.getConnection();
                
                // 🌟 [수정] 위에서 확인한 실제 테이블명 'products'와 상품명 컬럼 'title'을 반영한 3중 JOIN 쿼리
                // 🌟 [수정 완료] 기존 쿼리를 지우고 이 코드로 교체하세요.
PreparedStatement notiPstmt2 = notiConn2.prepareStatement(
    "SELECT n.*, p.title " +
    "FROM notifications n " +
    "LEFT JOIN auction a ON n.auction_id = a.auction_id " +
    "LEFT JOIN products p ON a.product_id = p.product_id " + 
    "WHERE n.user_id = ? " +
    "ORDER BY n.created_at DESC LIMIT 10"
);
notiPstmt2.setString(1, loginUserId);
ResultSet notiRs2 = notiPstmt2.executeQuery();
boolean hasNoti = false;

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

while (notiRs2.next()) {
    hasNoti = true;
    int notiId = notiRs2.getInt("noti_id");
    int auctionId = notiRs2.getInt("auction_id");
    String msg = notiRs2.getString("message");
    String type = notiRs2.getString("noti_type");
    boolean isRead = notiRs2.getInt("is_read") == 1;
    
    Timestamp createdAt = notiRs2.getTimestamp("created_at");
    String timeStr = (createdAt != null) ? sdf.format(createdAt) : "";
    
    // 🌟 [중요] DB에서 'product_name'이 아니라, 실제 테이블의 'title' 컬럼으로 가져옵니다.
    String productName = notiRs2.getString("title");
    String pNameStr = (productName != null) ? productName : "상품 정보 없음";
    %>
    <div class="p-3 border-bottom" style="<%= isRead ? "background:#fff;" : "background:#fffde7;" %>">
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="badge bg-secondary" style="font-size:0.75rem; text-overflow: ellipsis; white-space: nowrap; overflow: hidden; max-width: 70%;"><%= pNameStr %></span>
            <span style="font-size: 11px; color: #888;"><%= timeStr %></span>
        </div>
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
            } catch (Exception e) { 
                e.printStackTrace(); 
    %>
    <div class="p-3 text-danger small bg-light border-top">
        <i class="bi bi-exclamation-triangle-fill"></i> <strong>SQL/JSP 에러 발생:</strong><br>
        <code style="color: #dc3545; word-break: break-all;"><%= e.getMessage() %></code>
    </div>
    <%
            }
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
                                <i class="bi bi-person-circle"></i> 마이페이지
                            </a>
                        </li>
                        
                        <li class="nav-item">
                            <a class="nav-link text-light-50" href="${pageContext.request.contextPath}/user/logout">
                                <i class="bi bi-box-arrow-left"></i> 로그아웃
                            </a>
                        </li>
                    </c:when>

                    <%-- 3️⃣ [우선순위 3] 비회원 상태 (관리자도, 일반유저도 아닐 때) --%>
                    <c:otherwise>
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
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
</nav>