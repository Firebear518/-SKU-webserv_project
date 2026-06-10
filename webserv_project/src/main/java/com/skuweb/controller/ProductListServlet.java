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

@WebServlet("/board/list.do")
public class ProductListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        String searchKeyword = req.getParameter("searchKeyword");

        if (searchKeyword == null) {
            searchKeyword = "";
        }

        ProductDAO productDAO = new ProductDAO();
        List<ProductDTO> productList = productDAO.searchProductsByTitle(searchKeyword);

        req.setAttribute("productList", productList);
        req.setAttribute("searchKeyword", searchKeyword);

        req.getRequestDispatcher("/views/board/productList.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}