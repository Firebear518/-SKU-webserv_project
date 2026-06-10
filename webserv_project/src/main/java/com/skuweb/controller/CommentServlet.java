package com.skuweb.controller;

import java.io.IOException;

import com.skuweb.dao.CommentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/product/comment")
public class CommentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        int productId;
        try {
            productId = Integer.parseInt(request.getParameter("productId"));
        } catch (NumberFormatException e) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>alert('잘못된 접근입니다.'); history.back();</script>");
            return;
        }

        String detailUrl = request.getContextPath() + "/product/detail?productId=" + productId + "#comments";

        // 로그인 확인
        HttpSession session = request.getSession(false);
        String userId = (session != null) ? (String) session.getAttribute("userId") : null;
        if (userId == null) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().write("<script>alert('댓글 작성은 로그인 후 이용 가능합니다.'); history.back();</script>");
            return;
        }

        String content = request.getParameter("content");
        if (content == null || content.trim().isEmpty()) {
            response.sendRedirect(detailUrl);
            return;
        }

        CommentDAO commentDAO = new CommentDAO();

        boolean result =
    	    commentDAO.insertComment(
    	        productId,
    	        userId,
    	        content.trim()
    	    );

    	if (!result) {
    	    response.getWriter().write(
    	        "<script>alert('댓글 등록 실패');history.back();</script>"
    	    );
    	    return;
    	}

    	response.sendRedirect(detailUrl);
    }
}
