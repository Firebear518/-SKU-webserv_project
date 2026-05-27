<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<body>  
    <h1>관리자 대시보드</h1>
    <table border="1">
        <tr><th>상품ID</th><th>신고 횟수</th><th>기능</th></tr>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/auction_db", "jinwoo", "1234");

                String sql = "SELECT product_id, COUNT(*) as report_count FROM reports GROUP BY product_id";
                pstmt = conn.prepareStatement(sql);
                rs = pstmt.executeQuery();

                while(rs.next()) {
                    String pId = rs.getString("product_id");
                    int count = rs.getInt("report_count");
        %>
                    <tr>
                        <td><%= pId %></td>
                        <td><%= count %></td>
                        <td><a href="DeleteProductServlet?id=<%= pId %>">강제 삭제</a></td>
                    </tr>
        <%
                }
            } catch(Exception e) {
                e.printStackTrace();
            } finally {
                if(rs != null) rs.close();
                if(pstmt != null) pstmt.close();
                if(conn != null) conn.close();
            }
        %>
    </table>
</body>
</html>