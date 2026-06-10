package com.skuweb.controller;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

import com.skuweb.dao.AuctionDAO;
import com.skuweb.dao.ProductDAO;
import com.skuweb.dao.dto.ProductDTO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/product/register")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class ProductRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // 1. 폼 데이터 수집
        String productName = request.getParameter("productName");
        String category    = request.getParameter("category");
        String startPrice  = request.getParameter("startPrice");
        String endTimeDays = request.getParameter("endTime");
        String description = request.getParameter("description");

        if (productName == null || productName.trim().isEmpty()) {
            response.getWriter().write("<script>alert('상품명이 공백입니다.'); history.back();</script>");
            return;
        }

        // 2. 이미지 저장 경로 확보
        String uploadPath = getServletContext().getRealPath("/uploads");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }

        String savedMainFileName = "";
        List<String> savedDetailFileNames = new ArrayList<>();

        try {
            Collection<Part> parts = request.getParts();
            for (Part part : parts) {
                if (part.getSubmittedFileName() == null || part.getSize() == 0) continue;

                String originalName  = getFileName(part);
                String savedFileName = UUID.randomUUID().toString() + "_" + originalName;

                if (part.getName().equals("mainImage")) {
                    part.write(uploadPath + File.separator + savedFileName);
                    savedMainFileName = savedFileName;
                } else if (part.getName().equals("detailImages")) {
                    part.write(uploadPath + File.separator + savedFileName);
                    savedDetailFileNames.add(savedFileName);
                }
            }

            // 3. 세션에서 로그인 유저 ID 가져오기
            String sellerId = (String) request.getSession().getAttribute("userId");
            if (sellerId == null) sellerId = "anonymous";

            // 4. 카테고리명 → category_id 변환
            ProductDAO productDAO = new ProductDAO();
            int categoryId = productDAO.getCategoryIdByName(category);

            // 5. Product 객체 생성 후 DB 등록
            ProductDTO product = new ProductDTO();
            product.setTitle(productName);
            product.setDescription(description);
            product.setPrice(Integer.parseInt(startPrice));
            product.setImagePath("/uploads/" + savedMainFileName);
            product.setSellerId(sellerId);
            product.setCategoryId(categoryId);
            if (!savedDetailFileNames.isEmpty()) {
                StringBuilder sb = new StringBuilder();
                for (String name : savedDetailFileNames) {
                    if (sb.length() > 0) sb.append(",");
                    sb.append("/uploads/").append(name);
                }
                product.setDetailImagePaths(sb.toString());
            }

            int newProductId = productDAO.insertProduct(product);

            if (newProductId <= 0) {
                response.getWriter().write("<script>alert('상품 등록에 실패했습니다. 관리자에게 문의하세요.'); history.back();</script>");
                return;
            }

            // 6. 경매 레코드 생성 (경매 마감 기한 적용)
            int endDays = (endTimeDays != null && !endTimeDays.isEmpty()) ? Integer.parseInt(endTimeDays) : 7;
            AuctionDAO auctionDAO = new AuctionDAO();
            auctionDAO.insertAuction(newProductId, Integer.parseInt(startPrice), endDays);

            // 7. 등록 완료 후 경매 목록으로 이동
            response.getWriter().write("<script>");
            response.getWriter().write("alert('상품이 성공적으로 등록되었습니다!');");
            response.getWriter().write("location.href='" + request.getContextPath() + "/board/list.do';");
            response.getWriter().write("</script>");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("<script>alert('오류가 발생했습니다: " + e.getMessage() + "'); history.back();</script>");
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}
