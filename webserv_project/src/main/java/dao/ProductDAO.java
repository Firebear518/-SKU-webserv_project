package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import dto.Product;
import util.DBUtil;

public class ProductDAO {

    // 전체 상품 목록 (categories + auction LEFT JOIN)
    public List<Product> getAllProducts() {
        List<Product> list = new ArrayList<>();
        String sql =
        	    "SELECT p.product_id, p.title, p.seller_id, p.price, p.image_path, p.category_id, " +
        	    "c.category_name, a.auction_id, a.current_price, a.end_time, a.auction_status " +
        	    "FROM products p " +
        	    "LEFT JOIN categories c ON p.category_id = c.category_id " +
        	    "LEFT JOIN auction a ON a.product_id = p.product_id " +
        	    "ORDER BY p.product_id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setTitle(rs.getString("title"));
                p.setSellerId(rs.getString("seller_id"));
                p.setPrice(rs.getInt("price"));
                p.setImagePath(rs.getString("image_path"));
                p.setCategoryId(rs.getInt("category_id"));
                p.setCategoryName(rs.getString("category_name"));
                p.setAuctionId(rs.getInt("auction_id"));
                int currentPrice = rs.getInt("current_price");
                p.setCurrentPrice(currentPrice > 0 ? currentPrice : p.getPrice());
                p.setEndTime(rs.getString("end_time"));
                p.setAuctionStatus(rs.getString("auction_status"));
                list.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 최신 N개 상품 (메인 페이지용)
    public List<Product> getLatestProducts(int limit) {
        List<Product> list = new ArrayList<>();
        String sql =
        	    "SELECT p.product_id, p.title, p.seller_id, p.price, p.image_path, p.category_id, " +
        	    "c.category_name, a.auction_id, a.current_price, a.end_time, a.auction_status " +
        	    "FROM products p " +
        	    "LEFT JOIN categories c ON p.category_id = c.category_id " +
        	    "LEFT JOIN auction a ON a.product_id = p.product_id " +
        	    "ORDER BY p.product_id DESC LIMIT ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setTitle(rs.getString("title"));
                    p.setSellerId(rs.getString("seller_id"));
                    p.setPrice(rs.getInt("price"));
                    p.setImagePath(rs.getString("image_path"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setAuctionId(rs.getInt("auction_id"));
                    int currentPrice = rs.getInt("current_price");
                    p.setCurrentPrice(currentPrice > 0 ? currentPrice : p.getPrice());
                    p.setEndTime(rs.getString("end_time"));
                    p.setAuctionStatus(rs.getString("auction_status"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 상품 단건 조회 (상세 페이지용)
    public Product getProduct(int productId) {
        String sql = "SELECT p.*, c.category_name " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "WHERE p.product_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setTitle(rs.getString("title"));
                    p.setDescription(rs.getString("description"));
                    p.setPrice(rs.getInt("price"));
                    p.setImagePath(rs.getString("image_path"));
                    p.setSellerId(rs.getString("seller_id"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setDetailImagePaths(rs.getString("detail_image_paths"));
                    return p;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 상품 등록 → 생성된 product_id 반환 (실패 시 -1)
    public int insertProduct(Product product) {
        String sql = "INSERT INTO products (title, description, price, image_path, seller_id, category_id, detail_image_paths) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, product.getTitle());
            pstmt.setString(2, product.getDescription());
            pstmt.setInt(3, product.getPrice());
            pstmt.setString(4, product.getImagePath());
            pstmt.setString(5, product.getSellerId());
            pstmt.setInt(6, product.getCategoryId());
            pstmt.setString(7, product.getDetailImagePaths());

            if (pstmt.executeUpdate() > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    // 특정 판매자가 등록한 상품 목록 (경매 정보 JOIN)
    public List<Product> getProductsBySeller(String sellerId) {
        List<Product> list = new ArrayList<>();
        String sql = "SELECT p.product_id, p.title, p.seller_id, p.price, p.image_path, p.category_id, " +
                     "c.category_name, a.auction_id, a.current_price, a.end_time, a.auction_status " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "LEFT JOIN auction a ON a.product_id = p.product_id " +
                     "WHERE p.seller_id = ? " +
                     "ORDER BY p.product_id DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, sellerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setTitle(rs.getString("title"));
                    p.setSellerId(rs.getString("seller_id"));
                    p.setPrice(rs.getInt("price"));
                    p.setImagePath(rs.getString("image_path"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setAuctionId(rs.getInt("auction_id"));
                    int currentPrice = rs.getInt("current_price");
                    p.setCurrentPrice(currentPrice > 0 ? currentPrice : p.getPrice());
                    p.setEndTime(rs.getString("end_time"));
                    p.setAuctionStatus(rs.getString("auction_status"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // 상품 삭제 (소유권 확인 + FK 연쇄 삭제: comments → bid → auction → products)
    // 본인 상품이 아니거나 실패하면 false
    public boolean deleteProduct(int productId, String sellerId) {
        try (Connection conn = DBUtil.getConnection()) {
            // 1. 소유권 확인
            try (PreparedStatement check =
                     conn.prepareStatement("SELECT seller_id FROM products WHERE product_id = ?")) {
                check.setInt(1, productId);
                try (ResultSet rs = check.executeQuery()) {
                    if (!rs.next() || !sellerId.equals(rs.getString("seller_id"))) {
                        return false; // 존재하지 않거나 본인 상품이 아님
                    }
                }
            }

            // 2. 자식 행부터 순서대로 삭제 (트랜잭션)
            conn.setAutoCommit(false);
            try {
                // 댓글 삭제
                try (PreparedStatement ps =
                         conn.prepareStatement("DELETE FROM comments WHERE product_id = ?")) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }
                // 입찰 내역 삭제 (해당 상품의 경매에 달린 입찰)
                try (PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM bid WHERE auction_id IN (SELECT auction_id FROM auction WHERE product_id = ?)")) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }
                // 경매 삭제
                try (PreparedStatement ps =
                         conn.prepareStatement("DELETE FROM auction WHERE product_id = ?")) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }
                // 상품 삭제
                int deleted;
                try (PreparedStatement ps =
                         conn.prepareStatement("DELETE FROM products WHERE product_id = ?")) {
                    ps.setInt(1, productId);
                    deleted = ps.executeUpdate();
                }

                conn.commit();
                return deleted > 0;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // 카테고리명 → category_id 변환
    public int getCategoryIdByName(String categoryName) {
        String sql = "SELECT category_id FROM categories WHERE category_name = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, categoryName);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt("category_id");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 1; // fallback: 첫 번째 카테고리
    }
}
