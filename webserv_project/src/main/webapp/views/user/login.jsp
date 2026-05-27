<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 로그인</title>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-5">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-body p-5">
                        <h3 class="fw-bold text-center mb-4 text-dark">
                            <i class="bi bi-card-isomorphic text-warning"></i> 올댓카드 로그인
                        </h3>
                        
                        <form action="${pageContext.request.contextPath}/user/login" method="post">
                            
                            <div class="mb-3">
                                <label for="userId" class="form-label fw-semibold">아이디</label>
                                <input type="text" class="form-control" id="userId" name="userId" placeholder="아이디를 입력하세요" required>
                            </div>
                            
                            <div class="mb-4">
                                <label for="password" class="form-label fw-semibold">비밀번호</label>
                                <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호를 입력하세요" required>
                            </div>
                            
                            <button type="submit" class="btn btn-warning w-100 fw-bold py-2 shadow-sm mb-3">
                                로그인
                            </button>
                            
                            <hr class="text-muted">
                            
                            <div class="text-center small">
                                <span class="text-muted">아직 회원이 아니신가요?</span>
                                <a href="${pageContext.request.contextPath}/views/user/register.jsp" class="text-primary fw-semibold text-decoration-none ms-1">회원가입 하기</a>
                            </div>
                            
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

</body>
</html>