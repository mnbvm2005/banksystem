package banksystem.model;

import java.math.BigDecimal;
import java.util.Date;

public class TransactionBlackBox {
    private int transactionId;
    private String transactionNo;
    private String username;
    private String realName;
    private String transactionType;
    private BigDecimal amount;
    private String transactionStatus;
    private String riskLevel;
    private boolean needApproval;
    private Date createTime;
    private String ledgerTrace;
    private String validationResult;
    private int riskScore;
    private String riskReason;
    private String approvalStatus;
    private int operationLogCount;

    public int getTransactionId() { return transactionId; }
    public void setTransactionId(int transactionId) { this.transactionId = transactionId; }
    public String getTransactionNo() { return transactionNo; }
    public void setTransactionNo(String transactionNo) { this.transactionNo = transactionNo; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getRealName() { return realName; }
    public void setRealName(String realName) { this.realName = realName; }
    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }
    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }
    public String getTransactionStatus() { return transactionStatus; }
    public void setTransactionStatus(String transactionStatus) { this.transactionStatus = transactionStatus; }
    public String getRiskLevel() { return riskLevel; }
    public void setRiskLevel(String riskLevel) { this.riskLevel = riskLevel; }
    public boolean isNeedApproval() { return needApproval; }
    public void setNeedApproval(boolean needApproval) { this.needApproval = needApproval; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public String getLedgerTrace() { return ledgerTrace; }
    public void setLedgerTrace(String ledgerTrace) { this.ledgerTrace = ledgerTrace; }
    public String getValidationResult() { return validationResult; }
    public void setValidationResult(String validationResult) { this.validationResult = validationResult; }
    public int getRiskScore() { return riskScore; }
    public void setRiskScore(int riskScore) { this.riskScore = riskScore; }
    public String getRiskReason() { return riskReason; }
    public void setRiskReason(String riskReason) { this.riskReason = riskReason; }
    public String getApprovalStatus() { return approvalStatus; }
    public void setApprovalStatus(String approvalStatus) { this.approvalStatus = approvalStatus; }
    public int getOperationLogCount() { return operationLogCount; }
    public void setOperationLogCount(int operationLogCount) { this.operationLogCount = operationLogCount; }
}
