package com.skuweb.dao;

import java.sql.*;
import com.skuweb.dao.dto.ProductDTO;
import util.DBUtil;

// 레거시 파일 - 사용되지 않음 (실제 구현은 dao.ProductDAO 사용)
public class ProductDAO {

    public boolean insertProduct(ProductDTO dto) {
        String sql = "INSERT INTO products (title, description, price, seller_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, dto.getProductName());
            pstmt.setString(2, dto.getDescription());
            pstmt.setInt(3, dto.getStartPrice());
            pstmt.setString(4, "unknown");
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
