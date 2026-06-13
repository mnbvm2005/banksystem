# BankSystem

个人银行综合业务系统原型，界面主题为 FinCloud Bank Pro。项目用于 Java Web 综合开发实验，采用 Eclipse Dynamic Web Project 结构，不使用 Maven，不使用 Spring Boot，不做前后端分离。

## 技术概况

| 分类 | 技术 |
| --- | --- |
| 后端 | Java 8、Servlet、JSP、DAO、Model |
| 数据访问 | JDBC、PreparedStatement、MySQL Connector/J 8.0.28 |
| 数据库 | MySQL、InnoDB、事务、外键约束 |
| Web 容器 | Tomcat 9 |
| 前端 | JSP、Bootstrap 5 CDN、Bootstrap Icons、Chart.js、原生 JavaScript、现有 `style.css` |
| 架构 | MVC + DAO：Controller 处理请求，DAO 封装 SQL，Model 承载数据，JSP 负责展示 |

## 已实现功能

- 登录/退出：支持账号或手机号登录，登录状态保存在 session。
- Dashboard：首页统计、账户概览、快捷入口和图表原型。
- 账户查看：展示账户类型、余额、状态、开户行等信息。
- 交易明细：按用户账户查询存款、取款、转账、缴费等流水。
- 转账汇款：校验金额、账户状态、余额和收款账户，使用 JDBC 事务更新双方余额。
- 理财产品展示：展示产品名称、类型、风险等级、收益率、起购金额和期限。

## 后端已扩展功能

- 存款 `/deposit`：可直接演示。更新余额，写入 `transactions`、`ledger_entries`、`operation_logs`。
- 取款 `/withdraw`：可直接演示。校验账户状态和余额，写入交易主记录、明细账和操作日志。
- 缴费 `/payment`：可直接演示。扣减余额，写入 `transactions`、`ledger_entries`、`payment_records`、`operation_logs`。
- 转账升级 `/transfer`：在原有扣款/入账基础上，新增写入 `ledger_entries`、`transfer_records`、`operation_logs`、`notifications`。
- 账单查询 `/bill`：从 `ledger_entries` 按账户和日期范围动态统计收入/支出。
- 操作日志 `/logs`：查询当前登录用户的关键操作记录。

## 原型/预留功能

- 理财持仓 `/holding`：已提供 `InvestmentOrderDao`、`InvestmentHoldingDao` 和持仓查询页面；申购/赎回页面可后续继续补。
- 大额交易审核 `/approval`：已提供待审核查询、通过/拒绝更新、交易状态更新和日志写入；当前没有独立管理员权限体系。
- 认证记录：已新增 `auth_records` 表和 `AuthRecordDao`，可用于后续记录登录成功/失败。
- 交易校验记录：已新增 `transaction_validations` 表和 DAO，当前作为后端审计预留。
- 通知消息：已新增 `notifications` 表和 DAO，转账成功时会写入原型通知记录。

## 数据库表说明

| 表名 | 说明 |
| --- | --- |
| `users` | 用户登录资料、实名信息、手机号和状态 |
| `accounts` | 用户银行账户、账号、余额、币种、开户行和账户状态 |
| `financial_products` | 理财产品信息 |
| `transactions` | 交易主记录，含交易号、账户、类型、金额、交易状态和时间 |
| `ledger_entries` | 明细账，记录每个账户的 IN/OUT、交易前余额和交易后余额 |
| `transfer_records` | 转账详情，记录付款账号、收款账号、收款人和状态 |
| `payment_records` | 缴费详情，记录缴费类型、户号、服务商、金额和状态 |
| `bills` | 账单汇总数据预留表 |
| `bill_items` | 账单明细数据预留表 |
| `investment_orders` | 理财申购/赎回订单预留表 |
| `investment_holdings` | 理财持仓表 |
| `auth_records` | 登录/认证记录表 |
| `operation_logs` | 关键操作日志表 |
| `transaction_validations` | 交易校验记录表 |
| `transaction_approvals` | 大额交易审核记录表 |
| `notifications` | 用户通知消息表 |

## 主要目录

```text
src/main/java/banksystem/controller
├── LoginController.java
├── IndexController.java
├── AccountController.java
├── TransactionController.java
├── TransferController.java
├── FinanceController.java
├── DepositController.java
├── WithdrawController.java
├── PaymentController.java
├── BillController.java
├── HoldingController.java
├── ApprovalController.java
├── LogController.java
├── BaseController.java
└── MoneyOperationController.java

src/main/java/banksystem/dao
├── UserDao.java
├── AccountDao.java
├── TransactionDao.java
├── FinancialProductDao.java
├── LedgerEntryDao.java
├── TransferRecordDao.java
├── PaymentRecordDao.java
├── BillDao.java
├── InvestmentOrderDao.java
├── InvestmentHoldingDao.java
├── AuthRecordDao.java
├── OperationLogDao.java
├── TransactionValidationDao.java
├── TransactionApprovalDao.java
└── NotificationDao.java

src/main/java/banksystem/model
├── User.java
├── Account.java
├── Transaction.java
├── FinancialProduct.java
├── LedgerEntry.java
├── TransferRecord.java
├── PaymentRecord.java
├── Bill.java
├── BillItem.java
├── InvestmentOrder.java
├── InvestmentHolding.java
├── AuthRecord.java
├── OperationLog.java
├── TransactionValidation.java
├── TransactionApproval.java
└── Notification.java

src/main/webapp/views/user
├── index.jsp
├── account.jsp
├── transactions.jsp
├── transfer.jsp
├── finance.jsp
├── deposit.jsp
├── withdraw.jsp
├── payment.jsp
├── bill.jsp
├── holding.jsp
├── approval.jsp
└── logs.jsp
```

## 路由

| URL | 说明 |
| --- | --- |
| `/login`、`/logout` | 登录和退出 |
| `/index`、`/dashboard` | Dashboard 首页 |
| `/account` | 账户查看 |
| `/transactions` | 交易明细 |
| `/transfer` | 转账汇款 |
| `/finance` | 理财产品展示 |
| `/deposit` | 存款 |
| `/withdraw` | 取款 |
| `/payment` | 缴费 |
| `/bill` | 账单查询 |
| `/holding` | 理财持仓查询 |
| `/approval` | 大额交易审核原型 |
| `/logs` | 操作日志查询 |

## 数据库导入

1. 打开 MySQL。
2. 执行 `sql/banksystem.sql`。
3. 确认数据库名为 `banksystem`。
4. 如测试账号被改动，可执行 `sql/fix-login-1.sql` 重置账号、手机号和状态。
5. 如本机 MySQL 连接信息不同，修改 `src/main/java/banksystem/sqloperation/GetMySQLConnection.java`。

当前源码中的默认连接配置：

```text
url = jdbc:mysql://127.0.0.1:3306/banksystem?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8
username = root
password = @Asd984266
```

## Tomcat 部署

1. 使用 Eclipse 导入项目。
2. 配置 Tomcat 9 Server Runtime。
3. 确认 `src/main/webapp/WEB-INF/lib/mysql-connector-java-8.0.28.jar` 存在。
4. 刷新项目并重新部署到 Tomcat。
5. 启动 Tomcat。
6. 访问 `http://localhost:8080/BankSystem/`。

## 测试账号

```text
普通用户：cuppy / 123456
普通用户：alice / 123456
管理员：admin / admin123
```

测试收款账户：

```text
6222000000000002
```

## 演示流程

1. 执行 `sql/fincloud_bank_pro.sql`，重新创建数据库表、视图和测试数据。
2. 启动 Tomcat，访问 `http://localhost:8080/BankSystem/`。
3. 使用测试账号登录。
4. 查看 Dashboard、账户查看、交易明细、转账、理财产品。
5. 访问 `/deposit` 演示存款，再回到 `/transactions` 查看流水。
6. 访问 `/withdraw` 演示取款，再回到 `/transactions` 查看流水。
7. 访问 `/payment` 演示缴费，再回到 `/transactions` 查看流水。
8. 访问 `/bill` 按日期范围查看账单统计。
9. 访问 `/logs` 查看关键操作日志。
10. 访问 `/holding`、`/approval` 展示后端预留模块页面。

## 常见问题

- Tomcat 404：检查 context-root 是否为 `BankSystem`，项目是否已部署。
- 新路由 404：刷新 Eclipse 项目，重新发布 Tomcat，确认 `WEB-INF/web.xml` 已更新。
- 数据库表不存在：重新执行 `sql/fincloud_bank_pro.sql`。
- 数据库连接失败：检查 MySQL 是否启动，以及 `DB_URL`、`DB_USER`、`DB_PASSWORD` 或 `GetMySQLConnection.java` 默认值是否正确。
- 交易明细看不到新增缴费：确认已重新部署最新 class 文件，并使用扩展后的 SQL。
- CDN 图标或图表不显示：检查网络是否能访问 Bootstrap、Bootstrap Icons 和 Chart.js CDN。
- 本项目是课程实验原型，不是生产级银行系统；真实银行系统还需要密码加密、权限细分、风控、审计、短信/令牌验证、限流和监控告警。
