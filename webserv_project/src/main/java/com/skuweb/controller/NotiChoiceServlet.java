package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// 프로젝트 구조에 맞춘 DBUtil 경로
import util.DBUtil;

@WebServlet("/user/notiChoice")
public class NotiChoiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        // 세션 만료 안전장치
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String notiIdStr = request.getParameter("notiId");
        String auctionIdStr = request.getParameter("auctionId");
        String choice = request.getParameter("choice");

        if (notiIdStr == null || auctionIdStr == null || choice == null) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        try {
            int notiId = Integer.parseInt(notiIdStr);
            int auctionId = Integer.parseInt(auctionIdStr);

            try (Connection conn = DBUtil.getConnection()) {

                // 1) 상품명과 판매자 ID 조회 (products 테이블 Join)
                String productName = "알 수 없는 상품";
                String sellerId = null;
                
                String findProductSql = "SELECT p.title, p.seller_id " +
                                        "FROM auction a " +
                                        "JOIN products p ON a.product_id = p.product_id " +
                                        "WHERE a.auction_id = ?";
                
                try (PreparedStatement psName = conn.prepareStatement(findProductSql)) { 
                    psName.setInt(1, auctionId);
                    try (ResultSet rs = psName.executeQuery()) {
                        if (rs.next()) {
                            productName = rs.getString("title");
                            sellerId = rs.getString("seller_id");
                        }
                    }
                }

                // 2) 구매자 알림 읽음 처리
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE notifications SET is_read = 1 WHERE noti_id = ?")) {
                    ps.setInt(1, notiId);
                    ps.executeUpdate();
                }

                // 3) 판매자에게 알림 INSERT (사용자가 수령/반품 선택했다는 사실)
                if (sellerId != null) {
                    String choiceMsg = "RECEIVE".equals(choice)
                        ? "[" + productName + "] 구매자가 불합격 상품을 그대로 수령하기로 결정했습니다."
                        : "[" + productName + "] 구매자가 불합격 상품을 반품하기로 결정했습니다. 반품 절차를 진행해주세요.";
                    
                    String insertNotiSql = "INSERT INTO notifications (user_id, auction_id, message, noti_type, is_read) VALUES (?, ?, ?, 'INFO', 0)";
                    try (PreparedStatement ps = conn.prepareStatement(insertNotiSql)) {
                        ps.setString(1, sellerId);
                        ps.setInt(2, auctionId);
                        ps.setString(3, choiceMsg);
                        ps.executeUpdate();
                    }
                }

                // 🌟 4) 낙찰자(본인)에게 '배송 시작' 알림 INSERT (수령하기를 눌렀을 경우)
                if ("RECEIVE".equals(choice)) {
                    String buyerMsg = "[" + productName + "] 상품 인수가 확정되어 배송이 시작되었습니다.";
                    String insertBuyerNotiSql = "INSERT INTO notifications (user_id, auction_id, message, noti_type, is_read) VALUES (?, ?, ?, 'INFO', 0)";
                    try (PreparedStatement psBuyer = conn.prepareStatement(insertBuyerNotiSql)) {
                        psBuyer.setString(1, userId); // 현재 세션 사용자가 낙찰자
                        psBuyer.setInt(2, auctionId);
                        psBuyer.setString(3, buyerMsg);
                        psBuyer.executeUpdate();
                    }
                }

                // 5) 경매(auction) 테이블의 상태 업데이트
                String newStatus = "RECEIVE".equals(choice) ? "불합격(인수)" : "불합격(인수 거부)";
                try (PreparedStatement ps = conn.prepareStatement(
                        "UPDATE auction SET status = ? WHERE auction_id = ?")) {
                    ps.setString(1, newStatus);
                    ps.setInt(2, auctionId);
                    ps.executeUpdate();
                }
            }

            response.sendRedirect(request.getContextPath() + "/index.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}