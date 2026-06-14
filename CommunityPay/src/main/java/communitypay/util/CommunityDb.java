package communitypay.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class CommunityDb {
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://127.0.0.1:3306/community_pay?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8";
    private static final String USER = "root";
    private static final String PASSWORD = "@Asd984266";

    private CommunityDb() {
    }

    public static Connection getConnection() {
        try {
            Class.forName(DRIVER);
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new IllegalStateException("MySQL driver is missing.", e);
        } catch (SQLException e) {
            throw new IllegalStateException("Cannot connect to community_pay.", e);
        }
    }

    public static void close(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException ignored) {
            }
        }
    }
}
