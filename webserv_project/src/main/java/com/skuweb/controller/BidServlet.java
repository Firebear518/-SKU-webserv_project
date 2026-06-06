package com.skuweb.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

import com.skuweb.dao.BidDAO;
import com.skuweb.dao.dto.BidResultDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/bid")
public class BidServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "ASDasd336699@";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int auctionId = Integer.parseInt(request.getParameter("auctionId"));
            int bidPrice  = Integer.parseInt(request.getParameter("bidPrice"));

            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userId") == null) {
                out.print("{\"success\":false,\"message\":\"로그인이 필요합니다.\",\"currentPrice\":0}");
                return;
            }

            String sessionUserId = (String) session.getAttribute("userId");

            // BAN 유저 차단
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement("SELECT status FROM users WHERE userId = ?")) {
                ps.setString(1, sessionUserId);
                ResultSet rs = ps.executeQuery();
                if (rs.next() && "영구 정지".equals(rs.getString("status"))) {
                    out.print("{\"success\":false,\"message\":\"정지된 계정은 입찰이 불가합니다.\",\"currentPrice\":0}");
                    return;
                }
            } catch (Exception e) { e.printStackTrace(); }

            BidDAO bidDAO = new BidDAO();
            BidResultDTO result = bidDAO.placeBid(auctionId, Integer.parseInt(sessionUserId), bidPrice);

            out.print("{");
            out.print("\"success\":" + result.isSuccess() + ",");
            out.print("\"message\":\"" + result.getMessage() + "\",");
            out.print("\"currentPrice\":" + result.getCurrentPrice());
            out.print("}");

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"잘못된 요청 값입니다.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"서버 오류가 발생했습니다.\"}");
        } finally {
            out.close();
        }
    }
}