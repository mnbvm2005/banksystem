CREATE DATABASE IF NOT EXISTS banksystem
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE banksystem;

DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS transaction_approvals;
DROP TABLE IF EXISTS transaction_validations;
DROP TABLE IF EXISTS operation_logs;
DROP TABLE IF EXISTS auth_records;
DROP TABLE IF EXISTS investment_holdings;
DROP TABLE IF EXISTS investment_orders;
DROP TABLE IF EXISTS bill_items;
DROP TABLE IF EXISTS bills;
DROP TABLE IF EXISTS payment_records;
DROP TABLE IF EXISTS transfer_records;
DROP TABLE IF EXISTS ledger_entries;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS financial_products;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(30) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    id_card VARCHAR(30),
    email VARCHAR(100),
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1: normal, 0: disabled',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE accounts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    account_number VARCHAR(30) NOT NULL UNIQUE,
    account_type VARCHAR(20) NOT NULL DEFAULT 'SAVINGS',
    bank_name VARCHAR(100) NOT NULL DEFAULT 'Personal Bank Shanghai Branch',
    balance DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(10) NOT NULL DEFAULT 'CNY',
    reserved_phone VARCHAR(20),
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1: normal, 0: frozen',
    opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_accounts_user
        FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE financial_products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    product_code VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    product_type VARCHAR(30) NOT NULL,
    risk_level VARCHAR(20) NOT NULL,
    expected_annual_rate DECIMAL(6, 2) NOT NULL DEFAULT 0.00,
    min_amount DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    term_days INT NOT NULL DEFAULT 0,
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1: available, 0: unavailable',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE transactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_no VARCHAR(40) NOT NULL UNIQUE,
    from_account_id INT,
    to_account_id INT,
    transaction_type VARCHAR(30) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    balance_after DECIMAL(15, 2),
    description VARCHAR(255),
    transaction_status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    transaction_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transactions_from_account
        FOREIGN KEY (from_account_id) REFERENCES accounts(id),
    CONSTRAINT fk_transactions_to_account
        FOREIGN KEY (to_account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ledger_entries (
    entry_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    account_id INT NOT NULL,
    direction VARCHAR(10) NOT NULL,
    amount DECIMAL(18, 2) NOT NULL,
    balance_before DECIMAL(18, 2) NOT NULL,
    balance_after DECIMAL(18, 2) NOT NULL,
    entry_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    remark VARCHAR(255),
    CONSTRAINT fk_ledger_entries_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    CONSTRAINT fk_ledger_entries_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE transfer_records (
    transfer_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL UNIQUE,
    payer_account_no VARCHAR(30) NOT NULL,
    payee_account_no VARCHAR(30) NOT NULL,
    payee_name VARCHAR(50),
    transfer_type VARCHAR(20),
    transfer_status VARCHAR(20),
    CONSTRAINT fk_transfer_records_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE payment_records (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL UNIQUE,
    account_id INT NOT NULL,
    payment_type VARCHAR(20) NOT NULL,
    payment_no VARCHAR(50) NOT NULL,
    service_provider VARCHAR(100),
    payment_amount DECIMAL(18, 2) NOT NULL,
    payment_status VARCHAR(20),
    payment_time DATETIME,
    CONSTRAINT fk_payment_records_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    CONSTRAINT fk_payment_records_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bills (
    bill_id INT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    bill_type VARCHAR(20) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    income_total DECIMAL(18, 2),
    expense_total DECIMAL(18, 2),
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bills_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE bill_items (
    bill_item_id INT PRIMARY KEY AUTO_INCREMENT,
    bill_id INT NOT NULL,
    entry_id INT NOT NULL,
    item_time DATETIME,
    amount DECIMAL(18, 2),
    direction VARCHAR(10),
    CONSTRAINT fk_bill_items_bill
        FOREIGN KEY (bill_id) REFERENCES bills(bill_id),
    CONSTRAINT fk_bill_items_entry
        FOREIGN KEY (entry_id) REFERENCES ledger_entries(entry_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE investment_orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    account_id INT NOT NULL,
    product_id INT NOT NULL,
    order_type VARCHAR(20) NOT NULL,
    order_amount DECIMAL(18, 2) NOT NULL,
    order_status VARCHAR(20) NOT NULL,
    order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_investment_orders_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_investment_orders_account
        FOREIGN KEY (account_id) REFERENCES accounts(id),
    CONSTRAINT fk_investment_orders_product
        FOREIGN KEY (product_id) REFERENCES financial_products(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE investment_holdings (
    holding_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    account_id INT NOT NULL,
    product_id INT NOT NULL,
    order_id INT,
    holding_amount DECIMAL(18, 2) NOT NULL,
    current_income DECIMAL(18, 2) DEFAULT 0.00,
    holding_status VARCHAR(20),
    purchase_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_investment_holdings_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_investment_holdings_account
        FOREIGN KEY (account_id) REFERENCES accounts(id),
    CONSTRAINT fk_investment_holdings_product
        FOREIGN KEY (product_id) REFERENCES financial_products(id),
    CONSTRAINT fk_investment_holdings_order
        FOREIGN KEY (order_id) REFERENCES investment_orders(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE auth_records (
    auth_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    login_account VARCHAR(50),
    auth_type VARCHAR(20),
    auth_result VARCHAR(20),
    failure_reason VARCHAR(255),
    auth_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    login_ip VARCHAR(50),
    CONSTRAINT fk_auth_records_user
        FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE operation_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    operation_type VARCHAR(50) NOT NULL,
    object_type VARCHAR(50),
    object_id INT,
    operation_content VARCHAR(255),
    operation_result VARCHAR(20),
    ip_address VARCHAR(50),
    operation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_operation_logs_user
        FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE transaction_validations (
    validation_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT,
    account_id INT,
    amount_valid TINYINT,
    balance_sufficient TINYINT,
    account_status_valid TINYINT,
    target_account_valid TINYINT,
    validation_result VARCHAR(20),
    reject_reason VARCHAR(255),
    validation_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transaction_validations_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    CONSTRAINT fk_transaction_validations_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE transaction_approvals (
    approval_id INT PRIMARY KEY AUTO_INCREMENT,
    transaction_id INT NOT NULL,
    approver_id INT,
    approval_status VARCHAR(20) NOT NULL,
    approval_comment VARCHAR(255),
    approval_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transaction_approvals_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    CONSTRAINT fk_transaction_approvals_approver
        FOREIGN KEY (approver_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    related_type VARCHAR(50),
    related_id INT,
    notification_type VARCHAR(50),
    notification_content VARCHAR(255),
    send_status VARCHAR(20),
    send_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO users (username, password, real_name, phone, id_card, email, status) VALUES
('1', '1', 'Test User', '1', '110101200001010011', 'test2024110180@example.com', 1),
('2', '1', 'Receiver User', '2', '110101200001010029', 'receiver@example.com', 1);

INSERT INTO accounts (user_id, account_number, account_type, bank_name, balance, currency, reserved_phone, status) VALUES
(1, '6222024110180001', 'SAVING', 'Personal Bank Shanghai Branch', 9200.00, 'CNY', '1', 1),
(1, '6222024110180002', 'CURRENT', 'Personal Bank Shanghai Branch', 3500.50, 'CNY', '1', 1),
(2, '6222024110181001', 'SAVING', 'Personal Bank Beijing Branch', 7300.00, 'CNY', '2', 1);

INSERT INTO financial_products (
    product_code,
    product_name,
    product_type,
    risk_level,
    expected_annual_rate,
    min_amount,
    term_days,
    status
) VALUES
('FP2024001', 'Stable Income 30 Days', 'Fixed Income', 'LOW', 2.35, 1000.00, 30, 1),
('FP2024002', 'Monthly Income Plan', 'Fixed Income', 'LOW_MEDIUM', 3.10, 5000.00, 90, 1),
('FP2024003', 'Growth Select Balanced Plan', 'Balanced Fund', 'MEDIUM', 4.80, 10000.00, 180, 1);

INSERT INTO transactions (
    transaction_no,
    from_account_id,
    to_account_id,
    transaction_type,
    amount,
    balance_after,
    description,
    transaction_time
) VALUES
('TX202405010001', NULL, 1, 'DEPOSIT', 10000.00, 10000.00, 'Opening deposit', '2024-05-01 09:00:00'),
('TX202405030001', 1, 3, 'TRANSFER_OUT', 500.00, 9500.00, 'Transfer to receiver user', '2024-05-03 14:30:00'),
('TX202405030002', 1, 3, 'TRANSFER_IN', 500.00, 7300.00, 'Transfer received from test user', '2024-05-03 14:30:00'),
('TX202405060001', NULL, 2, 'DEPOSIT', 3500.50, 3500.50, 'Current account deposit', '2024-05-06 10:15:00'),
('TX202405100001', 1, NULL, 'WITHDRAW', 300.00, 9200.00, 'ATM withdrawal', '2024-05-10 18:20:00');
