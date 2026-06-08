<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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

        <%-- ───────────────────────────────────────────── --%>
        <%--  내가 등록한 상품 관리 (seller_id = 현재 세션 userId) --%>
        <%-- ───────────────────────────────────────────── --%>
        <div class="row justify-content-center mt-5">
            <div class="col-lg-9">
                <div class="card shadow-sm border-0 rounded-3">
                    <div class="card-body p-4 p-md-5">
                        <h3 class="fw-bold text-dark mb-1"><i class="bi bi-box-seam text-warning"></i> 내 상품 관리</h3>
                        <p class="text-muted small mb-4">내가 등록한 경매 상품의 진행 상태를 관리하고, 낙찰/유찰을 결정할 수 있습니다.</p>

                        <c:choose>
                            <c:when test="${empty myProducts}">
                                <div class="text-center py-5 text-muted">
                                    <i class="bi bi-inbox display-4"></i>
                                    <p class="mt-3 mb-3">아직 등록한 상품이 없습니다.</p>
                                    <a href="${pageContext.request.contextPath}/views/board/productRegister.jsp"
                                       class="btn btn-warning fw-bold"><i class="bi bi-plus-circle"></i> 상품 등록하러 가기</a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="table-responsive">
                                    <table class="table align-middle">
                                        <thead class="table-light">
                                            <tr>
                                                <th>상품</th>
                                                <th class="text-end">현재가</th>
                                                <th class="text-center">마감</th>
                                                <th class="text-center">상태</th>
                                                <th class="text-center" style="width: 260px;">관리</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        <c:forEach var="p" items="${myProducts}">
                                            <%-- 상태 라벨/뱃지 --%>
                                            <c:set var="statusBadge" value="bg-secondary" />
                                            <c:set var="statusLabel" value="진행중" />
                                            <c:choose>
                                                <c:when test="${p.auctionStatus == 'SOLD'}">
                                                    <c:set var="statusBadge" value="bg-success" />
                                                    <c:set var="statusLabel" value="낙찰" />
                                                </c:when>
                                                <c:when test="${p.auctionStatus == 'FAILED'}">
                                                    <c:set var="statusBadge" value="bg-dark" />
                                                    <c:set var="statusLabel" value="유찰" />
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="statusBadge" value="bg-primary" />
                                                    <c:set var="statusLabel" value="진행중" />
                                                </c:otherwise>
                                            </c:choose>
                                            <tr>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/product/detail?productId=${p.productId}"
                                                       class="d-flex align-items-center text-decoration-none text-dark">
                                                        <img src="${pageContext.request.contextPath}${fn:escapeXml(p.imagePath)}"
                                                             onerror="this.src='https://via.placeholder.com/48?text=No'"
                                                             style="width:48px;height:48px;object-fit:cover;border-radius:8px;"
                                                             class="me-2 border" alt="상품 이미지">
                                                        <span class="fw-semibold text-truncate" style="max-width:220px;">${fn:escapeXml(p.title)}</span>
                                                    </a>
                                                </td>
                                                <td class="text-end fw-bold text-danger">
                                                    ₩ <fmt:formatNumber value="${p.currentPrice}" type="number"/>
                                                </td>
                                                <td class="text-center small text-muted">
                                                    <c:choose>
                                                        <c:when test="${not empty p.endTime}">${fn:substring(p.endTime, 0, 16)}</c:when>
                                                        <c:otherwise>-</c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-center">
                                                    <span class="badge ${statusBadge}">${statusLabel}</span>
                                                </td>
                                                <td class="text-center">
                                                    <c:if test="${p.auctionStatus == 'ONGOING' or empty p.auctionStatus}">
                                                        <button type="button" class="btn btn-sm btn-success"
                                                                onclick="decideAuction(${p.auctionId}, 'sold')">
                                                            <i class="bi bi-check-lg"></i> 낙찰
                                                        </button>
                                                        <button type="button" class="btn btn-sm btn-outline-dark"
                                                                onclick="decideAuction(${p.auctionId}, 'failed')">
                                                            <i class="bi bi-x-lg"></i> 유찰
                                                        </button>
                                                    </c:if>
                                                    <button type="button" class="btn btn-sm btn-outline-danger"
                                                            onclick="deleteProduct(${p.productId}, '${fn:escapeXml(p.title)}')">
                                                        <i class="bi bi-trash"></i> 삭제
                                                    </button>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
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

    // 낙찰/유찰 결정 → 팀원 구현 엔드포인트(/auctionDecision)에 연결
    function decideAuction(auctionId, decision) {
        if (!auctionId) {
            alert("경매 정보가 없는 상품입니다.");
            return;
        }
        const label = decision === 'sold' ? '낙찰' : '유찰';
        if (!confirm("이 상품을 '" + label + "' 처리하시겠습니까? 결정 후에는 되돌릴 수 없습니다.")) return;

        fetch("${pageContext.request.contextPath}/auctionDecision", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "auctionId=" + auctionId + "&decision=" + decision
        })
        .then(res => res.json())
        .then(data => {
            alert(data.message || (data.success ? "처리되었습니다." : "처리에 실패했습니다."));
            if (data.success) location.reload();
        })
        .catch(() => alert("서버 오류가 발생했습니다."));
    }

    // 상품 삭제 → /DeleteProductServlet (GET) 로 연결
    function deleteProduct(productId, title) {
        if (!confirm("'" + title + "' 상품을 삭제하시겠습니까?\n관련 경매/입찰/댓글 내역도 함께 삭제됩니다.")) return;
        location.href = "${pageContext.request.contextPath}/DeleteProductServlet?id=" + productId;
    }
    </script>

</body>
</html>