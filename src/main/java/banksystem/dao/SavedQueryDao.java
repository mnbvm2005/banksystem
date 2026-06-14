package banksystem.dao;

import banksystem.model.SavedQuery;
import banksystem.sqloperation.GetMySQLConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SavedQueryDao {
    public List<SavedQuery> findByUserId(int userId) {
        List<SavedQuery> rows = new ArrayList<SavedQuery>();
        String sql = "SELECT * FROM saved_queries WHERE user_id = ? ORDER BY query_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
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

    public List<SavedQuery> findByUserIdAndType(int userId, String queryType) {
        List<SavedQuery> rows = new ArrayList<SavedQuery>();
        String sql = "SELECT * FROM saved_queries WHERE user_id = ? AND query_type = ? ORDER BY query_id DESC";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            return rows;
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, queryType);
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

    public void add(int userId, String queryName, String queryType, String queryCondition) throws SQLException {
        String sql = "INSERT INTO saved_queries(user_id, query_name, query_type, query_condition, create_time) "
                + "VALUES (?, ?, ?, ?, NOW())";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, queryName);
            ps.setString(3, queryType);
            ps.setString(4, queryCondition);
            ps.executeUpdate();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    public void deleteByIdAndUserId(int queryId, int userId) throws SQLException {
        String sql = "DELETE FROM saved_queries WHERE query_id = ? AND user_id = ?";
        Connection connection = GetMySQLConnection.getConnection();
        if (connection == null) {
            throw new SQLException("Database connection failed.");
        }
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, queryId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        } finally {
            GetMySQLConnection.closeConnection(connection);
        }
    }

    private SavedQuery mapRow(ResultSet rs) throws SQLException {
        SavedQuery row = new SavedQuery();
        row.setQueryId(rs.getInt("query_id"));
        row.setUserId(rs.getInt("user_id"));
        row.setQueryName(rs.getString("query_name"));
        row.setQueryType(rs.getString("query_type"));
        row.setQueryCondition(rs.getString("query_condition"));
        row.setCreateTime(rs.getTimestamp("create_time"));
        return row;
    }
}
