package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

import dto.Auction;
import dto.Bid;
import util.DBUtil;

public class BidDAO {

    public boolean insertBid(Bid bid) {
        String sql = "INSERT INTO bid (auction_id, user_id, bid_price) VALUES (?, ?, ?)";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(sql)
        ) {
            pstmt.setInt(1, bid.getAuctionId());
            pstmt.setInt(2, bid.getUserId());
            pstmt.setInt(3, bid.getBidPrice());

            int result = pstmt.executeUpdate();

            return result > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean placeBid(int auctionId, int userId, int bidPrice) {
        AuctionDAO auctionDAO = new AuctionDAO();

        Auction auction = auctionDAO.getAuctionById(auctionId);

        if (auction == null) {
            return false;
        }

        if (!"ONGOING".equals(auction.getAuctionStatus())) {
            return false;
        }

        if (bidPrice <= auction.getCurrentPrice()) {
            return false;
        }

        Bid bid = new Bid();
        bid.setAuctionId(auctionId);
        bid.setUserId(userId);
        bid.setBidPrice(bidPrice);

        boolean insertResult = insertBid(bid);

        if (!insertResult) {
            return false;
        }

        boolean updateResult = auctionDAO.updateCurrentPriceAndBidder(
            auctionId,
            bidPrice,
            userId
        );

        return updateResult;
    }
}