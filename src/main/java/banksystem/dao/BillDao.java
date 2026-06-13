package banksystem.dao;

import banksystem.model.Bill;
import banksystem.model.BillItem;
import banksystem.sqloperation.GetMySQLConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class BillDao {
    public Bill buildBill(int accountId, String billType, Date startDate, Date endDate) {
        String sql = "SELECT * FROM ledger_entries "
                + "WHERE account_id = ? AND DATE(entry_time) BETWEEN ? AND ? "
                + "ORDER BY entry_time DESC, entry_id DESC";
        Bill bill = new Bill();
        bill.setAccountId(accountId);
        bill.setBillType(billType);
        bill.setStartDate(startDate);
        bill.setEndDate(endDate);
        bill.setIncomeTotal(BigDecimal.ZERO);
        bill.setExpenseTotal(BigDecimal.ZERO);
        List<BillItem> items = new ArrayList<BillItem>();

        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            bill.setItems(items);
            return bill;
        }

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ps.setDate(2, startDate);
            ps.setDate(3, endDate);
            try (ResultSet rs = ps.executeQuery()) {
                BigDecimal income = BigDecimal.ZERO;
                BigDecimal expense = BigDecimal.ZERO;
                while (rs.next()) {
                    BillItem item = new BillItem();
                    item.setEntryId(rs.getInt("entry_id"));
                    item.setItemTime(rs.getTimestamp("entry_time"));
                    item.setAmount(rs.getBigDecimal("amount"));
                    item.setDirection(rs.getString("direction"));
                    items.add(item);
                    if ("IN".equals(item.getDirection())) {
                        income = income.add(item.getAmount());
                    } else {
                        expense = expense.add(item.getAmount());
                    }
                }
                bill.setIncomeTotal(income);
                bill.setExpenseTotal(expense);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }

        bill.setItems(items);
        return bill;
    }

    public int save(Connection connection, Bill bill) throws SQLException {
        String sql = "INSERT INTO bills "
                + "(account_id, bill_type, period_start, period_end, income_total, expense_total, net_amount, create_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, bill.getAccountId());
            ps.setString(2, normalizeBillType(bill.getBillType()));
            ps.setDate(3, new Date(bill.getStartDate().getTime()));
            ps.setDate(4, new Date(bill.getEndDate().getTime()));
            ps.setBigDecimal(5, bill.getIncomeTotal());
            ps.setBigDecimal(6, bill.getExpenseTotal());
            ps.setBigDecimal(7, bill.getIncomeTotal().subtract(bill.getExpenseTotal()));
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    private String normalizeBillType(String billType) {
        if ("DAY".equals(billType)) {
            return "DAILY";
        }
        if ("MONTH".equals(billType)) {
            return "MONTHLY";
        }
        if ("YEAR".equals(billType)) {
            return "YEARLY";
        }
        return billType;
    }
}
