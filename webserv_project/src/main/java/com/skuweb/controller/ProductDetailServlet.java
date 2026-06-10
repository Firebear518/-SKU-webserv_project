package com.skuweb.controller;

import java.io.IOException;

import java.util.List;

import com.skuweb.dao.AuctionDAO;
import com.skuweb.dao.CommentDAO;
import com.skuweb.dao.dto.AuctionDTO;
import com.skuweb.dao.dto.CommentDTO;
import com.skuweb.dao.ProductDAO;
import com.skuweb.dao.dto.ProductDTO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/product/detail")
public class ProductDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int productId = Integer.parseInt(req.getParameter("productId"));

        ProductDAO productDAO = new ProductDAO();
        AuctionDAO auctionDAO = new AuctionDAO();
        CommentDAO commentDAO = new CommentDAO();

        ProductDTO product = productDAO.getProduct(productId);
        AuctionDTO auction = auctionDAO.getAuctionByProductId(productId);
        List<CommentDTO> comments = commentDAO.getCommentsByProductId(productId);

        req.setAttribute("product", product);
        req.setAttribute("auction", auction);
        req.setAttribute("comments", comments);

        req.getRequestDispatcher("/views/board/productDetail.jsp").forward(req, resp);
    }
}
