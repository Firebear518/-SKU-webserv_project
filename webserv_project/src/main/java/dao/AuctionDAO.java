package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import dto.Auction;
import util.DBUtil;

public class AuctionDAO {

    public Auction getAuctionById(int auctionId) {
        Auction auction = null;

        String sql = "SELECT * FROM auction WHERE auction_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setInt(1, auctionId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    auction = new Auction();

                    auction.setAuctionId(rs.getInt("auction_id"));
                    auction.setProductId(rs.getInt("product_id"));
                    auction.setStartPrice(rs.getInt("start_price"));
                    auction.setCurrentPrice(rs.getInt("current_price"));

                    int highestBidderId = rs.getInt("highest_bidder_id");
                    if (rs.wasNull()) {
                        auction.setHighestBidderId(null);
                    } else {
                        auction.setHighestBidderId(highestBidderId);
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

    public Auction getAuctionByProductId(int productId) {
        Auction auction = null;

        String sql = "SELECT * FROM auction WHERE product_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setInt(1, productId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    auction = new Auction();

                    auction.setAuctionId(rs.getInt("auction_id"));
                    auction.setProductId(rs.getInt("product_id"));
                    auction.setStartPrice(rs.getInt("start_price"));
                    auction.setCurrentPrice(rs.getInt("current_price"));

                    int highestBidderId = rs.getInt("highest_bidder_id");
                    if (rs.wasNull()) {
                        auction.setHighestBidderId(null);
                    } else {
                        auction.setHighestBidderId(highestBidderId);
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

    public boolean updateCurrentPriceAndBidder(int auctionId, int bidPrice, int userId) {
        String sql = "UPDATE auction SET current_price = ?, highest_bidder_id = ? WHERE auction_id = ?";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setInt(1, bidPrice);
            pstmt.setInt(2, userId);
            pstmt.setInt(3, auctionId);

            int result = pstmt.executeUpdate();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }
}