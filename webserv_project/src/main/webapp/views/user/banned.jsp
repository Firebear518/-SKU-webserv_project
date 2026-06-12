<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>계정 정지 안내</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="min-height:100vh;">
    <div class="card border-0 shadow-sm rounded-4 p-5 text-center" style="max-width:480px; width:100%;">
        <div class="mb-4">
            <i class="bi bi-shield-fill-x text-danger" style="font-size:4rem;"></i>
        </div>
        <h4 class="fw-bold text-danger mb-3">계정이 정지되었습니다</h4>
        <p class="text-muted mb-4">
            귀하의 계정은 운영 정책 위반으로 인해<br>
            <strong>영구 정지(BAN)</strong> 처리되었습니다.<br><br>
            문의사항이 있으시면 관리자에게 연락해 주세요.
        </p>
        <a href="${pageContext.request.contextPath}/views/user/login.jsp" 
           class="btn btn-outline-secondary rounded-pill px-4">
            <i class="bi bi-arrow-left"></i> 로그인 페이지로 돌아가기
        </a>
    </div>
</body>
</html>