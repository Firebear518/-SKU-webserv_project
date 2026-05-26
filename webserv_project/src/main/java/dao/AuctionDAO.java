package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import dto.Auction;

public class AuctionDAO {

    public Auction getAuctionById(int auctionId) {
        Auction auction = null;

        String sql = "SELECT * FROM auction WHERE auction_id = ?";

        // TODO: DB 연결 후 구현

        return auction;
    }

    public Auction getAuctionByProductId(int productId) {
        Auction auction = null;

        String sql = "SELECT * FROM auction WHERE product_id = ?";

        // TODO: DB 연결 후 구현

        return auction;
    }

    public boolean updateCurrentPriceAndBidder(int auctionId, int bidPrice, int userId) {
        String sql = "UPDATE auction SET current_price = ?, highest_bidder_id = ? WHERE auction_id = ?";

        // TODO: DB 연결 후 구현

        return false;
    }
}