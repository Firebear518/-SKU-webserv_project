package com.skuweb.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;

import com.skuweb.dao.AuctionDAO;
import com.skuweb.dao.dto.AuctionDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/auctionDecision")
public class AuctionDecisionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        try {
            HttpSession session = request.getSession(false);

            if (session == null || session.getAttribute("userId") == null) {
                out.print("{\"success\":false,\"message\":\"로그인이 필요합니다.\"}");
                return;
            }

            int auctionId = Integer.parseInt(request.getParameter("auctionId"));
            String decision = request.getParameter("decision");

            String status;
            
            if ("sold".equals(decision)) {
                status = "SOLD";
            } else if ("failed".equals(decision)) {
                status = "FAILED";
            } else {
                out.print("{\"success\":false,\"message\":\"잘못된 결정 값입니다.\"}");
                return;
            }

            AuctionDAO auctionDAO = new AuctionDAO();
            AuctionDTO auction = auctionDAO.getAuctionById(auctionId);
            
            if (auction == null) {
            	out.print("{\"success\":false,\"message\":\"존재하지 않는 경매입니다.\"}");
            	return;
            }
            
            LocalDateTime endTime = 
            	LocalDateTime.parse(
            		auction.getEndTime().replace(" ", "T")
            	);
            
            if (LocalDateTime.now().isBefore(endTime)) {
            	out.print("{\"success\":false,\"message\":\"경매가 아직 종료되지 않았습니다.\"}");
            	return;
            }
            
            boolean result = auctionDAO.updateAuctionStatus(auctionId, status);

            if (result) {
                out.print("{\"success\":true,\"message\":\"경매 상태가 변경되었습니다.\"}");
            } else {
                out.print("{\"success\":false,\"message\":\"경매 상태 변경에 실패했습니다.\"}");
            }

        } catch (NumberFormatException e) {
            out.print("{\"success\":false,\"message\":\"auctionId 값이 올바르지 않습니다.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"서버 오류가 발생했습니다.\"}");
        } finally {
            out.close();
        }
    }
}