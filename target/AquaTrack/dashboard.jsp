
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.aquatrack.dao.WaterConsumptionDAO" %>

<%!
    // Escape user-provided text before displaying it
    public String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    // Check login session
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    String fullName = (String) session.getAttribute("fullName");
    String email = (String) session.getAttribute("email");

    BigDecimal todayTotal = BigDecimal.ZERO;
    BigDecimal monthlyTotal = BigDecimal.ZERO;

    // Fetch consumption totals from MySQL
    try {
        WaterConsumptionDAO waterDAO = new WaterConsumptionDAO();

        todayTotal = waterDAO.getTodayTotal(userId);
        monthlyTotal = waterDAO.getMonthlyTotal(userId);

        if (todayTotal == null) {
            todayTotal = BigDecimal.ZERO;
        }

        if (monthlyTotal == null) {
            monthlyTotal = BigDecimal.ZERO;
        }

    } catch (Exception e) {
        application.log("Error loading dashboard consumption data", e);
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>AquaTrack | Dashboard</title>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background-color: #f0f9ff;
            color: #222;
        }

        /* Header */

        header {
            background-color: #078bd0;
            color: white;
            padding: 22px 7.5%;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 28px;
            font-weight: bold;
        }

        .logo span {
            margin-right: 8px;
        }

        .header-links {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header-links a {
            text-decoration: none;
            padding: 11px 20px;
            border-radius: 7px;
            font-size: 15px;
            font-weight: bold;
        }

        .logout {
            color: #078bd0;
            background-color: white;
        }

        .logout:hover {
            background-color: #e6f5ff;
        }

        /* Main container */

        .container {
            width: 87%;
            max-width: 1500px;
            margin: 55px auto;
        }

        /* Welcome section */

        .welcome {
            background-color: white;
            padding: 55px 35px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.06);
            margin-bottom: 34px;
        }

        .welcome h1 {
            color: #078bd0;
            font-size: 36px;
            margin-bottom: 22px;
        }

        .welcome p {
            font-size: 18px;
            margin-bottom: 15px;
            line-height: 1.5;
        }

        /* Dashboard cards */

        .cards {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 22px;
        }

        .card {
            background-color: white;
            padding: 35px 28px;
            min-height: 230px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.06);
            transition: transform 0.2s;
        }

        .card:hover {
            transform: translateY(-5px);
        }

        .card h2 {
            color: #078bd0;
            font-size: 22px;
            margin-bottom: 20px;
        }

        .card p {
            font-size: 17px;
            line-height: 1.6;
            margin-bottom: 12px;
        }

        .amount {
            color: #078bd0;
            font-size: 30px;
            font-weight: bold;
            margin: 15px 0;
        }

        .card-link {
            display: inline-block;
            margin-top: 12px;
            margin-right: 5px;
            padding: 11px 18px;
            background-color: #078bd0;
            color: white;
            text-decoration: none;
            border-radius: 7px;
            font-size: 15px;
            font-weight: bold;
        }

        .card-link:hover {
            background-color: #006eaa;
        }

        /* Responsive design */

        @media (max-width: 950px) {

            .cards {
                grid-template-columns: repeat(2, 1fr);
            }

        }

        @media (max-width: 600px) {

            header {
                padding: 18px 5%;
            }

            .logo {
                font-size: 23px;
            }

            .container {
                width: 92%;
                margin: 30px auto;
            }

            .welcome {
                padding: 30px 22px;
            }

            .welcome h1 {
                font-size: 28px;
            }

            .cards {
                grid-template-columns: 1fr;
            }

            .card {
                padding: 30px 22px;
            }

        }

    </style>

</head>

<body>

    <!-- Header -->

    <header>

        <div class="logo">
            <span>💧</span>AquaTrack
        </div>

        <div class="header-links">

            <a class="logout"
               href="<%= request.getContextPath() %>/logout">
                Logout
            </a>

        </div>

    </header>


    <!-- Main Dashboard -->

    <div class="container">


        <!-- Welcome Section -->

        <section class="welcome">

            <h1>
                Welcome, <%= escapeHtml(fullName) %>!
            </h1>

            <p>
                Welcome to your Smart Water Consumption Monitoring System.
            </p>

            <p>
                Email: <%= escapeHtml(email) %>
            </p>

        </section>


        <!-- Dashboard Cards -->

        <section class="cards">


            <!-- Today's Water Consumption -->

            <div class="card">

                <h2>Water Consumption</h2>

                <p>Today's Consumption:</p>

                <div class="amount">
                    <%= todayTotal.stripTrailingZeros().toPlainString() %>
                    Litres
                </div>

                <p>
                    Monitor your daily water usage.
                </p>

                <a class="card-link"
                   href="<%= request.getContextPath() %>/water">
                    Add Consumption
                </a>

            </div>


            <!-- Monthly Usage History -->

            <div class="card">

                <h2>Usage History</h2>

                <p>This Month's Consumption:</p>

                <div class="amount">
                    <%= monthlyTotal.stripTrailingZeros().toPlainString() %>
                    Litres
                </div>

                <p>
                    View your previous consumption records.
                </p>

                <a class="card-link"
                   href="<%= request.getContextPath() %>/history">
                    View History
                </a>

            </div>


            <!-- Water Saving -->

            <div class="card">

                <h2>Water Saving</h2>

                <p>
                    Track your water-saving goals.
                </p>

                <p>
                    Make every drop count!
                </p>

                <a class="card-link"
                   href="<%= request.getContextPath() %>/analytics">
                    View Analytics
                </a>

                <a class="card-link"
                   href="<%= request.getContextPath() %>/reports">
                    View Reports
                </a>

            </div>


        </section>

    </div>

</body>

</html>
