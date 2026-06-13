package com.skuweb.controller;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import util.DBUtil;

/**
 * Servlet implementation class MyPageUpdateServlet
 * 회원정보 수정 (비밀번호, 배송지 정보)
 */
@WebServlet("/user/myPageUpdate")
public class MyPageUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== MyPageUpdateServlet doPost 시작 ===");
        
        // ✅ 한글 입력값 처리
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        // 세션에서 userId 가져오기
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        
        System.out.println("1. 세션 userId: " + userId);
        
        // 로그인 확인
        if (userId == null || userId.isEmpty()) {
            System.out.println("❌ 로그인하지 않음!");
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }

        // 1. 파라미터 값 가져오기 (비밀번호, 주소 등)
        String newPassword = request.getParameter("newPassword");
        String newPasswordConfirm = request.getParameter("newPasswordConfirm");
        String userPhone = request.getParameter("userPhone");
        String userAddress = request.getParameter("userAddress");
        String userAddressDetail = request.getParameter("userAddressDetail");
        
        System.out.println("2. 받은 파라미터:");
        System.out.println("   - newPassword: " + newPassword);
        System.out.println("   - newPasswordConfirm: " + newPasswordConfirm);
        System.out.println("   - userPhone: " + userPhone);
        System.out.println("   - userAddress: " + userAddress);
        System.out.println("   - userAddressDetail: " + userAddressDetail);

        // 2. 입력값 검증
        // 비밀번호 입력 여부 확인
        if (newPassword == null || newPassword.trim().isEmpty()) {
            System.out.println("❌ 비밀번호 입력 안 됨!");
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=emptyPassword");
            return;
        }
        
        if (newPasswordConfirm == null || newPasswordConfirm.trim().isEmpty()) {
            System.out.println("❌ 비밀번호 확인 입력 안 됨!");
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=emptyPasswordConfirm");
            return;
        }
        
        // 배송지 정보 필수 입력 확인
        if (userPhone == null || userPhone.trim().isEmpty() ||
            userAddress == null || userAddress.trim().isEmpty()) {
            System.out.println("❌ 배송지 정보 입력 안 됨!");
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=emptyAddress");
            return;
        }

        // 비밀번호 일치 확인
        if (!newPassword.equals(newPasswordConfirm)) {
            System.out.println("❌ 비밀번호 불일치!");
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=passwordMismatch");
            return;
        }
        
        // 비밀번호 길이 검증 (최소 4자 이상)
        if (newPassword.length() < 4) {
            System.out.println("❌ 비밀번호 너무 짧음!");
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=passwordTooShort");
            return;
        }

        System.out.println("3. ✅ 검증 완료!");

        // 3. 데이터베이스 업데이트 로직
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            // DB 연결
            conn = DBUtil.getConnection();
            System.out.println("4. ✅ DB 연결 성공!");
            
            // ✅ Auto-commit 비활성화
            conn.setAutoCommit(false);
            System.out.println("4-1. Auto-commit 비활성화");

            // SQL 쿼리 작성
            String sql = "UPDATE users SET password=?, userPhone=?, userAddress=?, userAddressDetail=? WHERE userId=?";
            System.out.println("5. SQL: " + sql);
            
            pstmt = conn.prepareStatement(sql);

            // 파라미터 설정
            pstmt.setString(1, newPassword);
            pstmt.setString(2, userPhone.trim());
            pstmt.setString(3, userAddress.trim());
            pstmt.setString(4, userAddressDetail != null ? userAddressDetail.trim() : "");
            pstmt.setString(5, userId);
            
            System.out.println("6. 파라미터 설정 완료");
            System.out.println("   - 새 비밀번호: " + newPassword);
            System.out.println("   - 새 전화번호: " + userPhone.trim());
            System.out.println("   - 새 주소: " + userAddress.trim());
            System.out.println("   - userId: " + userId);

            // 쿼리 실행
            int result = pstmt.executeUpdate();
            
            System.out.println("7. 업데이트 결과: " + result + "행");

            // ✅ Commit 실행 (중요!)
            conn.commit();
            System.out.println("7-1. ✅ COMMIT 실행됨!");

            // 업데이트 성공 여부 확인
            if (result > 0) {
                System.out.println("✅ DB 업데이트 성공!");
                // 4. 성공 시 myPage.jsp로 리다이렉트 (쿼리 파라미터로 결과 전달)
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?success=true");
            } else {
                System.out.println("❌ 업데이트 실패 (일치하는 회원 없음)");
                // 실패 시 (일치하는 회원이 없는 경우)
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=updateFailed");
            }

        } catch (SQLException e) {
            // SQL 예외 처리
            System.out.println("❌ SQL 오류: " + e.getMessage());
            e.printStackTrace();
            System.err.println("DB 업데이트 오류: " + e.getMessage());
            
            // ✅ Rollback 실행
            try {
                if (conn != null) {
                    conn.rollback();
                    System.out.println("7-2. ⚠ ROLLBACK 실행됨!");
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=dbError");
            
        } catch (Exception e) {
            // 그 외 예외 처리
            System.out.println("❌ 서버 오류: " + e.getMessage());
            e.printStackTrace();
            System.err.println("서버 오류: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=serverError");
            
        } finally {
            // 자원 정리
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);  // ✅ Auto-commit 다시 활성화
                    conn.close();
                }
                System.out.println("8. ✅ 자원 정리 완료");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        System.out.println("=== MyPageUpdateServlet doPost 종료 ===\n");
    }
}
