package banksystem.dao;

import banksystem.model.RiskAssessment;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RiskAssessmentDao {
    public List<RiskAssessment> findVisible(int userId, boolean admin) {
        List<RiskAssessment> rows = new ArrayList<RiskAssessment>();
        String sql = admin
                ? "SELECT * FROM risk_assessments ORDER BY create_time DESC, assessment_id DESC"
                : "SELECT * FROM risk_assessments WHERE user_id = ? ORDER BY create_time DESC, assessment_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            if (!admin) {
                ps.setInt(1, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rows.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return rows;
    }

    public RiskAssessment findLatestByUserId(int userId) {
        String sql = "SELECT * FROM risk_assessments WHERE user_id = ? ORDER BY create_time DESC, assessment_id DESC LIMIT 1";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return null;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
        return null;
    }

    private RiskAssessment mapRow(ResultSet rs) throws SQLException {
        RiskAssessment row = new RiskAssessment();
        row.setAssessmentId(rs.getInt("assessment_id"));
        row.setUserId(rs.getInt("user_id"));
        row.setScore(rs.getInt("score"));
        row.setRiskLevel(rs.getString("risk_level"));
        row.setValidUntil(rs.getDate("valid_until"));
        row.setCreateTime(rs.getTimestamp("create_time"));
        return row;
    }
}
