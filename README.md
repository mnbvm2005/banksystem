# BankSystem

BankSystem 是一个基于 Java Web 的个人银行业务原型项目，界面风格参考 FinCloud Bank Pro。项目采用 Eclipse Dynamic Web Project 目录结构，刻意不使用 Maven、Spring Boot，也没有做前后端分离。

## 技术概览

| 分类 | 技术 |
| --- | --- |
| 后端 | Java 8、Servlet、JSP、DAO、Model |
| 数据访问 | JDBC、PreparedStatement、MySQL Connector/J 8.0.28 |
| 数据库 | MySQL、InnoDB、事务、外键约束 |
| Web 容器 | Tomcat 9 |
| 前端 | JSP、Bootstrap 5 CDN、Bootstrap Icons、Chart.js、原生 JavaScript、共享 `style.css` |
| 架构 | MVC + DAO：Controller 处理请求，DAO 封装 SQL，Model 承载数据，JSP 负责渲染页面 |

## 已实现功能

- 登录、登出与基于 Session 的身份认证。
- Dashboard 总览页：账户总资产、月度流入流出、最近交易、快捷操作、图表展示。
- 账户列表页：展示账户类型、余额、状态、开户支行、账号等信息。
- 交易流水页：覆盖存款、取款、转账、缴费、理财购买等记录。
- 转账流程：包含金额校验、账户状态校验、余额校验、JDBC 事务处理与分录写入。
- 理财产品页：展示产品类型、风险等级、利率、起购金额、期限等信息。
- 存款、取款、缴费、账单查询、日志、通知、持仓、审批等原型页面。

## 数据库表

| 表名 | 用途 |
| --- | --- |
| `users` | 登录用户资料、实名信息、手机号、邮箱、状态 |
| `accounts` | 银行账户、余额、币种、支行、账户状态 |
| `financial_products` | 理财产品目录 |
| `transactions` | 主交易记录，包含类型、金额、状态、时间 |
| `ledger_entries` | 账户级 IN/OUT 分录与余额变化 |
| `transfer_records` | 转账详情、目标账户、收款人、银行、状态 |
| `payment_records` | 缴费类型、客户号、服务商、金额、状态 |
| `bills` | 账单汇总数据 |
| `bill_items` | 账单明细数据 |
| `investment_orders` | 理财下单记录 |
| `investment_holdings` | 理财持仓记录 |
| `auth_records` | 认证审计记录 |
| `operation_logs` | 操作审计日志 |
| `transaction_validations` | 交易校验记录 |
| `transaction_approvals` | 大额交易审批记录 |
| `notifications` | 用户通知消息 |

## 主要路由

| URL | 页面 |
| --- | --- |
| `/login`, `/logout`, `/register` | 登录认证 |
| `/index`, `/dashboard` | Dashboard 总览 |
| `/account` | 账户列表 |
| `/transactions` | 交易流水 |
| `/transfer` | 转账 |
| `/finance` | 理财产品 |
| `/deposit` | 存款 |
| `/withdraw` | 取款 |
| `/payment` | 缴费 |
| `/bill` | 账单查询 |
| `/holding` | 理财持仓 |
| `/approval` | 审批原型 |
| `/logs` | 操作日志 |
| `/notifications` | 通知中心 |

## 数据库初始化

1. 启动 MySQL。
2. 执行 `sql/fincloud_bank_pro.sql`，导入完整表结构、视图和演示数据。
3. 确认数据库名为 `fincloud_bank_pro`。
4. 如果你的本地 MySQL 用户名、密码或端口不同，请修改 `src/main/java/banksystem/sqloperation/GetMySQLConnection.java`。

默认本地连接如下：

```text
url = jdbc:mysql://127.0.0.1:3306/fincloud_bank_pro?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8
username = root
password = @Asd984266
```

## Tomcat 部署

1. 将项目导入 Eclipse。
2. 配置 Tomcat 9 Server Runtime。
3. 确认 `src/main/webapp/WEB-INF/lib/mysql-connector-java-8.0.28.jar` 存在。
4. 在 Eclipse 中刷新项目并重新发布到 Tomcat。
5. 启动 Tomcat。
6. 访问 `http://localhost:8080/BankSystem/`。

## 演示账号

```text
普通用户：cuppy / 123456
普通用户：alice / 123456
管理员：admin / admin123
```

演示收款账号：

```text
6222000000000002
```

## 演示流程

1. 先执行 `sql/fincloud_bank_pro.sql`，恢复表结构、视图和演示数据。
2. 启动 Tomcat 并访问 `http://localhost:8080/BankSystem/`。
3. 使用演示账号登录系统。
4. 依次查看 Dashboard、账户、交易、转账、理财页面。
5. 使用 `/deposit`、`/withdraw`、`/payment` 后，再回到 `/transactions` 查看流水变化。
6. 使用 `/bill` 按账户和日期范围查询分录。
7. 使用 `/logs`、`/holding`、`/approval`、`/notifications` 查看配套原型页面。

## 常见问题

- Tomcat 返回 404：确认上下文路径是 `BankSystem`，并且应用已经成功部署。
- 新增路由访问 404：刷新 Eclipse 项目、重新发布 Tomcat，并确认 `WEB-INF/web.xml` 是最新的。
- 缺少数据库表：重新执行 `sql/fincloud_bank_pro.sql`。
- 数据库连接失败：确认 MySQL 已启动，并检查 JDBC URL、用户名、密码是否正确。
- 图标或图表未显示：确认本机可以访问 Bootstrap、Bootstrap Icons、Chart.js 的 CDN。
- 这是课程原型项目，不是生产级银行系统。生产环境仍需要密码加密、细粒度权限控制、更强的风控、审计加固、多因素认证、限流与监控。
