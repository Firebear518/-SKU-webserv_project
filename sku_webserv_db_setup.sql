-- ============================================================
--  sku_webserv_db  전체 초기화 스크립트
--  실행 방법: mysql -u root -p < sku_webserv_db_setup.sql
--            또는 MySQL Workbench에서 전체 선택 후 실행
-- ============================================================

DROP DATABASE IF EXISTS sku_webserv_db;
CREATE DATABASE sku_webserv_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sku_webserv_db;

-- ─────────────────────────────────────────
--  1. 회원 테이블
--     · UserRegisterServlet INSERT (userId, password, userName, userPhone, userAddress, userAddressDetail)
--     · UserLoginServlet      SELECT userId, userName, status
--     · status : 정상(NULL) / '경고 회원' / '영구 정지' (관리자 처분)
-- ─────────────────────────────────────────
CREATE TABLE users (
    userId            VARCHAR(50)  PRIMARY KEY,
    password          VARCHAR(100) NOT NULL,
    userName          VARCHAR(50)  NOT NULL,
    userPhone         VARCHAR(20),
    userAddress       VARCHAR(255),
    userAddressDetail VARCHAR(255),
    status            VARCHAR(50)
);

-- ─────────────────────────────────────────
--  2. 관리자 테이블
--     · AdminLoginServlet SELECT adminId, adminName WHERE adminId = ? AND adminPw = ?
-- ─────────────────────────────────────────
CREATE TABLE admin (
    adminId   VARCHAR(50)  PRIMARY KEY,
    adminPw   VARCHAR(100) NOT NULL,
    adminName VARCHAR(50)  NOT NULL
);

-- ─────────────────────────────────────────
--  3. 카테고리 테이블
-- ─────────────────────────────────────────
CREATE TABLE categories (
    category_id   INT         PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL
);

-- ─────────────────────────────────────────
--  4. 상품 테이블
--     · report_count : 신고 1건마다 +1 (ReportDAO)
-- ─────────────────────────────────────────
CREATE TABLE products (
    product_id         INT          PRIMARY KEY AUTO_INCREMENT,
    title              VARCHAR(100) NOT NULL,
    description        TEXT,
    price              INT          NOT NULL DEFAULT 0,
    image_path         VARCHAR(255),
    seller_id          VARCHAR(50),
    category_id        INT,
    detail_image_paths TEXT,
    report_count       INT          NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (seller_id)   REFERENCES users(userId)
);

-- ─────────────────────────────────────────
--  5. 경매 테이블
--     · status        : 관리자 검수 워크플로 상태(입고대기/검수중/검수완료/배송중/불합격 등)
--     · reject_reason : 불합격 사유 (AdminAuctionStatusServlet)
-- ─────────────────────────────────────────
CREATE TABLE auction (
    auction_id        INT          PRIMARY KEY AUTO_INCREMENT,
    product_id        INT          NOT NULL,
    start_price       INT          NOT NULL,
    current_price     INT          NOT NULL,
    highest_bidder_id VARCHAR(50),
    start_time        DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time          DATETIME     NOT NULL,
    auction_status    VARCHAR(20)  NOT NULL DEFAULT 'ONGOING',
    status            VARCHAR(100),
    reject_reason     TEXT,
    FOREIGN KEY (product_id)        REFERENCES products(product_id),
    FOREIGN KEY (highest_bidder_id) REFERENCES users(userId)
);

-- ─────────────────────────────────────────
--  6. 입찰 테이블
-- ─────────────────────────────────────────
CREATE TABLE bid (
    bid_id     INT      PRIMARY KEY AUTO_INCREMENT,
    auction_id INT      NOT NULL,
    user_id    VARCHAR(50),
    bid_price  INT      NOT NULL,
    bid_time   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auction_id) REFERENCES auction(auction_id),
    FOREIGN KEY (user_id)    REFERENCES users(userId)
);

-- ─────────────────────────────────────────
--  7. 댓글 테이블
--     · CommentDAO : comment_id, product_id, user_id, content, created_at
-- ─────────────────────────────────────────
CREATE TABLE comments (
    comment_id INT      PRIMARY KEY AUTO_INCREMENT,
    product_id INT      NOT NULL,
    user_id    VARCHAR(50),
    content    TEXT     NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id)    REFERENCES users(userId)
);

-- ─────────────────────────────────────────
--  8. 신고 테이블
--     · ReportDAO INSERT (reporter_id, reported_user_id, product_id, report_reason, reported_at)
--     · 상품 삭제 시 함께 정리되도록 product_id 에 ON DELETE CASCADE
-- ─────────────────────────────────────────
CREATE TABLE reports (
    report_id        INT          PRIMARY KEY AUTO_INCREMENT,
    reporter_id      VARCHAR(50),
    reported_user_id VARCHAR(50),
    product_id       INT          NOT NULL,
    report_reason    TEXT,
    reported_at      DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id)       REFERENCES products(product_id)  ON DELETE CASCADE,
    FOREIGN KEY (reporter_id)      REFERENCES users(userId),
    FOREIGN KEY (reported_user_id) REFERENCES users(userId)
);

-- ─────────────────────────────────────────
--  9. 알림 테이블
--     · header.jsp / AdminAuctionStatusServlet / NotiChoiceServlet
--     · noti_type : INFO / REJECT_CHOICE / REJECT_SELLER / WARN / BAN 등
--     · is_read   : 0(안 읽음) / 1(읽음)
--     · 경매 삭제 시 함께 정리되도록 auction_id 에 ON DELETE CASCADE
-- ─────────────────────────────────────────
CREATE TABLE notifications (
    noti_id    INT          PRIMARY KEY AUTO_INCREMENT,
    user_id    VARCHAR(50),
    auction_id INT,
    message    TEXT,
    noti_type  VARCHAR(50),
    is_read    INT          NOT NULL DEFAULT 0,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)    REFERENCES users(userId),
    FOREIGN KEY (auction_id) REFERENCES auction(auction_id) ON DELETE CASCADE
);

-- ============================================================
--  테스트 데이터
-- ============================================================

-- ─────────────────────────────────────────
--  카테고리 (JSP 필터 키와 동일하게 맞춤)
-- ─────────────────────────────────────────
INSERT INTO categories (category_id, category_name) VALUES
(1, 'POKEMON'),
(2, 'YUGIOH'),
(3, 'SPORTS'),
(4, 'ETC');

-- ─────────────────────────────────────────
--  관리자 (비밀번호 "1234")
-- ─────────────────────────────────────────
INSERT INTO admin (adminId, adminPw, adminName) VALUES
('admin', '1234', '운영자');

-- ─────────────────────────────────────────
--  회원 (일반 유저 2명, 비밀번호 모두 "1234")
-- ─────────────────────────────────────────
INSERT INTO users (userId, password, userName, userPhone, userAddress, userAddressDetail, status) VALUES
('user1', '1234', '김유저', '010-1111-1111', '서울시 강남구 테헤란로 1', '101호', NULL),
('user2', '1234', '이회원', '010-2222-2222', '서울시 성북구 정릉로 77', '202호', NULL);

-- ─────────────────────────────────────────
--  상품 (image_path는 등록 시 /uploads/xxx 로 채워짐)
-- ─────────────────────────────────────────
INSERT INTO products (title, description, price, image_path, seller_id, category_id) VALUES
(
  '메가개굴닌자ex SAR',
  '수집 직후 슬리브·탑로더에 보관해 왔습니다.\n전면/후면 모두 흠집 없는 상태이며 PSA 9 이상 예상 컨디션입니다.\n실물 사진을 꼼꼼히 확인 후 입찰 부탁드립니다.',
  50000, '', 'user1', 1
),
(
  '푸른 눈의 백룡 Prismatic Secret Rare',
  '2024년 최신 판본 미개봉 슬리브 상태.\n홀로그램 인쇄 상태 최상, 모서리 마모 전혀 없음.\n직거래 가능 (강남 지역).',
  300000, '', 'user1', 2
),
(
  '오타니 쇼헤이 2024 MVP 루키 복각 한정판',
  'MLB 공식 라이선스 카드. 넘버링 /250 시리얼.\n케이스 포함 보관 중이며 BGS 인증 예정 카드입니다.\n해외 배송 가능.',
  1000000, '', 'user2', 3
),
(
  '리자몽 VMAX SSR (이중 레인보우)',
  '소드&실드 시리즈 최고 인기 카드.\n이중 레인보우 특수 인쇄 완전체. S급 민트 컨디션.\n탑로더 + 세미리짓 + 팀백 3중 포장 발송.',
  80000, '', 'user2', 1
);

-- ─────────────────────────────────────────
--  경매 (각 상품 1:1 매핑)
-- ─────────────────────────────────────────
INSERT INTO auction (product_id, start_price, current_price, highest_bidder_id, start_time, end_time, auction_status, status) VALUES
(1,  50000,   85000,  'user2', NOW(), DATE_ADD(NOW(), INTERVAL 4 DAY), 'ONGOING', '검수완료'),
(2, 300000,  420000,  'user1', NOW(), DATE_ADD(NOW(), INTERVAL 2 DAY), 'SOLD', '검수중'),
(3, 1000000, 1250000, 'user2', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 'ONGOING', '입고대기'),
(4,  80000,   80000,  NULL,    NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 'ONGOING', '입고대기');

-- ─────────────────────────────────────────
--  입찰 내역
-- ─────────────────────────────────────────
INSERT INTO bid (auction_id, user_id, bid_price) VALUES
(1, 'user1', 60000),
(1, 'user2', 85000),
(2, 'user2', 350000),
(2, 'user1', 420000),
(3, 'user1', 1100000),
(3, 'user2', 1250000);

-- ============================================================
--  결과 확인
-- ============================================================
SELECT 'users'         AS tbl, COUNT(*) AS cnt FROM users         UNION ALL
SELECT 'admin'         AS tbl, COUNT(*) AS cnt FROM admin         UNION ALL
SELECT 'categories'    AS tbl, COUNT(*) AS cnt FROM categories    UNION ALL
SELECT 'products'      AS tbl, COUNT(*) AS cnt FROM products      UNION ALL
SELECT 'auction'       AS tbl, COUNT(*) AS cnt FROM auction       UNION ALL
SELECT 'bid'           AS tbl, COUNT(*) AS cnt FROM bid           UNION ALL
SELECT 'comments'      AS tbl, COUNT(*) AS cnt FROM comments      UNION ALL
SELECT 'reports'       AS tbl, COUNT(*) AS cnt FROM reports       UNION ALL
SELECT 'notifications' AS tbl, COUNT(*) AS cnt FROM notifications;
