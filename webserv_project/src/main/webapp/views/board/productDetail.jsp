<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - ${fn:escapeXml(product.title)}</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        .detail-card-zone {
            perspective: 1000px;
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }
        .tilt-card-detail {
            width: 280px;
            height: 392px;
            border-radius: 14px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.3);
            overflow: hidden;
            background-color: #fff;
            transform-style: preserve-3d;
        }
        .tilt-card-detail img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            pointer-events: none;
        }
        .detail-thumb-box {
            width: 75px; height: 75px;
            object-fit: cover;
            border-radius: 8px;
            cursor: pointer;
            border: 2px solid #dee2e6;
            transition: all 0.2s;
        }
        .detail-thumb-box:hover {
            border-color: #0d6efd;
            transform: scale(1.05);
        }
        .price-board {
            background-color: #212529;
            color: #ffc107;
            border-radius: 10px;
            padding: 15px;
            font-family: 'Courier New', Courier, monospace;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }
        .seller-badge {
            background-color: #ffc107;
            color: #212529;
            font-size: 0.75rem;
            font-weight: bold;
            padding: 2px 6px;
            border-radius: 4px;
            margin-left: 5px;
        }
    </style>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <%
        String userRole = (String) session.getAttribute("userRole");
        if ("ADMIN".equals(userRole)) {
    %>
        <div class="bg-dark text-white py-2 shadow-sm">
            <div class="container d-flex justify-content-between align-items-center">
                <span class="small text-warning fw-bold"><i class="bi bi-shield-lock-fill"></i> 관리자 전용 권한 모드</span>
                <div class="btn-group btn-group-sm">
                    <button type="button" class="btn btn-outline-warning" onclick="toggleBlindPost()"><i class="bi bi-eye-slash"></i> 게시글 일시 숨김</button>
                    <button type="button" class="btn btn-outline-danger" onclick="forceDeletePost()"><i class="bi bi-trash"></i> 강제 즉시 삭제</button>
                </div>
            </div>
        </div>
    <%
        }
    %>

    <c:if test="${empty product}">
        <div class="container my-5 text-center">
            <h3 class="text-secondary">존재하지 않는 상품입니다.</h3>
            <a href="${pageContext.request.contextPath}/board/list.do" class="btn btn-primary mt-3">목록으로 돌아가기</a>
        </div>
    </c:if>

    <c:if test="${not empty product}">

    <%-- 카테고리 뱃지 색상 --%>
    <c:set var="badgeClass" value="bg-secondary" />
    <c:set var="categoryLabel" value="${fn:escapeXml(product.categoryName)}" />
    <c:choose>
        <c:when test="${product.categoryName == 'POKEMON'}">
            <c:set var="badgeClass" value="bg-primary" />
            <c:set var="categoryLabel" value="포켓몬 카드" />
        </c:when>
        <c:when test="${product.categoryName == 'YUGIOH'}">
            <c:set var="badgeClass" value="bg-danger" />
            <c:set var="categoryLabel" value="유희왕" />
        </c:when>
        <c:when test="${product.categoryName == 'SPORTS'}">
            <c:set var="badgeClass" value="bg-success" />
            <c:set var="categoryLabel" value="스포츠 카드" />
        </c:when>
    </c:choose>

    <div class="container my-5">
        <div class="row g-5">

            <div class="col-md-5 text-center">
                <div class="mb-2 text-start small text-muted fw-bold"><i class="bi bi-gem"></i> 대표 카드</div>
                <div class="detail-card-zone">
                    <div class="tilt-card-detail" data-tilt>
                        <img id="mainCardImg"
                             src="${pageContext.request.contextPath}${fn:escapeXml(product.imagePath)}"
                             alt="메인 대표 카드"
                             onerror="this.src='https://via.placeholder.com/280x392?text=No+Image'">
                    </div>
                </div>

                <%-- 상세 이미지 썸네일 갤러리 --%>
                <c:if test="${not empty product.detailImageList}">
                    <div class="mb-2 text-start small text-muted fw-bold mt-3"><i class="bi bi-images"></i> 상세 사진</div>
                    <div class="d-flex flex-wrap gap-2 justify-content-center">
                        <c:forEach var="imgPath" items="${product.detailImageList}">
                            <img src="${pageContext.request.contextPath}${fn:escapeXml(imgPath)}"
                                 class="detail-thumb-box"
                                 alt="상세 사진"
                                 onclick="openZoomModal('${pageContext.request.contextPath}${fn:escapeXml(imgPath)}')"
                                 onerror="this.style.display='none'">
                        </c:forEach>
                    </div>
                </c:if>
            </div>

            <div class="col-md-7">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge ${badgeClass} fs-6">${categoryLabel}</span>
                    <span class="text-muted small">등록 유저 ID: <b>${fn:escapeXml(product.sellerId)}</b></span>
                </div>

                <h2 class="fw-bold text-dark mb-3">${fn:escapeXml(product.title)}</h2>

                <div class="price-board mb-4">
                    <div class="d-flex justify-content-between mb-2">
                        <span>경매 시작가</span>
                        <span class="text-white">
                            ₩ <fmt:formatNumber value="${not empty auction ? auction.startPrice : product.price}" type="number"/>
                        </span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center border-top pt-2">
                        <span class="fs-5 fw-bold text-white"><i class="bi bi-graph-up-arrow text-danger"></i> 현재 최고 입찰가</span>
                        <span class="fs-3 fw-bold" id="currentHighestPrice">
                            ₩ <fmt:formatNumber value="${not empty auction ? auction.currentPrice : product.price}" type="number"/>
                        </span>
                    </div>
                    <div class="d-flex justify-content-between small text-secondary mt-2 border-top pt-1">
                        <span>경매 마감 시간</span>
                        <span class="text-light">
                            <c:choose>
                                <c:when test="${not empty auction}">${fn:escapeXml(auction.endTime)}</c:when>
                                <c:otherwise>미정</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </div>

                <div class="card border-0 shadow-sm rounded-3 p-4 bg-white mb-4">
                    <h6 class="fw-bold text-dark mb-3"><i class="bi bi-hammer text-info"></i> 경매 입찰 참여하기</h6>
                    <div class="row g-2">
                        <div class="col-sm-8">
                            <div class="input-group">
                                <span class="input-group-text bg-light fw-bold">₩</span>
                                <input type="number" id="bidAmountInput" class="form-control form-control-lg fw-bold" placeholder="입찰하실 금액 입력">
                            </div>
                            <div class="form-text text-danger mt-1">※ 최고가보다 높은 금액만 입찰 신청 가능합니다.</div>
                        </div>
                        <div class="col-sm-4">
                            <button type="button" id="submitBidBtn" class="btn btn-warning btn-lg w-100 fw-bold h-100 shadow-sm"
                                    onclick="submitBidAction(${not empty auction ? auction.auctionId : 0}, ${not empty auction ? auction.currentPrice : product.price})">
                                <i class="bi bi-wallet2"></i> 입찰 신청
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card border-0 shadow-sm rounded-3 p-4 my-5 bg-white">
            <h5 class="fw-bold text-dark mb-3 border-bottom pb-2"><i class="bi bi-file-earmark-text-fill text-secondary"></i> 상품 상세 설명</h5>
            <p class="text-secondary lh-lg mb-0" style="white-space: pre-line;">${fn:escapeXml(product.description)}</p>
        </div>

        <div class="card border-0 shadow-sm rounded-3 p-4 bg-white">
            <h5 class="fw-bold text-dark mb-4"><i class="bi bi-chat-dots-fill text-primary"></i> 회원 문의 및 댓글</h5>
            <div class="d-flex gap-3 mb-4">
                <div class="flex-grow-1">
                    <textarea id="commentInput" class="form-control" rows="2" placeholder="상품 상태나 질문을 작성해 보세요."></textarea>
                </div>
                <button type="button" class="btn btn-primary px-4 fw-bold" onclick="addCommentMock()">등록</button>
            </div>
            <div class="comment-list-box d-flex flex-column gap-3" id="commentListContainer">
                <p class="text-muted small">아직 등록된 댓글이 없습니다.</p>
            </div>
        </div>
    </div>

    </c:if><%-- end c:if product --%>

    <div class="modal fade" id="imageZoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content bg-transparent border-0">
                <div class="modal-body text-center p-0 position-relative">
                    <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3 fs-4" data-bs-dismiss="modal"></button>
                    <img id="modalZoomImg" src="" class="img-fluid rounded shadow-lg" style="max-height: 85vh;" alt="확대보기">
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/vanilla-tilt/1.8.1/vanilla-tilt.min.js"></script>

    <script>
        VanillaTilt.init(document.querySelectorAll(".tilt-card-detail"), {
            max: 20, speed: 400, glare: true, "max-glare": 0.4, scale: 1.04
        });

        function openZoomModal(src) {
            document.getElementById('modalZoomImg').src = src;
            new bootstrap.Modal(document.getElementById('imageZoomModal')).show();
        }

        let isBiddingInProgress = false;

        function submitBidAction(auctionId, currentHighPrice) {
            if (isBiddingInProgress) {
                alert("이전 입찰 요청이 아직 처리 중입니다.");
                return;
            }

            const bidInput = document.getElementById('bidAmountInput');
            const bidVal   = parseInt(bidInput.value);

            if (!bidVal || bidVal <= currentHighPrice) {
                alert("현재 최고가(" + currentHighPrice.toLocaleString() + "원)보다 높은 금액을 입력해 주세요.");
                return;
            }

            if (confirm("₩ " + bidVal.toLocaleString() + "원으로 입찰을 확정하시겠습니까?")) {
                isBiddingInProgress = true;
                const bidBtn = document.getElementById('submitBidBtn');
                bidBtn.disabled = true;
                bidBtn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> 처리 중...';

                fetch("${pageContext.request.contextPath}/bid", {
                    method: "POST",
                    headers: { "Content-Type": "application/x-www-form-urlencoded" },
                    body: "auctionId=" + auctionId + "&bidPrice=" + bidVal
                })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        document.getElementById('currentHighestPrice').innerText =
                            "₩ " + bidVal.toLocaleString();
                        bidInput.value = "";
                        alert("입찰이 성공적으로 접수되었습니다!");
                        currentHighPrice = bidVal;
                    } else {
                        alert("입찰 실패: " + (data.message || "다시 시도해 주세요."));
                    }
                })
                .catch(() => alert("서버 오류가 발생했습니다."))
                .finally(() => {
                    isBiddingInProgress = false;
                    bidBtn.disabled = false;
                    bidBtn.innerHTML = '<i class="bi bi-wallet2"></i> 입찰 신청';
                });
            }
        }

        function toggleBlindPost() {
            alert("[관리자] 해당 경매글이 숨김 처리되었습니다.");
        }

        function forceDeletePost() {
            if (confirm("[경고] 게시글을 강제 즉시 삭제하시겠습니까?")) {
                location.href = "${pageContext.request.contextPath}/";
            }
        }

        function addCommentMock() {
            const txt = document.getElementById('commentInput').value;
            if (!txt.trim()) return;
            const container = document.getElementById('commentListContainer');
            const p = container.querySelector('p.text-muted');
            if (p) p.remove();
            const div = document.createElement('div');
            div.className = "border-bottom pb-3";
            div.innerHTML = '<div class="d-flex justify-content-between mb-1"><span class="fw-bold small text-primary">' +
                            '${not empty sessionScope.userId ? sessionScope.userId : "게스트"}</span></div>' +
                            '<p class="text-secondary small mb-0">' + txt.replace(/</g, '&lt;') + '</p>';
            container.prepend(div);
            document.getElementById('commentInput').value = "";
        }
    </script>
</body>
</html>
