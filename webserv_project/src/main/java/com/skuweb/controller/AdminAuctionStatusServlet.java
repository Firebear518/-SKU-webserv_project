package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/admin/updateStatus")
public class AdminAuctionStatusServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("adminId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/admin/adminLogin.jsp");
            return;
        }

        request.setCharacterEncoding("UTF-8");

        int auctionId = Integer.parseInt(request.getParameter("auctionId"));
        String newStatus = request.getParameter("newStatus");
        String rejectReason = request.getParameter("rejectReason"); 

        try {
            try (Connection conn = DBUtil.getConnection()) {

                if ("불합격".equals(newStatus) && rejectReason != null) {
                    // 1. 불합격 처리
                    String sql = "UPDATE auction SET status = ?, reject_reason = ? WHERE auction_id = ?";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        pstmt.setString(1, "불합격");
                        pstmt.setString(2, rejectReason); 
                        pstmt.setInt(3, auctionId); 
                        pstmt.executeUpdate();
                    }
                    
                    // 2. 낙찰자에게 알림
                    String notiSql1 = "INSERT INTO notifications (user_id, auction_id, message, noti_type) " +
                            		"SELECT a.highest_bidder_id, a.auction_id, " +
                                      "CONCAT('낙찰하신 상품이 검수 불합격 처리되었습니다. 사유: ', ?, ' / 수령 또는 반품을 선택해주세요.'), " +
                                      "'REJECT_CHOICE' FROM auction a WHERE a.auction_id = ?";
                    try (PreparedStatement pstmtNoti = conn.prepareStatement(notiSql1)) {
                        pstmtNoti.setString(1, rejectReason);
                        pstmtNoti.setInt(2, auctionId);
                        pstmtNoti.executeUpdate();
                    }
                    
                    // 3. 판매자에게 알림
                    String notiSql2 = "INSERT INTO notifications (user_id, auction_id, message, noti_type) " +
                                      "SELECT p.seller_id, a.auction_id, " +
                                      "CONCAT('상품이 검수 불합격 처리되었습니다. 사유: ', ?, ' / 구매자의 선택을 기다리는 중입니다.'), " +
                                      "'REJECT_SELLER' FROM auction a JOIN products p ON a.product_id = p.product_id WHERE a.auction_id = ?";
                    try (PreparedStatement pstmtNoti2 = conn.prepareStatement(notiSql2)) {
                        pstmtNoti2.setString(1, rejectReason);
                        pstmtNoti2.setInt(2, auctionId);
                        pstmtNoti2.executeUpdate();
                    }

                } else {  
                    // 4. 일반 상태 업데이트 (입고대기→검수중, 검수중→검수완료, 낙찰자에게 배송중 등)
                    try (PreparedStatement pstmt = conn.prepareStatement(
                            "UPDATE auction SET status = ? WHERE auction_id = ?")) {
                        pstmt.setString(1, newStatus);
                        pstmt.setInt(2, auctionId);
                        pstmt.executeUpdate();
                    }

                    // 🌟 5. [추가] 관리자가 상태를 "낙찰자에게 배송중"으로 변경하면 낙찰자에게 알림 전송
                    if ("낙찰자에게 배송중".equals(newStatus) || "검수완료".equals(newStatus) || "검수합격".equals(newStatus)) {
                        
                    	String findInfoSql = "SELECT a.highest_bidder_id, p.title FROM auction a JOIN products p ON a.product_id = p.product_id WHERE a.auction_id = ?";
                        try (PreparedStatement psInfo = conn.prepareStatement(findInfoSql)) {
                            psInfo.setInt(1, auctionId);
                            try (ResultSet rs = psInfo.executeQuery()) {
                                if (rs.next()) {
                                	String buyerId = rs.getString("highest_bidder_id");
                                    String productName = rs.getString("title");
                                    
                                    // 낙찰자에게 알림 INSERT
                                    String insertNotiSql = "INSERT INTO notifications (user_id, auction_id, message, noti_type) VALUES (?, ?, ?, 'INFO')";
                                    try (PreparedStatement psNoti = conn.prepareStatement(insertNotiSql)) {
                                        psNoti.setString(1, buyerId);
                                        psNoti.setInt(2, auctionId);
                                        psNoti.setString(3, "[" + productName + "] 상품이 검수 합격되어 배송을 시작했습니다.");
                                        psNoti.executeUpdate();
                                    }
                                }
                            }
                        }
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