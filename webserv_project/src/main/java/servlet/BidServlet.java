package servlet;

import java.io.IOException;
import java.io.PrintWriter;

import dao.BidDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/bid")
public class BidServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    public BidServlet() {
        super();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        PrintWriter out = response.getWriter();

        try {
            int auctionId = Integer.parseInt(request.getParameter("auctionId"));
            int userId = Integer.parseInt(request.getParameter("userId"));
            int bidPrice = Integer.parseInt(request.getParameter("bidPrice"));

            BidDAO bidDAO = new BidDAO();
            boolean result = bidDAO.placeBid(auctionId, userId, bidPrice);

            if (result) {
                out.print("{\"success\":true, \"message\":\"입찰 성공\"}");
            } else {
                out.print("{\"success\":false, \"message\":\"입찰 실패\"}");
            }

        } catch (NumberFormatException e) {
            out.print("{\"success\":false, \"message\":\"잘못된 요청 값입니다.\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false, \"message\":\"서버 오류가 발생했습니다.\"}");
        } finally {
            out.close();
        }
    }
}