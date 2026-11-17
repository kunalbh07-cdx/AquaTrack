
package com.aquatrack.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Map;

import com.aquatrack.dao.WaterConsumptionDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        // Check login session
        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(
                    request.getContextPath() + "/login.jsp");
            return;
        }

        Integer userId = (Integer) session.getAttribute("userId");

        try {

            WaterConsumptionDAO waterDAO =
                    new WaterConsumptionDAO();

            // Retrieve category-wise totals
            Map<String, BigDecimal> categoryTotals =
                    waterDAO.getCategoryTotals(userId);

            // Calculate overall consumption
            BigDecimal overallTotal = BigDecimal.ZERO;

            for (BigDecimal amount : categoryTotals.values()) {

                overallTotal = overallTotal.add(amount);
            }

            // Pass data to JSP
            request.setAttribute(
                    "categoryTotals", categoryTotals);

            request.setAttribute(
                    "overallTotal", overallTotal);

        } catch (SQLException e) {

            getServletContext().log(
                    "Error loading analytics", e);

            request.setAttribute(
                    "analyticsError",
                    "Unable to load consumption analytics.");

        }

        // Forward to analytics page
        request.getRequestDispatcher("/analytics.jsp")
                .forward(request, response);
    }
}
