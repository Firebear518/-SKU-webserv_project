package com.skuweb.dao.dto;

// 레거시 스텁 파일 - 사용되지 않음 (실제 DTO는 dto.Product 사용)
public class ProductDTO {

    private String productName;
    private String category;
    private int startPrice;
    private int endTime;
    private String description;
    private String mainImagePath;

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public int getStartPrice() { return startPrice; }
    public void setStartPrice(int startPrice) { this.startPrice = startPrice; }

    public int getEndTime() { return endTime; }
    public void setEndTime(int endTime) { this.endTime = endTime; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getMainImagePath() { return mainImagePath; }
    public void setMainImagePath(String mainImagePath) { this.mainImagePath = mainImagePath; }
}
