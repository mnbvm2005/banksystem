package banksystem.model;

import java.util.Date;

public class TransactionValidation {
    private int validationId;
    private Integer transactionId;
    private Integer accountId;
    private boolean amountValid;
    private boolean balanceSufficient;
    private boolean accountStatusValid;
    private boolean targetAccountValid;
    private String validationResult;
    private String rejectReason;
    private Date validationTime;

    public int getValidationId() {
        return validationId;
    }

    public void setValidationId(int validationId) {
        this.validationId = validationId;
    }

    public Integer getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(Integer transactionId) {
        this.transactionId = transactionId;
    }

    public Integer getAccountId() {
        return accountId;
    }

    public void setAccountId(Integer accountId) {
        this.accountId = accountId;
    }

    public boolean isAmountValid() {
        return amountValid;
    }

    public void setAmountValid(boolean amountValid) {
        this.amountValid = amountValid;
    }

    public boolean isBalanceSufficient() {
        return balanceSufficient;
    }

    public void setBalanceSufficient(boolean balanceSufficient) {
        this.balanceSufficient = balanceSufficient;
    }

    public boolean isAccountStatusValid() {
        return accountStatusValid;
    }

    public void setAccountStatusValid(boolean accountStatusValid) {
        this.accountStatusValid = accountStatusValid;
    }

    public boolean isTargetAccountValid() {
        return targetAccountValid;
    }

    public void setTargetAccountValid(boolean targetAccountValid) {
        this.targetAccountValid = targetAccountValid;
    }

    public String getValidationResult() {
        return validationResult;
    }

    public void setValidationResult(String validationResult) {
        this.validationResult = validationResult;
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public Date getValidationTime() {
        return validationTime;
    }

    public void setValidationTime(Date validationTime) {
        this.validationTime = validationTime;
    }
}
