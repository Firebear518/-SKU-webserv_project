package com.skuweb.dao.dto;

 // 본인 프로젝트 패키지에 맞게 수정

public class ReportDisplayDTO {
    private String reportedUserId;
    private String displayTitle;
    private int reportCount;

    // 생성자
    public ReportDisplayDTO(String reportedUserId, String displayTitle, int reportCount) {
        this.reportedUserId = reportedUserId;
        this.displayTitle = displayTitle;
        this.reportCount = reportCount;
    }

    // 화면(JSP)이나 서블릿에서 꺼내 쓰기 위한 Getter 메소드들
    public String getReportedUserId() { return reportedUserId; }
    public String getDisplayTitle() { return displayTitle; }
    public int getReportCount() { return reportCount; }
}