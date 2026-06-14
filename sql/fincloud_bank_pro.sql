

CREATE DATABASE IF NOT EXISTS fincloud_bank_pro
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_general_ci;

USE fincloud_bank_pro;

SET FOREIGN_KEY_CHECKS = 0;

DROP VIEW IF EXISTS v_transaction_black_box;
DROP VIEW IF EXISTS v_user_account_overview;

DROP TABLE IF EXISTS investment_holdings;
DROP TABLE IF EXISTS investment_orders;
DROP TABLE IF EXISTS risk_assessments;
DROP TABLE IF EXISTS financial_products;
DROP TABLE IF EXISTS saved_queries;
DROP TABLE IF EXISTS user_budgets;
DROP TABLE IF EXISTS bill_items;
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS operation_logs;
DROP TABLE IF EXISTS transaction_approvals;
DROP TABLE IF EXISTS transaction_risk_scores;
DROP TABLE IF EXISTS transaction_validations;
DROP TABLE IF EXISTS transaction_limit_rules;
DROP TABLE IF EXISTS payment_records;
DROP TABLE IF EXISTS transfer_records;
DROP TABLE IF EXISTS ledger_entries;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS transaction_categories;
DROP TABLE IF EXISTS payees;
DROP TABLE IF EXISTS account_daily_summaries;
DROP TABLE IF EXISTS account_status_histories;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS bank_branches;
DROP TABLE IF EXISTS security_events;
DROP TABLE IF EXISTS login_devices;
DROP TABLE IF EXISTS auth_records;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;



CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_no VARCHAR(30) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    real_name VARCHAR(50) NOT NULL,
    id_card_hash VARCHAR(255),
    id_card_masked VARCHAR(30),
    phone VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL,
    password_salt VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    register_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_time DATETIME,
    CHECK (status IN ('NORMAL', 'FROZEN', 'CLOSED'))
) ENGINE=InnoDB;

CREATE TABLE roles (
    role_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_code VARCHAR(30) NOT NULL UNIQUE,
    role_name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE user_roles (
    user_role_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assign_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(role_id),
    UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB;

CREATE TABLE auth_records (
    auth_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NULL,
    auth_type VARCHAR(30) NOT NULL,
    auth_result VARCHAR(20) NOT NULL,
    login_account VARCHAR(50),
    ip_address VARCHAR(50),
    device_fingerprint VARCHAR(100),
    fail_reason VARCHAR(255),
    auth_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auth_records_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (auth_result IN ('SUCCESS', 'FAILED'))
) ENGINE=InnoDB;

CREATE TABLE login_devices (
    device_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    device_fingerprint VARCHAR(100) NOT NULL,
    device_name VARCHAR(100),
    browser VARCHAR(100),
    os VARCHAR(100),
    trusted_flag TINYINT(1) NOT NULL DEFAULT 0,
    first_login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login_time DATETIME,
    CONSTRAINT fk_login_devices_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY uk_user_device (user_id, device_fingerprint)
) ENGINE=InnoDB;

CREATE TABLE security_events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NULL,
    event_type VARCHAR(50) NOT NULL,
    risk_level VARCHAR(20) NOT NULL DEFAULT 'LOW',
    description VARCHAR(500),
    ip_address VARCHAR(50),
    device_fingerprint VARCHAR(100),
    handled_flag TINYINT(1) NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_security_events_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB;



CREATE TABLE bank_branches (
    branch_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    branch_code VARCHAR(30) NOT NULL UNIQUE,
    branch_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    address VARCHAR(255),
    phone VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE accounts (
    account_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    branch_id BIGINT NULL,
    account_no VARCHAR(30) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL DEFAULT 'SAVING',
    currency VARCHAR(10) NOT NULL DEFAULT 'CNY',
    balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    available_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    frozen_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'NORMAL',
    open_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id) REFERENCES bank_branches(branch_id) ON DELETE SET NULL,
    CHECK (account_type IN ('SAVING', 'CURRENT')),
    CHECK (status IN ('NORMAL', 'FROZEN', 'CLOSED')),
    CHECK (balance >= 0),
    CHECK (available_balance >= 0),
    CHECK (frozen_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE account_status_histories (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id BIGINT NOT NULL,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL,
    change_reason VARCHAR(255),
    changed_by BIGINT NULL,
    change_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_account_status_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_account_status_user FOREIGN KEY (changed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (new_status IN ('NORMAL', 'FROZEN', 'CLOSED'))
) ENGINE=InnoDB;

CREATE TABLE account_daily_summaries (
    summary_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id BIGINT NOT NULL,
    summary_date DATE NOT NULL,
    opening_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    income_total DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    expense_total DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    closing_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    transaction_count INT NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_daily_summary_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    UNIQUE KEY uk_account_summary_date (account_id, summary_date)
) ENGINE=InnoDB;

CREATE TABLE payees (
    payee_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    payee_name VARCHAR(50) NOT NULL,
    payee_account_no VARCHAR(30) NOT NULL,
    payee_bank_name VARCHAR(100),
    verified_status VARCHAR(20) NOT NULL DEFAULT 'UNVERIFIED',
    last_transfer_time DATETIME,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_payees_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY uk_user_payee_account (user_id, payee_account_no),
    CHECK (verified_status IN ('VERIFIED', 'UNVERIFIED'))
) ENGINE=InnoDB;



CREATE TABLE transaction_categories (
    category_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    category_code VARCHAR(30) NOT NULL UNIQUE,
    category_name VARCHAR(50) NOT NULL,
    income_expense_type VARCHAR(10) NOT NULL,
    description VARCHAR(255),
    CHECK (income_expense_type IN ('IN', 'OUT', 'BOTH'))
) ENGINE=InnoDB;

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_no VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    channel VARCHAR(30) NOT NULL DEFAULT 'WEB',
    risk_level VARCHAR(20) NOT NULL DEFAULT 'LOW',
    need_approval TINYINT(1) NOT NULL DEFAULT 0,
    description VARCHAR(255),
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finish_time DATETIME,
    CONSTRAINT fk_transactions_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (amount > 0),
    CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAW', 'TRANSFER', 'PAYMENT', 'INVEST_BUY', 'INVEST_REDEEM')),
    CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'APPROVING', 'REJECTED')),
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB;

CREATE TABLE ledger_entries (
    entry_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    direction VARCHAR(10) NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    balance_before DECIMAL(18,2) NOT NULL,
    balance_after DECIMAL(18,2) NOT NULL,
    category_id BIGINT NULL,
    summary VARCHAR(255),
    entry_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ledger_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_ledger_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_ledger_category FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id) ON DELETE SET NULL,
    CHECK (direction IN ('IN', 'OUT')),
    CHECK (amount > 0),
    CHECK (balance_before >= 0),
    CHECK (balance_after >= 0)
) ENGINE=InnoDB;

CREATE TABLE transfer_records (
    transfer_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL UNIQUE,
    from_account_id BIGINT NOT NULL,
    to_account_id BIGINT NULL,
    to_account_no VARCHAR(30) NOT NULL,
    to_name VARCHAR(50),
    to_bank_name VARCHAR(100),
    transfer_type VARCHAR(20) NOT NULL,
    is_new_payee TINYINT(1) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    CONSTRAINT fk_transfer_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_transfer_from_account FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_transfer_to_account FOREIGN KEY (to_account_id) REFERENCES accounts(account_id) ON DELETE SET NULL,
    CHECK (transfer_type IN ('INNER', 'CROSS')),
    CHECK (status IN ('SUCCESS', 'FAILED', 'APPROVING', 'REJECTED'))
) ENGINE=InnoDB;

CREATE TABLE payment_records (
    payment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL UNIQUE,
    account_id BIGINT NOT NULL,
    payment_type VARCHAR(30) NOT NULL,
    customer_no VARCHAR(50) NOT NULL,
    provider_name VARCHAR(100),
    amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    CONSTRAINT fk_payment_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_payment_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CHECK (payment_type IN ('WATER', 'ELECTRICITY', 'GAS', 'PHONE')),
    CHECK (amount > 0),
    CHECK (status IN ('SUCCESS', 'FAILED'))
) ENGINE=InnoDB;



CREATE TABLE transaction_limit_rules (
    rule_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    role_id BIGINT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    single_limit DECIMAL(18,2) NOT NULL,
    daily_limit DECIMAL(18,2) NOT NULL,
    approval_threshold DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_limit_rule_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL,
    CHECK (single_limit > 0),
    CHECK (daily_limit > 0),
    CHECK (approval_threshold > 0),
    CHECK (status IN ('ACTIVE', 'DISABLED'))
) ENGINE=InnoDB;

CREATE TABLE transaction_validations (
    validation_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL UNIQUE,
    account_status_ok TINYINT(1) NOT NULL DEFAULT 1,
    balance_ok TINYINT(1) NOT NULL DEFAULT 1,
    amount_ok TINYINT(1) NOT NULL DEFAULT 1,
    limit_ok TINYINT(1) NOT NULL DEFAULT 1,
    validation_result VARCHAR(20) NOT NULL,
    fail_reason VARCHAR(255),
    validation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_validation_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CHECK (validation_result IN ('PASS', 'FAIL'))
) ENGINE=InnoDB;

CREATE TABLE transaction_risk_scores (
    risk_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL UNIQUE,
    risk_score INT NOT NULL DEFAULT 0,
    risk_level VARCHAR(20) NOT NULL DEFAULT 'LOW',
    risk_reason VARCHAR(500),
    rule_hit_count INT NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_risk_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CHECK (risk_score BETWEEN 0 AND 100),
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB;

CREATE TABLE transaction_approvals (
    approval_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    transaction_id BIGINT NOT NULL UNIQUE,
    approver_id BIGINT NULL,
    approval_status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    approval_opinion VARCHAR(255),
    submit_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approval_time DATETIME,
    CONSTRAINT fk_approval_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_approval_user FOREIGN KEY (approver_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED'))
) ENGINE=InnoDB;



CREATE TABLE operation_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NULL,
    operation_type VARCHAR(50) NOT NULL,
    target_type VARCHAR(50),
    target_id BIGINT,
    result VARCHAR(20) NOT NULL,
    ip_address VARCHAR(50),
    description VARCHAR(500),
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_operation_logs_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (result IN ('SUCCESS', 'FAILED'))
) ENGINE=InnoDB;

CREATE TABLE notifications (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    title VARCHAR(100) NOT NULL,
    content VARCHAR(500) NOT NULL,
    notification_type VARCHAR(30) NOT NULL DEFAULT 'SYSTEM',
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_time DATETIME,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (notification_type IN ('TRANSACTION', 'APPROVAL', 'SECURITY', 'SYSTEM'))
) ENGINE=InnoDB;



CREATE TABLE bills (
    bill_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id BIGINT NOT NULL,
    bill_type VARCHAR(20) NOT NULL,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    income_total DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    expense_total DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    net_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bills_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    UNIQUE KEY uk_account_bill_period (account_id, bill_type, period_start, period_end),
    CHECK (bill_type IN ('DAILY', 'MONTHLY', 'YEARLY'))
) ENGINE=InnoDB;

CREATE TABLE bill_items (
    bill_item_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    bill_id BIGINT NOT NULL,
    entry_id BIGINT NOT NULL,
    item_summary VARCHAR(255),
    CONSTRAINT fk_bill_items_bill FOREIGN KEY (bill_id) REFERENCES bills(bill_id),
    CONSTRAINT fk_bill_items_entry FOREIGN KEY (entry_id) REFERENCES ledger_entries(entry_id),
    UNIQUE KEY uk_bill_entry (bill_id, entry_id)
) ENGINE=InnoDB;

CREATE TABLE user_budgets (
    budget_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    budget_month CHAR(7) NOT NULL,
    budget_amount DECIMAL(18,2) NOT NULL,
    used_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    warning_threshold DECIMAL(5,2) NOT NULL DEFAULT 0.80,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_budgets_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_budgets_category FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id),
    UNIQUE KEY uk_user_budget_month_category (user_id, category_id, budget_month),
    CHECK (budget_amount > 0),
    CHECK (used_amount >= 0),
    CHECK (warning_threshold > 0 AND warning_threshold <= 1)
) ENGINE=InnoDB;

CREATE TABLE saved_queries (
    query_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    query_name VARCHAR(100) NOT NULL,
    query_type VARCHAR(30) NOT NULL,
    query_condition VARCHAR(1000),
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_saved_queries_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (query_type IN ('TRANSACTION', 'BILL', 'ACCOUNT'))
) ENGINE=InnoDB;



CREATE TABLE financial_products (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    product_code VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    product_type VARCHAR(30) NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    expected_rate DECIMAL(6,4),
    min_amount DECIMAL(18,2) NOT NULL,
    period_days INT,
    status VARCHAR(20) NOT NULL DEFAULT 'ON_SALE',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH')),
    CHECK (min_amount > 0),
    CHECK (status IN ('ON_SALE', 'OFF_SALE'))
) ENGINE=InnoDB;

CREATE TABLE risk_assessments (
    assessment_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    score INT NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    valid_until DATE,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_risk_assessments_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (score BETWEEN 0 AND 100),
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB;

CREATE TABLE investment_orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    order_no VARCHAR(50) NOT NULL UNIQUE,
    user_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    transaction_id BIGINT NULL,
    order_type VARCHAR(20) NOT NULL,
    amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_invest_order_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_invest_order_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_invest_order_product FOREIGN KEY (product_id) REFERENCES financial_products(product_id),
    CONSTRAINT fk_invest_order_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL,
    UNIQUE KEY uk_invest_order_transaction (transaction_id),
    CHECK (order_type IN ('BUY', 'REDEEM')),
    CHECK (amount > 0),
    CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED'))
) ENGINE=InnoDB;

CREATE TABLE investment_holdings (
    holding_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    account_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    order_id BIGINT NULL,
    holding_amount DECIMAL(18,2) NOT NULL,
    profit_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00,
    holding_status VARCHAR(20) NOT NULL DEFAULT 'HOLDING',
    buy_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_holding_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_holding_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_holding_product FOREIGN KEY (product_id) REFERENCES financial_products(product_id),
    CONSTRAINT fk_holding_order FOREIGN KEY (order_id) REFERENCES investment_orders(order_id) ON DELETE SET NULL,
    CHECK (holding_amount >= 0),
    CHECK (profit_amount >= 0),
    CHECK (holding_status IN ('HOLDING', 'REDEEMED'))
) ENGINE=InnoDB;



CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_accounts_user ON accounts(user_id);
CREATE INDEX idx_accounts_status ON accounts(status);
CREATE INDEX idx_transactions_user_time ON transactions(user_id, create_time);
CREATE INDEX idx_transactions_type_status ON transactions(transaction_type, status);
CREATE INDEX idx_ledger_account_time ON ledger_entries(account_id, entry_time);
CREATE INDEX idx_ledger_transaction ON ledger_entries(transaction_id);
CREATE INDEX idx_operation_logs_user_time ON operation_logs(user_id, create_time);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, is_read);
CREATE INDEX idx_bills_account_period ON bills(account_id, period_start, period_end);
CREATE INDEX idx_security_events_user_time ON security_events(user_id, create_time);



INSERT INTO roles(role_id, role_code, role_name, description) VALUES
(1, 'CUSTOMER', 'Customer', 'Register, sign in, view own accounts, deposit, withdraw, transfer, pay bills, query bills, and view wealth products'),
(2, 'ADMIN', 'Administrator', 'Manage users, freeze or unfreeze accounts, view transaction records, and inspect operation logs'),
(3, 'APPROVER', 'Approver', 'Review and approve high-value transactions');

INSERT INTO users(user_id, user_no, username, real_name, id_card_hash, id_card_masked, phone, email, password_hash, password_salt, status, register_time, last_login_time) VALUES
(1, 'U202506120001', 'cuppy', 'Cuppy Zhang', SHA2('110101200001010001', 256), '110101********0001', '13800000001', 'cuppy@test.com', SHA2(CONCAT('123456', 'SALT_CUPPY'), 256), 'SALT_CUPPY', 'NORMAL', NOW(), NOW()),
(2, 'U202506120002', 'alice', 'Anna Li', SHA2('110101200001010002', 256), '110101********0002', '13800000002', 'alice@test.com', SHA2(CONCAT('123456', 'SALT_ALICE'), 256), 'SALT_ALICE', 'NORMAL', NOW(), NOW()),
(3, 'U202506120099', 'admin', 'System Admin', SHA2('110101200001019999', 256), '110101********9999', '13800000099', 'admin@test.com', SHA2(CONCAT('admin123', 'SALT_ADMIN'), 256), 'SALT_ADMIN', 'NORMAL', NOW(), NOW());

INSERT INTO user_roles(user_id, role_id) VALUES
(1, 1),
(2, 1),
(3, 2),
(3, 3);

INSERT INTO auth_records(user_id, auth_type, auth_result, login_account, ip_address, device_fingerprint, fail_reason, auth_time) VALUES
(1, 'PASSWORD', 'SUCCESS', 'cuppy', '127.0.0.1', 'DEV-CUPPY-PC', NULL, NOW()),
(3, 'PASSWORD', 'SUCCESS', 'admin', '127.0.0.1', 'DEV-ADMIN-PC', NULL, NOW());

INSERT INTO login_devices(user_id, device_fingerprint, device_name, browser, os, trusted_flag, first_login_time, last_login_time) VALUES
(1, 'DEV-CUPPY-PC', 'Cuppy Laptop', 'Chrome', 'Windows', 1, NOW(), NOW()),
(3, 'DEV-ADMIN-PC', 'Admin Laptop', 'Edge', 'Windows', 1, NOW(), NOW());

INSERT INTO security_events(user_id, event_type, risk_level, description, ip_address, device_fingerprint, handled_flag, create_time) VALUES
(1, 'NEW_DEVICE', 'LOW', 'First sign-in on this device. Device fingerprint recorded.', '127.0.0.1', 'DEV-CUPPY-PC', 1, NOW());

INSERT INTO bank_branches(branch_id, branch_code, branch_name, city, address, phone) VALUES
(1, 'BJ001', 'FinCloud Bank Beijing Zhongguancun Branch', 'Beijing', 'Zhongguancun, Haidian District, Beijing', '010-10000001'),
(2, 'SH001', 'FinCloud Bank Shanghai Lujiazui Branch', 'Shanghai', 'Lujiazui, Pudong New Area, Shanghai', '021-10000002');

INSERT INTO accounts(account_id, user_id, branch_id, account_no, account_type, currency, balance, available_balance, frozen_amount, status, open_time) VALUES
(1, 1, 1, '6222000000000001', 'SAVING', 'CNY', 8600.00, 8600.00, 0.00, 'NORMAL', NOW()),
(2, 2, 2, '6222000000000002', 'SAVING', 'CNY', 5920.00, 5920.00, 0.00, 'NORMAL', NOW()),
(4, 1, 2, '6222000000000004', 'CURRENT', 'CNY', 4100.50, 4100.50, 0.00, 'NORMAL', NOW());

INSERT INTO account_status_histories(account_id, old_status, new_status, change_reason, changed_by, change_time) VALUES
(1, NULL, 'NORMAL', 'Account opened successfully', 3, NOW()),
(2, NULL, 'NORMAL', 'Account opened successfully', 3, NOW()),
(4, NULL, 'NORMAL', 'Payroll account opened successfully', 3, NOW());

INSERT INTO account_daily_summaries(account_id, summary_date, opening_balance, income_total, expense_total, closing_balance, transaction_count, create_time) VALUES
(1, CURDATE(), 10000.00, 100.00, 1500.00, 8600.00, 3, NOW()),
(2, CURDATE(), 5500.00, 420.00, 0.00, 5920.00, 1, NOW()),
(4, CURDATE(), 3500.50, 1200.00, 600.00, 4100.50, 3, NOW());

INSERT INTO payees(user_id, payee_name, payee_account_no, payee_bank_name, verified_status, last_transfer_time, create_time) VALUES
(1, 'Anna Li', '6222000000000002', 'FinCloud Bank Shanghai Lujiazui Branch', 'VERIFIED', NOW(), NOW());

INSERT INTO transaction_categories(category_id, category_code, category_name, income_expense_type, description) VALUES
(1, 'DEPOSIT_IN', 'Deposit Income', 'IN', 'Income entry from a user deposit'),
(2, 'WITHDRAW_OUT', 'Withdrawal Expense', 'OUT', 'Expense entry from a user withdrawal'),
(3, 'TRANSFER_IN', 'Transfer Income', 'IN', 'Inbound transfer'),
(4, 'TRANSFER_OUT', 'Transfer Expense', 'OUT', 'Outbound transfer'),
(5, 'LIVING_PAYMENT', 'Living Payment', 'OUT', 'Utility, mobile, or daily service payment'),
(6, 'INVESTMENT', 'Investment Transaction', 'OUT', 'Wealth product purchase or redemption entry');

INSERT INTO transactions(transaction_id, transaction_no, user_id, transaction_type, amount, status, channel, risk_level, need_approval, description, create_time, finish_time) VALUES
(1, 'TX202506120001', 1, 'DEPOSIT', 100.00, 'SUCCESS', 'WEB', 'LOW', 0, 'User deposited CNY 100', NOW(), NOW()),
(2, 'TX202506120002', 1, 'TRANSFER', 500.00, 'SUCCESS', 'WEB', 'LOW', 0, 'Transfer CNY 500 to Anna Li', NOW(), NOW()),
(3, 'TX202506120003', 1, 'INVEST_BUY', 1000.00, 'SUCCESS', 'WEB', 'LOW', 0, 'Purchased Stable Monthly Income for CNY 1,000', NOW(), NOW()),
(4, 'TX202506120004', 1, 'DEPOSIT', 1200.00, 'SUCCESS', 'MOBILE', 'LOW', 0, 'Salary income of CNY 1,200', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 'TX202506120005', 1, 'PAYMENT', 180.00, 'SUCCESS', 'WEB', 'LOW', 0, 'Mobile bill payment of CNY 180', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 'TX202506120006', 1, 'TRANSFER', 420.00, 'SUCCESS', 'MOBILE', 'LOW', 0, 'Transfer CNY 420 to Anna Li for rent split', NOW(), NOW());

INSERT INTO ledger_entries(entry_id, transaction_id, account_id, direction, amount, balance_before, balance_after, category_id, summary, entry_time) VALUES
(1, 1, 1, 'IN', 100.00, 10000.00, 10100.00, 1, 'Deposit income', NOW()),
(2, 2, 1, 'OUT', 500.00, 10100.00, 9600.00, 4, 'Transfer to Anna Li', NOW()),
(3, 2, 2, 'IN', 500.00, 5000.00, 5500.00, 3, 'Transfer received from Cuppy Zhang', NOW()),
(4, 3, 1, 'OUT', 1000.00, 9600.00, 8600.00, 6, 'Wealth product purchase', NOW()),
(5, 4, 4, 'IN', 1200.00, 3500.50, 4700.50, 1, 'Salary income', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(6, 5, 4, 'OUT', 180.00, 4700.50, 4520.50, 5, 'Mobile bill payment', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(7, 6, 4, 'OUT', 420.00, 4520.50, 4100.50, 4, 'Rent split transfer', NOW()),
(8, 6, 2, 'IN', 420.00, 5500.00, 5920.00, 3, 'Rent split received from Cuppy Zhang', NOW());

INSERT INTO transfer_records(transaction_id, from_account_id, to_account_id, to_account_no, to_name, to_bank_name, transfer_type, is_new_payee, status) VALUES
(2, 1, 2, '6222000000000002', 'Anna Li', 'FinCloud Bank Shanghai Lujiazui Branch', 'INNER', 0, 'SUCCESS'),
(6, 4, 2, '6222000000000002', 'Anna Li', 'FinCloud Bank Shanghai Lujiazui Branch', 'INNER', 0, 'SUCCESS');

INSERT INTO payment_records(transaction_id, account_id, payment_type, customer_no, provider_name, amount, status) VALUES
(5, 4, 'PHONE', 'PH13800000001', 'China Mobile Beijing Branch', 180.00, 'SUCCESS');

INSERT INTO transaction_limit_rules(role_id, transaction_type, single_limit, daily_limit, approval_threshold, status, create_time) VALUES
(1, 'TRANSFER', 50000.00, 100000.00, 30000.00, 'ACTIVE', NOW()),
(1, 'PAYMENT', 10000.00, 30000.00, 20000.00, 'ACTIVE', NOW()),
(1, 'INVEST_BUY', 50000.00, 100000.00, 30000.00, 'ACTIVE', NOW());

INSERT INTO transaction_validations(transaction_id, account_status_ok, balance_ok, amount_ok, limit_ok, validation_result, fail_reason, validation_time) VALUES
(1, 1, 1, 1, 1, 'PASS', NULL, NOW()),
(2, 1, 1, 1, 1, 'PASS', NULL, NOW()),
(3, 1, 1, 1, 1, 'PASS', NULL, NOW()),
(4, 1, 1, 1, 1, 'PASS', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 1, 1, 1, 1, 'PASS', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 1, 1, 1, 1, 'PASS', NULL, NOW());

INSERT INTO transaction_risk_scores(transaction_id, risk_score, risk_level, risk_reason, rule_hit_count, create_time) VALUES
(1, 5, 'LOW', 'NORMAL_DEPOSIT', 0, NOW()),
(2, 10, 'LOW', 'VERIFIED_PAYEE', 0, NOW()),
(3, 15, 'LOW', 'LOW_RISK_PRODUCT', 0, NOW()),
(4, 5, 'LOW', 'SALARY_INCOME', 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 8, 'LOW', 'NORMAL_PAYMENT', 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 12, 'LOW', 'VERIFIED_PAYEE', 0, NOW());

INSERT INTO operation_logs(user_id, operation_type, target_type, target_id, result, ip_address, description, create_time) VALUES
(1, 'LOGIN', 'USER', 1, 'SUCCESS', '127.0.0.1', 'User signed in successfully', NOW()),
(1, 'DEPOSIT', 'TRANSACTION', 1, 'SUCCESS', '127.0.0.1', 'User deposited CNY 100', NOW()),
(1, 'TRANSFER', 'TRANSACTION', 2, 'SUCCESS', '127.0.0.1', 'User transferred CNY 500 to Anna Li', NOW()),
(1, 'INVEST_BUY', 'TRANSACTION', 3, 'SUCCESS', '127.0.0.1', 'User purchased a wealth product for CNY 1,000', NOW()),
(1, 'DEPOSIT', 'TRANSACTION', 4, 'SUCCESS', '127.0.0.1', 'Salary income of CNY 1,200', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 'PAYMENT', 'TRANSACTION', 5, 'SUCCESS', '127.0.0.1', 'Mobile bill payment of CNY 180', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 'TRANSFER', 'TRANSACTION', 6, 'SUCCESS', '127.0.0.1', 'Rent split transfer of CNY 420 to Anna Li', NOW());

INSERT INTO notifications(user_id, title, content, notification_type, is_read, create_time) VALUES
(1, 'Deposit Completed', 'You deposited CNY 100.00 successfully.', 'TRANSACTION', 0, NOW()),
(1, 'Transfer Completed', 'You transferred CNY 500.00 to Anna Li successfully.', 'TRANSACTION', 0, NOW()),
(2, 'Transfer Received', 'You received a CNY 500.00 transfer from Cuppy Zhang.', 'TRANSACTION', 0, NOW()),
(1, 'Salary Posted', 'Your payroll account received CNY 1,200.00.', 'TRANSACTION', 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 'Payment Completed', 'You paid a CNY 180.00 mobile bill successfully.', 'TRANSACTION', 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 'Transfer Completed', 'You transferred CNY 420.00 to Anna Li successfully.', 'TRANSACTION', 0, NOW()),
(2, 'Transfer Received', 'You received a CNY 420.00 transfer from Cuppy Zhang.', 'TRANSACTION', 0, NOW());

INSERT INTO bills(bill_id, account_id, bill_type, period_start, period_end, income_total, expense_total, net_amount, create_time) VALUES
(1, 1, 'MONTHLY', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 100.00, 1500.00, -1400.00, NOW()),
(2, 4, 'MONTHLY', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1200.00, 600.00, 600.00, NOW());

INSERT INTO bill_items(bill_id, entry_id, item_summary) VALUES
(1, 1, 'Monthly deposit income'),
(1, 2, 'Monthly transfer expense'),
(1, 4, 'Monthly wealth purchase expense'),
(2, 5, 'Monthly salary income'),
(2, 6, 'Monthly mobile bill'),
(2, 7, 'Monthly rent split');

INSERT INTO user_budgets(user_id, category_id, budget_month, budget_amount, used_amount, warning_threshold, create_time) VALUES
(1, 5, DATE_FORMAT(CURDATE(), '%Y-%m'), 800.00, 180.00, 0.80, NOW()),
(1, 4, DATE_FORMAT(CURDATE(), '%Y-%m'), 3000.00, 920.00, 0.80, NOW());

INSERT INTO saved_queries(user_id, query_name, query_type, query_condition, create_time) VALUES
(1, 'Monthly Expense Query', 'BILL', '{"period":"current_month","direction":"OUT"}', NOW());

INSERT INTO financial_products(product_id, product_code, product_name, product_type, risk_level, expected_rate, min_amount, period_days, status, create_time) VALUES
(1, 'FP001', 'Stable Monthly Income', 'FIXED', 'LOW', 0.0320, 1000.00, 30, 'ON_SALE', NOW()),
(2, 'FP002', 'Growth Select Fund', 'FUND', 'MEDIUM', 0.0580, 1000.00, 180, 'ON_SALE', NOW()),
(3, 'FP003', 'High Yield Growth Plan', 'FUND', 'HIGH', 0.0880, 5000.00, 365, 'ON_SALE', NOW());

INSERT INTO risk_assessments(user_id, score, risk_level, valid_until, create_time) VALUES
(1, 62, 'MEDIUM', DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NOW());

INSERT INTO investment_orders(order_id, order_no, user_id, account_id, product_id, transaction_id, order_type, amount, status, order_time) VALUES
(1, 'IO202506120001', 1, 1, 1, 3, 'BUY', 1000.00, 'SUCCESS', NOW());

INSERT INTO investment_holdings(user_id, account_id, product_id, order_id, holding_amount, profit_amount, holding_status, buy_time) VALUES
(1, 1, 1, 1, 1000.00, 0.00, 'HOLDING', NOW());



CREATE VIEW v_transaction_black_box AS
SELECT
    t.transaction_id,
    t.transaction_no,
    u.username,
    u.real_name,
    t.transaction_type,
    t.amount,
    t.status AS transaction_status,
    t.risk_level,
    t.need_approval,
    t.create_time,
    GROUP_CONCAT(
        CONCAT(
            a.account_no, ' ', le.direction, ' ', le.amount,
            ', balance ', le.balance_before, ' -> ', le.balance_after
        )
        ORDER BY le.entry_id
        SEPARATOR ' | '
    ) AS ledger_trace,
    tv.validation_result,
    trs.risk_score,
    trs.risk_reason,
    ta.approval_status,
    COUNT(DISTINCT ol.log_id) AS operation_log_count
FROM transactions t
JOIN users u ON t.user_id = u.user_id
LEFT JOIN ledger_entries le ON t.transaction_id = le.transaction_id
LEFT JOIN accounts a ON le.account_id = a.account_id
LEFT JOIN transaction_validations tv ON t.transaction_id = tv.transaction_id
LEFT JOIN transaction_risk_scores trs ON t.transaction_id = trs.transaction_id
LEFT JOIN transaction_approvals ta ON t.transaction_id = ta.transaction_id
LEFT JOIN operation_logs ol ON ol.target_type = 'TRANSACTION' AND ol.target_id = t.transaction_id
GROUP BY
    t.transaction_id,
    t.transaction_no,
    u.username,
    u.real_name,
    t.transaction_type,
    t.amount,
    t.status,
    t.risk_level,
    t.need_approval,
    t.create_time,
    tv.validation_result,
    trs.risk_score,
    trs.risk_reason,
    ta.approval_status;

CREATE VIEW v_user_account_overview AS
SELECT
    u.user_id,
    u.user_no,
    u.username,
    u.real_name,
    a.account_id,
    a.account_no,
    a.account_type,
    a.currency,
    a.balance,
    a.available_balance,
    a.frozen_amount,
    a.status AS account_status,
    b.branch_name
FROM users u
JOIN accounts a ON u.user_id = a.user_id
LEFT JOIN bank_branches b ON a.branch_id = b.branch_id;


