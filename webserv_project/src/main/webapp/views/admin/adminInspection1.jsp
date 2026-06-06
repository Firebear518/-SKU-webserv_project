<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 검수 센터 관리</title>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h2 class="fw-bold text-dark"><i class="bi bi-box-seam-fill text-primary"></i> 검수 센터 관리 장부</h2>
                <p class="text-muted mb-0">판매자가 발송한 카드의 도착 확인 및 정품 검수 상태를 관리합니다.</p>
            </div>
            <div class="btn-group shadow-sm">
                <button class="btn btn-outline-secondary active">전체</button>
                <button class="btn btn-outline-secondary">대기중</button>
                <button class="btn btn-outline-secondary">검수중</button>
                <button class="btn btn-outline-secondary">완료</button>
            </div>
        </div>

        <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-4">낙찰 번호</th>
                            <th>상품명</th>
                            <th>판매자/구매자</th>
                            <th>낙찰가</th>
                            <th>현재 상태</th>
                            <th class="text-center">액션</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td class="ps-4 text-muted small">#AU-20240501</td>
                            <td>
                                <div class="fw-bold text-dark">[포켓몬] 리자몽 VMAX SSR</div>
                                <span class="badge bg-light text-dark border small">샤이니스타V</span>
                            </td>
                            <td>
                                <div class="small">S: seller01</div>
                                <div class="small text-primary font-monospace">B: buyer_pro</div>
                            </td>
                            <td class="fw-bold">65,000원</td>
                            <td><span class="badge rounded-pill bg-warning text-dark"><i class="bi bi-truck"></i> 입고 대기</span></td>
                            <td class="text-center">
                                <button class="btn btn-sm btn-primary px-3 fw-bold">박스 입고 확인</button>
                            </td>
                        </tr>

                        <tr>
                            <td class="ps-4 text-muted small">#AU-20240498</td>
                            <td>
                                <div class="fw-bold text-dark">[유희왕] 푸른 눈의 백룡</div>
                                <span class="badge bg-light text-dark border small">홀로그래픽</span>
                            </td>
                            <td>
                                <div class="small">S: kaiba_fan</div>
                                <div class="small text-primary font-monospace">B: yugi_boy</div>
                            </td>
                            <td class="fw-bold">120,000원</td>
                            <td><span class="badge rounded-pill bg-info text-white"><i class="bi bi-search"></i> 정밀 검수중</span></td>
                            <td class="text-center">
                                <div class="btn-group">
                                    <button class="btn btn-sm btn-success px-2">검수합격</button>
                                    <button class="btn btn-sm btn-danger px-2">불합격</button>
                                </div>
                            </td>
                        </tr>

                        <tr>
                            <td class="ps-4 text-muted small">#AU-20240495</td>
                            <td>
                                <div class="fw-bold text-dark">오타니 쇼헤이 로드 투 홈런</div>
                                <span class="badge bg-light text-dark border small">스포츠</span>
                            </td>
                            <td>
                                <div class="small">S: mlb_collector</div>
                                <div class="small text-primary font-monospace">B: shohei_fans</div>
                            </td>
                            <td class="fw-bold">42,000원</td>
                            <td><span class="badge rounded-pill bg-success text-white"><i class="bi bi-check-all"></i> 검수 완료</span></td>
                            <td class="text-center text-muted small italic">낙찰자에게 배송중</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        
        <div class="mt-4 p-3 bg-white border rounded-3 small text-muted">
            <i class="bi bi-info-circle-fill text-primary"></i> 
            <strong>관리자 팁:</strong> 검수 합격 버튼을 누르면 즉시 낙찰자에게 배송 안내가 발송되며 결제가 확정됩니다. 불합격 처리 시 사유를 입력하는 팝업이 뜹니다.
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

</body>
</html>