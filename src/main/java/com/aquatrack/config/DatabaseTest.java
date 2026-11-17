
package com.aquatrack.config;

import java.sql.Connection;
import java.sql.SQLException;

public class DatabaseTest {

    public static void main(String[] args) {

        System.out.println("Connecting to AquaTrack...");

        try (Connection connection =
                DatabaseConnection.getConnection()) {

            if (connection != null && connection.isValid(5)) {

                System.out.println(
                    "Database connected successfully!"
                );

                System.out.println(
                    "Database: " + connection.getCatalog()
                );

                System.out.println("Connection established!");
            }

        } catch (SQLException e) {

            System.out.println("Database connection failed!");
            e.printStackTrace();
        }
    }
}
