package banksystem.model;

import java.math.BigDecimal;

public class FinancialProduct {
    private int id;
    private String productCode;
    private String productName;
    private String productType;
    private String riskLevel;
    private BigDecimal expectedAnnualRate;
    private BigDecimal minAmount;
    private int termDays;
    private int status;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getProductCode() {
        return productCode;
    }

    public void setProductCode(String productCode) {
        this.productCode = productCode;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

    public String getProductType() {
        return productType;
    }

    public void setProductType(String productType) {
        this.productType = productType;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public void setRiskLevel(String riskLevel) {
        this.riskLevel = riskLevel;
    }

    public BigDecimal getExpectedAnnualRate() {
        return expectedAnnualRate;
    }

    public void setExpectedAnnualRate(BigDecimal expectedAnnualRate) {
        this.expectedAnnualRate = expectedAnnualRate;
    }

    public BigDecimal getMinAmount() {
        return minAmount;
    }

    public void setMinAmount(BigDecimal minAmount) {
        this.minAmount = minAmount;
    }

    public int getTermDays() {
        return termDays;
    }

    public void setTermDays(int termDays) {
        this.termDays = termDays;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }
}
