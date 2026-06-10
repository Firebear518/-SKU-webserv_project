-- ============================================================
--  댓글(comments) 테이블 추가 마이그레이션
--  기존 데이터를 유지한 채 실행:  mysql -u root -p < add_comments_table.sql
-- ============================================================
USE sku_webserv_db;

CREATE TABLE IF NOT EXISTS comments (
    comment_id  INT          PRIMARY KEY AUTO_INCREMENT,
    product_id  INT          NOT NULL,
    user_id     VARCHAR(50),
    content     TEXT         NOT NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)
);
