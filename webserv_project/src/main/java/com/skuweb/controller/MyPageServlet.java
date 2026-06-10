package com.skuweb.controller;

import java.io.IOException;
import java.util.List;

import com.skuweb.dao.ProductDAO;
import com.skuweb.dao.dto.ProductDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/user/myPage")
public class MyPageServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;

        // 로그인하지 않았으면 로그인 페이지로
        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/views/user/login.jsp");
            return;
        }

        // 현재 세션 user_id == products.seller_id 인 상품 목록 조회
        ProductDAO productDAO = new ProductDAO();
        List<ProductDTO> myProducts = productDAO.getProductsBySeller(userId);

        req.setAttribute("myProducts", myProducts);
        req.getRequestDispatcher("/views/user/myPage.jsp").forward(req, resp);
    }
}
