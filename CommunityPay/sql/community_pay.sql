CREATE DATABASE IF NOT EXISTS community_pay DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE community_pay;

DROP TABLE IF EXISTS payment_events;
DROP TABLE IF EXISTS utility_bills;
DROP TABLE IF EXISTS community_users;
DROP TABLE IF EXISTS api_config;

CREATE TABLE community_users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    resident_name VARCHAR(50),
    resident_no VARCHAR(50),
    bank_login_account VARCHAR(50),
    status VARCHAR(20),
    create_time DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE utility_bills (
    bill_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    bill_no VARCHAR(100) UNIQUE,
    resident_name VARCHAR(50),
    resident_no VARCHAR(50),
    bill_type VARCHAR(30),
    provider_name VARCHAR(100),
    customer_no VARCHAR(50),
    period VARCHAR(20),
    amount DECIMAL(18,2),
    due_date DATE,
    status VARCHAR(20),
    bank_pay_token VARCHAR(100),
    bank_transaction_id BIGINT,
    create_time DATETIME,
    paid_time DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payment_events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    bill_no VARCHAR(100),
    event_type VARCHAR(50),
    event_content VARCHAR(500),
    create_time DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE api_config (
    config_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    platform_name VARCHAR(100),
    access_key VARCHAR(100),
    secret_key VARCHAR(255),
    bank_api_base VARCHAR(255),
    status VARCHAR(20),
    create_time DATETIME
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO api_config(platform_name, access_key, secret_key, bank_api_base, status, create_time) VALUES
('上财小区生活缴费系统', 'FC_MERCHANT_001', 'FC_SECRET_001_123456', 'http://localhost:8080/BankSystem', 'ACTIVE', NOW());

INSERT INTO community_users(username, password_hash, resident_name, resident_no, bank_login_account, status, create_time) VALUES
('xg1', '123456', '信管1号同学', 'XM-001', 'cuppy', 'ACTIVE', NOW());

INSERT INTO utility_bills(bill_no, resident_name, resident_no, bill_type, provider_name, customer_no, period, amount, due_date, status, create_time) VALUES
('SQ202606140001', '信管1号同学', 'XM-001', 'ELECTRICITY', '上财小区电力服务站', 'E202606140001', '2026-06', 88.00, '2026-06-30', 'UNPAID', NOW()),
('SQ202606140002', '信管1号同学', 'XM-001', 'WATER', '上财小区水务服务站', 'W202606140015', '2026-06', 36.50, '2026-06-30', 'UNPAID', NOW()),
('SQ202606140003', '信管1号同学', 'XM-001', 'GAS', '上财小区燃气服务站', 'G202606140009', '2026-06', 52.00, '2026-06-30', 'UNPAID', NOW()),
('SQ202606140004', '信管1号同学', 'XM-001', 'PHONE', '上财小区通信服务站', '138****1024', '2026-06', 59.00, '2026-06-30', 'PAID', NOW()),
('SQ202606140005', '信管1号同学', 'XM-001', 'PROPERTY', '上财小区物业服务中心', '3-1602', '2026-06', 180.00, '2026-06-30', 'UNPAID', NOW());
