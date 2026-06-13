package banksystem.model;

public class TransactionCategory {
    private int categoryId;
    private String categoryCode;
    private String categoryName;
    private String incomeExpenseType;
    private String description;

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryCode() {
        return categoryCode;
    }

    public void setCategoryCode(String categoryCode) {
        this.categoryCode = categoryCode;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getIncomeExpenseType() {
        return incomeExpenseType;
    }

    public void setIncomeExpenseType(String incomeExpenseType) {
        this.incomeExpenseType = incomeExpenseType;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

}