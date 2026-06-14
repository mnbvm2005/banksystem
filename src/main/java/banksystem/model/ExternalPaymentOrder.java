package banksystem.model;

import java.math.BigDecimal;
import java.util.Date;

public class ExternalPaymentOrder {
    private int orderId;
    private int merchantId;
    private String billNo;
    private String payToken;
    private String externalUserName;
    private String externalUserNo;
    private String bankLoginAccount;
    private String billType;
    private String providerName;
    private String customerNo;
    private String period;
    private BigDecimal amount;
    private String subject;
    private String returnUrl;
    private String status;
    private Integer bankTransactionId;
    private Date createTime;
    private Date paidTime;

    public int getOrderId() { return orderId; }
    public void setOrderId(int orderId) { this.orderId = orderId; }
    public int getMerchantId() { return merchantId; }
    public void setMerchantId(int merchantId) { this.merchantId = merchantId; }
    public String getBillNo() { return billNo; }
    public void setBillNo(String billNo) { this.billNo = billNo; }
    public String getPayToken() { return payToken; }
    public void setPayToken(String payToken) { this.payToken = payToken; }
    public String getExternalUserName() { return externalUserName; }
    public void setExternalUserName(String externalUserName) { this.externalUserName = externalUserName; }
    public String getExternalUserNo() { return externalUserNo; }
    public void setExternalUserNo(String externalUserNo) { this.externalUserNo = externalUserNo; }
    public String getBankLoginAccount() { return bankLoginAccount; }
    public void setBankLoginAccount(String bankLoginAccount) { this.bankLoginAccount = bankLoginAccount; }
    public String getBillType() { return billType; }
    public void setBillType(String billType) { this.billType = billType; }
    public String getProviderName() { return providerName; }
    public void setProviderName(String providerName) { this.providerName = providerName; }
    public String getCustomerNo() { return customerNo; }
    public void setCustomerNo(String customerNo) { this.customerNo = customerNo; }
    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getReturnUrl() { return returnUrl; }
    public void setReturnUrl(String returnUrl) { this.returnUrl = returnUrl; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getBankTransactionId() { return bankTransactionId; }
    public void setBankTransactionId(Integer bankTransactionId) { this.bankTransactionId = bankTransactionId; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public Date getPaidTime() { return paidTime; }
    public void setPaidTime(Date paidTime) { this.paidTime = paidTime; }
}
