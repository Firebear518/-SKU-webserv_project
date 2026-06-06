package com.skuweb.controller;

import java.io.File;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

@WebServlet("/product/register")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class ProductRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String DB_URL  = "jdbc:mysql://localhost:3306/auction_db?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "ASDasd336699@";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // BAN 유저 차단
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/views/user/login.jsp");
            return;
        }
        String sessionUserId = (String) session.getAttribute("userId");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                 PreparedStatement ps = conn.prepareStatement("SELECT status FROM users WHERE userId = ?")) {
                ps.setString(1, sessionUserId);
                ResultSet rs = ps.executeQuery();
                if (rs.next() && "영구 정지".equals(rs.getString("status"))) {
                    response.getWriter().write("<script>alert('정지된 계정은 상품 등록이 불가합니다.'); history.back();</script>");
                    return;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        // 기존 코드 그대로
        String productName = request.getParameter("productName");
        String category = request.getParameter("category");
        String startPrice = request.getParameter("startPrice");
        String endTime = request.getParameter("endTime");
        String description = request.getParameter("description");

        if (productName == null || productName.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("<script>alert('상품명이 공백입니다. 올바른 상품명을 입력해주세요.'); history.back();</script>");
            return;
        }

        String uploadPath = getServletContext().getRealPath("/uploads");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdir();

        String savedMainFileName = "";
        List<String> savedDetailFileNames = new ArrayList<>();

        try {
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getSubmittedFileName() == null || part.getSize() == 0) continue;
                String originalName = getFileName(part);
                String savedFileName = UUID.randomUUID().toString() + "_" + originalName;
                if (part.getName().equals("mainImage")) {
                    part.write(uploadPath + File.separator + savedFileName);
                    savedMainFileName = savedFileName;
                } else if (part.getName().equals("detailImages")) {
                    part.write(uploadPath + File.separator + savedFileName);
                    savedDetailFileNames.add(savedFileName);
                }
            }
            response.getWriter().write("<script>");
            response.getWriter().write("alert('🎉 상품 등록 테스트 성공!\\n\\n[텍스트 데이터]\\n- 상품명: " + productName + "\\n- 카테고리: " + category + "\\n- 시작가: ₩" + startPrice + "\\n\\n[업로드 파일 결과]\\n- 대표 이미지: " + savedMainFileName + "\\n- 상세 이미지 개수: " + savedDetailFileNames.size() + "장 저장 완료');");
            response.getWriter().write("location.href='" + request.getContextPath() + "/';");
            response.getWriter().write("</script>");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("<script>alert('파일 서버 전송 중 오류가 발생했습니다.'); history.back();</script>");
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}