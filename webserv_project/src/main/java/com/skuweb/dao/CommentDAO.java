package com.skuweb.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.skuweb.dao.dto.CommentDTO;

import util.DBUtil;

public class CommentDAO {

    // 특정 상품의 댓글 목록 (오래된 순)
    public List<CommentDTO> getCommentsByProductId(int productId) {
        List<CommentDTO> list = new ArrayList<>();
        String sql = "SELECT comment_id, product_id, user_id, content, created_at " +
                     "FROM comments WHERE product_id = ? ORDER BY comment_id ASC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    CommentDTO c = new CommentDTO();
                    c.setCommentId(rs.getInt("comment_id"));
                    c.setProductId(rs.getInt("product_id"));
                    c.setUserId(rs.getString("user_id"));
                    c.setContent(rs.getString("content"));
                    c.setCreatedAt(rs.getString("created_at"));
                    list.add(c);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 댓글 등록 → 성공 여부
    public boolean insertComment(int productId, String userId, String content) {
        String sql = "INSERT INTO comments (product_id, user_id, content) VALUES (?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            pstmt.setString(2, userId);
            pstmt.setString(3, content);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}
