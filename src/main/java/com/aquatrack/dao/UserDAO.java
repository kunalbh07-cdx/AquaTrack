
package com.aquatrack.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import com.aquatrack.config.DatabaseConnection;
import com.aquatrack.model.User;

public class UserDAO {

    // Check whether email already exists
    public boolean emailExists(String email)
            throws Exception {

        String sql =
            "SELECT user_id FROM users WHERE email = ?";

        try (Connection con =
                    DatabaseConnection.getConnection();
             PreparedStatement ps =
                    con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // Register a new user
    public boolean registerUser(User user)
            throws Exception {

        String sql =
            "INSERT INTO users (full_name, email, password_hash) VALUES (?, ?, ?)";

        try (Connection con =
                    DatabaseConnection.getConnection();
             PreparedStatement ps =
                    con.prepareStatement(
                        sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());

            int rows = ps.executeUpdate();

            if (rows > 0) {
                try (ResultSet keys =
                        ps.getGeneratedKeys()) {

                    if (keys.next()) {
                        user.setUserId(keys.getInt(1));
                    }
                }
                return true;
            }
        }

        return false;
    }
    
    // Find user by email
    public User getUserByEmail(String email)
            throws Exception {

        String sql =
            "SELECT user_id, full_name, email, password_hash " +
            "FROM users WHERE email = ?";

        try (Connection con =
                    DatabaseConnection.getConnection();
             PreparedStatement ps =
                    con.prepareStatement(sql)) {

            ps.setString(1, email);

            try (ResultSet rs = ps.executeQuery()) {

                if (rs.next()) {

                    User user = new User();

                    user.setUserId(rs.getInt("user_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setPasswordHash(
                        rs.getString("password_hash")
                    );

                    return user;
                }
            }
        }

        return null;
    }

}
