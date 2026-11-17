
package com.aquatrack.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.time.LocalDate;

import com.aquatrack.config.DatabaseConnection;
import com.aquatrack.model.WaterConsumption;
public class WaterConsumptionDAO {

    // 1. Add water consumption record
    public boolean addConsumption(WaterConsumption consumption)
            throws SQLException {

        String sql = "INSERT INTO water_consumption " +
                "(user_id, category, amount_liters, notes) " +
                "VALUES (?, ?, ?, ?)";

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, consumption.getUserId());
            ps.setString(2, consumption.getCategory());
            ps.setBigDecimal(3, consumption.getAmountLiters());
            ps.setString(4, consumption.getNotes());

            return ps.executeUpdate() == 1;
        }
    }

    // 2. Retrieve consumption history
    public List<WaterConsumption> getConsumptionHistory(int userId)
            throws SQLException {

        List<WaterConsumption> records = new ArrayList<>();

        String sql = "SELECT consumption_id, user_id, category, " +
                "amount_liters, notes, recorded_at " +
                "FROM water_consumption " +
                "WHERE user_id = ? " +
                "ORDER BY recorded_at DESC";

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    WaterConsumption consumption =
                            new WaterConsumption();

                    consumption.setConsumptionId(
                            rs.getInt("consumption_id"));

                    consumption.setUserId(
                            rs.getInt("user_id"));

                    consumption.setCategory(
                            rs.getString("category"));

                    consumption.setAmountLiters(
                            rs.getBigDecimal("amount_liters"));

                    consumption.setNotes(
                            rs.getString("notes"));

                    consumption.setRecordedAt(
                            rs.getTimestamp("recorded_at"));

                    records.add(consumption);
                }
            }
        }

        return records;
    }

    // 3. Calculate today's consumption
    public BigDecimal getTodayTotal(int userId)
            throws SQLException {

        String sql = "SELECT COALESCE(SUM(amount_liters), 0) " +
                "FROM water_consumption " +
                "WHERE user_id = ? " +
                "AND recorded_at >= CURDATE() " +
                "AND recorded_at < CURDATE() + INTERVAL 1 DAY";

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getBigDecimal(1);
                }
            }
        }

        return BigDecimal.ZERO;
    }

    // 4. Calculate monthly consumption
    public BigDecimal getMonthlyTotal(int userId)
            throws SQLException {

        String sql = "SELECT COALESCE(SUM(amount_liters), 0) AS total " +
                "FROM water_consumption " +
                "WHERE user_id = ? " +
                "AND YEAR(recorded_at) = YEAR(CURDATE()) " +
                "AND MONTH(recorded_at) = MONTH(CURDATE())";

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {
                    return rs.getBigDecimal("total");
                }
            }
        }

        return BigDecimal.ZERO;
    }

    // 5. Retrieve category-wise consumption totals
    public Map<String, BigDecimal> getCategoryTotals(int userId)
            throws SQLException {

        Map<String, BigDecimal> categoryTotals =
                new LinkedHashMap<>();

        String sql = "SELECT category, SUM(amount_liters) AS total " +
                "FROM water_consumption " +
                "WHERE user_id = ? " +
                "GROUP BY category " +
                "ORDER BY total DESC";

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {

                    String category = rs.getString("category");

                    BigDecimal total = rs.getBigDecimal("total");

                    categoryTotals.put(category, total);
                }
            }
        }

        return categoryTotals;
    }

public Map<LocalDate, BigDecimal> getConsumptionReport(
        int userId,
        LocalDate startDate,
        LocalDate endDate) throws SQLException {

    Map<LocalDate, BigDecimal> report = new LinkedHashMap<>();

    String sql =
        "SELECT DATE(recorded_at) AS consumption_date, " +
        "SUM(amount_liters) AS total_liters " +
        "FROM water_consumption " +
        "WHERE user_id = ? " +
        "AND recorded_at >= ? " +
        "AND recorded_at < ? " +
        "GROUP BY DATE(recorded_at) " +
        "ORDER BY consumption_date ASC";

    try (Connection con = DatabaseConnection.getConnection();
         PreparedStatement ps = con.prepareStatement(sql)) {

        ps.setInt(1, userId);
        ps.setDate(2, java.sql.Date.valueOf(startDate));
        ps.setDate(3, java.sql.Date.valueOf(endDate.plusDays(1)));

        try (ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                LocalDate consumptionDate =
                    rs.getDate("consumption_date").toLocalDate();

                BigDecimal total =
                    rs.getBigDecimal("total_liters");

                report.put(consumptionDate, total);
            }
        }
    }

    return report;
}

}
