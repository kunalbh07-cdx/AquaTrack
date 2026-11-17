
package com.aquatrack.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeParseException;
import java.time.temporal.TemporalAdjusters;
import java.util.LinkedHashMap;
import java.util.Map;

import com.aquatrack.dao.WaterConsumptionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/reports")
public class ReportsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Check login session
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        // Read report filters
        String period = request.getParameter("period");
        String dateParameter = request.getParameter("date");

        if (period == null || period.isBlank()) {
            period = "weekly";
        }

        LocalDate selectedDate;

        try {
            selectedDate = (dateParameter == null
                    || dateParameter.isBlank())
                    ? LocalDate.now()
                    : LocalDate.parse(dateParameter);

        } catch (DateTimeParseException e) {
            selectedDate = LocalDate.now();
        }

        // Validate report period
        if (!period.equals("daily")
                && !period.equals("weekly")
                && !period.equals("monthly")) {

            period = "weekly";
        }

        LocalDate startDate;
        LocalDate endDate;

        // Calculate report date range
        switch (period) {

            case "daily" -> {
                startDate = selectedDate;
                endDate = selectedDate;
            }

            case "monthly" -> {
                YearMonth month = YearMonth.from(selectedDate);

                startDate = month.atDay(1);
                endDate = month.atEndOfMonth();
            }

            default -> {
                startDate = selectedDate.with(
                    TemporalAdjusters.previousOrSame(
                        DayOfWeek.MONDAY
                    )
                );

                endDate = startDate.plusDays(6);
            }
        }

        try {

            WaterConsumptionDAO waterDAO =
                new WaterConsumptionDAO();

            Map<LocalDate, BigDecimal> dailyTotals =
                waterDAO.getConsumptionReport(
                    userId,
                    startDate,
                    endDate
                );

            // Calculate total consumption
            BigDecimal totalConsumption = BigDecimal.ZERO;

            for (BigDecimal amount : dailyTotals.values()) {
                totalConsumption = totalConsumption.add(amount);
            }

            // Fill missing dates with zero
            Map<LocalDate, BigDecimal> completeReport =
                new LinkedHashMap<>();

            for (LocalDate date = startDate;
                    !date.isAfter(endDate);
                    date = date.plusDays(1)) {

                completeReport.put(
                    date,
                    dailyTotals.getOrDefault(
                        date,
                        BigDecimal.ZERO
                    )
                );
            }

            request.setAttribute("dailyTotals", completeReport);
            request.setAttribute("totalConsumption", totalConsumption);
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("period", period);

        } catch (SQLException e) {

            getServletContext().log(
                "Error generating consumption report", e
            );

            request.setAttribute(
                "reportError",
                "Unable to generate the consumption report."
            );
        }

        request.getRequestDispatcher("/reports.jsp")
               .forward(request, response);
    }
}
