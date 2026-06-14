package communitypay.dao;

import communitypay.model.CommunityUser;
import communitypay.util.CommunityDb;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CommunityUserDao {
    public CommunityUser findByUsername(String username) {
        String sql = "SELECT * FROM community_users WHERE username = ? AND status = 'ACTIVE'";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
    }

    private CommunityUser map(ResultSet rs) throws SQLException {
        CommunityUser user = new CommunityUser();
        user.setUserId(rs.getLong("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setResidentName(rs.getString("resident_name"));
        user.setResidentNo(rs.getString("resident_no"));
        user.setBankLoginAccount(rs.getString("bank_login_account"));
        user.setStatus(rs.getString("status"));
        return user;
    }
}
