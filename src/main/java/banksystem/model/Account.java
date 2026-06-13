package banksystem.model;

import java.math.BigDecimal;
import java.util.Date;

public class Account {
    private int accountId;
    private int userId;
    private Integer branchId;
    private String accountNo;
    private String accountType;
    private String currency;
    private BigDecimal balance;
    private BigDecimal availableBalance;
    private BigDecimal frozenAmount;
    private String status;
    private Date openTime;
    private String branchName;

    public int getAccountId() {
        return accountId;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public int getId() {
        return accountId;
    }

    public void setId(int id) {
        this.accountId = id;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getBranchId() {
        return branchId;
    }

    public void setBranchId(Integer branchId) {
        this.branchId = branchId;
    }

    public String getAccountNo() {
        return accountNo;
    }

    public void setAccountNo(String accountNo) {
        this.accountNo = accountNo;
    }

    public String getAccountType() {
        return accountType;
    }

    public void setAccountType(String accountType) {
        this.accountType = accountType;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public BigDecimal getBalance() {
        return balance;
    }

    public void setBalance(BigDecimal balance) {
        this.balance = balance;
    }

    public BigDecimal getAvailableBalance() {
        return availableBalance;
    }

    public void setAvailableBalance(BigDecimal availableBalance) {
        this.availableBalance = availableBalance;
    }

    public BigDecimal getFrozenAmount() {
        return frozenAmount;
    }

    public void setFrozenAmount(BigDecimal frozenAmount) {
        this.frozenAmount = frozenAmount;
    }

    public int getStatus() {
        return isNormal() ? 1 : 0;
    }

    public String getAccountStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public void setStatus(int status) {
        this.status = status == 1 ? "NORMAL" : "FROZEN";
    }

    public boolean isNormal() {
        return "NORMAL".equals(status);
    }

    public Date getOpenTime() {
        return openTime;
    }

    public void setOpenTime(Date openTime) {
        this.openTime = openTime;
    }

    public Date getOpenedAt() {
        return openTime;
    }

    public void setOpenedAt(Date openedAt) {
        this.openTime = openedAt;
    }

    public String getBranchName() {
        return branchName;
    }

    public void setBranchName(String branchName) {
        this.branchName = branchName;
    }

    public String getBankName() {
        return branchName;
    }

    public void setBankName(String bankName) {
        this.branchName = bankName;
    }

    public String getReservedPhone() {
        return "";
    }

    public void setReservedPhone(String reservedPhone) {
    }
}
