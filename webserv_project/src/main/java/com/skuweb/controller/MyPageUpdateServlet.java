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
import java.sql.ResultSet;
import java.sql.SQLException;
import util.DBUtil;

/**
 * Servlet implementation class MyPageUpdateServlet
 * 회원정보 수정 (기존 비밀번호 검증 추가)
 */
@WebServlet("/user/myPageUpdate")
public class MyPageUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("=== MyPageUpdateServlet doPost 시작 ===");
        
        // 한글 입력값 처리
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

        // 1. 파라미터 값 가져오기
        String currentPassword = request.getParameter("currentPassword"); // ⭐ [추가] 현재 비밀번호
        String newPassword = request.getParameter("newPassword");
        String newPasswordConfirm = request.getParameter("newPasswordConfirm");
        String userPhone = request.getParameter("userPhone");
        String userAddress = request.getParameter("userAddress");
        String userAddressDetail = request.getParameter("userAddressDetail");

        // 비밀번호를 변경하러 들어왔는지 여부 체크
        boolean isPasswordChange = (newPassword != null && !newPassword.trim().isEmpty());

        // 2. 입력값 검증
        if (isPasswordChange) {
            // 현재 비밀번호 입력 여부 확인
            if (currentPassword == null || currentPassword.trim().isEmpty()) {
                System.out.println("❌ 현재 비밀번호 입력 안 됨!");
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=emptyCurrentPassword");
                return;
            }
            
            if (newPasswordConfirm == null || newPasswordConfirm.trim().isEmpty()) {
                System.out.println("❌ 새 비밀번호 확인 입력 안 됨!");
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=emptyPasswordConfirm");
                return;
            }
            
            if (!newPassword.equals(newPasswordConfirm)) {
                System.out.println("❌ 새 비밀번호 불일치!");
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=passwordMismatch");
                return;
            }
            
            if (newPassword.length() < 4) {
                System.out.println("❌ 새 비밀번호 너무 짧음!");
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=passwordTooShort");
                return;
            }
        }
        
        // 배송지 정보 필수 입력 확인
        if (userPhone == null || userPhone.trim().isEmpty() ||
            userAddress == null || userAddress.trim().isEmpty()) {
            System.out.println("❌ 배송지 정보 입력 안 됨!");
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=emptyAddress");
            return;
        }

        // 전화번호 하이픈 자동 삽입
        String formattedPhone = userPhone.replaceAll("[^0-9]", "");
        if (formattedPhone.length() == 11) {
            formattedPhone = formattedPhone.replaceFirst("(\\d{3})(\\d{4})(\\d{4})", "$1-$2-$3");
        } else if (formattedPhone.length() == 10) {
            if (formattedPhone.startsWith("02")) {
                formattedPhone = formattedPhone.replaceFirst("(\\d{2})(\\d{4})(\\d{4})", "$1-$2-$3");
            } else {
                formattedPhone = formattedPhone.replaceFirst("(\\d{3})(\\d{3})(\\d{4})", "$1-$2-$3");
            }
        } else if (formattedPhone.length() == 9) {
            formattedPhone = formattedPhone.replaceFirst("(\\d{2})(\\d{3})(\\d{4})", "$1-$2-$3");
        }
        userPhone = formattedPhone;

        System.out.println("3. ✅ 기본 입력값 검증 완료!");

        // 3. 데이터베이스 로직
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // 트랜잭션 시작

            // ⭐ [추가] 비밀번호를 변경할 때만 현재 비밀번호 일치 여부를 DB에서 조회하여 검증
            if (isPasswordChange) {
                String checkSql = "SELECT password FROM users WHERE userId = ?";
                pstmt = conn.prepareStatement(checkSql);
                pstmt.setString(1, userId);
                rs = pstmt.executeQuery();
                
                String dbPassword = null;
                if (rs.next()) {
                    dbPassword = rs.getString("password");
                }
                
                // 자원 중간 정리
                rs.close();
                pstmt.close();
                
                // 입력한 현재 비밀번호가 DB에 저장된 비밀번호와 다르면 튕겨내기
                if (dbPassword == null || !dbPassword.equals(currentPassword)) {
                    System.out.println("❌ 현재 비밀번호가 DB와 일치하지 않음!");
                    response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=wrongCurrentPassword");
                    conn.rollback();
                    return;
                }
            }

            // 업데이트 SQL 작성 및 실행
            String sql;
            if (isPasswordChange) {
                sql = "UPDATE users SET password=?, userPhone=?, userAddress=?, userAddressDetail=? WHERE userId=?";
            } else {
                sql = "UPDATE users SET userPhone=?, userAddress=?, userAddressDetail=? WHERE userId=?";
            }
            
            pstmt = conn.prepareStatement(sql);
            int paramIndex = 1;

            if (isPasswordChange) {
                pstmt.setString(paramIndex++, newPassword);
            }
            pstmt.setString(paramIndex++, userPhone.trim());
            pstmt.setString(paramIndex++, userAddress.trim());
            pstmt.setString(paramIndex++, userAddressDetail != null ? userAddressDetail.trim() : "");
            pstmt.setString(paramIndex++, userId);
            
            int result = pstmt.executeUpdate();
            conn.commit(); // 성공 시 커밋
            System.out.println("7. 업데이트 결과: " + result + "행 (COMMIT 완료)");

            if (result > 0) {
                // 세션 최신 정보로 갱신
                session.setAttribute("user_phone", userPhone);
                session.setAttribute("user_address", userAddress);
                session.setAttribute("user_address_detail", userAddressDetail);
                
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=updateFailed");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=dbError");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/user/myPage.jsp?error=serverError");
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                    conn.close();
                }
            } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
