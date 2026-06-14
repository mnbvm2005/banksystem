package communitypay.dao;

import communitypay.model.ApiConfig;
import communitypay.util.CommunityDb;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class ApiConfigDao {
    public ApiConfig findActive() {
        String sql = "SELECT * FROM api_config WHERE status = 'ACTIVE' ORDER BY config_id LIMIT 1";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                ApiConfig config = new ApiConfig();
                config.setPlatformName(rs.getString("platform_name"));
                config.setAccessKey(rs.getString("access_key"));
                config.setSecretKey(rs.getString("secret_key"));
                config.setBankApiBase(rs.getString("bank_api_base"));
                return config;
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
        return null;
    }
}
