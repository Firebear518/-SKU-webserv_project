<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="com.skuweb.dao.ProductDAO, com.skuweb.dao.dto.ProductDTO, java.util.List" %>
<%
    ProductDAO productDAO = new ProductDAO();
    List<ProductDTO> productList = productDAO.getLatestProducts(4);
    request.setAttribute("productList", productList);
%>
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
            <c:forEach var="p" items="${productList}">
                <div class="col">
                    <a href="${pageContext.request.contextPath}/product/detail?productId=${p.productId}" class="text-decoration-none text-dark">
                        <div class="card h-100 shadow-sm border-0 rounded-3 overflow-hidden">
                            <c:choose>
                                <c:when test="${not empty p.imagePath}">
                                    <img src="${pageContext.request.contextPath}${p.imagePath}"
                                         class="card-img-top" style="height:200px; object-fit:cover;" alt="${p.title}">
                                </c:when>
                                <c:otherwise>
                                    <div class="bg-secondary text-white d-flex align-items-center justify-content-center" style="height:200px;">
                                        <i class="bi bi-card-image fs-1"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div class="card-body">
                                <c:choose>
                                    <c:when test="${p.categoryName eq 'POKEMON'}"><span class="badge bg-primary mb-2">포켓몬</span></c:when>
                                    <c:when test="${p.categoryName eq 'YUGIOH'}"><span class="badge bg-success mb-2">유희왕</span></c:when>
                                    <c:when test="${p.categoryName eq 'SPORTS'}"><span class="badge bg-dark mb-2">스포츠</span></c:when>
                                    <c:otherwise><span class="badge bg-secondary mb-2">기타</span></c:otherwise>
                                </c:choose>
                                <h5 class="card-title fw-bold text-truncate mb-1">${p.title}</h5>
                                <p class="text-danger small fw-bold mb-2"><i class="bi bi-clock"></i> 마감: ${p.endTime}</p>
                                <div class="d-flex justify-content-between align-items-center mt-3">
                                    <span class="text-muted small">시작가 <fmt:formatNumber value="${p.price}" pattern="#,###"/>원</span>
                                    <span class="fw-bold text-dark fs-5">현재가 <fmt:formatNumber value="${p.currentPrice}" pattern="#,###"/>원</span>
                                </div>
                            </div>
                        </div>
                    </a>
                </div>
            </c:forEach>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

</body>
</html>
