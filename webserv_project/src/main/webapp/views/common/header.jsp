<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

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
                    <li class="nav-item">
                        <span class="nav-link text-white me-2">
                            <i class="bi bi-person-circle text-warning"></i> <strong>${sessionScope.userId}</strong>님 환영합니다
                        </span>
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