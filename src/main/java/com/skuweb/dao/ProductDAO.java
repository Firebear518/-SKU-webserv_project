package com.skuweb.dao;

 
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.skuweb.dao.dto.ProductDTO;
 
public class ProductDAO {
    // DB 연결 정보 (본인의 DB ID/PW/URL로 변경하세요)
    private String url = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=UTC";
    private String user = "root";
    private String password = "password";

    // DB 연결 함수
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        return DriverManager.getConnection(url, user, password);
    }

    // 상품 등록 함수
    public boolean insertProduct(ProductDTO dto) {
        String sql = "INSERT INTO product (product_name, category, start_price, end_time, description, main_image_path) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = getConnection(); 
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, dto.getProductName());
            pstmt.setString(2, dto.getCategory());
            pstmt.setInt(3, dto.getStartPrice()); 
            pstmt.setInt(4, dto.getEndTime());
            pstmt.setString(5, dto.getDescription());
            pstmt.setString(6, dto.getMainImagePath());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}
}