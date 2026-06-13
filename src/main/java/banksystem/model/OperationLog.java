package banksystem.model;

import java.util.Date;

public class OperationLog {
    private int logId;
    private Integer userId;
    private String operationType;
    private String objectType;
    private Integer objectId;
    private String operationContent;
    private String operationResult;
    private String ipAddress;
    private Date operationTime;

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getOperationType() {
        return operationType;
    }

    public void setOperationType(String operationType) {
        this.operationType = operationType;
    }

    public String getObjectType() {
        return objectType;
    }

    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    public String getTargetType() {
        return objectType;
    }

    public void setTargetType(String targetType) {
        this.objectType = targetType;
    }

    public Integer getObjectId() {
        return objectId;
    }

    public void setObjectId(Integer objectId) {
        this.objectId = objectId;
    }

    public Integer getTargetId() {
        return objectId;
    }

    public void setTargetId(Integer targetId) {
        this.objectId = targetId;
    }

    public String getOperationContent() {
        return operationContent;
    }

    public void setOperationContent(String operationContent) {
        this.operationContent = operationContent;
    }

    public String getDescription() {
        return operationContent;
    }

    public void setDescription(String description) {
        this.operationContent = description;
    }

    public String getOperationResult() {
        return operationResult;
    }

    public void setOperationResult(String operationResult) {
        this.operationResult = operationResult;
    }

    public String getResult() {
        return operationResult;
    }

    public void setResult(String result) {
        this.operationResult = result;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public Date getOperationTime() {
        return operationTime;
    }

    public void setOperationTime(Date operationTime) {
        this.operationTime = operationTime;
    }

    public Date getCreateTime() {
        return operationTime;
    }

    public void setCreateTime(Date createTime) {
        this.operationTime = createTime;
    }
}
