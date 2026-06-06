package com.skuweb.controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/user/notiChoice")
public class NotiChoiceServlet extends HttpServlet {

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "ASDasd336699@";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String userId    = (String) session.getAttribute("userId");
        int    notiId    = Integer.parseInt(request.getParameter("notiId"));
        int    auctionId = Integer.parseInt(request.getParameter("auctionId"));
        String choice    = request.getParameter("choice"); // RECEIVE or RETURN

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            // 1) 구매자 알림 읽음 처리
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE notifications SET is_read = 1 WHERE noti_id = ?")) {
                ps.setInt(1, notiId);
                ps.executeUpdate();
            }

            // 2) 선택 메시지 구성
            String choiceMsg = "RECEIVE".equals(choice)
                ? "구매자가 불합격 상품을 그대로 수령하기로 결정했습니다."
                : "구매자가 불합격 상품을 반품하기로 결정했습니다. 반품 절차를 진행해주세요.";

            // 3) 판매자에게 알림 UPDATE
            try (PreparedStatement ps = conn.prepareStatement(
                    "UPDATE notifications SET message = ?, is_read = 0 " +
                    "WHERE auction_id = ? AND noti_type = 'REJECT_SELLER'")) {
                ps.setString(1, choiceMsg);
                ps.setInt(2, auctionId);
                ps.executeUpdate();
            }

            conn.close();

            response.sendRedirect(request.getContextPath() + "/views/index.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/index.jsp");
        }
    }
}