# BankSystem Brand Assets

Suggested asset layout:

```text
src/main/webapp/statics/assets/
├── logo/
│   ├── logo-wordmark-horizontal.svg
│   ├── logo-wordmark-horizontal-dark.svg
│   ├── logo-mark-transparent.svg
│   ├── logo-mark-square.svg
│   └── favicon.svg
└── icons/
    ├── icon-dashboard.svg
    ├── icon-account.svg
    ├── icon-transactions.svg
    ├── icon-transfer.svg
    ├── icon-finance.svg
    ├── icon-search.svg
    ├── icon-filter.svg
    ├── icon-calendar.svg
    ├── icon-user.svg
    ├── icon-shield.svg
    ├── icon-eye.svg
    ├── icon-eye-off.svg
    ├── icon-success.svg
    ├── icon-warning.svg
    ├── icon-error.svg
    └── icon-pending.svg
```

Recommended usage:

```jsp
<img src="${pageContext.request.contextPath}/statics/assets/logo/logo-wordmark-horizontal.svg" alt="BankSystem">
<img src="${pageContext.request.contextPath}/statics/assets/icons/icon-dashboard.svg" alt="" aria-hidden="true">
```

Palette:

```text
Primary #2563EB
Dark #0F172A
Background #F5F7FB
Text #111827
Muted #6B7280
Success #16A34A
Danger #DC2626
Warning #D97706
```
