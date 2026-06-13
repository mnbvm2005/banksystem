USE fincloud_bank_pro;

INSERT INTO accounts(account_id, user_id, branch_id, account_no, account_type, currency, balance, available_balance, frozen_amount, status, open_time) VALUES
(2, 2, 2, '6222000000000002', 'SAVING', 'CNY', 5920.00, 5920.00, 0.00, 'NORMAL', NOW()),
(4, 1, 2, '6222000000000004', 'CURRENT', 'CNY', 4100.50, 4100.50, 0.00, 'NORMAL', NOW())
ON DUPLICATE KEY UPDATE
balance = VALUES(balance),
available_balance = VALUES(available_balance),
status = VALUES(status);

INSERT IGNORE INTO account_status_histories(account_id, old_status, new_status, change_reason, changed_by, change_time) VALUES
(4, NULL, 'NORMAL', '工资卡开户成功', 3, NOW());

INSERT INTO account_daily_summaries(account_id, summary_date, opening_balance, income_total, expense_total, closing_balance, transaction_count, create_time) VALUES
(2, CURDATE(), 5500.00, 420.00, 0.00, 5920.00, 1, NOW()),
(4, CURDATE(), 3500.50, 1200.00, 600.00, 4100.50, 3, NOW())
ON DUPLICATE KEY UPDATE
opening_balance = VALUES(opening_balance),
income_total = VALUES(income_total),
expense_total = VALUES(expense_total),
closing_balance = VALUES(closing_balance),
transaction_count = VALUES(transaction_count);

INSERT INTO transactions(transaction_id, transaction_no, user_id, transaction_type, amount, status, channel, risk_level, need_approval, description, create_time, finish_time) VALUES
(4, 'TX202506120004', 1, 'DEPOSIT', 1200.00, 'SUCCESS', 'MOBILE', 'LOW', 0, '工资入账 1200 元', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 'TX202506120005', 1, 'PAYMENT', 180.00, 'SUCCESS', 'WEB', 'LOW', 0, '手机话费缴费 180 元', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 'TX202506120006', 1, 'TRANSFER', 420.00, 'SUCCESS', 'MOBILE', 'LOW', 0, '向李安娜转账 420 元作为房租分摊', NOW(), NOW())
ON DUPLICATE KEY UPDATE
amount = VALUES(amount),
status = VALUES(status),
description = VALUES(description);

INSERT INTO ledger_entries(entry_id, transaction_id, account_id, direction, amount, balance_before, balance_after, category_id, summary, entry_time) VALUES
(5, 4, 4, 'IN', 1200.00, 3500.50, 4700.50, 1, '工资入账', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(6, 5, 4, 'OUT', 180.00, 4700.50, 4520.50, 5, '手机话费缴费', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(7, 6, 4, 'OUT', 420.00, 4520.50, 4100.50, 4, '房租分摊转账', NOW()),
(8, 6, 2, 'IN', 420.00, 5500.00, 5920.00, 3, '收到张小云房租分摊', NOW())
ON DUPLICATE KEY UPDATE
amount = VALUES(amount),
balance_before = VALUES(balance_before),
balance_after = VALUES(balance_after),
summary = VALUES(summary);

INSERT INTO transfer_records(transaction_id, from_account_id, to_account_id, to_account_no, to_name, to_bank_name, transfer_type, is_new_payee, status) VALUES
(6, 4, 2, '6222000000000002', '李安娜', 'FinCloud Bank 上海陆家嘴支行', 'INNER', 0, 'SUCCESS')
ON DUPLICATE KEY UPDATE
from_account_id = VALUES(from_account_id),
to_account_id = VALUES(to_account_id),
status = VALUES(status);

INSERT INTO payment_records(transaction_id, account_id, payment_type, customer_no, provider_name, amount, status) VALUES
(5, 4, 'PHONE', 'PH13800000001', '中国移动北京分公司', 180.00, 'SUCCESS')
ON DUPLICATE KEY UPDATE
amount = VALUES(amount),
status = VALUES(status);

INSERT INTO transaction_validations(transaction_id, account_status_ok, balance_ok, amount_ok, limit_ok, validation_result, fail_reason, validation_time) VALUES
(4, 1, 1, 1, 1, 'PASS', NULL, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 1, 1, 1, 1, 'PASS', NULL, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 1, 1, 1, 1, 'PASS', NULL, NOW())
ON DUPLICATE KEY UPDATE
validation_result = VALUES(validation_result),
fail_reason = VALUES(fail_reason);

INSERT INTO transaction_risk_scores(transaction_id, risk_score, risk_level, risk_reason, rule_hit_count, create_time) VALUES
(4, 5, 'LOW', 'SALARY_INCOME', 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(5, 8, 'LOW', 'NORMAL_PAYMENT', 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(6, 12, 'LOW', 'VERIFIED_PAYEE', 0, NOW())
ON DUPLICATE KEY UPDATE
risk_score = VALUES(risk_score),
risk_level = VALUES(risk_level),
risk_reason = VALUES(risk_reason);

INSERT INTO operation_logs(user_id, operation_type, target_type, target_id, result, ip_address, description, create_time) VALUES
(1, 'DEPOSIT', 'TRANSACTION', 4, 'SUCCESS', '127.0.0.1', '工资入账 1200 元', DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, 'PAYMENT', 'TRANSACTION', 5, 'SUCCESS', '127.0.0.1', '手机话费缴费 180 元', DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, 'TRANSFER', 'TRANSACTION', 6, 'SUCCESS', '127.0.0.1', '房租分摊转账 420 元给李安娜', NOW());

INSERT INTO notifications(user_id, title, content, notification_type, is_read, create_time) VALUES
(1, '工资入账', '您的工资卡收到 1200.00 元入账。', 'TRANSACTION', 0, DATE_SUB(NOW(), INTERVAL 2 DAY)),
(1, '缴费成功', '您已成功缴纳手机话费 180.00 元。', 'TRANSACTION', 0, DATE_SUB(NOW(), INTERVAL 1 DAY)),
(1, '转账成功', '您已成功向李安娜转账 420.00 元。', 'TRANSACTION', 0, NOW()),
(2, '收到转账', '您收到张小云转账 420.00 元。', 'TRANSACTION', 0, NOW());

INSERT INTO bills(bill_id, account_id, bill_type, period_start, period_end, income_total, expense_total, net_amount, create_time) VALUES
(2, 4, 'MONTHLY', DATE_FORMAT(CURDATE(), '%Y-%m-01'), LAST_DAY(CURDATE()), 1200.00, 600.00, 600.00, NOW())
ON DUPLICATE KEY UPDATE
income_total = VALUES(income_total),
expense_total = VALUES(expense_total),
net_amount = VALUES(net_amount);

INSERT IGNORE INTO bill_items(bill_id, entry_id, item_summary) VALUES
(2, 5, '本月工资收入'),
(2, 6, '本月手机话费'),
(2, 7, '本月房租分摊');

INSERT INTO user_budgets(user_id, category_id, budget_month, budget_amount, used_amount, warning_threshold, create_time) VALUES
(1, 5, DATE_FORMAT(CURDATE(), '%Y-%m'), 800.00, 180.00, 0.80, NOW()),
(1, 4, DATE_FORMAT(CURDATE(), '%Y-%m'), 3000.00, 920.00, 0.80, NOW())
ON DUPLICATE KEY UPDATE
used_amount = VALUES(used_amount),
budget_amount = VALUES(budget_amount);
