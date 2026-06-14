package communitypay.dao;

import communitypay.util.CommunityDb;
import communitypay.model.PaymentEvent;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PaymentEventDao {
    public void add(String billNo, String type, String content) {
        String sql = "INSERT INTO payment_events(bill_no, event_type, event_content, create_time) VALUES (?, ?, ?, NOW())";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, billNo);
            ps.setString(2, type);
            ps.setString(3, content);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
    }

    public List<PaymentEvent> findRecent(int limit) {
        List<PaymentEvent> events = new ArrayList<PaymentEvent>();
        String sql = "SELECT * FROM payment_events ORDER BY event_id DESC LIMIT ?";
        Connection connection = CommunityDb.getConnection();
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PaymentEvent event = new PaymentEvent();
                    event.setEventId(rs.getLong("event_id"));
                    event.setBillNo(rs.getString("bill_no"));
                    event.setEventType(rs.getString("event_type"));
                    event.setEventContent(rs.getString("event_content"));
                    event.setCreateTime(rs.getTimestamp("create_time"));
                    events.add(event);
                }
            }
        } catch (SQLException e) {
            throw new IllegalStateException(e);
        } finally {
            CommunityDb.close(connection);
        }
        return events;
    }
}
