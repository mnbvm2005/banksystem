package communitypay.model;

public class ApiConfig {
    private String platformName;
    private String accessKey;
    private String secretKey;
    private String bankApiBase;

    public String getPlatformName() { return platformName; }
    public void setPlatformName(String platformName) { this.platformName = platformName; }
    public String getAccessKey() { return accessKey; }
    public void setAccessKey(String accessKey) { this.accessKey = accessKey; }
    public String getSecretKey() { return secretKey; }
    public void setSecretKey(String secretKey) { this.secretKey = secretKey; }
    public String getBankApiBase() { return bankApiBase; }
    public void setBankApiBase(String bankApiBase) { this.bankApiBase = bankApiBase; }
}
