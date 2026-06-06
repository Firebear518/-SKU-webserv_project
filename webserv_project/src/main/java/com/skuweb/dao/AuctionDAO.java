package com.skuweb.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.skuweb.dao.dto.AuctionDTO;

import util.DBUtil;

public class AuctionDAO {

    public AuctionDTO getAuctionById(int auctionId) {
        AuctionDTO auction = null;

        String sql = "SELECT * FROM auction WHERE auction_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setInt(1, auctionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    auction = new AuctionDTO();

                    auction.setAuctionId(rs.getInt("auction_id"));
                    auction.setProductId(rs.getInt("product_id"));
                    auction.setStartPrice(rs.getInt("start_price"));
                    auction.setCurrentPrice(rs.getInt("current_price"));

                    int highestBidderId1 = rs.getInt("highest_bidder_id");
                    if (rs.wasNull()) {
                        auction.setHighestBidderId(null);
                    } else {
                        auction.setHighestBidderId(highestBidderId1);
                    }
                    auction.setStartTime(rs.getString("start_time"));
                    auction.setEndTime(rs.getString("end_time"));
                    auction.setAuctionStatus(rs.getString("auction_status"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return auction;
    }

    public AuctionDTO getAuctionByProductId(int productId) {
        AuctionDTO auction = null;

        String sql = "SELECT * FROM auction WHERE product_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setInt(1, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    auction = new AuctionDTO();

                    auction.setAuctionId(rs.getInt("auction_id"));
                    auction.setProductId(rs.getInt("product_id"));
                    auction.setStartPrice(rs.getInt("start_price"));
                    auction.setCurrentPrice(rs.getInt("current_price"));

                    int highestBidderId2 = rs.getInt("highest_bidder_id");
                    if (rs.wasNull()) {
                        auction.setHighestBidderId(null);
                    } else {
                        auction.setHighestBidderId(highestBidderId2);
                    }
                    auction.setStartTime(rs.getString("start_time"));
                    auction.setEndTime(rs.getString("end_time"));
                    auction.setAuctionStatus(rs.getString("auction_status"));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return auction;
    }

    public boolean updateCurrentPriceAndBidder(int auctionId, int bidPrice, String userId) {
        String sql = "UPDATE auction SET current_price = ?, highest_bidder_id = ? WHERE auction_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setInt(1, bidPrice);
            pstmt.setString(2, userId);
            pstmt.setInt(3, auctionId);

            int result = pstmt.executeUpdate();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
    
    // 상품 등록 시 경매 레코드 생성 → 생성된 auction_id 반환 (실패 시 -1)
    public int insertAuction(int productId, int startPrice, int endDays) {
        String sql = "INSERT INTO auction (product_id, start_price, current_price, start_time, end_time, auction_status) " +
                     "VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY), 'ONGOING')";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, productId);
            pstmt.setInt(2, startPrice);
            pstmt.setInt(3, startPrice); // 최초 현재가 = 시작가
            pstmt.setInt(4, endDays);

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

    public boolean updateAuctionStatus(int auctionId, String status) {
        String sql = "UPDATE auction SET auction_status = ? WHERE auction_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setString(1, status);
            pstmt.setInt(2, auctionId);

            int result = pstmt.executeUpdate();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}