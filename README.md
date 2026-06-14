# BankSystem + 上财小区生活缴费系统

本项目是一个基于 Java Web 的个人银行业务系统原型，并额外实现了一个极简外部生活缴费平台，用于演示“外部系统接入银行开放支付”的完整流程。

项目包含两个 Web 应用：

- `BankSystem`：主银行系统，提供账户、交易、转账、缴费、账单、理财、日志、通知、审批、风控、安全等银行业务原型功能。
- `CommunityPay`：外部生活缴费系统，系统名称为“上财小区生活缴费”，用于模拟小区水电燃气、通信、物业账单，并通过 BankSystem 开放支付接口完成缴费。

项目整体采用传统 Java Web 技术栈，目录结构接近 Eclipse Dynamic Web Project，不使用 Maven、Spring Boot，也没有做前后端分离。

## 技术栈

| 分类 | 技术 |
| --- | --- |
| 后端 | Java 8、Servlet、JSP、DAO、Model |
| 数据访问 | JDBC、PreparedStatement、MySQL Connector/J 8.0.28 |
| 数据库 | MySQL、InnoDB、事务、外键、审计表 |
| Web 容器 | Apache Tomcat 9 |
| 前端 | JSP、Bootstrap 5 CDN、Bootstrap Icons、Chart.js、原生 JavaScript、CSS |
| 架构 | MVC + DAO：Controller 处理请求，DAO 封装 SQL，Model 承载数据，JSP 渲染页面 |

项目目前没有独立 Service 层。业务逻辑主要分布在 Controller 与 DAO 中，其中 Controller 负责流程控制、校验、事务编排，DAO 负责数据库访问。

## 项目结构

```text
BankSystem/
├── src/main/java/banksystem/
│   ├── controller/          # BankSystem Servlet 控制器
│   ├── dao/                 # BankSystem DAO
│   ├── model/               # BankSystem Model
│   └── sqloperation/        # MySQL 连接工具
├── src/main/webapp/
│   ├── WEB-INF/web.xml      # BankSystem 路由配置
│   ├── WEB-INF/lib/         # MySQL Connector/J
│   ├── statics/             # CSS、JS、图标资源
│   └── views/               # JSP 页面
├── CommunityPay/
│   ├── src/main/java/communitypay/
│   │   ├── controller/      # 外部缴费系统 Servlet
│   │   ├── dao/             # 外部缴费系统 DAO
│   │   ├── model/           # 外部缴费系统 Model
│   │   └── util/            # 数据库连接、银行开放支付客户端
│   ├── src/main/webapp/
│   │   ├── WEB-INF/web.xml
│   │   ├── statics/css/community.css
│   │   └── views/
│   └── sql/community_pay.sql
├── sql/
│   ├── fincloud_bank_pro.sql
│   ├── fincloud_bank_pro_extra.sql
│   ├── fincloud_open_payment_extra.sql
│   └── banksystem.sql
└── README.md
```

## 数据库连接

BankSystem 默认连接：

```text
database = fincloud_bank_pro
url      = jdbc:mysql://127.0.0.1:3306/fincloud_bank_pro?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8
user     = root
password = @Asd984266
```

配置文件位置：

```text
src/main/java/banksystem/sqloperation/GetMySQLConnection.java
```

CommunityPay 默认连接：

```text
database = community_pay
url      = jdbc:mysql://127.0.0.1:3306/community_pay?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8
user     = root
password = @Asd984266
```

配置文件位置：

```text
CommunityPay/src/main/java/communitypay/util/CommunityDb.java
```

如果本地 MySQL 用户名、密码或端口不同，需要同步修改以上两个连接类。

## 数据库初始化

### 1. 初始化 BankSystem

执行：

```sql
source sql/fincloud_bank_pro.sql;
```

该脚本会创建 `fincloud_bank_pro` 数据库及完整演示数据。

如需追加更多演示交易、账单和预算数据，可执行：

```sql
source sql/fincloud_bank_pro_extra.sql;
```

### 2. 初始化开放支付扩展表

执行：

```sql
source sql/fincloud_open_payment_extra.sql;
```

该脚本会创建或补齐开放支付相关表：

- `merchant_apps`
- `external_payment_orders`
- `api_request_logs`

并初始化外部商户：

```text
merchant_name = 上财小区生活缴费系统
access_key    = FC_MERCHANT_001
secret_key    = FC_SECRET_001_123456
status        = ACTIVE
```

脚本还会补齐以下字段：

- `external_user_name`
- `external_user_no`
- `bank_login_account`
- `period`

并允许同一个外部账单号重复创建支付订单，便于课堂或答辩重复演示。

### 3. 初始化 CommunityPay

执行：

```sql
source CommunityPay/sql/community_pay.sql;
```

该脚本会创建 `community_pay` 数据库，并初始化：

- 小区住户账号
- 小区账单
- 支付事件表
- API 配置表

CommunityPay 演示住户：

```text
username           = xg1
password           = 123456
resident_name      = 信管1号同学
resident_no        = XM-001
bank_login_account = cuppy
status             = ACTIVE
```

## 演示账号

### BankSystem

```text
普通用户：cuppy / 123456
普通用户：alice / 123456
管理员：admin / admin123
```

常用演示账户：

```text
cuppy 主账户：6222000000000001
cuppy 另一账户：6222000000000004
演示收款账户：6222000000000002
```

### CommunityPay

```text
住户账号：xg1 / 123456
住户名称：信管1号同学
住户号：XM-001
绑定银行登录账号：cuppy
```

## BankSystem 功能

### 认证与用户

- 登录、登出、注册。
- Session 登录态管理。
- 登录设备记录。
- 认证审计记录。
- 用户状态校验。
- 管理员角色与普通用户角色。

### Dashboard

Dashboard 是主工作台，包含：

- 总资产概览。
- Monthly Inflow / Monthly Outflow。
- Recent Transactions，并支持分页，避免记录过多拉长页面。
- Quick Actions：
  - Deposit
  - Make a Transfer
  - Pay a Bill
  - 打开上财小区生活缴费
  - Notifications
  - Logs
- 图表展示。
- 与其他页面统一的深色/浅色分割背景风格。

### 账户管理

账户页展示：

- 账号。
- 账户类型。
- 币种。
- 余额。
- 可用余额。
- 冻结金额。
- 状态。
- 开户支行。
- 开户时间。

已修复账户卡片文字可读性问题，避免白字与背景重叠。

### 转账

转账流程包含：

- 收款账号输入。
- 常用收款人快捷填充。
- 金额输入。
- 备注输入。
- 转账确认弹窗。
- 后端余额校验。
- 后端账户状态校验。
- 收款账户存在性校验。
- 不能向同一账户转账。
- 单笔限额校验。
- JDBC 事务处理。
- 出账交易与入账交易。
- 借贷分录写入。
- 转账记录写入。
- 风险分数写入。
- 操作日志写入。
- 通知写入。

失败提示已补齐：

- 余额不足会显示：`余额不足，当前账户可用余额不足以完成本次转账。`
- 没有可用付款账户会显示中文提示。
- 收款账户不存在会显示：`收款账户不存在，转账失败。`
- 错误提示不会自动淡出。

### 存款与取款

存款和取款页面包含：

- 选择账户。
- 输入金额。
- 账户状态校验。
- 金额合法性校验。
- 余额更新。
- 交易记录写入。
- 分录写入。
- 操作日志写入。
- 通知写入。

### 普通缴费

BankSystem 内部缴费页面支持：

- 选择付款账户。
- 缴费类型。
- 缴费户号。
- 服务商。
- 金额。
- 余额校验。
- 账户状态校验。
- 支付记录写入。
- 交易记录写入。
- 分录写入。
- 校验记录写入。
- 操作日志写入。
- 通知写入。

失败提示已补齐：

- 余额不足会显示：`余额不足，当前账户可用余额不足以完成本次缴费。`
- 没有可用付款账户会显示中文提示。
- 错误提示不会自动淡出。

### 账单查询

账单页支持：

- 按账户筛选。
- 按账期类型筛选。
- 按开始日期和结束日期查询。
- 展示收入总额。
- 展示支出总额。
- 展示 Income vs Expense 图表。
- 展示分录明细。
- 页面样式已调整为更精致的银行风格，并避免右侧内容溢出。

### 交易流水

交易页支持：

- 展示全部可见交易。
- 统计总交易数。
- 总流入。
- 总流出。
- 待处理数量。
- 交易明细列表。
- 与 Dashboard 卡片风格统一。
- 图标与标题位置已调整。
- 金额字号、按钮、卡片布局已做适配，避免重叠。

### 理财

理财模块包含：

- 理财产品列表。
- 产品类型。
- 风险等级。
- 预期收益率。
- 起购金额。
- 产品期限。
- 购买入口。
- 风险评估提示。
- 余额校验。
- 持仓记录。
- 投资订单。

### 持仓

持仓页展示：

- 用户当前投资持仓。
- 产品信息。
- 持有金额。
- 收益金额。
- 持仓状态。
- 买入时间。

### 审批

审批页用于大额交易审批原型展示，包含：

- 审批记录。
- 审批状态。
- 审批人。
- 审批意见。
- 审批时间。

已修复 approval 403 访问问题。

### 日志

日志页展示系统操作日志：

- 操作用户。
- 操作类型。
- 对象类型。
- 对象 ID。
- 操作结果。
- IP 地址。
- 操作内容。
- 创建时间。

Dashboard Quick Actions 中已增加 Logs 入口。

### 通知

通知中心展示：

- 交易通知。
- 系统通知。
- 安全通知。
- 是否已读。
- 创建时间。

### 安全与风控

安全与风控相关页面包括：

- `/security`
- `/risk`
- `/blackbox`
- `/transaction/blackbox`

配套数据包括：

- `security_events`
- `transaction_risk_scores`
- `transaction_validations`
- `transaction_limit_rules`
- `login_devices`

### 管理后台

管理员入口：

```text
/admin
```

管理员可查看和维护部分基础数据，例如：

- 用户。
- 角色。
- 用户角色。
- 账户。
- 支行。
- 状态历史。
- 交易分类。
- 认证记录。
- 交易校验。
- 审批记录。

### 基础数据页面

系统还包含多个底层数据查看页面，用于展示数据库业务域，不作为主要业务入口：

- `/budgets`
- `/saved-queries`
- `/security`
- `/risk`
- `/daily-summaries`
- `/branches`
- `/categories`

这些页面用于“底层数据支撑”和“查漏补缺”，不是侧边栏里的主要业务菜单。

## CommunityPay 功能

CommunityPay 是外部系统，不属于银行内部页面。它模拟“上财小区生活缴费系统”，用于演示外部平台如何接入 BankSystem 的开放支付能力。

### 页面风格

CommunityPay 已单独设计为蓝白社区服务平台风格：

- 左侧海军蓝固定侧栏。
- 主体浅蓝白背景。
- 与银行系统类似的斜切分割背景，但使用小区系统自己的蓝色系。
- 白色半透明卡片。
- 蓝色渐变按钮。
- 蓝色系图标。
- 高级感卡片阴影。
- 移动端和窄屏适配。
- 账单行、状态卡、统计卡均已细化。

### 登录

路由：

```text
/CommunityPay/login
```

登录后 Session 中保存：

- `communityUser`
- `residentName`
- `residentNo`
- `bankLoginAccount`

当前演示住户：

```text
信管1号同学
住户号 XM-001
绑定银行账号 cuppy
```

### 待缴账单

路由：

```text
/CommunityPay/bills
```

功能：

- 只显示当前登录住户 `resident_no = XM-001` 的账单。
- 展示待缴账单数量。
- 展示本月应缴金额。
- 展示已缴账单数量。
- 展示即将到期数量。
- 所有账单都显示为“可缴费”，便于重复演示。
- 按钮文案为“跳转缴费”。
- 点击后跳转 BankSystem 开放支付收银台。

演示账单来自 `community_pay.utility_bills`：

| 类型 | 金额 | 服务商 |
| --- | ---: | --- |
| 电费 | 88.00 | 上财小区电力服务站 |
| 水费 | 36.50 | 上财小区水务服务站 |
| 燃气费 | 52.00 | 上财小区燃气服务站 |
| 通信费 | 59.00 | 上财小区通信服务站 |
| 物业费 | 180.00 | 上财小区物业服务中心 |

### 缴费记录

路由：

```text
/CommunityPay/records
```

功能：

- 展示当前住户的历史缴费记录。
- 包含已缴费、支付失败、支付中记录。
- 数据来自 `community_pay.utility_bills`。

### API 接入

路由：

```text
/CommunityPay/api
```

功能：

- 展示平台名称。
- 展示 access_key。
- secret_key 脱敏显示。
- 展示 BankSystem API Base。
- 展示签名算法说明。
- 展示最近 payment_events。

已修复 JSP 内置变量 `config` 命名冲突导致的 500 问题，当前页面正常访问。

### 缴费跳转

路由：

```text
/CommunityPay/pay?billNo=...
```

流程：

1. 根据 billNo 查询当前住户账单。
2. 校验账单属于当前 session 住户。
3. 调用 BankSystem `/api/open/payment/create`。
4. 请求中携带 AK/SK 签名。
5. 请求中携带外部用户和账单信息。
6. BankSystem 创建开放支付订单。
7. CommunityPay 写入 `payment_events`。
8. CommunityPay 将账单状态临时标记为 `PAYING`。
9. 跳转到 BankSystem 收银台。

为了便于重复演示，已允许已经支付过或演示过的账单再次发起新支付订单。

### 支付结果

路由：

```text
/CommunityPay/result
```

流程：

1. 接收 BankSystem 回跳参数。
2. 校验当前住户账单。
3. 使用 AK/SK 调用 BankSystem `/api/open/payment/status`。
4. 如果银行返回 `SUCCESS`：
   - 更新账单状态。
   - 写入银行交易号。
   - 写入 paid_time。
   - 写入 payment_events。
5. 如果失败：
   - 更新失败状态。
   - 展示失败结果。

## BankSystem 开放支付能力

BankSystem 为外部系统提供开放支付接口。

### 创建支付订单

```text
POST /BankSystem/api/open/payment/create
```

请求头：

```text
X-FC-AK
X-FC-Timestamp
X-FC-Nonce
X-FC-Signature
```

签名算法：

```text
HMAC-SHA256(method + path + timestamp + nonce + bodyHash)
```

请求字段：

```text
billNo
externalUserName
externalUserNo
bankLoginAccount
billType
providerName
customerNo
period
amount
subject
returnUrl
```

返回字段：

```text
success
payToken
payUrl
```

### 查询支付状态

```text
GET /BankSystem/api/open/payment/status?billNo=...
```

同样需要 AK/SK 签名。

返回：

```text
success
billNo
status
bankTransactionId
```

### 银行收银台

```text
/BankSystem/bankpay/checkout?payToken=...
/BankSystem/bankpay/confirm
```

收银台展示：

- 外部住户姓名。
- 住户号。
- 缴费类型。
- 服务商。
- 户号/房号。
- 账期。
- 金额。
- 银行付款账户。

支付前校验：

- 当前 BankSystem 登录用户必须匹配外部订单中的 `bank_login_account`。
- 匹配规则：银行登录用户名或手机号等于绑定账号。
- 当前用户必须有可用付款账户。
- 账户状态必须正常。
- 余额必须充足。

失败提示已补齐：

- 银行账号不匹配：提示切换银行账号。
- 没有可用付款账户：禁用确认按钮并显示中文提示。
- 余额不足：显示 `余额不足，当前账户可用余额不足以完成本次缴费。`

成功后写入：

- `transactions`
- `ledger_entries`
- `payment_records`
- `transaction_validations`
- `operation_logs`
- `notifications`
- `external_payment_orders`

并回跳 CommunityPay。

## 主要路由

### BankSystem

| URL | 功能 |
| --- | --- |
| `/login` | 登录 |
| `/register` | 注册 |
| `/logout` | 登出 |
| `/index`, `/dashboard` | Dashboard |
| `/account` | 账户 |
| `/transactions` | 交易流水 |
| `/blackbox`, `/transaction/blackbox` | 交易黑盒 |
| `/transfer` | 转账 |
| `/finance` | 理财产品 |
| `/deposit` | 存款 |
| `/withdraw` | 取款 |
| `/payment` | 银行内部缴费 |
| `/api/open/payment/create` | 开放支付创建订单 |
| `/api/open/payment/status` | 开放支付状态查询 |
| `/bankpay/checkout` | 外部支付银行收银台 |
| `/bankpay/confirm` | 外部支付确认 |
| `/bill` | 账单查询 |
| `/holding` | 理财持仓 |
| `/approval` | 审批 |
| `/logs` | 操作日志 |
| `/notifications` | 通知 |
| `/admin` | 管理后台 |
| `/budgets` | 预算数据 |
| `/saved-queries` | 保存查询 |
| `/security` | 安全事件 |
| `/risk` | 风险数据 |
| `/daily-summaries` | 账户日汇总 |
| `/branches` | 支行 |
| `/categories` | 交易分类 |

### CommunityPay

| URL | 功能 |
| --- | --- |
| `/CommunityPay/login` | 小区系统登录 |
| `/CommunityPay/logout` | 小区系统登出 |
| `/CommunityPay/bills` | 待缴账单 |
| `/CommunityPay/records` | 缴费记录 |
| `/CommunityPay/api` | API 接入说明 |
| `/CommunityPay/pay?billNo=...` | 发起银行支付 |
| `/CommunityPay/result` | 支付结果页 |

## 数据库表说明

### BankSystem 核心表

| 表名 | 用途 |
| --- | --- |
| `users` | 用户资料、登录名、实名信息、手机号、邮箱、状态 |
| `roles` | 角色 |
| `user_roles` | 用户角色关联 |
| `auth_records` | 登录认证审计 |
| `login_devices` | 登录设备 |
| `security_events` | 安全事件 |
| `bank_branches` | 支行 |
| `accounts` | 银行账户、余额、状态 |
| `account_status_histories` | 账户状态历史 |
| `account_daily_summaries` | 账户日汇总 |
| `payees` | 常用收款人 |
| `transaction_categories` | 交易分类 |
| `transactions` | 主交易流水 |
| `ledger_entries` | 借贷分录 |
| `transfer_records` | 转账详情 |
| `payment_records` | 缴费详情 |
| `transaction_limit_rules` | 交易限额规则 |
| `transaction_validations` | 交易校验 |
| `transaction_risk_scores` | 交易风险评分 |
| `transaction_approvals` | 交易审批 |
| `operation_logs` | 操作日志 |
| `notifications` | 通知 |
| `bills` | 账单汇总 |
| `bill_items` | 账单明细 |
| `user_budgets` | 用户预算 |
| `saved_queries` | 保存查询 |
| `financial_products` | 理财产品 |
| `risk_assessments` | 风险测评 |
| `investment_orders` | 理财订单 |
| `investment_holdings` | 理财持仓 |

### BankSystem 开放支付表

| 表名 | 用途 |
| --- | --- |
| `merchant_apps` | 外部商户应用 AK/SK |
| `external_payment_orders` | 外部支付订单 |
| `api_request_logs` | 开放 API 请求验签日志 |

### CommunityPay 表

| 表名 | 用途 |
| --- | --- |
| `community_users` | 小区住户账号、住户号、绑定银行账号 |
| `utility_bills` | 小区生活缴费账单 |
| `payment_events` | 小区支付事件 |
| `api_config` | 小区系统对接 BankSystem 的 AK/SK 配置 |

## 推荐演示流程

### 银行系统基础演示

1. 启动 MySQL。
2. 导入 BankSystem 数据库脚本。
3. 启动 Tomcat。
4. 访问 `http://localhost:8080/BankSystem/`。
5. 使用 `cuppy / 123456` 登录。
6. 查看 Dashboard。
7. 查看账户、交易流水。
8. 进入转账页，使用演示收款账号转账。
9. 回到交易流水查看记录。
10. 进入缴费页，做普通缴费。
11. 查看账单查询、日志、通知、持仓、审批等页面。

### 外部小区缴费演示

1. 启动 BankSystem。
2. 启动 CommunityPay。
3. 访问 `http://localhost:8080/CommunityPay/login`。
4. 使用 `xg1 / 123456` 登录。
5. 进入待缴账单页。
6. 点击任意账单的“跳转缴费”。
7. 系统调用 BankSystem 开放支付创建订单。
8. 页面进入 BankSystem 收银台。
9. 使用绑定银行账号 `cuppy` 登录 BankSystem。
10. 选择付款账户并确认支付。
11. BankSystem 完成扣款、写交易、写分录、写日志、写通知。
12. BankSystem 回跳 CommunityPay。
13. CommunityPay 调用银行状态查询接口确认支付结果。
14. CommunityPay 展示缴费结果。

### 失败场景演示

可以演示以下失败提示：

- BankSystem 转账余额不足。
- BankSystem 普通缴费余额不足。
- 小区缴费跳转银行后余额不足。
- 当前银行登录账号与小区绑定账号不一致。
- 当前用户没有可用付款账户。
- 收款账户不存在。

错误提示为红色提示块，不会自动淡出。

## 编译与部署

项目没有 Maven，需要使用 `javac` 或 IDE 编译。

### BankSystem 编译示例

```bash
javac -encoding UTF-8 \
  -cp /Users/cyl/dev/apache-tomcat-9.0.118/lib/servlet-api.jar:src/main/webapp/WEB-INF/lib/mysql-connector-java-8.0.28.jar \
  -d src/main/webapp/WEB-INF/classes \
  $(find src/main/java -name '*.java')
```

部署到 Tomcat：

```bash
cp -R src/main/webapp/* /Users/cyl/dev/apache-tomcat-9.0.118/webapps/BankSystem/
```

### CommunityPay 编译示例

```bash
javac -encoding UTF-8 \
  -cp /Users/cyl/dev/apache-tomcat-9.0.118/lib/servlet-api.jar:CommunityPay/src/main/webapp/WEB-INF/lib/mysql-connector-java-8.0.28.jar \
  -d CommunityPay/src/main/webapp/WEB-INF/classes \
  $(find CommunityPay/src/main/java -name '*.java')
```

部署到 Tomcat：

```bash
cp -R CommunityPay/src/main/webapp/* /Users/cyl/dev/apache-tomcat-9.0.118/webapps/CommunityPay/
```

### Tomcat 启动与停止

```bash
/Users/cyl/dev/apache-tomcat-9.0.118/bin/startup.sh
/Users/cyl/dev/apache-tomcat-9.0.118/bin/shutdown.sh
```

访问地址：

```text
BankSystem   http://127.0.0.1:8080/BankSystem/
CommunityPay http://127.0.0.1:8080/CommunityPay/login
```

如果浏览器访问 `localhost` 异常，可以使用 `127.0.0.1`。

## 页面与视觉调整记录

项目页面已经经过多轮细化：

- BankSystem 非 Dashboard 页面统一分割背景。
- Bill 页面改为更精致的账单查询布局。
- Transaction 页面卡片风格对齐 Dashboard。
- Recent Transactions 增加分页，避免页面被交易记录撑高。
- Quick Actions 增加 Logs。
- Account 卡片文字颜色修复。
- 登录页支持注册，并调整大标题字体与背景对比。
- 图标增加 tooltip。
- 所有用户可见页面尽量去除中文/英文混乱问题，README 当前使用中文说明。
- CommunityPay 使用蓝白社区服务平台风格。
- CommunityPay 账单按钮改为“跳转缴费”。
- CommunityPay 账单全部可重复缴费演示。
- CommunityPay 图标统一蓝色系并强制居中。
- CommunityPay 右侧状态卡宽度收窄，左侧账单大卡片自适应。
- CommunityPay API 页修复 JSP `config` 命名冲突。
- 错误提示补齐并禁止错误提示自动淡出。

## 常见问题

### 访问 `/BankSystem/index` 或 `/BankSystem/dashboard` 返回 404

确认：

- Tomcat 已启动。
- 应用部署目录为 `webapps/BankSystem`。
- `WEB-INF/web.xml` 已部署最新版本。
- 修改 Java 后已经重新编译。
- 修改 JSP/CSS 后已经重新复制到 Tomcat。

### CommunityPay `/api` 返回 500

曾经出现过 JSP 变量名 `config` 与 JSP 内置变量冲突。当前已改为 `apiConfig`。

如果浏览器仍显示旧错误：

1. 强刷页面。
2. 清理 Tomcat JSP 缓存：

```bash
find /Users/cyl/dev/apache-tomcat-9.0.118/work/Catalina/localhost/CommunityPay -type f -delete
```

3. 重新部署 CommunityPay。

### 修改 JSP 后页面仍是旧样式

Tomcat 可能仍在使用旧缓存：

- 重新复制 webapp 文件。
- 清理 `work/Catalina/localhost/...` 下的 JSP 编译缓存。
- 重启 Tomcat。

### 数据库表缺失

按顺序执行：

```sql
source sql/fincloud_bank_pro.sql;
source sql/fincloud_open_payment_extra.sql;
source CommunityPay/sql/community_pay.sql;
```

### 开放支付无法重复演示

确认已执行最新版：

```sql
source sql/fincloud_open_payment_extra.sql;
```

并确认 `external_payment_orders` 不再使用 `(merchant_id, bill_no)` 唯一索引阻止重复订单。

### 余额不足没有提示

当前已补齐：

- 转账余额不足提示。
- 普通缴费余额不足提示。
- 小区跳银行支付余额不足提示。
- 没有账户提示。

如果仍看不到，请确认 `src/main/webapp/statics/js/app.js` 已部署最新版本，错误提示不会自动淡出。

### 图标不显示

页面使用 Bootstrap Icons CDN：

```text
https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css
```

如果网络无法访问 CDN，图标会显示异常。

## 项目定位

这是课程/答辩/原型展示项目，不是生产级银行系统。

生产系统仍需要补充：

- 密码强哈希与盐值策略。
- MFA 多因素认证。
- 更细粒度权限控制。
- CSRF 防护。
- XSS 防护。
- 请求限流。
- 完整审计追踪。
- 幂等号机制。
- 支付回调签名验签加固。
- 数据脱敏。
- 异常监控。
- 生产日志体系。
- 自动化测试。

当前项目重点是：

- 展示 Java Web MVC + DAO 架构。
- 展示银行核心业务域。
- 展示数据库表之间的业务联系。
- 展示交易、分录、日志、通知的串联。
- 展示外部系统通过 AK/SK 签名接入银行支付。
- 展示前端页面的一致性和可演示性。
