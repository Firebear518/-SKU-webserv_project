<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 경매장</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">

    <style>
        .category-btn {
            border-radius: 20px;
            padding: 8px 20px;
            font-weight: bold;
            transition: all 0.2s;
        }
        .product-card {
            border: none;
            border-radius: 15px;
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
            background: #fff;
        }
        .product-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.15) !important;
        }
        .card-img-wrapper {
            position: relative;
            width: 100%;
            padding-top: 130%;
            overflow: hidden;
            background-color: #f8f9fa;
        }
        .card-img-wrapper img {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            object-fit: contain;
            padding: 10px;
        }
        .time-badge {
            position: absolute;
            top: 15px; right: 15px;
            background-color: rgba(220, 53, 69, 0.9);
            color: white;
            padding: 4px 10px;
            border-radius: 30px;
            font-size: 0.75rem;
            font-weight: bold;
            z-index: 2;
        }
        .price-text {
            color: #dc3545;
            font-weight: 800;
        }
    </style>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">

        <div class="row justify-content-center mb-5">
            <div class="col-md-8 text-center">
                <h2 class="fw-bold text-dark mb-4"><i class="bi bi-hammer text-warning"></i> 실시간 카드 경매장</h2>
                <form action="${pageContext.request.contextPath}/board/list.do" method="get">
                    <div class="input-group input-group-lg shadow-sm rounded-pill overflow-hidden bg-white p-1 border">
                        <span class="input-group-text bg-transparent border-0 text-muted"><i class="bi bi-search ms-2"></i></span>
                        <input type="text" name="searchKeyword" class="form-control border-0 bg-transparent fs-6" placeholder="카드 이름, 등급, 세트명 등으로 검색해 보세요...">
                        <input type="hidden" id="currentCategoryInput" name="category" value="ALL">
                        <button type="submit" class="btn btn-primary px-4 rounded-pill fw-bold fs-6 me-1">검색</button>
                    </div>
                </form>
            </div>
        </div>

        <div class="d-flex justify-content-center gap-2 mb-5 flex-wrap" id="categoryTabContainer">
            <button type="button" class="btn btn-primary category-btn" onclick="filterCategory('ALL', this)">전체</button>
            <button type="button" class="btn btn-outline-secondary category-btn" onclick="filterCategory('POKEMON', this)">포켓몬 카드</button>
            <button type="button" class="btn btn-outline-secondary category-btn" onclick="filterCategory('YUGIOH', this)">유희왕</button>
            <button type="button" class="btn btn-outline-secondary category-btn" onclick="filterCategory('SPORTS', this)">스포츠 카드</button>
        </div>

        <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4" id="productGridContainer">

            <c:forEach var="p" items="${productList}">
                <%-- 카테고리 뱃지 색상 결정 --%>
                <c:set var="badgeClass" value="bg-secondary" />
                <c:set var="categoryLabel" value="${fn:escapeXml(p.categoryName)}" />
                <c:choose>
                    <c:when test="${p.categoryName == 'POKEMON'}">
                        <c:set var="badgeClass" value="bg-primary" />
                        <c:set var="categoryLabel" value="포켓몬 카드" />
                    </c:when>
                    <c:when test="${p.categoryName == 'YUGIOH'}">
                        <c:set var="badgeClass" value="bg-danger" />
                        <c:set var="categoryLabel" value="유희왕" />
                    </c:when>
                    <c:when test="${p.categoryName == 'SPORTS'}">
                        <c:set var="badgeClass" value="bg-success" />
                        <c:set var="categoryLabel" value="스포츠 카드" />
                    </c:when>
                    <c:otherwise>
                        <c:set var="badgeClass" value="bg-secondary" />
                        <c:set var="categoryLabel" value="기타" />
                    </c:otherwise>
                </c:choose>

                <div class="col product-item" data-category="${fn:escapeXml(p.categoryName)}">
                    <div class="card product-card h-100 shadow-sm"
                         onclick="location.href='${pageContext.request.contextPath}/product/detail?productId=${p.productId}'"
                         style="cursor:pointer;">
                        <div class="card-img-wrapper">
                            <span class="time-badge">
                                <i class="bi bi-clock-fill"></i>
                                <c:choose>
                                    <c:when test="${not empty p.endTime}">${fn:substring(p.endTime, 0, 10)} 마감</c:when>
                                    <c:otherwise>경매 중</c:otherwise>
                                </c:choose>
                            </span>
                            <img src="${pageContext.request.contextPath}${fn:escapeXml(p.imagePath)}"
                                 alt="카드 이미지"
                                 onerror="this.src='https://via.placeholder.com/200x280?text=No+Image'">
                        </div>
                        <div class="card-body d-flex flex-column justify-content-between p-3">
                            <div>
                                <span class="badge ${badgeClass} mb-2" style="font-size: 0.7rem;">${categoryLabel}</span>
                                <h6 class="card-title fw-bold text-dark text-truncate mb-1">${fn:escapeXml(p.title)}</h6>
                                <p class="text-muted mb-2" style="font-size: 0.8rem;">출품자: ${fn:escapeXml(p.sellerId)}</p>
                            </div>
                            <div class="border-top pt-2 mt-2">
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="small text-secondary">현재 최고가</span>
                                    <span class="fs-5 price-text">₩ <fmt:formatNumber value="${p.currentPrice}" type="number"/></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

        </div>

        <c:if test="${empty productList}">
            <div class="text-center py-5">
                <i class="bi bi-inbox text-muted display-1"></i>
                <h4 class="text-secondary mt-3 fw-bold">등록된 경매 상품이 없습니다.</h4>
                <a href="${pageContext.request.contextPath}/views/board/productRegister.jsp" class="btn btn-warning mt-3 fw-bold">
                    <i class="bi bi-plus-circle"></i> 첫 상품 등록하기
                </a>
            </div>
        </c:if>

        <div class="text-center py-5 d-none" id="noItemAlert">
            <i class="bi bi-exclamation-triangle text-muted display-1"></i>
            <h4 class="text-secondary mt-3 fw-bold">해당 카테고리에 진행 중인 경매 상품이 없습니다.</h4>
        </div>

    </div>

    <jsp:include page="/views/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
        function filterCategory(categoryKey, targetBtn) {
            document.getElementById('currentCategoryInput').value = categoryKey;

            document.querySelectorAll('#categoryTabContainer .category-btn').forEach(btn => {
                btn.classList.remove('btn-primary');
                btn.classList.add('btn-outline-secondary');
            });
            targetBtn.classList.remove('btn-outline-secondary');
            targetBtn.classList.add('btn-primary');

            const items = document.querySelectorAll('.product-item');
            let visibleCount = 0;
            items.forEach(item => {
                const itemCategory = item.getAttribute('data-category');
                if (categoryKey === 'ALL' || itemCategory === categoryKey) {
                    item.classList.remove('d-none');
                    visibleCount++;
                } else {
                    item.classList.add('d-none');
                }
            });

            const alertBox = document.getElementById('noItemAlert');
            if (visibleCount === 0) {
                alertBox.classList.remove('d-none');
            } else {
                alertBox.classList.add('d-none');
            }
        }
    </script>
</body>
</html>
