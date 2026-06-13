package banksystem.model;

import java.util.Date;

public class Notification {
    private int notificationId;
    private int userId;
    private String title;
    private String content;
    private String notificationType;
    private boolean read;
    private Date createTime;
    private Date readTime;
    private String relatedType;
    private Integer relatedId;
    private String sendStatus;

    public int getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(String notificationType) {
        this.notificationType = notificationType;
    }

    public boolean isRead() {
        return read;
    }

    public void setRead(boolean read) {
        this.read = read;
    }

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Date getReadTime() {
        return readTime;
    }

    public void setReadTime(Date readTime) {
        this.readTime = readTime;
    }

    public String getRelatedType() {
        return relatedType;
    }

    public void setRelatedType(String relatedType) {
        this.relatedType = relatedType;
    }

    public Integer getRelatedId() {
        return relatedId;
    }

    public void setRelatedId(Integer relatedId) {
        this.relatedId = relatedId;
    }

    public String getNotificationContent() {
        return content;
    }

    public void setNotificationContent(String notificationContent) {
        this.content = notificationContent;
        if (this.title == null) {
            this.title = notificationContent == null || notificationContent.length() <= 20
                    ? notificationContent : notificationContent.substring(0, 20);
        }
    }

    public String getSendStatus() {
        return sendStatus;
    }

    public void setSendStatus(String sendStatus) {
        this.sendStatus = sendStatus;
    }

    public Date getSendTime() {
        return createTime;
    }

    public void setSendTime(Date sendTime) {
        this.createTime = sendTime;
    }
}
