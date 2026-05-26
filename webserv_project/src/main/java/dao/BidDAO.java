package dao;

import dto.Bid;

public class BidDAO {

    public boolean insertBid(Bid bid) {
        String sql = "INSERT INTO bid (auction_id, user_id, bid_price) VALUES (?, ?, ?)";

        // TODO: DB 연결 후 구현

        return false;
    }

    public boolean placeBid(int auctionId, int userId, int bidPrice) {
        // TODO:
        // 1. auction 조회
        // 2. 경매 상태 ONGOING 확인
        // 3. 입찰가가 현재가보다 높은지 확인
        // 4. bid insert
        // 5. auction current_price, highest_bidder_id 갱신

        return false;
    }
}
