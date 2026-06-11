<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>상품 및 유저 신고</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
</head>
<body class="bg-light p-4">
    <div class="card shadow-sm border-0">
        <div class="card-body">
            <h5 class="card-title text-danger fw-bold mb-3">🚨 신고하기</h5>
            <p class="text-muted small">허위 신고 시 서비스 이용이 제한될 수 있습니다.</p>
            
            <form id="reportForm">
                <div class="mb-3">
                    <label class="form-label fw-bold small">상품 번호 (직접 입력)</label>
                    <input type="text" id="productId" class="form-control" value="<%= request.getParameter("productId") != null ? request.getParameter("productId") : "" %>" placeholder="상품 번호를 입력하세요">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold small">판매자 ID (직접 입력)</label>
                    <input type="text" id="reportedUserId" class="form-control" value="<%= request.getParameter("reportedUserId") != null ? request.getParameter("reportedUserId") : "" %>" placeholder="판매자 ID를 입력하세요">
                </div>
                
                <div class="mb-3">
                    <label class="form-label fw-bold small">신고 사유 선택</label>
                    <select id="reasonSelect" class="form-control" onchange="checkReason(this.value)">
                        <option value="">사유를 선택하세요</option>
                        <option value="사기 의심">사기 의심</option>
                        <option value="욕설 및 비방">욕설 및 비방</option> 
                        <option value="도배/광고">도배/광고</option>
                        <option value="기타">기타</option>
                    </select>

                    <div id="otherReasonDiv" style="display: none; margin-top: 10px;">
                        <textarea id="otherReason" class="form-control" placeholder="상세 사유를 입력해주세요"></textarea>
                    </div>
                </div>
                
                <div class="d-grid gap-2 mt-4">
                    <button type="button" class="btn btn-danger" onclick="submitReport()">신고 접수</button>
                    <button type="button" class="btn btn-secondary" onclick="window.close()">취소</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function checkReason(value) {
            const otherDiv = document.getElementById('otherReasonDiv');
            if (value === '기타') {
                otherDiv.style.display = 'block';
            } else {
                otherDiv.style.display = 'none';
                document.getElementById('otherReason').value = '';
            }
        }

        function submitReport() {
            const productId = document.getElementById('productId').value;
            const reportedUserId = document.getElementById('reportedUserId').value;
            const selectValue = document.getElementById('reasonSelect').value;
            const otherValue = document.getElementById('otherReason').value;

            // 최종 신고 사유 결정 (기타를 선택했으면 상세 입력값을 사용)
            let finalReason = selectValue;
            if (selectValue === '기타') {
                if (!otherValue.trim()) {
                    alert("상세 사유를 입력해 주세요.");
                    return;
                }
                finalReason = otherValue;
            } else if (!selectValue) {
                alert("신고 사유를 선택해 주세요.");
                return;
            }

            // 서블릿으로 POST 요청 보내기
            fetch("${pageContext.request.contextPath}/report", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                },
                body: "productId=" + encodeURIComponent(productId) + 
                      "&reportedUserId=" + encodeURIComponent(reportedUserId) + 
                      "&reportReason=" + encodeURIComponent(finalReason)
            })
            .then(response => {
                if(response.ok) {
                    alert("신고가 정상적으로 접수되었습니다.");
                    window.close();
                } else {
                    alert("오류가 발생했습니다. 다시 시도해 주세요.");
                }
            })
            .catch(error => {
                alert("서버 통신 중 오류가 발생했습니다.");
            });
        }
    </script>
</body>
</html>