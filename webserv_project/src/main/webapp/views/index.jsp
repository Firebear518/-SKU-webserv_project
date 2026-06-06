<%@ page contentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - All That Card</title>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        <h3 class="fw-bold text-dark mb-4"><i class="bi bi-gavel text-warning"></i> 현재 진행 중인 실시간 경매</h3>
        
        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-4 g-4">
            
            <div class="col">
                <div class="card h-100 shadow-sm border-0 rounded-3 overflow-hidden">
                    <div class="bg-secondary text-white d-flex align-items-center justify-content-center" style="height: 200px;">
                        <i class="bi bi-card-image fs-1"></i>
                    </div>
                    <div class="card-body">
                        <span class="badge bg-primary mb-2">포켓몬</span>
                        <h5 class="card-title fw-bold text-truncate mb-1">[포켓몬] 리자몽 VMAX SSR</h5>
                        <p class="text-danger small fw-bold mb-2"><i class="bi bi-clock"></i> 남은 시간: 02:15:43</p>
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <span class="text-muted small">시작가 50,000원</span>
                            <span class="fw-bold text-dark fs-5">현재가 65,000원</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col">
                <div class="card h-100 shadow-sm border-0 rounded-3 overflow-hidden">
                    <div class="bg-secondary text-white d-flex align-items-center justify-content-center" style="height: 200px;">
                        <i class="bi bi-card-image fs-1"></i>
                    </div>
                    <div class="card-body">
                        <span class="badge bg-success mb-2">유희왕</span>
                        <h5 class="card-title fw-bold text-truncate mb-1">[유희왕] 푸른 눈의 백룡 (홀로그래픽 래어)</h5>
                        <p class="text-danger small fw-bold mb-2"><i class="bi bi-clock"></i> 남은 시간: 11:04:12</p>
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <span class="text-muted small">시작가 120,000원</span>
                            <span class="fw-bold text-dark fs-5">현재가 120,000원</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col">
                <div class="card h-100 shadow-sm border-0 rounded-3 overflow-hidden">
                    <div class="bg-secondary text-white d-flex align-items-center justify-content-center" style="height: 200px;">
                        <i class="bi bi-card-image fs-1"></i>
                    </div>
                    <div class="card-body">
                        <span class="badge bg-primary mb-2">포켓몬</span>
                        <h5 class="card-title fw-bold text-truncate mb-1">[포켓몬] 피카츄 25주년 프로모</h5>
                        <p class="text-danger small fw-bold mb-2"><i class="bi bi-clock"></i> 남은 시간: 00:32:19</p>
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <span class="text-muted small">시작가 10,000원</span>
                            <span class="fw-bold text-dark fs-5">현재가 23,000원</span>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col">
                <div class="card h-100 shadow-sm border-0 rounded-3 overflow-hidden">
                    <div class="bg-secondary text-white d-flex align-items-center justify-content-center" style="height: 200px;">
                        <i class="bi bi-card-image fs-1"></i>
                    </div>
                    <div class="card-body">
                        <span class="badge bg-dark mb-2">스포츠</span>
                        <h5 class="card-title fw-bold text-truncate mb-1">오타니 쇼헤이 2024 로드 투 홈런 카드</h5>
                        <p class="text-danger small fw-bold mb-2"><i class="bi bi-clock"></i> 남은 시간: 05:41:00</p>
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <span class="text-muted small">시작가 35,000원</span>
                            <span class="fw-bold text-dark fs-5">현재가 42,000원</span>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

</body>
</html>