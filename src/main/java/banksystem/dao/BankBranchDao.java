package banksystem.dao;

import banksystem.model.BankBranch;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class BankBranchDao {
    public List<BankBranch> findAll() {
        List<BankBranch> rows = new ArrayList<BankBranch>();
        String sql = "SELECT * FROM bank_branches ORDER BY branch_name ASC, branch_id ASC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                BankBranch row = new BankBranch();
                row.setBranchId(rs.getInt("branch_id"));
                row.setBranchCode(rs.getString("branch_code"));
                row.setBranchName(rs.getString("branch_name"));
                row.setCity(rs.getString("city"));
                row.setAddress(rs.getString("address"));
                row.setPhone(rs.getString("phone"));
                rows.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }
}
