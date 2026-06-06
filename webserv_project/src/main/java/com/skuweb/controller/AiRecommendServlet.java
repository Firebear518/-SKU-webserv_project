package com.skuweb.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/api/ai-recommend")
public class AiRecommendServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private String geminiApiKey;
    private String geminiApiUrl;

    @Override
    public void init() throws ServletException {
        Properties props = new Properties();

        try (InputStream is = getServletContext().getResourceAsStream("/WEB-INF/config.properties")) {
            if (is != null) {
                props.load(is);
                this.geminiApiKey = props.getProperty("gemini.api.key");
                if (this.geminiApiKey != null) {
                    this.geminiApiKey = this.geminiApiKey.trim();
                    this.geminiApiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + this.geminiApiKey;
                }
            } else {
                System.err.println("⚠️ /WEB-INF/config.properties 파일을 찾을 수 없습니다.");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        
        String productName = request.getParameter("productName");
        
        // 이름이 아예 없거나 공백(스페이스바만 입력)인 경우 구글 API를 호출하지 않음
        if (productName == null || productName.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400 에러 반환
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("상품명이 공백입니다. 올바른 상품명을 입력해주세요.");
            return;
        }

        // 위 검사를 통과해야만 아래의 API Key 검사 및 구글 통신 로직이 실행됨
        if (this.geminiApiKey == null || this.geminiApiKey.isEmpty()) {
            response.setContentType("text/plain; charset=UTF-8");
            response.getWriter().write("API 키 설정 에러가 발생했습니다.");
            return;
        }

        try {
            String prompt = "너는 희귀 카드 경매 플랫폼의 'AI 등록 매니저'야.\n"
                          + "사용자가 등록하려는 카드의 이름은 '" + productName + "'이야.\n\n"
                          + "이 카드의 중고 경매 상품 설명 본문을 작성해줘. 과대광고나 근거 없는 수식어는 절대 쓰지 말고, 중고장터에 어울리는 '담백하고 객관적인 사실' 위주로 간결하게 작성해야 해.\n\n"
                          + "[필수 제약 조건]\n"
                          + "1. 허위 정보 금지: 카드의 능력치, 역사적 의미, 투자 가치 향상 같은 근거 없는 거짓 정보나 과장된 칭찬은 절대 지어내지 말 것.\n"
                          + "2. 톤앤매너: 지나치게 감정적인 표현(보물, 로망, 감탄 등)은 빼고, 정중하고 깔끔한 어조로 요점만 적을 것.\n"
                          + "3. 분량 제한: 전체 글은 3~4개의 짧은 단락, 총 5~6문장 이내로 매우 간략하게 끝낼 것.\n"
                          + "4. 상품 상태 안내: '실물 상태는 첨부된 사진을 꼭 확인해달라'는 점과 함께, 수집품 특성상 '안전하게 슬리브와 탑로더에 보관 중'이라는 팩트만 적을 것.\n"
                          + "5. 형식 제한: 문단 제목이나 마크다운 기호(#, **, --- 등)는 단 하나도 쓰지 말고, 줄바꿈(Enter)으로만 문단을 나누어 순수한 텍스트로만 리턴할 것.";

            JsonObject messageObj = new JsonObject();
            JsonArray partsArr = new JsonArray();
            JsonObject textObj = new JsonObject();
            
            textObj.addProperty("text", prompt);
            partsArr.add(textObj);
            messageObj.add("parts", partsArr);

            JsonArray contentsArr = new JsonArray();
            contentsArr.add(messageObj);

            JsonObject rootObj = new JsonObject();
            rootObj.add("contents", contentsArr);

            String jsonRequestBody = new Gson().toJson(rootObj);

            URL url = new URL(this.geminiApiUrl); // 멤버 변수에 저장된 URL 사용
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setRequestProperty("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36");
            conn.setRequestProperty("Accept", "*/*");
            conn.setDoOutput(true);

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonRequestBody.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            response.setContentType("text/plain; charset=UTF-8");
            if (responseCode == HttpURLConnection.HTTP_OK) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder responseBuilder = new StringBuilder();
                    String responseLine;
                    while ((responseLine = br.readLine()) != null) {
                        responseBuilder.append(responseLine.trim());
                    }

                    JsonObject jsonResponse = new Gson().fromJson(responseBuilder.toString(), JsonObject.class);
                    String aiResultText = jsonResponse.getAsJsonArray("candidates")
                                                      .get(0).getAsJsonObject()
                                                      .getAsJsonObject("content")
                                                      .getAsJsonArray("parts")
                                                      .get(0).getAsJsonObject()
                                                      .get("text").getAsString();

                    response.getWriter().write(aiResultText);
                }
            } else {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {
                    StringBuilder errBuilder = new StringBuilder();
                    String line;
                    while ((line = br.readLine()) != null) errBuilder.append(line);
                    System.err.println("Gemini API 오류 응답: " + errBuilder);
                }
                response.getWriter().write("AI 통신 실패 (에러 코드: " + responseCode + ")");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("AI 처리 중 오류 발생: " + e.getMessage());
        }
    }
}