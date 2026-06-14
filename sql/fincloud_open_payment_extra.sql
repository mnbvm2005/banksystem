USE fincloud_bank_pro;

CREATE TABLE IF NOT EXISTS merchant_apps (
    merchant_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    merchant_name VARCHAR(100) NOT NULL,
    access_key VARCHAR(100) NOT NULL UNIQUE,
    secret_key VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS external_payment_orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    merchant_id BIGINT NOT NULL,
    bill_no VARCHAR(100) NOT NULL,
    pay_token VARCHAR(100) NOT NULL UNIQUE,
    external_user_name VARCHAR(50),
    external_user_no VARCHAR(50),
    bank_login_account VARCHAR(50),
    bill_type VARCHAR(30) NOT NULL,
    provider_name VARCHAR(100) NOT NULL,
    customer_no VARCHAR(50) NOT NULL,
    period VARCHAR(20),
    amount DECIMAL(18,2) NOT NULL,
    subject VARCHAR(255),
    return_url VARCHAR(500) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'CREATED',
    bank_transaction_id BIGINT NULL,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    paid_time DATETIME NULL,
    CONSTRAINT fk_external_payment_merchant FOREIGN KEY (merchant_id) REFERENCES merchant_apps(merchant_id),
    UNIQUE KEY uk_external_merchant_bill (merchant_id, bill_no),
    CHECK (status IN ('CREATED', 'PAYING', 'SUCCESS', 'FAILED', 'CLOSED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS api_request_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    access_key VARCHAR(100),
    request_method VARCHAR(10),
    request_path VARCHAR(255),
    request_nonce VARCHAR(100),
    request_timestamp BIGINT,
    request_body_hash VARCHAR(100),
    verify_result VARCHAR(20),
    response_code VARCHAR(20),
    error_message VARCHAR(500),
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_api_nonce (access_key, request_nonce)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO merchant_apps(merchant_name, access_key, secret_key, status, create_time)
SELECT '上财小区生活缴费系统', 'FC_MERCHANT_001', 'FC_SECRET_001_123456', 'ACTIVE', NOW()
WHERE NOT EXISTS (SELECT 1 FROM merchant_apps WHERE access_key = 'FC_MERCHANT_001');

DROP PROCEDURE IF EXISTS add_external_payment_column;
DELIMITER //
CREATE PROCEDURE add_external_payment_column(IN column_name VARCHAR(64), IN column_definition VARCHAR(255))
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'external_payment_orders'
          AND COLUMN_NAME = column_name
    ) THEN
        SET @ddl = CONCAT('ALTER TABLE external_payment_orders ADD COLUMN ', column_name, ' ', column_definition);
        PREPARE stmt FROM @ddl;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

CALL add_external_payment_column('external_user_name', 'VARCHAR(50) AFTER pay_token');
CALL add_external_payment_column('external_user_no', 'VARCHAR(50) AFTER external_user_name');
CALL add_external_payment_column('bank_login_account', 'VARCHAR(50) AFTER external_user_no');
CALL add_external_payment_column('period', 'VARCHAR(20) AFTER customer_no');
DROP PROCEDURE IF EXISTS add_external_payment_column;

DROP PROCEDURE IF EXISTS add_external_merchant_index;
DELIMITER //
CREATE PROCEDURE add_external_merchant_index()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'external_payment_orders'
          AND INDEX_NAME = 'idx_external_payment_merchant'
    ) THEN
        ALTER TABLE external_payment_orders ADD INDEX idx_external_payment_merchant (merchant_id);
    END IF;
END//
DELIMITER ;

CALL add_external_merchant_index();
DROP PROCEDURE IF EXISTS add_external_merchant_index;

DROP PROCEDURE IF EXISTS drop_external_bill_unique_key;
DELIMITER //
CREATE PROCEDURE drop_external_bill_unique_key()
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'external_payment_orders'
          AND INDEX_NAME = 'uk_external_merchant_bill'
    ) THEN
        ALTER TABLE external_payment_orders DROP INDEX uk_external_merchant_bill;
    END IF;
END//
DELIMITER ;

CALL drop_external_bill_unique_key();
DROP PROCEDURE IF EXISTS drop_external_bill_unique_key;
