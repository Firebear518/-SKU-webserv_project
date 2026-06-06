<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 내 정보 관리</title>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-body p-5">
                        <h3 class="fw-bold text-dark mb-1"><i class="bi bi-gear-fill text-secondary"></i> 내 정보 관리</h3>
                        <p class="text-muted small mb-4">비밀번호 및 낙찰 시 수령할 배송지 정보를 수정할 수 있습니다.</p>
                        
                        <form action="${pageContext.request.contextPath}/user/myPageUpdate" method="post" onsubmit="return validateMypageForm()">
                            
                            <h6 class="fw-bold text-secondary mb-3"><i class="bi bi-lock"></i> 비밀번호 변경</h6>
                            <div class="mb-3">
                                <label class="form-label fw-semibold text-muted">아이디 (변경 불가)</label>
                                <input type="text" class="form-control bg-light" value="${sessionScope.userId}" readonly>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="newPassword" class="form-label fw-semibold">새 비밀번호</label>
                                    <input type="password" class="form-control" id="newPassword" name="newPassword" placeholder="변경할 새 비밀번호">
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="newPasswordConfirm" class="form-label fw-semibold">새 비밀번호 확인</label>
                                    <input type="password" class="form-control" id="newPasswordConfirm" placeholder="한번 더 입력">
                                </div>
                            </div>
                            <div id="passwordError" class="form-text text-danger d-none mb-3">새 비밀번호가 서로 일치하지 않습니다.</div>

                            <hr class="my-4 text-muted">

                            <h6 class="fw-bold text-secondary mb-3"><i class="bi bi-truck"></i> 배송지 정보 수정</h6>
                            
                            <div class="mb-3">
                                <label for="userPhone" class="form-label fw-semibold">배송 연락처</label>
                                <input type="tel" class="form-control" id="userPhone" name="userPhone" value="010-1234-5678" required>
                            </div>

                            <div class="mb-2">
                                <label for="userAddress" class="form-label fw-semibold">배송지 주소</label>
                                <input type="text" class="form-control" id="userAddress" name="userAddress" value="서울시 성북구 서경로 124" required>
                            </div>
                            <div class="mb-4">
                                <input type="text" class="form-control" id="userAddressDetail" name="userAddressDetail" value="연구동 3층 소프트웨어학과 학과사무실" required>
                            </div>

                            <button type="submit" class="btn btn-warning w-100 fw-bold py-2 shadow-sm text-dark">
                                <i class="bi bi-check-lg"></i> 회원 정보 수정 완료
                            </button>
                            
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

    <script>
    function validateMypageForm() {
        const newPassword = document.getElementById('newPassword').value;
        const confirm = document.getElementById('newPasswordConfirm').value;
        const errorDiv = document.getElementById('passwordError');
        
        // 비밀번호를 변경하려고 값을 입력했을 때만 검증 수행
        if (newPassword.trim().length > 0) {
            if (newPassword !== confirm) {
                errorDiv.classList.remove('d-none');
                document.getElementById('newPasswordConfirm').focus();
                return false;
            }
        }
        
        errorDiv.classList.add('d-none');
        return true;
    }
    </script>

</body>
</html>