<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 회원가입</title>
 
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

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        <div class="row justify-content-center">
            <div class="col-md-6"> <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-body p-5">
                        <h3 class="fw-bold text-center mb-2 text-dark">👋 회원가입</h3>
                        <p class="text-muted text-center small mb-4">올댓카드는 안전한 '검수 후 배송' 시스템을 제공합니다.</p>
                        
                        <form action="${pageContext.request.contextPath}/user/register" method="post" onsubmit="return validateForm()">
                            
                            <h6 class="fw-bold text-secondary mb-3"><i class="bi bi-person-badge"></i> 기본 계정 정보</h6>
                            
                            <div class="mb-3">
                                <label for="userId" class="form-label fw-semibold">아이디</label>
                                <input type="text" class="form-control" id="userId" name="userId" placeholder="사용할 아이디 입력" required>
                            </div>

                            <div class="mb-3">
                                <label for="userName" class="form-label fw-semibold">이름 (실명 권장)</label>
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
                            
                            <hr class="my-4 text-muted">
                            <h6 class="fw-bold text-secondary mb-3"><i class="bi bi-truck"></i> 상품 배송지 정보 (낙찰 시 수령 주소)</h6>

                            <div class="mb-3">
                                <label for="userPhone" class="form-label fw-semibold">연락처</label>
                                <input type="tel" class="form-control" id="userPhone" name="userPhone" placeholder="010-1234-5678" required>
                            </div>

                            <div class="mb-2">
                                <label for="userAddress" class="form-label fw-semibold">배송지 주소</label>
                                <input type="text" class="form-control" id="userAddress" name="userAddress" placeholder="예: 서울시 성북구 서경로 124" required>
                            </div>
                            <div class="mb-4">
                                <input type="text" class="form-control" id="userAddressDetail" name="userAddressDetail" placeholder="상세 주소 입력 (아파트 동/호수, 빌라 호수 등)" required>
                            </div>

                            <hr class="my-4 text-muted">
                            <h6 class="fw-bold text-secondary mb-3"><i class="bi bi-check-circle-fill"></i> 약관 및 서비스 동의</h6>

                            <div class="mb-2">
                                <div class="privacy-box text-muted">
                                    <strong>[올댓카드 개인정보 수집 및 제3자 제공 동의]</strong><br>
                                    1. 수집 항목: 아이디, 이름, 연락처, 배송지 주소<br>
                                    2. 수집 및 이용 목적: 플랫폼 내 경매 진행, 낙찰 대금 정산 및 당사 검수 센터를 통한 3자 물류 배송(판매자 -> 검수센터 -> 구매자) 처리<br>
                                    3. <strong>제3자 제공 안내:</strong> 본 플랫폼은 안전 거래 및 검수 대행을 위해 낙찰 발생 시 회원 간의 배송 정보 연동을 지원하며, 배송 대행사 및 검수 파트너에게 물품 배송 목적으로 최소한의 정보가 제공될 수 있습니다.<br>
                                    4. 보유 및 이용 기간: 회원 탈퇴 시 즉시 파기 (단, 전자상거래법 등 관계법령에 따름)
                                </div>
                            </div>

                            <div class="form-check mb-4">
                                <input class="form-check-input" type="checkbox" id="privacyAgree" required>
                                <label class="form-check-label small fw-semibold text-dark" for="privacyAgree">
                                    (필수) 개인정보 수집 및 배송 처리를 위한 제3자 제공에 동의합니다.
                                </label>
                            </div>
                            
                            <button type="submit" class="btn btn-dark w-100 fw-bold py-2 shadow-sm mb-3">
  								동의하고 가입하기
                            </button>
                            
                            
                            <hr class="text-muted">
                            
                            <div class="text-center small">
                                <span class="text-muted">이미 계정이 있으신가요?</span>
                                <a href="${pageContext.request.contextPath}/views/user/login.jsp" class="text-primary fw-semibold text-decoration-none ms-1">로그인 하기</a>
                            </div>
                            
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

    <script>
    function validateForm() {
        const password = document.getElementById('password').value;
        const confirm = document.getElementById('passwordConfirm').value;
        const errorDiv = document.getElementById('passwordError');
        const privacyAgree = document.getElementById('privacyAgree').checked;
        
        // 1. 비밀번호 일치 검증
        if (password !== confirm) {
            errorDiv.classList.remove('d-none');
            document.getElementById('passwordConfirm').focus();
            return false;
        }
        errorDiv.classList.add('d-none');
        
        // 2. 약관 동의 검증 (기본 HTML required가 있지만 안전장치로 추가)
        if (!privacyAgree) {
            alert('개인정보 수집 및 제3자 제공에 동의하셔야 가입이 가능합니다.');
            return false;
        }
        
        return true;
    }
    </script>

</body>
</html>