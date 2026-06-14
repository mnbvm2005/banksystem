package communitypay.model;

import java.util.Date;

public class PaymentEvent {
    private long eventId;
    private String billNo;
    private String eventType;
    private String eventContent;
    private Date createTime;

    public long getEventId() { return eventId; }
    public void setEventId(long eventId) { this.eventId = eventId; }
    public String getBillNo() { return billNo; }
    public void setBillNo(String billNo) { this.billNo = billNo; }
    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
    public String getEventContent() { return eventContent; }
    public void setEventContent(String eventContent) { this.eventContent = eventContent; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}
