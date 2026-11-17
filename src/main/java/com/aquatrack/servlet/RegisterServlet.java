
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

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (fullName == null || email == null ||
                password == null ||
                fullName.isBlank() ||
                email.isBlank() ||
                password.isBlank()) {

            response.sendRedirect(
                "register.jsp?status=invalid"
            );
            return;
        }

        try {

            if (userDAO.emailExists(email)) {
                response.sendRedirect(
                    "register.jsp?status=exists"
                );
                return;
            }

            String hashedPassword =
                PasswordUtil.hashPassword(password);

            User user = new User(
                fullName.trim(),
                email.trim(),
                hashedPassword
            );

            boolean registered =
                userDAO.registerUser(user);

            if (registered) {
                response.sendRedirect(
                    "register.jsp?status=success"
                );
            } else {
                response.sendRedirect(
                    "register.jsp?status=error"
                );
            }

        } catch (Exception e) {

            log("Registration failed", e);

            response.sendRedirect(
                "register.jsp?status=error"
            );
        }
    }
}   
