package banksystem.model;

import java.util.Date;

public class TransactionRiskScore {
    private int riskId;
    private int transactionId;
    private int riskScore;
    private String riskLevel;
    private String riskReason;
    private int ruleHitCount;
    private Date createTime;

    public int getRiskId() {
        return riskId;
    }

    public void setRiskId(int riskId) {
        this.riskId = riskId;
    }

    public int getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(int transactionId) {
        this.transactionId = transactionId;
    }

    public int getRiskScore() {
        return riskScore;
    }

    public void setRiskScore(int riskScore) {
        this.riskScore = riskScore;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public String getRiskReason() {
        return riskReason;
    }

    public void setRiskReason(String riskReason) {
        this.riskReason = riskReason;
    }

    public int getRuleHitCount() {
        return ruleHitCount;
    }

    public void setRuleHitCount(int ruleHitCount) {
        this.ruleHitCount = ruleHitCount;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

}