package com.skuweb.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import com.skuweb.dao.dto.AuctionDTO;
import com.skuweb.dao.dto.BidDTO;
import com.skuweb.dao.dto.BidResultDTO;
import util.DBUtil;

public class BidDAO {

    public boolean insertBid(BidDTO bid) {
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

    public BidResultDTO placeBid(int auctionId, int userId, int bidPrice) {
        AuctionDAO auctionDAO = new AuctionDAO();

        AuctionDTO auction = auctionDAO.getAuctionById(auctionId);

        if (auction == null) {
            return new BidResultDTO(false, "존재하지 않는 경매입니다.");
        }

        if (!"ONGOING".equals(auction.getAuctionStatus())) {
            return new BidResultDTO(false, "이미 종료된 경매입니다.", auction.getCurrentPrice());
        }

        if (isAuctionExpired(auction.getEndTime())) {
            auctionDAO.updateAuctionStatus(auctionId, "ENDED");
            return new BidResultDTO(false, "경매 시간이 종료되었습니다.", auction.getCurrentPrice());
        }

        if (bidPrice <= auction.getCurrentPrice()) {
            return new BidResultDTO(false, "현재가보다 높은 금액을 입력하세요.", auction.getCurrentPrice());
        }

        BidDTO bid = new BidDTO();
        bid.setAuctionId(auctionId);
        bid.setUserId(userId);
        bid.setBidPrice(bidPrice);

        boolean insertResult = insertBid(bid);

        if (!insertResult) {
            return new BidResultDTO(false, "입찰 기록 저장에 실패했습니다.", auction.getCurrentPrice());
        }

        boolean updateResult = auctionDAO.updateCurrentPriceAndBidder(
            auctionId,
            bidPrice,
            userId
        );

        if (!updateResult) {
            return new BidResultDTO(false, "현재가 갱신에 실패했습니다.", auction.getCurrentPrice());
        }

        return new BidResultDTO(true, "입찰 성공", bidPrice);
    }

    private boolean isAuctionExpired(String endTime) {
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            LocalDateTime auctionEndTime = LocalDateTime.parse(endTime, formatter);
            LocalDateTime now = LocalDateTime.now();

            return now.isAfter(auctionEndTime);

        } catch (Exception e) {
            e.printStackTrace();
            return true;
        }
    }
}