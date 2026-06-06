<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 회원가입</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .privacy-box {
            max-height: 120px;
            overflow-y: scroll;
            font-size: 0.8rem;
            background-color: #f8f9fa;
            border: 1px solid #dee2e6;
            padding: 10px;
            border-radius: 4px;
        }
    </style>
</head>
<body class="bg-light">

    <div class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-body p-5">
                        <h3 class="fw-bold text-center mb-2 text-dark">👋 회원가입</h3>
                        <p class="text-muted text-center small mb-4">올댓카드는 안전한 '검수 후 배송' 시스템을 제공합니다.</p>

                        <form action="<%= request.getContextPath() %>/user/register" method="post" onsubmit="return validateForm()">

                            <h6 class="fw-bold text-secondary mb-3">기본 계정 정보</h6>

                            <div class="mb-3">
                                <label for="userId" class="form-label fw-semibold">아이디</label>
                                <input type="text" class="form-control" id="userId" name="userId" placeholder="사용할 아이디 입력" required>
                            </div>

                            <div class="mb-3">
                                <label for="userName" class="form-label fw-semibold">이름</label>
                                <input type="text" class="form-control" id="userName" name="userName" placeholder="홍길동" required>
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label fw-semibold">비밀번호</label>
                                <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호 입력" required>
                            </div>

                            <div class="mb-4">
                                <label for="passwordConfirm" class="form-label fw-semibold">비밀번호 확인</label>
                                <input type="password" class="form-control" id="passwordConfirm" placeholder="비밀번호 확인" required>
                                <div id="passwordError" class="form-text text-danger d-none">비밀번호가 일치하지 않습니다.</div>
                            </div>

                            <hr class="my-4">
                            <h6 class="fw-bold text-secondary mb-3">배송지 정보</h6>

                            <div class="mb-3">
                                <label for="userPhone" class="form-label fw-semibold">연락처</label>
                                <input type="tel" class="form-control" id="userPhone" name="userPhone" placeholder="010-1234-5678" required>
                            </div>

                            <div class="mb-2">
                                <label for="userAddress" class="form-label fw-semibold">배송지 주소</label>
                                <input type="text" class="form-control" id="userAddress" name="userAddress" placeholder="서울시 성북구 서경로 124" required>
                            </div>
                            <div class="mb-4">
                                <input type="text" class="form-control" id="userAddressDetail" name="userAddressDetail" placeholder="상세 주소 입력" required>
                            </div>

                            <hr class="my-4">
                            <h6 class="fw-bold text-secondary mb-3">약관 동의</h6>

                            <div class="mb-2">
                                <div class="privacy-box text-muted">
                                    <strong>[개인정보 수집 및 제3자 제공 동의]</strong><br>
                                    1. 수집 항목: 아이디, 이름, 연락처, 배송지 주소<br>
                                    2. 수집 목적: 경매 진행, 낙찰 대금 정산 및 배송 처리<br>
                                    3. 보유 기간: 회원 탈퇴 시 즉시 파기
                                </div>
                            </div>

                            <div class="form-check mb-4">
                                <input class="form-check-input" type="checkbox" id="privacyAgree" required>
                                <label class="form-check-label small fw-semibold" for="privacyAgree">
                                    (필수) 개인정보 수집 및 제3자 제공에 동의합니다.
                                </label>
                            </div>

                            <button type="submit" class="btn btn-dark w-100 fw-bold py-2 mb-3">
                                동의하고 가입하기
                            </button>

                            <hr>

                            <div class="text-center small">
                                <span class="text-muted">이미 계정이 있으신가요?</span>
                                <a href="<%= request.getContextPath() %>/views/user/login.jsp" class="text-primary fw-semibold text-decoration-none ms-1">로그인 하기</a>
                            </div>

                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    function validateForm() {
        const password = document.getElementById('password').value;
        const confirm  = document.getElementById('passwordConfirm').value;
        const errorDiv = document.getElementById('passwordError');

        if (password !== confirm) {
            errorDiv.classList.remove('d-none');
            document.getElementById('passwordConfirm').focus();
            return false;
        }
        errorDiv.classList.add('d-none');
        return true;
    }
    </script>
</body>
</html>