<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // 관리자 세션 확인
    String adminId = (String) session.getAttribute("adminId");
    if (adminId == null) {
        response.sendRedirect(request.getContextPath() + "/views/admin/adminLogin.jsp");
        return;
    }

    String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    String DB_USER = "root";
    String DB_PASS = "ASDasd336699@";

    // 모드 설정 (inspection: 상품검수, report: 유저신고)
    String mode = request.getParameter("mode");
    if (mode == null) mode = "inspection";

    // 필터 파라미터
    String filter = request.getParameter("filter");
    if (filter == null) filter = "전체";
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>올댓카드 - 관리자 통합 콘솔</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        .table-hover tbody tr { cursor: pointer; }
        .inspector-card { position: sticky; top: 20px; }
    </style>
</head>
<body class="bg-light">

    <jsp:include page="/views/common/header.jsp" />

    <div class="container my-5">
        
        <div class="d-flex justify-content-between align-items-end mb-4">
            <div>
                <h2 class="fw-bold text-dark">
                    <i class="bi bi-shield-lock-fill text-primary"></i> 올댓카드 통합 관리자 센터
                </h2>
                <p class="text-muted mb-0">상품 검수 장부 확인 및 유저들의 신고 내역을 실시간으로 심사합니다.</p>
            </div>
            <div>
                <a href="<%= request.getContextPath() %>/admin/logout" class="btn btn-outline-danger btn-sm">로그아웃</a>
            </div>
        </div>

        <ul class="nav nav-tabs mb-4 fw-bold">
            <li class="nav-item">
                <a class="nav-link <%= "inspection".equals(mode) ? "active text-primary" : "text-secondary" %>" href="?mode=inspection">
                    <i class="bi bi-box-seam-fill"></i> 검수 센터 관리 장부
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link <%= "report".equals(mode) ? "active text-danger" : "text-secondary" %>" href="?mode=report">
                    <i class="bi bi-exclamation-triangle-fill"></i> 유저/상품 신고 관리 구역
                </a>
            </li>
        </ul>

        <% if (request.getParameter("success") != null) { %>
        <div class="alert alert-success small py-2"><%= request.getParameter("success") %></div>
        <% } %>
        <% if (request.getParameter("error") != null) { %>
        <div class="alert alert-danger small py-2">오류가 발생했습니다.</div>
        <% } %>

        <% if ("inspection".equals(mode)) { %>
        <div class="d-flex justify-content-between align-items-center mb-3">
            <span class="text-muted small">상태별 실물 카드 입고 현황을 조회합니다.</span>
            <div class="btn-group shadow-sm bg-white">
                <a href="?mode=inspection&filter=전체"   class="btn btn-sm btn-outline-secondary <%= "전체".equals(filter)   ? "active" : "" %>">전체</a>
                <a href="?mode=inspection&filter=대기중" class="btn btn-sm btn-outline-secondary <%= "대기중".equals(filter) ? "active" : "" %>">대기중</a>
                <a href="?mode=inspection&filter=검수중" class="btn btn-sm btn-outline-secondary <%= "검수중".equals(filter) ? "active" : "" %>">검수중</a>
                <a href="?mode=inspection&filter=완료"   class="btn btn-sm btn-outline-secondary <%= "완료".equals(filter)   ? "active" : "" %>">완료</a>
            </div>
        </div>

        <div class="card border-0 shadow-sm rounded-3 overflow-hidden mb-4">
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
<%
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // 🎯 [수정] 맨 뒤에 a.reject_reason 컬럼을 조회하도록 추가했습니다!
        String sql = "SELECT a.auction_id, p.title, p.seller_id, a.highest_bidder, a.current_price, a.status, a.reject_reason " +
                     "FROM auctions a JOIN products p ON a.product_id = p.product_id " +
                     "WHERE a.status != 'active'";

        if ("대기중".equals(filter)) sql += " AND a.status = '입고대기'";
        else if ("검수중".equals(filter)) sql += " AND a.status = '검수중'";
        else if ("완료".equals(filter)) sql += " AND a.status = '검수완료'";
        sql += " ORDER BY a.auction_id DESC";

        PreparedStatement pstmt = conn.prepareStatement(sql);
        ResultSet rs = pstmt.executeQuery();

        boolean hasData = false;
        while (rs.next()) {
            hasData = true;
            String status       = rs.getString("status");
            int    auctionId    = rs.getInt("auction_id");
            // 🎯 [추정] DB에서 불합격 사유 텍스트를 꺼내옵니다.
            String rejectReason = rs.getString("reject_reason"); 

            String badgeClass = "bg-secondary";
            String badgeText  = status;
            String tooltipAttr = ""; // 툴팁을 담을 변수 생성

            if ("입고대기".equals(status)) { badgeClass = "bg-warning text-dark"; badgeText = "입고 대기"; }
            else if ("검수중".equals(status)) { badgeClass = "bg-info text-white";  badgeText = "정밀 검수중"; }
            else if ("검수완료".equals(status)) { badgeClass = "bg-success text-white"; badgeText = "검수 완료"; }
            else if ("배송중".equals(status)) { badgeClass = "bg-primary text-white"; badgeText = "배송중"; }
            // 🎯 [추가] 상태가 '불합격'일 때 빨간색 배지와 마우스 오버 속성을 부여합니다!
            else if ("불합격".equals(status)) { 
                badgeClass = "bg-danger text-white"; 
                badgeText = "불합격"; 
                if (rejectReason != null && !rejectReason.trim().isEmpty()) {
                    tooltipAttr = "title=\"불합격 사유: " + rejectReason + "\"";
                }
            }
%>
                        <tr>
                            <td class="ps-4 text-muted small">#AU-<%= auctionId %></td>
                            <td><div class="fw-bold text-dark"><%= rs.getString("title") %></div></td>
                            <td>
                                <div class="small">S: <%= rs.getString("seller_id") %></div>
                                <div class="small text-primary font-monospace">B: <%= rs.getString("highest_bidder") != null ? rs.getString("highest_bidder") : "-" %></div>
                            </td>
                            <td class="fw-bold"><%= String.format("%,d", rs.getInt("current_price")) %>원</td>
                            <td><span class="badge rounded-pill <%= badgeClass %>" <%= tooltipAttr %>><%= badgeText %></span></td>
                            <td class="text-center">
<%
            if ("입고대기".equals(status)) {
%>
                                <button type="button" class="btn btn-sm btn-primary px-3 fw-bold" onclick="updateStatus(<%= auctionId %>, '검수중')">박스 입고 확인</button>                
<%
            } else if ("검수중".equals(status)) {
%>
                                <div class="btn-group">
                                    <button type="button" class="btn btn-sm btn-success px-2" onclick="updateStatus(<%= auctionId %>, '검수완료')">검수합격</button>
                                    <button type="button" class="btn btn-sm btn-danger px-2" onclick="rejectProduct(<%= auctionId %>)">불합격</button>
                                </div>
<%
            } else if ("검수완료".equals(status) || "배송중".equals(status)) {
%>
                                <span class="text-muted small fst-italic">낙찰자에게 배송중</span>
<%
            }
%>
                            </td>
                        </tr>
<%
        }
        if (!hasData) {
%>
                        <tr><td colspan="6" class="text-center text-muted py-4">해당 상태의 상품이 없습니다.</td></tr>
<%
        }
        rs.close(); pstmt.close(); conn.close();
    } catch (Exception e) {
%>
                        <tr><td colspan="6" class="text-center text-danger py-4">DB 오류: <%= e.getMessage() %></td></tr>
<%
    }
%>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="mt-4 p-3 bg-white border rounded-3 small text-muted">
            <i class="bi bi-info-circle-fill text-primary"></i>
            <strong>관리자 팁:</strong> 검수 합격 버튼을 누르면 즉시 낙찰자에게 배송 안내가 발송되며 결제가 확정됩니다. 불합격 처리 시 사유를 입력하는 팝업이 뜹니다.
        </div>
        <% } %>

        <% if ("report".equals(mode)) { 
            String targetUid = request.getParameter("targetUid");
            String action = request.getParameter("action");
            
            // ==========================================
            // ⚡ [실시간 관리자 액션 처리 파트] 
            // ==========================================
            if (action != null && !action.isEmpty()) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection connAction = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                    
                    // 1) 신고 내역 완전히 삭제 기능
                    if ("DELETE".equals(action)) {
                        String deleteUid = request.getParameter("deleteUid");
                        if (deleteUid != null && !deleteUid.isEmpty()) {
                            String deleteSql = "DELETE FROM reports WHERE reported_user_id = ?";
                            PreparedStatement pstmtDel = connAction.prepareStatement(deleteSql);
                            pstmtDel.setString(1, deleteUid);
                            pstmtDel.executeUpdate();
                            pstmtDel.close();
                            
                            // 만약 현재 상세조회 중이던 유저를 지웠다면 우측창 초기화
                            if (deleteUid.equals(targetUid)) { targetUid = ""; }
                            
                            out.print("<script>alert('" + deleteUid + " 유저의 모든 신고 접수 건이 대시보드에서 삭제되었습니다.'); location.href='?mode=report&targetUid=" + targetUid + "';</script>");
                        }
                    } 
                    // 2) 회원 제재 권한 실행 (경고 / BAN)
                    else if ("WARN".equals(action) || "BAN".equals(action)) {
                        String statusValue = "WARN".equals(action) ? "경고 회원" : "영구 정지";
                        
                        // ⚠️ [주의] 서비스 고유의 회원 테이블명(예: users, members) 및 컬럼명에 맞게 조정하세요!
                        String updateStatusSql = "UPDATE users SET status = ? WHERE userId = ?"; 
                        
                        PreparedStatement pstmtStatus = connAction.prepareStatement(updateStatusSql);
                        pstmtStatus.setString(1, statusValue);
                        pstmtStatus.setString(2, targetUid);
                        pstmtStatus.executeUpdate();
                        pstmtStatus.close();
                        
                        String notiMsg = "WARN".equals(action)
                                ? "관리자로부터 경고 조치를 받았습니다. 규정 위반 시 계정이 정지될 수 있습니다."
                                : "귀하의 계정이 관리자에 의해 영구 정지(BAN) 처리되었습니다.";
                            String notiType = "WARN".equals(action) ? "WARN" : "BAN";

                            try (PreparedStatement pstmtNoti = connAction.prepareStatement(
                                "INSERT INTO notifications (user_id, message, noti_type) VALUES (?, ?, ?)")) {
                                pstmtNoti.setString(1, targetUid);
                                pstmtNoti.setString(2, notiMsg);
                                pstmtNoti.setString(3, notiType);
                                pstmtNoti.executeUpdate();
                            }
                        out.print("<script>alert('" + targetUid + " 유저에게 조치를 취했습니다. 상태가 [" + statusValue + "](으)로 실시간 변경됩니다.'); location.href='?mode=report&targetUid=" + targetUid + "';</script>");
                    }
                    connAction.close();
                } catch (Exception e) {
                    e.printStackTrace();
                    out.print("<script>alert('DB 오류 상세: " + e.getMessage() + "');</script>");
                }
            }
        %>
        
        <script>
        function executeAdminAction(actionType, uid) {
            var msg = actionType === 'WARN' ? '해당 유저에게 경고장을 발송하고 회원 상태를 변경하시겠습니까?' : '해당 유저를 즉시 영구 제재(BAN) 처리하시겠습니까?';
            if (confirm(msg)) {
                location.href = '?mode=report&targetUid=' + uid + '&action=' + actionType;
            }
        }
        </script>

        <div class="row g-4">
            <div class="col-lg-7">
                <div class="card border-0 shadow-sm rounded-3 p-4 bg-white">
                    <h5 class="fw-bold text-dark mb-3 border-bottom pb-2">
                        <i class="bi bi-list-stars text-danger"></i> 신고 접수된 상품 및 유저 목록
                    </h5>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-secondary small">
                                <tr>
                                    <th>신고유저(판매자)</th>
                                    <th>대상 상품명</th>
                                    <th>누적 횟수</th>
                                    <th class="text-center">관리 액션</th>
                                </tr>
                            </thead>
                            <tbody class="small">
<%
    // 왼쪽 요약 목록 로드 쿼리
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection connList = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        String listSql = "SELECT r.reported_user_id, " +
                         "CASE WHEN COUNT(DISTINCT r.product_id) > 1 " +
                         "THEN CONCAT(MIN(p.title), ' 외 ', COUNT(DISTINCT r.product_id) - 1, '건') " +
                         "ELSE MIN(p.title) END AS display_title, " +
                         "COUNT(r.report_id) AS report_count " +
                         "FROM reports r JOIN products p ON r.product_id = p.product_id " +
                         "GROUP BY r.reported_user_id ORDER BY report_count DESC";

        PreparedStatement pstmtList = connList.prepareStatement(listSql);
        ResultSet rsList = pstmtList.executeQuery();

        while (rsList.next()) {
            String rUserId = rsList.getString("reported_user_id");
            String displayTitle = rsList.getString("display_title");
            int reportCount = rsList.getInt("report_count");
            
            String activeClass = rUserId.equals(targetUid) ? "table-active border-primary" : "";
%>
                                <tr class="<%= activeClass %>" style="cursor:pointer;" onclick="location.href='?mode=report&targetUid=<%= rUserId %>'">
                                    <td><span class="fw-bold text-danger"><%= rUserId %></span></td>
                                    <td><span class="text-muted"><%= displayTitle %></span></td>
                                    <td><span class="badge <%= reportCount >= 5 ? "bg-danger" : "bg-warning text-dark" %>"><%= reportCount %>회</span></td>
                                    <td class="text-center">
                                        <div class="d-flex justify-content-center gap-1">
                                            <button class="btn btn-xs btn-outline-dark py-0 px-2" style="font-size:0.75rem;">조회</button>
                                            <button class="btn btn-xs btn-danger py-0 px-2 text-white" style="font-size:0.75rem;" 
                                                    onclick="event.stopPropagation(); if(confirm('<%= rUserId %> 유저의 모든 신고 기록을 목록에서 삭제하시겠습니까?')) location.href='?mode=report&targetUid=<%= targetUid %>&action=DELETE&deleteUid=<%= rUserId %>';">
                                                삭제
                                            </button>
                                        </div>
                                    </td>
                                </tr>
<%
        }
        rsList.close(); pstmtList.close(); connList.close();
    } catch (Exception e) {
%>
                                <tr><td colspan="4" class="text-center text-danger">목록 로드 오류: <%= e.getMessage() %></td></tr>
<%
    }
%>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <div class="col-lg-5">
                <div class="card border-0 shadow-sm rounded-3 p-4 bg-white inspector-card" id="detailInspectorBox">
<%
    if (targetUid == null || targetUid.isEmpty()) {
%>
                    <div class="text-center py-5 text-muted" id="emptyNotice">
                        <i class="bi bi-person-bounding-box display-4"></i>
                        <p class="mt-3 small">왼쪽 목록에서 신고된 유저를 클릭하시면<br>해당 회원의 상세 신고 내역이 여기에 바인딩됩니다.</p>
                    </div>
<%
    } else {
        int totalCount = 0;
        String currentDbStatus = "정상 회원"; // 기본값 설정
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connDetail = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // 1) 누적 신고수 가져오기
            String countSql = "SELECT COUNT(*) FROM reports WHERE reported_user_id = ?";
            PreparedStatement pstmtCount = connDetail.prepareStatement(countSql);
            pstmtCount.setString(1, targetUid);
            ResultSet rsCount = pstmtCount.executeQuery();
            if (rsCount.next()) totalCount = rsCount.getInt(1);
            rsCount.close(); pstmtCount.close();

            // 2) 실시간 유저 테이블 상태 값 가져오기
            try {
            	String statusSql = "SELECT status FROM users WHERE userId = ?";
                PreparedStatement pstmtDbStatus = connDetail.prepareStatement(statusSql);
                pstmtDbStatus.setString(1, targetUid);
                ResultSet rsDbStatus = pstmtDbStatus.executeQuery();
                if (rsDbStatus.next() && rsDbStatus.getString("status") != null) {
                    currentDbStatus = rsDbStatus.getString("status");
                }
                rsDbStatus.close(); pstmtDbStatus.close();
            } catch(Exception ex) {
                // 아직 users 테이블이나 status 컬럼 세팅이 안 되어 있다면 기존 로직(카운트 기준)으로 자동 대체
                if (totalCount >= 5) { currentDbStatus = "경고 조치 누적"; }
            }
%>
                    <div id="memberInfoContent">
                        <h5 class="fw-bold text-dark mb-3 border-bottom pb-2">
                            <i class="bi bi-person-vcard-fill text-primary"></i> 피신고자 상세 정보
                        </h5>
                        <div class="bg-light p-3 rounded-3 mb-4">
                            <div class="row g-2 small">
                                <div class="col-4 text-muted fw-bold">회원 ID</div>
                                <div class="col-8 fw-bold text-dark" id="infoId"><%= targetUid %></div>
                                <div class="col-4 text-muted fw-bold">현재 상태</div>
                                <div class="col-8">
                                    <% if("영구 정지".equals(currentDbStatus)) { %>
                                        <span class='badge bg-danger text-white'>영구 정지 회원 (BAN)</span>
                                    <% } else if("경고 회원".equals(currentDbStatus) || "경고 조치 누적".equals(currentDbStatus)) { %>
                                        <span class='badge bg-warning text-dark'>경고 조치 누적</span>
                                    <% } else { %>
                                        <span class='badge bg-success'>정상 회원</span>
                                    <% } %>
                                </div>
                                <div class="col-4 text-danger fw-bold">누적 신고량</div>
                                <div class="col-8 fw-bold text-danger"><%= totalCount %>회</div>
                            </div>
                        </div>

                        <h6 class="fw-bold text-dark mb-2 small"><i class="bi bi-shield-exclamation text-danger"></i> 접수된 증거 로그 내역</h6>
                        <div class="table-responsive mb-4" style="max-height: 250px; overflow-y: auto;">
                            <table class="table table-sm table-bordered align-middle text-center small" style="font-size: 0.8rem;">
                                <thead class="table-dark">
                                    <tr>
                                        <th>신고자</th>
                                        <th>상품명</th>
                                        <th>신고 사유</th>
                                        <th>시각</th>
                                    </tr>
                                </thead>
                                <tbody>
<%
            String logSql = "SELECT r.reporter_id, p.title, r.report_reason, r.reported_at " +
                            "FROM reports r JOIN products p ON r.product_id = p.product_id " +
                            "WHERE r.reported_user_id = ? ORDER BY r.reported_at DESC";
            
            PreparedStatement pstmtLog = connDetail.prepareStatement(logSql);
            pstmtLog.setString(1, targetUid);
            ResultSet rsLog = pstmtLog.executeQuery();

            boolean hasLog = false;
            while (rsLog.next()) {
                hasLog = true;
%>
                                    <tr>
                                        <td class="fw-bold text-secondary"><%= rsLog.getString("reporter_id") %></td>
                                        <td class="text-start text-truncate" style="max-width: 100px;" title="<%= rsLog.getString("title") %>"><%= rsLog.getString("title") %></td>
                                        <td class="text-start text-wrap"><%= rsLog.getString("report_reason") %></td>
                                        <td class="text-muted" style="font-size:0.7rem;"><%= rsLog.getString("reported_at") %></td>
                                    </tr>
<%
            }
            if(!hasLog) {
                %><tr><td colspan="4" class="text-muted py-3">접수된 상세 내역이 없습니다.</td></tr><%
            }
            rsLog.close(); pstmtLog.close(); connDetail.close();
        } catch (Exception e) {
            out.print("<tr><td colspan='4' class='text-danger'>로그 조회 실패: " + e.getMessage() + "</td></tr>");
        }
%>
                                </tbody>
                            </table>
                        </div>

                        <h6 class="fw-bold text-dark mb-2 small"><i class="bi bi-style text-warning"></i> 관리자 패널 강제 권한</h6>
                        <div class="d-grid gap-2">
                            <button type="button" class="btn btn-warning btn-sm fw-bold shadow-sm" onclick="executeAdminAction('WARN', '<%= targetUid %>')">경고장 발송 및 회원 상태 업데이트</button>
                            <button type="button" class="btn btn-danger btn-sm fw-bold shadow-sm" onclick="executeAdminAction('BAN', '<%= targetUid %>')">해당 회원 영구 제재 (BAN)</button>
                        </div>
                    </div>
<%
    } // end of else
%>
                </div>
            </div>
        </div>
        <% } %>

    </div>

    <div class="modal fade" id="rejectModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">검수 불합격 사유 입력</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <form onsubmit="submitReject(event)">
                    <div class="modal-body">
                        <input type="hidden" name="auctionId" id="rejectAuctionId">
                        <input type="hidden" name="newStatus" value="불합격">
                        <div class="mb-3">
                            <label class="form-label fw-semibold">불합격 사유</label>
                            <textarea class="form-control" name="rejectReason" rows="3" required
                                      placeholder="예: 카드 표면 스크래치 발견, 위조 카드 의심 등"></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">취소</button>
                        <button type="submit" class="btn btn-danger">불합격 처리</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <jsp:include page="/views/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    function rejectProduct(auctionId) {
        document.getElementById('rejectAuctionId').value = auctionId;
        new bootstrap.Modal(document.getElementById('rejectModal')).show();
    }
    
    async function updateStatus(auctionId, newStatus) {
        const params = new URLSearchParams();
        params.append('auctionId', auctionId);
        params.append('newStatus', newStatus);

        const res = await fetch('<%= request.getContextPath() %>/admin/updateStatus', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params.toString()
        });

        if (res.ok) {
            location.reload();
        } else {
            alert('오류가 발생했습니다.');
        }
    }

    // 💡 중복 제거 및 단일화 완료
    function viewMemberDetail(id, name, email, status, date, count) {
        document.getElementById('emptyNotice').classList.add('d-none');
        document.getElementById('memberInfoContent').classList.remove('d-none');

        document.getElementById('infoId').innerText = id;
        document.getElementById('infoName').innerText = name;
        document.getElementById('infoEmail').innerText = email;
        document.getElementById('infoDate').innerText = date;
        document.getElementById('infoCount').innerText = count;

        const statusBadge = document.getElementById('infoStatus');
        if(status === '경고회원') {
            statusBadge.innerHTML = `<span class="badge bg-warning text-dark">경고 조치 누적</span>`;
        } else {
            statusBadge.innerHTML = `<span class="badge bg-success">정상 회원</span>`;
        }
    }

    function adminAction(type) {
        const userId = document.getElementById('infoId').innerText;
        if(type === 'WARN') {
            alert(`⚠️ [처분 완료] ${userId} 회원에게 경고 알림 전송 및 업로드된 상품을 임시 비공개(블라인드) 처리했습니다.`);
        } else if(type === 'BAN') {
            if(confirm(`🚨 [최종 처분 확인] 정말로 ${userId} 유저의 로그인 자격을 영구 정지하시겠습니까?`)) {
                alert(`🔨 자격 정지 완료: ${userId} 유저는 시스템에서 강제 로그아웃됩니다.`);
            }
        }
    }
    async function submitReject(event) {
        event.preventDefault(); // 💡 중요: 브라우저가 흰 화면(서블릿 주소)으로 날아가는 것을 막아줍니다.
        
        const form = event.target;
        // 폼 안에 입력된 사유(rejectReason)와 hidden 값들을 싹 포장합니다.
        const params = new URLSearchParams(new FormData(form)); 

        const res = await fetch('<%= request.getContextPath() %>/admin/updateStatus', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: params.toString()
        }); 

        if (res.ok) {
            // 💡 성공하면 화면을 새로고침하여 두 번째 사진처럼 "불합격" 뱃지가 뜨게 만듭니다!
            location.reload(); 
        } else {
            alert('오류가 발생했습니다.');
        }
    }
    </script>
</body>
</html>