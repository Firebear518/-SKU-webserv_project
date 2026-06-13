package com.skuweb.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import com.skuweb.dao.ProductDAO;
import com.skuweb.dao.dto.ProductDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import util.DBUtil;

/**
 * Servlet implementation class MyPageServlet
 * 회원의 마이페이지 정보 조회 (배송지 정보 + 등록상품)
 */
@WebServlet("/user/myPage")
public class MyPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // 인코딩 설정
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        
        // 세션에서 userId 가져오기
        HttpSession session = req.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;
        
        // 로그인 확인
        if (userId == null || userId.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/views/user/login.jsp");
            return;
        }
        
        // 1. 현재 회원의 배송정보 DB에서 조회
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBUtil.getConnection();
            
            // SQL 쿼리: 현재 회원의 정보 조회
            String sql = "SELECT userId, userName, userPhone, userAddress, userAddressDetail FROM users WHERE userId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                // DB에서 조회한 정보를 request에 저장
                req.setAttribute("user_phone", rs.getString("userPhone"));
                req.setAttribute("user_address", rs.getString("userAddress"));
                req.setAttribute("user_address_detail", rs.getString("userAddressDetail"));
                System.out.println("회원정보 조회 성공: " + userId);
            }
            
        } catch (SQLException e) {
            // SQL 예외 처리
            e.printStackTrace();
            System.err.println("DB 조회 오류: " + e.getMessage());
            req.setAttribute("error", "dbError");
            
        } catch (Exception e) {
            // 기타 예외 처리
            e.printStackTrace();
            System.err.println("서버 오류: " + e.getMessage());
            req.setAttribute("error", "serverError");
            
        } finally {
            // 자원 정리
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        // 2. 현재 세션 user_id == products.seller_id 인 상품 목록 조회
        try {
            ProductDAO productDAO = new ProductDAO();
            List<ProductDTO> myProducts = productDAO.getProductsBySeller(userId);
            req.setAttribute("myProducts", myProducts);
            System.out.println("상품목록 조회 성공: " + (myProducts != null ? myProducts.size() : 0) + "개");
            
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("상품목록 조회 오류: " + e.getMessage());
            req.setAttribute("myProducts", null);
        }
        
        // 3. myPage.jsp로 포워드
        try {
            req.getRequestDispatcher("/views/user/myPage.jsp").forward(req, resp);
        } catch (ServletException | IOException e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "페이지 포워드 오류");
        }
    }
}
