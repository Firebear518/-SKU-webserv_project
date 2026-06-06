<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 본인 확인</title>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-5">
                <div class="card shadow-sm border-0 rounded-3 mt-4">
                    <div class="card-body p-5">
                        <h4 class="fw-bold text-center mb-2 text-dark"><i class="bi bi-shield-lock-fill text-danger"></i> 회원 정보 보호</h4>
                        <p class="text-muted text-center small mb-4">안전한 정보 변경을 위해 비밀번호를 한 번 더 입력해 주세요.</p>
                        
                        <form action="${pageContext.request.contextPath}/user/myPageConfirm" method="post">
                            
                            <div class="mb-3">
                                <label class="form-label fw-semibold text-muted">접근 계정</label>
                                <input type="text" class="form-control bg-white" value="${sessionScope.userId}" readonly disabled>
                            </div>
                            <% if ("invalid".equals(request.getParameter("error"))) { %>
<div class="alert alert-danger small py-2">비밀번호가 일치하지 않습니다.</div>
<% } %>
                            <div class="mb-4">
                                <label for="password" class="form-label fw-semibold">비밀번호 확인</label>
                                
                                <input type="password" class="form-control" id="password" name="password" placeholder="현재 비밀번호를 입력하세요" required>
                            </div>
                            
                            <button type="submit" class="btn btn-dark w-100 fw-bold py-2 shadow-sm">
                                인증 및 진입하기
                            </button>
                            
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

</body>
</html>