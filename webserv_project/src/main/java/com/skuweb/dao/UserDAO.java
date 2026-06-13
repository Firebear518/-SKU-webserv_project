package com.skuweb.dao; // 🌟 본인의 패키지 경로가 맞는지 확인하세요!

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet; // 🌟 필수 추가
import util.DBUtil;        // 🌟 필수 추가

public class UserDAO {

    public boolean isIdDuplicate(String userId) {
        String sql = "SELECT COUNT(*) FROM users WHERE userId = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, userId);
            
            // 🌟 'var'를 'ResultSet'으로 변경하여 Java 버전 호환성 해결
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    // count가 1 이상이면 true (중복임)
                    return rs.getInt(1) > 0;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false; // 오류 발생 시 안전하게 false 반환
    }
}
