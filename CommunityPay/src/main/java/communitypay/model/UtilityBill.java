package communitypay.model;

import java.math.BigDecimal;
import java.util.Date;

public class UtilityBill {
    private int billId;
    private String billNo;
    private String residentName;
    private String residentNo;
    private String billType;
    private String providerName;
    private String customerNo;
    private String period;
    private BigDecimal amount;
    private Date dueDate;
    private String status;
    private String bankPayToken;
    private Integer bankTransactionId;

    public int getBillId() { return billId; }
    public void setBillId(int billId) { this.billId = billId; }
    public String getBillNo() { return billNo; }
    public void setBillNo(String billNo) { this.billNo = billNo; }
    public String getResidentName() { return residentName; }
    public void setResidentName(String residentName) { this.residentName = residentName; }
    public String getResidentNo() { return residentNo; }
    public void setResidentNo(String residentNo) { this.residentNo = residentNo; }
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
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getBankPayToken() { return bankPayToken; }
    public void setBankPayToken(String bankPayToken) { this.bankPayToken = bankPayToken; }
    public Integer getBankTransactionId() { return bankTransactionId; }
    public void setBankTransactionId(Integer bankTransactionId) { this.bankTransactionId = bankTransactionId; }
}
