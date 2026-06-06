package servlet;

import java.io.IOException;

import com.skuweb.dao.AuctionDAO;
import com.skuweb.dao.dto.AuctionDTO;
import dao.ProductDAO;
import dto.Product;
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

        Product product    = productDAO.getProduct(productId);
        AuctionDTO auction = auctionDAO.getAuctionByProductId(productId);

        req.setAttribute("product", product);
        req.setAttribute("auction", auction);

        req.getRequestDispatcher("/views/board/productDetail.jsp").forward(req, resp);
    }
}
