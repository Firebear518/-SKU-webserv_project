package com.skuweb.controller;

import java.sql.SQLException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/updateStatus")
public class AuctionStatusServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "ASDasd336699@";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 관리자 세션 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/admin/adminLogin.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        int    auctionId    = Integer.parseInt(request.getParameter("auctionId"));
        String newStatus    = request.getParameter("newStatus");
        String rejectReason = request.getParameter("rejectReason"); // 불합격 시에만 존재

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS)) {

            	if ("불합격".equals(newStatus) && rejectReason != null) {
            	    // 💡 [해결] status와 reject_reason을 동시에 한 번에 업데이트합니다.
            	    String sql = "UPDATE auctions SET status = ?, reject_reason = ? WHERE auction_id = ?";
            	    
            	    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            	        pstmt.setString(1, "불합격");
            	        pstmt.setString(2, rejectReason); // "카드 표면 스크래치 발견"이 드디어 저장됩니다!
            	        pstmt.setInt(3, auctionId); 
            	        
            	        pstmt.executeUpdate();
            	    } catch (SQLException e) {
            	        e.printStackTrace(); // 에러 발생 시 로그 출력
            	    }
            	    try (PreparedStatement pstmtNoti = conn.prepareStatement(
            	            "INSERT INTO notifications (user_id, auction_id, message, noti_type) " +
            	            "SELECT a.highest_bidder, a.auction_id, " +
            	            "CONCAT('낙찰하신 상품이 검수 불합격 처리되었습니다. 사유: ', ?, ' / 수령 또는 반품을 선택해주세요.'), " +
            	            "'REJECT_CHOICE' FROM auctions a WHERE a.auction_id = ?")) {
            	            pstmtNoti.setString(1, rejectReason);
            	            pstmtNoti.setInt(2, auctionId);
            	            pstmtNoti.executeUpdate();
            	        }
            	        
            	        // 판매자에게 알림
            	        try (PreparedStatement pstmtNoti2 = conn.prepareStatement(
            	            "INSERT INTO notifications (user_id, auction_id, message, noti_type) " +
            	            "SELECT p.seller_id, a.auction_id, " +
            	            "CONCAT('상품이 검수 불합격 처리되었습니다. 사유: ', ?, ' / 구매자의 선택을 기다리는 중입니다.'), " +
            	            "'REJECT_SELLER' FROM auctions a JOIN products p ON a.product_id = p.product_id WHERE a.auction_id = ?")) {
            	            pstmtNoti2.setString(1, rejectReason);
            	            pstmtNoti2.setInt(2, auctionId);
            	            pstmtNoti2.executeUpdate();
            	        }

            	        } else {  // ← 59번 줄 else 시작
                    
               
                    // 일반 상태 변경 (입고대기→검수중, 검수중→검수완료)
                    try (PreparedStatement pstmt = conn.prepareStatement(
                            "UPDATE auctions SET status = ? WHERE auction_id = ?")) {
                        pstmt.setString(1, newStatus);
                        pstmt.setInt(2, auctionId);
                        pstmt.executeUpdate();
                    }
                }
            }

            response.setContentType("application/json; charset=UTF-8");
            response.getWriter().print("{\"success\":true}");
        } catch (Exception e) {
        	e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().print("{\"success\":false}");
        }
    }
}
