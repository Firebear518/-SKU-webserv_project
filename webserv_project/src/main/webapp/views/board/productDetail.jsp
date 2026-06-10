<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 상품 상세 정보</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    
    <style>
        /* 1. 🌟 메인 대표 카드 전용 3D 틸트 존 */
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

        /* 2. ❌ 상세 설명 사진 구역 (3D 효과 제거, 돋보기 기능 제공) */
        .detail-thumb-box {
            width: 75px;
            height: 75px;
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

        /* 입찰 현황판 전광판 효과 */
        .price-board {
            background-color: #212529;
            color: #ffc107;
            border-radius: 10px;
            padding: 15px;
            font-family: 'Courier New', Courier, monospace;
            box-shadow: inset 0 0 10px rgba(0,0,0,0.5);
        }

        /* 판매자 댓글 강조 라벨 */
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
        // 💡 세션에서 로그인한 유저의 권한을 체크하는 로직
        String userRole = (String) session.getAttribute("userRole"); 
        if("ADMIN".equals(userRole)) {
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

    <div class="container my-5">
        <div class="row g-5">
            
            <div class="col-md-5 text-center">
                <div class="mb-2 text-start small text-muted fw-bold"><i class="bi bi-gem"></i> 대표 카드 (3D 틸트)</div>
                <div class="detail-card-zone">
                    <div class="tilt-card-detail" data-tilt>
                        <img src="https://images.pokemontcg.io/sv6/193_hires.png" alt="메인 대표 카드">
                    </div>
                </div>
                
                <div class="text-start small text-muted fw-bold mt-4 mb-2"><i class="bi bi-images"></i> 상태 검증용 상세 사진 (최대 5장)</div>
                <div class="d-flex justify-content-start gap-2 flex-wrap">
                    <img class="detail-thumb-box" src="https://images.pokemontcg.io/sv6/166_hires.png" onclick="openZoomModal(this.src)" alt="상세1">
                    <img class="detail-thumb-box" src="https://images.pokemontcg.io/sv6/167_hires.png" onclick="openZoomModal(this.src)" alt="상세2">
                    <img class="detail-thumb-box" src="https://images.pokemontcg.io/sv6/168_hires.png" onclick="openZoomModal(this.src)" alt="상세3">
                </div>
                <div class="form-text text-start mt-2"><i class="bi bi-search"></i> 상세 사진을 클릭하면 원본 고화질 크기로 정밀 확인이 가능합니다.</div>
            </div>

            <div class="col-md-7">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <span class="badge bg-primary fs-6">포켓몬 카드</span>
                    <span class="text-muted small">등록 유저 ID: <b>pokemon_master</b></span>
                <button type="button" class="btn btn-link text-danger p-0 border-0 extra-small text-decoration-none fw-bold" style="font-size: 0.8rem;" onclick="submitReportAction()">
                <i class="bi bi-exclamation-triangle-fill"></i> 신고하기
            </button>
            </div>
                
                <h2 class="fw-bold text-dark mb-3">메가개굴닌자ex SAR</h2>
                
                <div class="price-board mb-4">
                    <div class="d-flex justify-content-between mb-2">
                        <span>경매 시작가</span>
                        <span class="text-white">₩ 50,000</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center border-top pt-2">
                        <span class="fs-5 fw-bold text-white"><i class="bi bi-graph-up-arrow text-danger"></i> 현재 최고 입찰가</span>
                        <span class="fs-3 fw-bold" id="currentHighestPrice">₩ 85,000</span>
                    </div>
                    <div class="d-flex justify-content-between small text-secondary mt-2 border-top pt-1">
                        <span><i class="bi bi-hourglass-split"></i> 경매 마감까지</span>
                        <span class="text-light fw-bold" id="auctionCountdown"
                              data-endtime="${not empty auction ? fn:escapeXml(auction.endTime) : ''}">
                            <c:choose>
                                <c:when test="${not empty auction}">계산 중...</c:when>
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
                        	<c:choose>
                        		<c:when test="${auction.auctionStatus == 'ONGOING'}">
                        			<button type="button" id="submitBidBtn" class="btn btn-warning btn-lg w-100 fw-bold h-100 shadow-sm"
	                                    	onclick="submitBidAction(${not empty auction ? auction.auctionId : 0}, ${not empty auction ? auction.currentPrice : product.price})">
		                                <i class="bi bi-wallet2"></i> 입찰 신청
		                            </button>
                        		</c:when>
                        		<c:otherwise>
                        			<div class="alert alert-secondary">
                        				경매가 종료되었습니다.
                        			</div>
                        		</c:otherwise>
                        	</c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="card border-0 shadow-sm rounded-3 p-4 my-5 bg-white">
            <h5 class="fw-bold text-dark mb-3 border-bottom pb-2"><i class="bi bi-file-earmark-text-fill text-secondary"></i> 상품 상세 설명</h5>
            <p class="text-secondary lh-lg mb-0" style="white-space: pre-line;">
                안녕하세요. 경매에 출품된 상품은 메가개굴닌자ex SAR 카드입니다.
                본 카드는 수집 후 즉시 슬리브와 탑로더에 넣어 안전하게 보관해 왔습니다. 
                전반적인 훼손을 방지하며 철저히 관리했으나, 상세한 카드 표면 상태는 첨부된 실물 사진들을 통해 꼼꼼히 확인하신 후 입찰해 주시기 바랍니다.
            </p>
        </div>

        <div class="card border-0 shadow-sm rounded-3 p-4 bg-white" id="comments">
            <h5 class="fw-bold text-dark mb-4">
                <i class="bi bi-chat-dots-fill text-primary"></i> 회원 문의 및 댓글
                <span class="text-muted small fw-normal">(${fn:length(comments)})</span>
            </h5>

            <%-- 댓글 작성 폼 (로그인 시에만 노출) --%>
            <c:choose>
                <c:when test="${not empty sessionScope.userId}">
                    <form action="${pageContext.request.contextPath}/product/comment" method="post" class="d-flex gap-3 mb-4">
                        <input type="hidden" name="productId" value="${product.productId}">
                        <div class="flex-grow-1">
                            <textarea name="content" class="form-control" rows="2"
                                      placeholder="상품 상태나 질문을 작성해 보세요." required></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary px-4 fw-bold">등록</button>
                    </form>
                </c:when>
                <c:otherwise>
                    <div class="alert alert-light border text-center text-muted mb-4">
                        댓글을 작성하려면
                        <a href="${pageContext.request.contextPath}/views/user/login.jsp" class="fw-bold text-decoration-none">로그인</a>이 필요합니다.
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- 댓글 목록 --%>
            <div class="comment-list-box d-flex flex-column gap-3" id="commentListContainer">
                <c:choose>
                    <c:when test="${empty comments}">
                        <p class="text-muted small">아직 등록된 댓글이 없습니다. 첫 문의를 남겨보세요!</p>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="cmt" items="${comments}">
                            <%-- 판매자 댓글이면 노란색 배경으로 강조 --%>
                            <c:set var="isSeller" value="${cmt.userId == product.sellerId}" />
                            <div class="border-bottom pb-3 ${isSeller ? 'rounded-2 p-2' : ''}"
                                 style="${isSeller ? 'background-color:#fff8e1;' : ''}">
                                <div class="d-flex justify-content-between mb-1">
                                    <span>
                                        <span class="fw-bold small ${isSeller ? 'text-warning' : 'text-primary'}">
                                            <c:if test="${isSeller}"><i class="bi bi-patch-check-fill"></i> </c:if>${fn:escapeXml(cmt.userId)}
                                        </span>
                                        <c:if test="${isSeller}">
                                            <span class="badge bg-warning text-dark ms-1">판매자</span>
                                        </c:if>
                                    </span>
                                    <span class="text-muted small">${fn:escapeXml(cmt.createdAt)}</span>
                                </div>
                                <p class="text-secondary small mb-0" style="white-space: pre-line;">${fn:escapeXml(cmt.content)}</p>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="modal fade" id="imageZoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-lg">
            <div class="modal-content bg-transparent border-0">
                <div class="modal-body text-center p-0 position-relative">
                    <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-3 fs-4" data-bs-dismiss="modal" aria-label="Close"></button>
                    <img id="modalZoomImg" src="" class="img-fluid rounded shadow-lg" style="max-height: 85vh;" alt="확대보기">
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/vanilla-tilt/1.8.1/vanilla-tilt.min.js"></script>

    <script>
        // 1. 오직 대표 카드 1장에만 3D 무브 이펙트 가동
        VanillaTilt.init(document.querySelectorAll(".tilt-card-detail"), {
            max: 20,
            speed: 400,
            glare: true,
            "max-glare": 0.4,
            scale: 1.04
        });

        // 경매 마감까지 남은 시간 실시간 카운트다운
        (function initAuctionCountdown() {
            const el = document.getElementById('auctionCountdown');
            if (!el) return;

            const raw = el.getAttribute('data-endtime');
            if (!raw) return; // 경매 정보 없음 → "미정" 유지

            // MySQL DATETIME "2026-06-12 14:30:00" → ISO 형태로 보정 (서버/클라이언트 동일 시간대 가정)
            const endTime = new Date(raw.replace(' ', 'T')).getTime();
            if (isNaN(endTime)) { el.textContent = '시간 정보 오류'; return; }

            let timer = null;

            function pad(n) { return String(n).padStart(2, '0'); }

            function tick() {
                const diff = endTime - Date.now();

                if (diff <= 0) {
                    el.textContent = '경매 종료';
                    el.classList.remove('text-light');
                    el.classList.add('text-danger');
                    if (timer) clearInterval(timer);
                    return;
                }

                const days    = Math.floor(diff / 86400000);
                const hours   = Math.floor((diff % 86400000) / 3600000);
                const minutes = Math.floor((diff % 3600000) / 60000);
                const seconds = Math.floor((diff % 60000) / 1000);

                let txt = '';
                if (days > 0) txt += days + '일 ';
                txt += pad(hours) + ':' + pad(minutes) + ':' + pad(seconds);
                el.textContent = txt;

                // 마감 1시간 이내면 강조
                if (diff <= 3600000) {
                    el.classList.remove('text-light');
                    el.classList.add('text-warning');
                }
            }

            tick();
            timer = setInterval(tick, 1000);
        })();

        function openZoomModal(src) {
            document.getElementById('modalZoomImg').src = src;
            const myModal = new bootstrap.Modal(document.getElementById('imageZoomModal'));
            myModal.show();
        }

        // 💡 [동시성 차단] 입찰 진행 여부를 감지하는 전역 상태 플래그
        let isBiddingInProgress = false;

        // 3. 🔥 실시간 입찰 신청 모형 업데이트 (경쟁 상태 방어 레이어 탑재)
        function submitBidAction() {
            // [방어 레이어 1] 이미 서버와 통신 중이면 후속 클릭 강제 차단
            if (isBiddingInProgress) {
                alert("⏳ 이전 입찰 요청이 아직 처리 중입니다. 잠시만 기다려주세요!");
                return;
            }

            const bidInput = document.getElementById('bidAmountInput');
            const bidVal = parseInt(bidInput.value);
            
            if (!bidVal || bidVal <= 85000) {
                alert("⚠️ 현재 최고가보다 높은 금액을 입력해 주세요.");
                return;
            }
            
            if (confirm("📢 ₩ " + bidVal.toLocaleString() + "원으로 입찰을 확정하시겠습니까?")) {
                // [방어 레이어 2] 확인을 누르는 순간 즉시 플래그 변환 및 버튼 잠금 기동
                isBiddingInProgress = true;
                
                const bidBtn = document.getElementById('submitBidBtn');
                bidBtn.disabled = true; // 버튼 비활성화 (클릭 원천 불가)
                bidBtn.innerHTML = `<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> 처리 중...`;

                // 💡 [백엔드 Ajax 연동 가상 시뮬레이션] 1.2초간 서버 통신을 수행한다고 가정
                setTimeout(() => {
                    // 서버 통신 완료 시 화면 갱신
                    document.getElementById('currentHighestPrice').innerText = "₩ " + bidVal.toLocaleString();
                    bidInput.value = "";
                    alert("🎉 성공적으로 입찰이 접수되었습니다!");

                    // [방어 해제] 모든 로직이 종료된 후 안전하게 상태를 복구시킵니다.
                    isBiddingInProgress = false;
                    bidBtn.disabled = false;
                    bidBtn.innerHTML = `<i class="bi bi-wallet2"></i> 입찰 신청`;
                }, 1200);
            }
        }

        // 4. 관리자 긴급 권한 트리거
        function toggleBlindPost() { 
            alert("🔒 [관리자] 해당 경매글이 숨김 처리되었습니다."); 
        }
        
        function forceDeletePost() {
            if (confirm("🚨 [경고] 게시글을 강제 즉시 삭제하시겠습니까?")) {
                location.href = "${pageContext.request.contextPath}/";
            }
        }
    </script>
</body>
</html>