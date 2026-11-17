
package com.aquatrack.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Set;

import com.aquatrack.dao.WaterConsumptionDAO;
import com.aquatrack.model.WaterConsumption;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/water")
public class WaterServlet extends HttpServlet {

    private final WaterConsumptionDAO consumptionDAO =
            new WaterConsumptionDAO();

    private static final Set<String> VALID_CATEGORIES =
            Set.of(
                "Drinking",
                "Bathing",
                "Cooking",
                "Washing Clothes",
                "Cleaning",
                "Other"
            );

    // Display consumption form
    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        request.getRequestDispatcher(
            "/add-consumption.jsp"
        ).forward(request, response);
    }

    // Save consumption record
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);

        // Check authentication
        if (session == null ||
                session.getAttribute("userId") == null) {

            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        int userId = (Integer) session.getAttribute("userId");

        String category = request.getParameter("category");
        String amountInput = request.getParameter("amount");
        String notes = request.getParameter("notes");

        // Validate required fields
        if (category == null ||
                amountInput == null ||
                category.isBlank() ||
                amountInput.isBlank()) {

            redirect(request, response, "invalid");
            return;
        }

        category = category.trim();
        amountInput = amountInput.trim();

        // Validate category
        if (!VALID_CATEGORIES.contains(category)) {
            redirect(request, response, "invalid");
            return;
        }

        try {

            BigDecimal amount = new BigDecimal(amountInput);

            // Validate water quantity
            if (amount.compareTo(BigDecimal.ZERO) <= 0 ||
                    amount.compareTo(new BigDecimal("99999999.99")) > 0 ||
                    amount.scale() > 2) {

                redirect(request, response, "invalid");
                return;
            }

            // Validate notes
            if (notes != null) {
                notes = notes.trim();

                if (notes.length() > 255) {
                    redirect(request, response, "invalid");
                    return;
                }

                if (notes.isEmpty()) {
                    notes = null;
                }
            }

            WaterConsumption consumption =
                    new WaterConsumption(
                        userId,
                        category,
                        amount,
                        notes
                    );

            boolean saved =
                    consumptionDAO.addConsumption(consumption);

            if (saved) {

                redirect(request, response, "success");

            } else {

                redirect(request, response, "error");
            }

        } catch (NumberFormatException e) {

            redirect(request, response, "invalid");

        } catch (SQLException e) {

            getServletContext().log(
                "Error saving water consumption", e
            );

            redirect(request, response, "error");
        }
    }

    private void redirect(
            HttpServletRequest request,
            HttpServletResponse response,
            String status)
            throws IOException {

        response.sendRedirect(
            request.getContextPath() +
            "/add-consumption.jsp?status=" + status
        );
    }
}
