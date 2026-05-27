

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String productId = request.getParameter("id");
        
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            // 1. DB 연결 설정
            Class.forName("com.mysql.cj.jdbc.Driver");
            // 본인의 DB URL, ID, 패스워드로 정확히 맞춰주세요
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/auction_db", "jinwoo", "1234");
            
            // 2. 삭제 쿼리
            String sql = "DELETE FROM products WHERE product_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, productId);
            
            // 3. 실행
            pstmt.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 4. 안전한 연결 종료 (에러가 났던 finally 블록 해결)
            try {
                if (pstmt != null) pstmt.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        // 5. 삭제 후 관리자 페이지로 이동
        response.sendRedirect("admin.jsp");
    }
} 
