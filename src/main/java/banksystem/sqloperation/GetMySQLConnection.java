package banksystem.sqloperation;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class GetMySQLConnection {
    private static final String DRIVER_NAME = "com.mysql.cj.jdbc.Driver";
    private static final String DEFAULT_URL = "jdbc:mysql://127.0.0.1:3306/fincloud_bank_pro?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8";
    private static final String DEFAULT_USERNAME = "root";
    private static final String DEFAULT_PASSWORD = "@Asd984266";

    private GetMySQLConnection() {
    }

    public static Connection getConnection() {
        String url = valueOrDefault(System.getenv("DB_URL"), DEFAULT_URL);
        String username = valueOrDefault(System.getenv("DB_USER"), DEFAULT_USERNAME);
        String password = valueOrDefault(System.getenv("DB_PASSWORD"), DEFAULT_PASSWORD);
        try {
            Class.forName(DRIVER_NAME);
            return DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException e) {
            System.err.println("Failed to load MySQL JDBC driver. Please check mysql-connector-java under WEB-INF/lib.");
            e.printStackTrace();
            return null;
        } catch (SQLException e) {
            System.err.println("MySQL database connection failed. Please check database name, URL, username, and password.");
            System.err.println("Current URL: " + url);
            System.err.println("Current username: " + username);
            e.printStackTrace();
            return null;
        }
    }

    private static String valueOrDefault(String value, String defaultValue) {
        if (value == null || value.trim().length() == 0) {
            return defaultValue;
        }
        return value.trim();
    }

    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}
