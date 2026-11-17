
package com.aquatrack.servlet;

import java.io.IOException;

import com.aquatrack.dao.UserDAO;
import com.aquatrack.model.User;
import com.aquatrack.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null ||
                email.isBlank() || password.isBlank()) {

            response.sendRedirect(
                request.getContextPath() +
                "/login.jsp?status=invalid"
            );
            return;
        }

        try {

            User user = userDAO.getUserByEmail(email.trim());

            if (user != null &&
                    PasswordUtil.checkPassword(
                        password,
                        user.getPasswordHash()
                    )) {

                HttpSession oldSession = request.getSession(false);

                if (oldSession != null) {
                    oldSession.invalidate();
                }

                HttpSession session = request.getSession(true);

                session.setAttribute("userId", user.getUserId());
                session.setAttribute("fullName", user.getFullName());
                session.setAttribute("email", user.getEmail());

                session.setMaxInactiveInterval(30 * 60);

                response.sendRedirect(
                    request.getContextPath() +
                    "/dashboard.jsp"
                );

            } else {

                response.sendRedirect(
                    request.getContextPath() +
                    "/login.jsp?status=invalid"
                );
            }

        } catch (Exception e) {

            log("Login failed", e);

            response.sendRedirect(
                request.getContextPath() +
                "/login.jsp?status=error"
            );
        }
    }
}
