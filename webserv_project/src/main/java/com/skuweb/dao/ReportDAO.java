package com.skuweb.dao; // 1. 실제 패키지 경로로 변경

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.skuweb.dao.dto.ReportDisplayDTO; // 2. 정확한 DTO 경로
import util.DBUtil; // 3. util 패키지의 DBUtil을 import!

public class ReportDAO {
    // ==========================================
    // [기능 1] 누군가 신고 버튼을 눌렀을 때 처리 (INSERT + UPDATE 세트)
    // ==========================================
    public boolean insertReport(String reporterId, String reportedUserId, int productId, String reportReason) {
        Connection conn = null;
        PreparedStatement pstmtInsert = null;
        PreparedStatement pstmtUpdate = null;
        
        String insertSql = "INSERT INTO reports (reporter_id, reported_user_id, product_id, report_reason, reported_at) VALUES (?, ?, ?, ?, NOW())";
        String updateSql = "UPDATE products SET report_count = report_count + 1 WHERE product_id = ?";
        
        try {
            // ★ 중요: 본인 프로젝트의 Connection 획득 메소드로 변경하세요 (예: DBManager.getConnection() 등)
             conn = DBUtil.getConnection(); 
            
            conn.setAutoCommit(false); // 자동 커밋 끄기 (트랜잭션 시작)
            
            // 1. 신고 내역 추가 (INSERT)
            pstmtInsert = conn.prepareStatement(insertSql);
            pstmtInsert.setString(1, reporterId);
            pstmtInsert.setString(2, reportedUserId);
            pstmtInsert.setInt(3, productId);
            pstmtInsert.setString(4, reportReason);
            pstmtInsert.executeUpdate();
            
            // 2. 상품 테이블 신고수 +1 (UPDATE)
            pstmtUpdate = conn.prepareStatement(updateSql);
            pstmtUpdate.setInt(1, productId);
            pstmtUpdate.executeUpdate();
            
            conn.commit(); // 둘 다 성공 시 최종 반영!
            return true;
            
        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); } // 하나라도 실패하면 롤백
            }
            return false;
        } finally {
            try { if (pstmtUpdate != null) pstmtUpdate.close(); } catch (Exception e) {}
            try { if (pstmtInsert != null) pstmtInsert.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    }

    // ==========================================
    // [기능 2] 관리자 페이지 등에서 신고된 목록을 보여줄 때 처리 (JOIN 쿼리)
    // ==========================================
    public List<ReportDisplayDTO> getReportDisplayList() {
        List<ReportDisplayDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT r.reported_user_id, p.title AS display_title, p.report_count " +
                     "FROM reports r " +
                     "JOIN products p ON r.product_id = p.product_id";
        
        try {
            conn = DBUtil.getConnection(); // 본인 프로젝트에 맞게 주석 해제하여 사용
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                String reportedUserId = rs.getString("reported_user_id");
                String displayTitle = rs.getString("display_title");
                int reportCount = rs.getInt("report_count");
                
                // 조회한 행 데이터를 DTO에 쏙 넣어서 리스트에 쌓기
                ReportDisplayDTO dto = new ReportDisplayDTO(reportedUserId, displayTitle, reportCount);
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
        return list; // 가득 찬 바구니 리스트 리턴
    }
}