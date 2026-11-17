
package com.aquatrack.servlet;

import java.io.IOException;
import java.util.List;

import com.aquatrack.dao.WaterConsumptionDAO;
import com.aquatrack.model.WaterConsumption;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/history")
public class HistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // Check login session
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

            // Retrieve records belonging to logged-in user
            List<WaterConsumption> records =
                    waterDAO.getConsumptionHistory(userId);

            // Pass records to JSP
            request.setAttribute("consumptionRecords", records);

            // Forward to history page
            request.getRequestDispatcher("/history.jsp")
                    .forward(request, response);

        } catch (Exception e) {

            getServletContext().log(
                    "Error loading consumption history", e);

            request.setAttribute(
                    "errorMessage",
                    "Unable to load consumption history.");

            request.getRequestDispatcher("/history.jsp")
                    .forward(request, response);
        }
    }
}
