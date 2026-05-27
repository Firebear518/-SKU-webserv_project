package com.skuweb.controller;

import java.io.File;
import java.io.IOException;
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
import jakarta.servlet.http.Part;

@WebServlet("/product/register")
// 💡 파일 업로드를 안전하게 처리하기 위한 필수 설정
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB (이 용량 이하는 메모리 사용, 초과 시 임시 디렉토리에 저장)
    maxFileSize = 1024 * 1024 * 10,       // 파일 1개당 최대 용량: 10MB
    maxRequestSize = 1024 * 1024 * 50     // 한 번에 보낼 수 있는 전체 요청 최대 용량: 50MB
)
public class ProductRegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 인코딩 및 응답 타입 설정 (한국어 깨짐 방지)
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // 1. 일반 텍스트 폼 데이터 수집
        String productName = request.getParameter("productName");
        String category = request.getParameter("category");
        String startPrice = request.getParameter("startPrice");
        String endTime = request.getParameter("endTime");
        String description = request.getParameter("description");

        // [2차 방어] 혹시라도 프론트엔드를 우회해서 공백이 들어올 경우 원천 차단
        if (productName == null || productName.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("<script>alert('상품명이 공백입니다. 올바른 상품명을 입력해주세요.'); history.back();</script>");
            return;
        }

        // 2. 파일이 저장될 서버 내부의 실제 물리적 경로 확보 (/src/main/webapp/uploads 가 타겟)
        String uploadPath = getServletContext().getRealPath("/uploads");
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir(); // 서버 내에 uploads 폴더가 없을 경우 자동 생성
        }

        // 향후 차근차근 DB(MySQL 등)에 밀어 넣을 파일명 변수 바구니 준비
        String savedMainFileName = "";
        List<String> savedDetailFileNames = new ArrayList<>();

        try {
            // 3. 💡 request.getParts()를 사용해 폼으로 날아온 모든 파트(텍스트+모든 파일)를 일괄 수집
            Collection<Part> parts = request.getParts();
            
            for (Part part : parts) {
                // 일반 텍스트 필드이거나 파일이 첨부되지 않은 Part(용량이 0인 경우)는 건너뜀
                if (part.getSubmittedFileName() == null || part.getSize() == 0) {
                    continue;
                }
                
                // 순수 원본 파일명 추출 및 중복 방지용 UUID 결합
                String originalName = getFileName(part);
                String savedFileName = UUID.randomUUID().toString() + "_" + originalName;
                
                // A. 메인 대표 사진 파싱 (JSP의 name="mainImage"와 매칭)
                if (part.getName().equals("mainImage")) {
                    part.write(uploadPath + File.separator + savedFileName);
                    savedMainFileName = savedFileName;
                    System.out.println("[ALLTHATCARD - LOG] 메인 대표 사진 저장 성공: " + savedMainFileName);
                }
                
                // B. 상세 사진 다중 파싱 (JSP의 name="detailImages"와 매칭)
                else if (part.getName().equals("detailImages")) {
                    part.write(uploadPath + File.separator + savedFileName);
                    savedDetailFileNames.add(savedFileName);
                    System.out.println("[ALLTHATCARD - LOG] 상세 사진 [" + savedDetailFileNames.size() + "장째] 저장 성공: " + savedFileName);
                }
            }

            // 4. 테스트 확인용 Alert 출력 및 메인페이지 이동 (나중에 이 영역을 DB INSERT 로직으로 고도화할 예정!)
            response.getWriter().write("<script>");
            response.getWriter().write("alert('🎉 상품 등록 테스트 성공!\\n\\n"
                                     + "[텍스트 데이터]\\n"
                                     + "- 상품명: " + productName + "\\n"
                                     + "- 카테고리: " + category + "\\n"
                                     + "- 시작가: ₩" + startPrice + "\\n\\n"
                                     + "[업로드 파일 결과]\\n"
                                     + "- 대표 이미지: " + savedMainFileName + "\\n"
                                     + "- 상세 이미지 개수: " + savedDetailFileNames.size() + "장 저장 완료');");
            response.getWriter().write("location.href='" + request.getContextPath() + "/';");
            response.getWriter().write("</script>");

        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("[ALLTHATCARD - ERROR] 파일 업로드 진행 중 예외 발생!");
            response.getWriter().write("<script>alert('파일 서버 전송 중 오류가 발생했습니다.'); history.back();</script>");
        }
    }

    /**
     * 💡 Part 헤더 정보(Content-Disposition)에서 순수 파일명만 정밀 추출하는 헬퍼 메서드
     */
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                // filename="포켓몬카드.png" 구조에서 앞뒤 따옴표와 등호를 자르고 파일명만 리턴
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}