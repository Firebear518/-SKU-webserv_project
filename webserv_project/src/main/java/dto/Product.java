package dto;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Product {
    // products 테이블 컬럼
    private int productId;
    private String title;
    private String description;
    private int price;
    private String imagePath;
    private String sellerId;
    private int categoryId;
    private String detailImagePaths; // 쉼표 구분 경로 문자열 (DB 저장용)

    // JOIN 결과 (표시용)
    private String categoryName;   // categories.category_name
    private int currentPrice;      // auction.current_price
    private String endTime;        // auction.end_time
    private int auctionId;         // auction.auction_id

    public Product() {}

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getSellerId() { return sellerId; }
    public void setSellerId(String sellerId) { this.sellerId = sellerId; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public int getCurrentPrice() { return currentPrice; }
    public void setCurrentPrice(int currentPrice) { this.currentPrice = currentPrice; }

    public String getEndTime() { return endTime; }
    public void setEndTime(String endTime) { this.endTime = endTime; }

    public int getAuctionId() { return auctionId; }
    public void setAuctionId(int auctionId) { this.auctionId = auctionId; }

    public String getDetailImagePaths() { return detailImagePaths; }
    public void setDetailImagePaths(String detailImagePaths) { this.detailImagePaths = detailImagePaths; }

    // 쉼표 구분 문자열 → List 변환 (JSP/서블릿 편의용)
    public List<String> getDetailImageList() {
        if (detailImagePaths == null || detailImagePaths.trim().isEmpty()) return new ArrayList<>();
        return Arrays.asList(detailImagePaths.split(","));
    }
}
