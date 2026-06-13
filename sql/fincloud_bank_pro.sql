/*
 FinCloud Bank Pro
 基于 RBAC 权限控制与账务分录的安全型个人银行综合业务系统
 MySQL 8.x 建库建表脚本：30 张表 + 约束 + 索引 + 测试数据 + 交易黑匣子视图

 设计主轴：Account —— LedgerEntry —— TransactionRecord
 说明：transactions 记录交易事件，ledger_entries 记录账户资金变化。
*/

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

/* =========================================================
   A. 用户、安全与权限域：6 张表
   ========================================================= */

CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户编号',
    user_no VARCHAR(30) NOT NULL UNIQUE COMMENT '系统自动生成用户账号',
    username VARCHAR(50) NOT NULL UNIQUE COMMENT '登录用户名',
    real_name VARCHAR(50) NOT NULL COMMENT '真实姓名',
    id_card_hash VARCHAR(255) COMMENT '身份证号哈希值，不存明文',
    id_card_masked VARCHAR(30) COMMENT '脱敏身份证号',
    phone VARCHAR(20) NOT NULL UNIQUE COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    password_salt VARCHAR(64) NOT NULL COMMENT '密码盐值',
    status VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT '用户状态：NORMAL/FROZEN/CLOSED',
    register_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    last_login_time DATETIME COMMENT '最近登录时间',
    CHECK (status IN ('NORMAL', 'FROZEN', 'CLOSED'))
) ENGINE=InnoDB COMMENT='用户表：存储注册、登录、实名信息和用户状态';

CREATE TABLE roles (
    role_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '角色编号',
    role_code VARCHAR(30) NOT NULL UNIQUE COMMENT '角色代码：CUSTOMER/ADMIN/APPROVER',
    role_name VARCHAR(50) NOT NULL COMMENT '角色名称',
    description VARCHAR(255) COMMENT '角色说明'
) ENGINE=InnoDB COMMENT='角色表：RBAC 权限模型中的角色定义';

CREATE TABLE user_roles (
    user_role_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户角色关系编号',
    user_id BIGINT NOT NULL COMMENT '用户编号',
    role_id BIGINT NOT NULL COMMENT '角色编号',
    assign_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分配时间',
    CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(role_id),
    UNIQUE KEY uk_user_role (user_id, role_id)
) ENGINE=InnoDB COMMENT='用户角色表：拆解用户与角色的多对多关系';

CREATE TABLE auth_records (
    auth_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '认证记录编号',
    user_id BIGINT NULL COMMENT '用户编号，登录失败时可为空',
    auth_type VARCHAR(30) NOT NULL COMMENT '认证类型：PASSWORD/SMS/FACE/LOGOUT',
    auth_result VARCHAR(20) NOT NULL COMMENT '认证结果：SUCCESS/FAILED',
    login_account VARCHAR(50) COMMENT '本次输入的账号或手机号',
    ip_address VARCHAR(50) COMMENT 'IP 地址',
    device_fingerprint VARCHAR(100) COMMENT '设备指纹',
    fail_reason VARCHAR(255) COMMENT '失败原因',
    auth_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '认证时间',
    CONSTRAINT fk_auth_records_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (auth_result IN ('SUCCESS', 'FAILED'))
) ENGINE=InnoDB COMMENT='认证记录表：记录登录、验证码、人脸识别和退出等认证行为';

CREATE TABLE login_devices (
    device_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '设备编号',
    user_id BIGINT NOT NULL COMMENT '用户编号',
    device_fingerprint VARCHAR(100) NOT NULL COMMENT '设备指纹',
    device_name VARCHAR(100) COMMENT '设备名称',
    browser VARCHAR(100) COMMENT '浏览器',
    os VARCHAR(100) COMMENT '操作系统',
    trusted_flag TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否为可信设备',
    first_login_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '首次登录时间',
    last_login_time DATETIME COMMENT '最近登录时间',
    CONSTRAINT fk_login_devices_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY uk_user_device (user_id, device_fingerprint)
) ENGINE=InnoDB COMMENT='登录设备表：记录用户常用或异常登录设备';

CREATE TABLE security_events (
    event_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '安全事件编号',
    user_id BIGINT NULL COMMENT '用户编号',
    event_type VARCHAR(50) NOT NULL COMMENT '事件类型：NEW_DEVICE/LOGIN_FAIL_TOO_MANY/RISK_TRANSFER',
    risk_level VARCHAR(20) NOT NULL DEFAULT 'LOW' COMMENT '风险等级：LOW/MEDIUM/HIGH',
    description VARCHAR(500) COMMENT '事件描述',
    ip_address VARCHAR(50) COMMENT 'IP 地址',
    device_fingerprint VARCHAR(100) COMMENT '设备指纹',
    handled_flag TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已处理',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT fk_security_events_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB COMMENT='安全事件表：记录异常登录、新设备登录、多次失败等安全风险';

/* =========================================================
   B. 账户管理域：5 张表
   ========================================================= */

CREATE TABLE bank_branches (
    branch_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '支行编号',
    branch_code VARCHAR(30) NOT NULL UNIQUE COMMENT '支行代码',
    branch_name VARCHAR(100) NOT NULL COMMENT '支行名称',
    city VARCHAR(50) COMMENT '城市',
    address VARCHAR(255) COMMENT '地址',
    phone VARCHAR(20) COMMENT '联系电话'
) ENGINE=InnoDB COMMENT='银行支行表：存储开户行和跨行业务中的银行信息';

CREATE TABLE accounts (
    account_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '账户编号',
    user_id BIGINT NOT NULL COMMENT '所属用户编号',
    branch_id BIGINT NULL COMMENT '开户支行编号',
    account_no VARCHAR(30) NOT NULL UNIQUE COMMENT '银行账号',
    account_type VARCHAR(20) NOT NULL DEFAULT 'SAVING' COMMENT '账户类型：SAVING/CURRENT',
    currency VARCHAR(10) NOT NULL DEFAULT 'CNY' COMMENT '币种',
    balance DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '账户总余额',
    available_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '可用余额',
    frozen_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '冻结金额',
    status VARCHAR(20) NOT NULL DEFAULT 'NORMAL' COMMENT '账户状态：NORMAL/FROZEN/CLOSED',
    open_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '开户时间',
    CONSTRAINT fk_accounts_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_accounts_branch FOREIGN KEY (branch_id) REFERENCES bank_branches(branch_id) ON DELETE SET NULL,
    CHECK (account_type IN ('SAVING', 'CURRENT')),
    CHECK (status IN ('NORMAL', 'FROZEN', 'CLOSED')),
    CHECK (balance >= 0),
    CHECK (available_balance >= 0),
    CHECK (frozen_amount >= 0)
) ENGINE=InnoDB COMMENT='账户表：存储银行账户、余额、可用余额、冻结金额和状态';

CREATE TABLE account_status_histories (
    history_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '状态变更记录编号',
    account_id BIGINT NOT NULL COMMENT '账户编号',
    old_status VARCHAR(20) COMMENT '原账户状态',
    new_status VARCHAR(20) NOT NULL COMMENT '新账户状态',
    change_reason VARCHAR(255) COMMENT '变更原因',
    changed_by BIGINT NULL COMMENT '操作人用户编号',
    change_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '变更时间',
    CONSTRAINT fk_account_status_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_account_status_user FOREIGN KEY (changed_by) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (new_status IN ('NORMAL', 'FROZEN', 'CLOSED'))
) ENGINE=InnoDB COMMENT='账户状态历史表：记录冻结、解冻、注销等账户状态变化';

CREATE TABLE account_daily_summaries (
    summary_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '日终统计编号',
    account_id BIGINT NOT NULL COMMENT '账户编号',
    summary_date DATE NOT NULL COMMENT '统计日期',
    opening_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '日初余额',
    income_total DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '当日收入合计',
    expense_total DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '当日支出合计',
    closing_balance DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '日终余额',
    transaction_count INT NOT NULL DEFAULT 0 COMMENT '交易笔数',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
    CONSTRAINT fk_daily_summary_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    UNIQUE KEY uk_account_summary_date (account_id, summary_date)
) ENGINE=InnoDB COMMENT='账户日终统计表：用于报表和性能优化的受控冗余数据';

CREATE TABLE payees (
    payee_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '常用收款人编号',
    user_id BIGINT NOT NULL COMMENT '所属用户编号',
    payee_name VARCHAR(50) NOT NULL COMMENT '收款人姓名',
    payee_account_no VARCHAR(30) NOT NULL COMMENT '收款账号',
    payee_bank_name VARCHAR(100) COMMENT '收款银行',
    verified_status VARCHAR(20) NOT NULL DEFAULT 'UNVERIFIED' COMMENT '验证状态：VERIFIED/UNVERIFIED',
    last_transfer_time DATETIME COMMENT '最近转账时间',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT fk_payees_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY uk_user_payee_account (user_id, payee_account_no),
    CHECK (verified_status IN ('VERIFIED', 'UNVERIFIED'))
) ENGINE=InnoDB COMMENT='常用收款人表：支持常用收款人和新收款人风险识别';

/* =========================================================
   C. 交易账务核心域：5 张表
   ========================================================= */

CREATE TABLE transaction_categories (
    category_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '交易分类编号',
    category_code VARCHAR(30) NOT NULL UNIQUE COMMENT '分类代码',
    category_name VARCHAR(50) NOT NULL COMMENT '分类名称',
    income_expense_type VARCHAR(10) NOT NULL COMMENT '收支方向：IN/OUT/BOTH',
    description VARCHAR(255) COMMENT '分类说明',
    CHECK (income_expense_type IN ('IN', 'OUT', 'BOTH'))
) ENGINE=InnoDB COMMENT='交易分类表：支持账单分类、预算提醒和收支分析';

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '交易编号',
    transaction_no VARCHAR(50) NOT NULL UNIQUE COMMENT '交易流水号',
    user_id BIGINT NOT NULL COMMENT '发起用户编号',
    transaction_type VARCHAR(30) NOT NULL COMMENT '交易类型：DEPOSIT/WITHDRAW/TRANSFER/PAYMENT/INVEST_BUY/INVEST_REDEEM',
    amount DECIMAL(18,2) NOT NULL COMMENT '交易金额',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '交易状态：PENDING/SUCCESS/FAILED/APPROVING/REJECTED',
    channel VARCHAR(30) NOT NULL DEFAULT 'WEB' COMMENT '交易渠道：WEB/MOBILE/COUNTER',
    risk_level VARCHAR(20) NOT NULL DEFAULT 'LOW' COMMENT '风险等级：LOW/MEDIUM/HIGH',
    need_approval TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否需要审核',
    description VARCHAR(255) COMMENT '交易说明',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    finish_time DATETIME COMMENT '完成时间',
    CONSTRAINT fk_transactions_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (amount > 0),
    CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAW', 'TRANSFER', 'PAYMENT', 'INVEST_BUY', 'INVEST_REDEEM')),
    CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'APPROVING', 'REJECTED')),
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB COMMENT='交易主记录表：记录发生了什么交易事件';

CREATE TABLE ledger_entries (
    entry_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '账务分录编号',
    transaction_id BIGINT NOT NULL COMMENT '所属交易编号',
    account_id BIGINT NOT NULL COMMENT '受影响账户编号',
    direction VARCHAR(10) NOT NULL COMMENT '资金方向：IN/OUT',
    amount DECIMAL(18,2) NOT NULL COMMENT '分录金额',
    balance_before DECIMAL(18,2) NOT NULL COMMENT '交易前余额',
    balance_after DECIMAL(18,2) NOT NULL COMMENT '交易后余额',
    category_id BIGINT NULL COMMENT '交易分类编号',
    summary VARCHAR(255) COMMENT '分录摘要',
    entry_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '分录时间',
    CONSTRAINT fk_ledger_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_ledger_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_ledger_category FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id) ON DELETE SET NULL,
    CHECK (direction IN ('IN', 'OUT')),
    CHECK (amount > 0),
    CHECK (balance_before >= 0),
    CHECK (balance_after >= 0)
) ENGINE=InnoDB COMMENT='账务分录表：记录每个账户资金如何变化，是余额追溯核心表';

CREATE TABLE transfer_records (
    transfer_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '转账详情编号',
    transaction_id BIGINT NOT NULL UNIQUE COMMENT '所属交易编号',
    from_account_id BIGINT NOT NULL COMMENT '付款账户编号',
    to_account_id BIGINT NULL COMMENT '本行收款账户编号，跨行时可为空',
    to_account_no VARCHAR(30) NOT NULL COMMENT '收款账号',
    to_name VARCHAR(50) COMMENT '收款人姓名',
    to_bank_name VARCHAR(100) COMMENT '收款银行名称',
    transfer_type VARCHAR(20) NOT NULL COMMENT '转账类型：INNER/CROSS',
    is_new_payee TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否新收款人',
    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS' COMMENT '转账状态：SUCCESS/FAILED/APPROVING/REJECTED',
    CONSTRAINT fk_transfer_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_transfer_from_account FOREIGN KEY (from_account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_transfer_to_account FOREIGN KEY (to_account_id) REFERENCES accounts(account_id) ON DELETE SET NULL,
    CHECK (transfer_type IN ('INNER', 'CROSS')),
    CHECK (status IN ('SUCCESS', 'FAILED', 'APPROVING', 'REJECTED'))
) ENGINE=InnoDB COMMENT='转账详情表：记录转账业务特有信息，不替代账务分录';

CREATE TABLE payment_records (
    payment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '缴费详情编号',
    transaction_id BIGINT NOT NULL UNIQUE COMMENT '所属交易编号',
    account_id BIGINT NOT NULL COMMENT '付款账户编号',
    payment_type VARCHAR(30) NOT NULL COMMENT '缴费类型：WATER/ELECTRICITY/GAS/PHONE',
    customer_no VARCHAR(50) NOT NULL COMMENT '缴费户号',
    provider_name VARCHAR(100) COMMENT '服务商名称',
    amount DECIMAL(18,2) NOT NULL COMMENT '缴费金额',
    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS' COMMENT '缴费状态：SUCCESS/FAILED',
    CONSTRAINT fk_payment_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_payment_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CHECK (payment_type IN ('WATER', 'ELECTRICITY', 'GAS', 'PHONE')),
    CHECK (amount > 0),
    CHECK (status IN ('SUCCESS', 'FAILED'))
) ENGINE=InnoDB COMMENT='缴费详情表：记录水电煤、话费等生活缴费信息';

/* =========================================================
   D. 风控与审核域：4 张表
   ========================================================= */

CREATE TABLE transaction_limit_rules (
    rule_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '限额规则编号',
    role_id BIGINT NULL COMMENT '适用角色编号，为空表示通用规则',
    transaction_type VARCHAR(30) NOT NULL COMMENT '交易类型',
    single_limit DECIMAL(18,2) NOT NULL COMMENT '单笔限额',
    daily_limit DECIMAL(18,2) NOT NULL COMMENT '日累计限额',
    approval_threshold DECIMAL(18,2) NOT NULL COMMENT '大额审核阈值',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' COMMENT '规则状态：ACTIVE/DISABLED',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT fk_limit_rule_role FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL,
    CHECK (single_limit > 0),
    CHECK (daily_limit > 0),
    CHECK (approval_threshold > 0),
    CHECK (status IN ('ACTIVE', 'DISABLED'))
) ENGINE=InnoDB COMMENT='交易限额规则表：定义单笔限额、日限额和大额审核阈值';

CREATE TABLE transaction_validations (
    validation_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '交易校验编号',
    transaction_id BIGINT NOT NULL UNIQUE COMMENT '交易编号',
    account_status_ok TINYINT(1) NOT NULL DEFAULT 1 COMMENT '账户状态校验是否通过',
    balance_ok TINYINT(1) NOT NULL DEFAULT 1 COMMENT '余额校验是否通过',
    amount_ok TINYINT(1) NOT NULL DEFAULT 1 COMMENT '金额合法性是否通过',
    limit_ok TINYINT(1) NOT NULL DEFAULT 1 COMMENT '限额校验是否通过',
    validation_result VARCHAR(20) NOT NULL COMMENT '校验结果：PASS/FAIL',
    fail_reason VARCHAR(255) COMMENT '失败原因',
    validation_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '校验时间',
    CONSTRAINT fk_validation_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CHECK (validation_result IN ('PASS', 'FAIL'))
) ENGINE=InnoDB COMMENT='交易校验表：记录账户状态、余额、金额和限额校验结果';

CREATE TABLE transaction_risk_scores (
    risk_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '风险评分编号',
    transaction_id BIGINT NOT NULL UNIQUE COMMENT '交易编号',
    risk_score INT NOT NULL DEFAULT 0 COMMENT '风险分数，0-100',
    risk_level VARCHAR(20) NOT NULL DEFAULT 'LOW' COMMENT '风险等级：LOW/MEDIUM/HIGH',
    risk_reason VARCHAR(500) COMMENT '风险原因，如 LARGE_AMOUNT/NEW_PAYEE',
    rule_hit_count INT NOT NULL DEFAULT 0 COMMENT '命中规则数量',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT fk_risk_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CHECK (risk_score BETWEEN 0 AND 100),
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB COMMENT='交易风险评分表：记录交易风险分、风险等级和命中原因';

CREATE TABLE transaction_approvals (
    approval_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '审核编号',
    transaction_id BIGINT NOT NULL UNIQUE COMMENT '交易编号',
    approver_id BIGINT NULL COMMENT '审核员用户编号',
    approval_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '审核状态：PENDING/APPROVED/REJECTED',
    approval_opinion VARCHAR(255) COMMENT '审核意见',
    submit_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '提交审核时间',
    approval_time DATETIME COMMENT '审核时间',
    CONSTRAINT fk_approval_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id),
    CONSTRAINT fk_approval_user FOREIGN KEY (approver_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED'))
) ENGINE=InnoDB COMMENT='交易审核表：记录大额交易审核状态和审核意见';

/* =========================================================
   E. 审计与通知域：2 张表
   ========================================================= */

CREATE TABLE operation_logs (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '操作日志编号',
    user_id BIGINT NULL COMMENT '操作用户编号',
    operation_type VARCHAR(50) NOT NULL COMMENT '操作类型：LOGIN/TRANSFER/FREEZE/APPROVE 等',
    target_type VARCHAR(50) COMMENT '操作对象类型',
    target_id BIGINT COMMENT '操作对象编号',
    result VARCHAR(20) NOT NULL COMMENT '操作结果：SUCCESS/FAILED',
    ip_address VARCHAR(50) COMMENT 'IP 地址',
    description VARCHAR(500) COMMENT '操作说明',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    CONSTRAINT fk_operation_logs_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    CHECK (result IN ('SUCCESS', 'FAILED'))
) ENGINE=InnoDB COMMENT='操作日志表：记录登录、转账、冻结、审核等关键操作';

CREATE TABLE notifications (
    notification_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '通知编号',
    user_id BIGINT NOT NULL COMMENT '接收用户编号',
    title VARCHAR(100) NOT NULL COMMENT '通知标题',
    content VARCHAR(500) NOT NULL COMMENT '通知内容',
    notification_type VARCHAR(30) NOT NULL DEFAULT 'SYSTEM' COMMENT '通知类型：TRANSACTION/APPROVAL/SECURITY/SYSTEM',
    is_read TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已读',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    read_time DATETIME COMMENT '阅读时间',
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (notification_type IN ('TRANSACTION', 'APPROVAL', 'SECURITY', 'SYSTEM'))
) ENGINE=InnoDB COMMENT='通知消息表：记录交易成功、审核结果、安全提醒等通知';

/* =========================================================
   F. 账单与报表域：4 张表
   ========================================================= */

CREATE TABLE bills (
    bill_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '账单编号',
    account_id BIGINT NOT NULL COMMENT '账户编号',
    bill_type VARCHAR(20) NOT NULL COMMENT '账单类型：DAILY/MONTHLY/YEARLY',
    period_start DATE NOT NULL COMMENT '账期开始日期',
    period_end DATE NOT NULL COMMENT '账期结束日期',
    income_total DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '收入合计',
    expense_total DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '支出合计',
    net_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '净收支',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '生成时间',
    CONSTRAINT fk_bills_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    UNIQUE KEY uk_account_bill_period (account_id, bill_type, period_start, period_end),
    CHECK (bill_type IN ('DAILY', 'MONTHLY', 'YEARLY'))
) ENGINE=InnoDB COMMENT='账单汇总表：由账务分录聚合得到的日/月/年账单';

CREATE TABLE bill_items (
    bill_item_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '账单明细编号',
    bill_id BIGINT NOT NULL COMMENT '账单编号',
    entry_id BIGINT NOT NULL COMMENT '账务分录编号',
    item_summary VARCHAR(255) COMMENT '账单明细摘要',
    CONSTRAINT fk_bill_items_bill FOREIGN KEY (bill_id) REFERENCES bills(bill_id),
    CONSTRAINT fk_bill_items_entry FOREIGN KEY (entry_id) REFERENCES ledger_entries(entry_id),
    UNIQUE KEY uk_bill_entry (bill_id, entry_id)
) ENGINE=InnoDB COMMENT='账单明细表：账单对应的具体账务分录';

CREATE TABLE user_budgets (
    budget_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '预算编号',
    user_id BIGINT NOT NULL COMMENT '用户编号',
    category_id BIGINT NOT NULL COMMENT '交易分类编号',
    budget_month CHAR(7) NOT NULL COMMENT '预算月份，格式 YYYY-MM',
    budget_amount DECIMAL(18,2) NOT NULL COMMENT '预算金额',
    used_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '已使用金额',
    warning_threshold DECIMAL(5,2) NOT NULL DEFAULT 0.80 COMMENT '预警比例，如 0.80',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT fk_user_budgets_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_user_budgets_category FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id),
    UNIQUE KEY uk_user_budget_month_category (user_id, category_id, budget_month),
    CHECK (budget_amount > 0),
    CHECK (used_amount >= 0),
    CHECK (warning_threshold > 0 AND warning_threshold <= 1)
) ENGINE=InnoDB COMMENT='用户预算表：支持智能账单、分类预算和预算提醒';

CREATE TABLE saved_queries (
    query_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '保存查询编号',
    user_id BIGINT NOT NULL COMMENT '用户编号',
    query_name VARCHAR(100) NOT NULL COMMENT '查询名称',
    query_type VARCHAR(30) NOT NULL COMMENT '查询类型：TRANSACTION/BILL/ACCOUNT',
    query_condition VARCHAR(1000) COMMENT '查询条件，可保存 JSON 字符串',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CONSTRAINT fk_saved_queries_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (query_type IN ('TRANSACTION', 'BILL', 'ACCOUNT'))
) ENGINE=InnoDB COMMENT='保存查询条件表：保存用户常用账单或交易查询条件';

/* =========================================================
   G. 理财业务域：4 张表
   ========================================================= */

CREATE TABLE financial_products (
    product_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '理财产品编号',
    product_code VARCHAR(30) NOT NULL UNIQUE COMMENT '产品代码',
    product_name VARCHAR(100) NOT NULL COMMENT '产品名称',
    product_type VARCHAR(30) NOT NULL COMMENT '产品类型：FIXED/FUND/BOND',
    risk_level VARCHAR(20) NOT NULL COMMENT '产品风险等级：LOW/MEDIUM/HIGH',
    expected_rate DECIMAL(6,4) COMMENT '预期年化收益率',
    min_amount DECIMAL(18,2) NOT NULL COMMENT '起购金额',
    period_days INT COMMENT '产品期限，单位天',
    status VARCHAR(20) NOT NULL DEFAULT 'ON_SALE' COMMENT '产品状态：ON_SALE/OFF_SALE',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH')),
    CHECK (min_amount > 0),
    CHECK (status IN ('ON_SALE', 'OFF_SALE'))
) ENGINE=InnoDB COMMENT='理财产品表：存储理财产品、收益率、风险等级和起购金额';

CREATE TABLE risk_assessments (
    assessment_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '风险测评编号',
    user_id BIGINT NOT NULL COMMENT '用户编号',
    score INT NOT NULL COMMENT '测评分数',
    risk_level VARCHAR(20) NOT NULL COMMENT '用户风险承受等级：LOW/MEDIUM/HIGH',
    valid_until DATE COMMENT '有效期',
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '测评时间',
    CONSTRAINT fk_risk_assessments_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CHECK (score BETWEEN 0 AND 100),
    CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH'))
) ENGINE=InnoDB COMMENT='理财风险测评表：记录用户风险承受能力，用于产品适配';

CREATE TABLE investment_orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '理财订单编号',
    order_no VARCHAR(50) NOT NULL UNIQUE COMMENT '理财订单号',
    user_id BIGINT NOT NULL COMMENT '用户编号',
    account_id BIGINT NOT NULL COMMENT '资金账户编号',
    product_id BIGINT NOT NULL COMMENT '理财产品编号',
    transaction_id BIGINT NULL COMMENT '关联交易编号',
    order_type VARCHAR(20) NOT NULL COMMENT '订单类型：BUY/REDEEM',
    amount DECIMAL(18,2) NOT NULL COMMENT '订单金额',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' COMMENT '订单状态：PENDING/SUCCESS/FAILED',
    order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
    CONSTRAINT fk_invest_order_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_invest_order_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_invest_order_product FOREIGN KEY (product_id) REFERENCES financial_products(product_id),
    CONSTRAINT fk_invest_order_transaction FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE SET NULL,
    UNIQUE KEY uk_invest_order_transaction (transaction_id),
    CHECK (order_type IN ('BUY', 'REDEEM')),
    CHECK (amount > 0),
    CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED'))
) ENGINE=InnoDB COMMENT='理财订单表：记录申购和赎回订单';

CREATE TABLE investment_holdings (
    holding_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '理财持仓编号',
    user_id BIGINT NOT NULL COMMENT '用户编号',
    account_id BIGINT NOT NULL COMMENT '资金账户编号',
    product_id BIGINT NOT NULL COMMENT '理财产品编号',
    order_id BIGINT NULL COMMENT '来源订单编号',
    holding_amount DECIMAL(18,2) NOT NULL COMMENT '持仓金额',
    profit_amount DECIMAL(18,2) NOT NULL DEFAULT 0.00 COMMENT '累计收益',
    holding_status VARCHAR(20) NOT NULL DEFAULT 'HOLDING' COMMENT '持仓状态：HOLDING/REDEEMED',
    buy_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '买入时间',
    CONSTRAINT fk_holding_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_holding_account FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT fk_holding_product FOREIGN KEY (product_id) REFERENCES financial_products(product_id),
    CONSTRAINT fk_holding_order FOREIGN KEY (order_id) REFERENCES investment_orders(order_id) ON DELETE SET NULL,
    CHECK (holding_amount >= 0),
    CHECK (profit_amount >= 0),
    CHECK (holding_status IN ('HOLDING', 'REDEEMED'))
) ENGINE=InnoDB COMMENT='理财持仓表：记录用户当前持有的理财产品';

/* =========================================================
   常用索引
   ========================================================= */

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

/* =========================================================
   测试数据：支持注册/登录/账户/交易/黑匣子/理财演示
   密码说明：示例用 SHA2(明文 + 盐值, 256)，Java 端需保持同样算法。
   ========================================================= */

INSERT INTO roles(role_id, role_code, role_name, description) VALUES
(1, 'CUSTOMER', '普通用户', '注册登录、查看本人账户、存取款、转账、缴费、账单和理财'),
(2, 'ADMIN', '系统管理员', '用户管理、账户冻结解冻、查看交易记录和操作日志'),
(3, 'APPROVER', '审核员', '查看并审核大额交易');

INSERT INTO users(user_id, user_no, username, real_name, id_card_hash, id_card_masked, phone, email, password_hash, password_salt, status, register_time, last_login_time) VALUES
(1, 'U202506120001', 'cuppy', '张小云', SHA2('110101200001010001', 256), '110101********0001', '13800000001', 'cuppy@test.com', SHA2(CONCAT('123456', 'SALT_CUPPY'), 256), 'SALT_CUPPY', 'NORMAL', NOW(), NOW()),
(2, 'U202506120002', 'alice', '李安娜', SHA2('110101200001010002', 256), '110101********0002', '13800000002', 'alice@test.com', SHA2(CONCAT('123456', 'SALT_ALICE'), 256), 'SALT_ALICE', 'NORMAL', NOW(), NOW()),
(3, 'U202506120099', 'admin', '系统管理员', SHA2('110101200001019999', 256), '110101********9999', '13800000099', 'admin@test.com', SHA2(CONCAT('admin123', 'SALT_ADMIN'), 256), 'SALT_ADMIN', 'NORMAL', NOW(), NOW());

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
(1, 'NEW_DEVICE', 'LOW', '首次在当前设备登录，已记录设备指纹', '127.0.0.1', 'DEV-CUPPY-PC', 1, NOW());

INSERT INTO bank_branches(branch_id, branch_code, branch_name, city, address, phone) VALUES
(1, 'BJ001', 'FinCloud Bank 北京中关村支行', '北京', '北京市海淀区中关村', '010-10000001'),
(2, 'SH001', 'FinCloud Bank 上海陆家嘴支行', '上海', '上海市浦东新区陆家嘴', '021-10000002');

-- 账户当前余额与下面示例交易保持一致：
-- Cuppy 储蓄账户：初始 10000 +100 -500 -1000 = 8600；
-- Cuppy 活期账户：初始 3500.50 +1200 -180 -420 = 4100.50；
-- Alice 储蓄账户：初始 5000 +500 +420 = 5920。
INSERT INTO accounts(account_id, user_id, branch_id, account_no, account_type, currency, balance, available_balance, frozen_amount, status, open_time) VALUES
(1, 1, 1, '6222000000000001', 'SAVING', 'CNY', 8600.00, 8600.00, 0.00, 'NORMAL', NOW()),
(2, 2, 2, '6222000000000002', 'SAVING', 'CNY', 5920.00, 5920.00, 0.00, 'NORMAL', NOW()),
(4, 1, 2, '6222000000000004', 'CURRENT', 'CNY', 4100.50, 4100.50, 0.00, 'NORMAL', NOW());

INSERT INTO account_status_histories(account_id, old_status, new_status, change_reason, changed_by, change_time) VALUES
(1, NULL, 'NORMAL', '开户成功', 3, NOW()),
(2, NULL, 'NORMAL', '开户成功', 3, NOW()),
(4, NULL, 'NORMAL', '工资卡开户成功', 3, NOW());

INSERT INTO account_daily_summaries(account_id, summary_date, opening_balance, income_total, expense_total, closing_balance, transaction_count, create_time) VALUES
(1, CURDATE(), 10000.00, 100.00, 1500.00, 8600.00, 3, NOW()),
(2, CURDATE(), 5500.00, 420.00, 0.00, 5920.00, 1, NOW()),
(4, CURDATE(), 3500.50, 1200.00, 600.00, 4100.50, 3, NOW());

INSERT INTO payees(user_id, payee_name, payee_account_no, payee_bank_name, verified_status, last_transfer_time, create_time) VALUES
(1, '李安娜', '6222000000000002', 'FinCloud Bank 上海陆家嘴支行', 'VERIFIED', NOW(), NOW());

INSERT INTO transaction_categories(category_id, category_code, category_name, income_expense_type, description) VALUES
(1, 'DEPOSIT_IN', '存款收入', 'IN', '用户存款产生的收入分录'),
(2, 'WITHDRAW_OUT', '取款支出', 'OUT', '用户取款产生的支出分录'),
(3, 'TRANSFER_IN', '转账收入', 'IN', '收到转账'),
(4, 'TRANSFER_OUT', '转账支出', 'OUT', '发起转账'),
(5, 'LIVING_PAYMENT', '生活缴费', 'OUT', '水电煤或话费缴费'),
(6, 'INVESTMENT', '理财交易', 'OUT', '理财申购或赎回相关分录');

INSERT INTO transactions(transaction_id, transaction_no, user_id, transaction_type, amount, status, channel, risk_level, need_approval, description, create_time, finish_time) VALUES
(1, 'TX202506120001', 1, 'DEPOSIT', 100.00, 'SUCCESS', 'WEB', 'LOW', 0, '用户存款 100 元', NOW(), NOW()),
(2, 'TX202506120002', 1, 'TRANSFER', 500.00, 'SUCCESS', 'WEB', 'LOW', 0, '向李安娜转账 500 元', NOW(), NOW()),
(3, 'TX202506120003', 1, 'INVEST_BUY', 1000.00, 'SUCCESS', 'WEB', 'LOW', 0, '申购稳健月月盈 1000 元', NOW(), NOW()),
(4, 'TX202506120004', 1, 'DEPOSIT', 1200.00, 'SUCCESS', 'MOBILE', 'LOW', 0, '工资入账 1200 元', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 'TX202506120005', 1, 'PAYMENT', 180.00, 'SUCCESS', 'WEB', 'LOW', 0, '手机话费缴费 180 元', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 'TX202506120006', 1, 'TRANSFER', 420.00, 'SUCCESS', 'MOBILE', 'LOW', 0, '向李安娜转账 420 元作为房租分摊', NOW(), NOW());

INSERT INTO ledger_entries(entry_id, transaction_id, account_id, direction, amount, balance_before, balance_after, category_id, summary, entry_time) VALUES
(1, 1, 1, 'IN', 100.00, 10000.00, 10100.00, 1, '存款收入', NOW()),
(2, 2, 1, 'OUT', 500.00, 10100.00, 9600.00, 4, '转账给李安娜', NOW()),
(3, 2, 2, 'IN', 500.00, 5000.00, 5500.00, 3, '收到张小云转账', NOW()),
(4, 3, 1, 'OUT', 1000.00, 9600.00, 8600.00, 6, '申购理财产品', NOW()),
(5, 4, 4, 'IN', 1200.00, 3500.50, 4700.50, 1, '工资入账', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(6, 5, 4, 'OUT', 180.00, 4700.50, 4520.50, 5, '手机话费缴费', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(7, 6, 4, 'OUT', 420.00, 4520.50, 4100.50, 4, '房租分摊转账', NOW()),
(8, 6, 2, 'IN', 420.00, 5500.00, 5920.00, 3, '收到张小云房租分摊', NOW());

INSERT INTO transfer_records(transaction_id, from_account_id, to_account_id, to_account_no, to_name, to_bank_name, transfer_type, is_new_payee, status) VALUES
(2, 1, 2, '6222000000000002', '李安娜', 'FinCloud Bank 上海陆家嘴支行', 'INNER', 0, 'SUCCESS'),
(6, 4, 2, '6222000000000002', '李安娜', 'FinCloud Bank 上海陆家嘴支行', 'INNER', 0, 'SUCCESS');

INSERT INTO payment_records(transaction_id, account_id, payment_type, customer_no, provider_name, amount, status) VALUES
(5, 4, 'PHONE', 'PH13800000001', '中国移动北京分公司', 180.00, 'SUCCESS');

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
(1, 'LOGIN', 'USER', 1, 'SUCCESS', '127.0.0.1', '用户登录成功', NOW()),
(1, 'DEPOSIT', 'TRANSACTION', 1, 'SUCCESS', '127.0.0.1', '用户存款 100 元', NOW()),
(1, 'TRANSFER', 'TRANSACTION', 2, 'SUCCESS', '127.0.0.1', '用户转账 500 元给李安娜', NOW()),
(1, 'INVEST_BUY', 'TRANSACTION', 3, 'SUCCESS', '127.0.0.1', '用户申购理财产品 1000 元', NOW()),
(1, 'DEPOSIT', 'TRANSACTION', 4, 'SUCCESS', '127.0.0.1', '工资入账 1200 元', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 'PAYMENT', 'TRANSACTION', 5, 'SUCCESS', '127.0.0.1', '手机话费缴费 180 元', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 'TRANSFER', 'TRANSACTION', 6, 'SUCCESS', '127.0.0.1', '房租分摊转账 420 元给李安娜', NOW());

INSERT INTO notifications(user_id, title, content, notification_type, is_read, create_time) VALUES
(1, '存款成功', '您已成功存款 100.00 元。', 'TRANSACTION', 0, NOW()),
(1, '转账成功', '您已成功向李安娜转账 500.00 元。', 'TRANSACTION', 0, NOW()),
(2, '收到转账', '您收到张小云转账 500.00 元。', 'TRANSACTION', 0, NOW()),
(1, '工资入账', '您的工资卡收到 1200.00 元入账。', 'TRANSACTION', 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, '缴费成功', '您已成功缴纳手机话费 180.00 元。', 'TRANSACTION', 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, '转账成功', '您已成功向李安娜转账 420.00 元。', 'TRANSACTION', 0, NOW()),
(2, '收到转账', '您收到张小云转账 420.00 元。', 'TRANSACTION', 0, NOW());

INSERT INTO bills(bill_id, account_id, bill_type, period_start, period_end, income_total, expense_total, net_amount, create_time) VALUES
(1, 1, 'MONTHLY', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 100.00, 1500.00, -1400.00, NOW()),
(2, 4, 'MONTHLY', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1200.00, 600.00, 600.00, NOW());

INSERT INTO bill_items(bill_id, entry_id, item_summary) VALUES
(1, 1, '本月存款收入'),
(1, 2, '本月转账支出'),
(1, 4, '本月理财申购支出'),
(2, 5, '本月工资收入'),
(2, 6, '本月手机话费'),
(2, 7, '本月房租分摊');

INSERT INTO user_budgets(user_id, category_id, budget_month, budget_amount, used_amount, warning_threshold, create_time) VALUES
(1, 5, DATE_FORMAT(CURDATE(), '%Y-%m'), 800.00, 180.00, 0.80, NOW()),
(1, 4, DATE_FORMAT(CURDATE(), '%Y-%m'), 3000.00, 920.00, 0.80, NOW());

INSERT INTO saved_queries(user_id, query_name, query_type, query_condition, create_time) VALUES
(1, '本月支出查询', 'BILL', '{"period":"current_month","direction":"OUT"}', NOW());

INSERT INTO financial_products(product_id, product_code, product_name, product_type, risk_level, expected_rate, min_amount, period_days, status, create_time) VALUES
(1, 'FP001', '稳健月月盈', 'FIXED', 'LOW', 0.0320, 1000.00, 30, 'ON_SALE', NOW()),
(2, 'FP002', '成长精选基金', 'FUND', 'MEDIUM', 0.0580, 1000.00, 180, 'ON_SALE', NOW()),
(3, 'FP003', '高收益进取计划', 'FUND', 'HIGH', 0.0880, 5000.00, 365, 'ON_SALE', NOW());

INSERT INTO risk_assessments(user_id, score, risk_level, valid_until, create_time) VALUES
(1, 62, 'MEDIUM', DATE_ADD(CURDATE(), INTERVAL 1 YEAR), NOW());

INSERT INTO investment_orders(order_id, order_no, user_id, account_id, product_id, transaction_id, order_type, amount, status, order_time) VALUES
(1, 'IO202506120001', 1, 1, 1, 3, 'BUY', 1000.00, 'SUCCESS', NOW());

INSERT INTO investment_holdings(user_id, account_id, product_id, order_id, holding_amount, profit_amount, holding_status, buy_time) VALUES
(1, 1, 1, 1, 1000.00, 0.00, 'HOLDING', NOW());

/* =========================================================
   交易黑匣子视图：用于演示“交易事件 + 账务分录 + 风控 + 审核 + 日志”
   ========================================================= */

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
            '，余额 ', le.balance_before, ' -> ', le.balance_after
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

/* =========================================================
   快速验证查询，可手动执行
   =========================================================

SELECT * FROM v_user_account_overview;
SELECT * FROM v_transaction_black_box;
SELECT * FROM ledger_entries ORDER BY entry_id;
SELECT * FROM operation_logs ORDER BY create_time DESC;

*/
