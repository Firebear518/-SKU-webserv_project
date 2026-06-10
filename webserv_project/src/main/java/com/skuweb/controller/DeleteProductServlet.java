package com.skuweb.controller;

import java.io.IOException;

import com.skuweb.dao.ProductDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html; charset=UTF-8");

        // 로그인 확인
        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;
        if (userId == null) {
            response.getWriter().write("<script>alert('로그인이 필요합니다.'); location.href='"
                    + request.getContextPath() + "/views/user/login.jsp';</script>");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException e) {
            response.getWriter().write("<script>alert('잘못된 요청입니다.'); history.back();</script>");
            return;
        }

        // 본인 소유 상품만 삭제 (FK 연쇄 삭제는 DAO 내부 트랜잭션에서 처리)
        ProductDAO productDAO = new ProductDAO();
        boolean deleted = productDAO.deleteProduct(productId, userId);

        if (deleted) {
            response.getWriter().write("<script>alert('상품이 삭제되었습니다.'); location.href='"
                    + request.getContextPath() + "/user/myPage';</script>");
        } else {
            response.getWriter().write("<script>alert('삭제에 실패했습니다. (본인 상품이 아니거나 이미 삭제됨)'); location.href='"
                    + request.getContextPath() + "/user/myPage';</script>");
        }
    }
}
