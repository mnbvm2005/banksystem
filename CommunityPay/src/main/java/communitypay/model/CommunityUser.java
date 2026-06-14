package communitypay.model;

public class CommunityUser {
    private long userId;
    private String username;
    private String passwordHash;
    private String residentName;
    private String residentNo;
    private String bankLoginAccount;
    private String status;

    public long getUserId() { return userId; }
    public void setUserId(long userId) { this.userId = userId; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getResidentName() { return residentName; }
    public void setResidentName(String residentName) { this.residentName = residentName; }
    public String getResidentNo() { return residentNo; }
    public void setResidentNo(String residentNo) { this.residentNo = residentNo; }
    public String getBankLoginAccount() { return bankLoginAccount; }
    public void setBankLoginAccount(String bankLoginAccount) { this.bankLoginAccount = bankLoginAccount; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
