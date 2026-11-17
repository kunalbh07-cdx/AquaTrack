
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>

<%!
    // Escape HTML special characters
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

    // Retrieve report data
    Map<LocalDate, BigDecimal> dailyTotals =
        (Map<LocalDate, BigDecimal>)
        request.getAttribute("dailyTotals");

    BigDecimal totalConsumption =
        (BigDecimal) request.getAttribute("totalConsumption");

    LocalDate selectedDate =
        (LocalDate) request.getAttribute("selectedDate");

    LocalDate startDate =
        (LocalDate) request.getAttribute("startDate");

    LocalDate endDate =
        (LocalDate) request.getAttribute("endDate");

    String period = (String) request.getAttribute("period");

    String reportError =
        (String) request.getAttribute("reportError");

    if (dailyTotals == null) {
        dailyTotals = new LinkedHashMap<>();
    }

    if (totalConsumption == null) {
        totalConsumption = BigDecimal.ZERO;
    }

    if (selectedDate == null) {
        selectedDate = LocalDate.now();
    }

    if (startDate == null) {
        startDate = selectedDate;
    }

    if (endDate == null) {
        endDate = selectedDate;
    }

    if (period == null) {
        period = "weekly";
    }

    // Prepare chart JSON
    StringBuilder labelsJson = new StringBuilder("[");
    StringBuilder valuesJson = new StringBuilder("[");

    int index = 0;

    DateTimeFormatter chartDateFormat =
        DateTimeFormatter.ofPattern("dd MMM");

    for (Map.Entry<LocalDate, BigDecimal> entry :
            dailyTotals.entrySet()) {

        if (index > 0) {
            labelsJson.append(",");
            valuesJson.append(",");
        }

        String label =
            entry.getKey().format(chartDateFormat);

        labelsJson.append("\"")
                  .append(label)
                  .append("\"");

        valuesJson.append(entry.getValue().toPlainString());

        index++;
    }

    labelsJson.append("]");
    valuesJson.append("]");

    DateTimeFormatter inputDateFormat =
        DateTimeFormatter.ofPattern("yyyy-MM-dd");

    String selectedDateText =
        selectedDate.format(inputDateFormat);
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>AquaTrack | Consumption Reports</title>

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background: #f0f9ff;
            color: #222;
        }

        /* Header */

        header {
            background: #078bd0;
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

        .header-link {
            background: white;
            color: #078bd0;
            padding: 11px 18px;
            border-radius: 7px;
            text-decoration: none;
            font-weight: bold;
        }

        /* Main container */

        .container {
            width: 87%;
            max-width: 1400px;
            margin: 40px auto;
        }

        .page-heading {
            margin-bottom: 25px;
        }

        .page-heading h1 {
            color: #078bd0;
            font-size: 32px;
            margin-bottom: 10px;
        }

        .page-heading p {
            color: #555;
            font-size: 16px;
        }

        /* Filter card */

        .filter-card {
            background: white;
            padding: 25px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.06);
            margin-bottom: 25px;
        }

        .filter-card h2 {
            color: #078bd0;
            font-size: 21px;
            margin-bottom: 20px;
        }

        .filter-form {
            display: flex;
            align-items: end;
            flex-wrap: wrap;
            gap: 18px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 9px;
            min-width: 180px;
        }

        .form-group label {
            font-weight: bold;
            font-size: 14px;
        }

        select,
        input[type="date"] {
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 7px;
            font-size: 15px;
            background: white;
        }

        .filter-button {
            padding: 13px 22px;
            background: #078bd0;
            color: white;
            border: none;
            border-radius: 7px;
            cursor: pointer;
            font-size: 15px;
            font-weight: bold;
        }

        .filter-button:hover {
            background: #006eaa;
        }

        /* Summary card */

        .summary-card {
            background: white;
            padding: 28px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.06);
            margin-bottom: 25px;
        }

        .summary-card h2 {
            color: #078bd0;
            font-size: 20px;
            margin-bottom: 12px;
        }

        .total {
            color: #078bd0;
            font-size: 34px;
            font-weight: bold;
            margin-bottom: 10px;
        }

        .date-range {
            color: #666;
            font-size: 15px;
        }

        /* Chart */

        .chart-card {
            background: white;
            padding: 25px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.06);
            margin-bottom: 25px;
        }

        .chart-card h2 {
            color: #078bd0;
            font-size: 21px;
            margin-bottom: 20px;
        }

        .chart-container {
            position: relative;
            height: 380px;
        }

        /* Table */

        .table-card {
            background: white;
            padding: 25px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.06);
            margin-bottom: 25px;
            overflow-x: auto;
        }

        .table-card h2 {
            color: #078bd0;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }

        th {
            background: #e8f6ff;
            color: #078bd0;
        }

        /* Error */

        .error {
            background: #fee4e2;
            color: #b42318;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        /* Empty state */

        .empty {
            background: white;
            padding: 35px;
            border-radius: 14px;
            text-align: center;
            margin-bottom: 25px;
        }

        /* Navigation */

        .back-link {
            display: inline-block;
            margin-top: 10px;
            background: #078bd0;
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 7px;
            font-weight: bold;
        }

        .back-link:hover {
            background: #006eaa;
        }

        /* Responsive */

        @media(max-width: 800px) {

            .container {
                width: 92%;
            }

            header {
                padding: 20px;
            }

            .filter-form {
                flex-direction: column;
                align-items: stretch;
            }

            .form-group {
                width: 100%;
            }

            .chart-container {
                height: 300px;
            }

        }

    </style>

</head>

<body>

    <!-- Header -->

    <header>

        <div class="logo">
            💧 AquaTrack
        </div>

        <a class="header-link"
           href="<%= request.getContextPath() %>/dashboard.jsp">
            Dashboard
        </a>

    </header>


    <div class="container">

        <!-- Page heading -->

        <div class="page-heading">

            <h1>Water Consumption Reports</h1>

            <p>
                Analyse your daily, weekly and monthly water usage.
            </p>

        </div>


        <!-- Filter section -->

        <div class="filter-card">

            <h2>Generate Report</h2>

            <form class="filter-form"
                  action="<%= request.getContextPath() %>/reports"
                  method="get">

                <div class="form-group">

                    <label for="period">
                        Report Period
                    </label>

                    <select name="period" id="period">

                        <option value="daily"
                            <%= "daily".equals(period) ? "selected" : "" %>>
                            Daily
                        </option>

                        <option value="weekly"
                            <%= "weekly".equals(period) ? "selected" : "" %>>
                            Weekly
                        </option>

                        <option value="monthly"
                            <%= "monthly".equals(period) ? "selected" : "" %>>
                            Monthly
                        </option>

                    </select>

                </div>


                <div class="form-group">

                    <label for="date">
                        Select Date
                    </label>

                    <input type="date"
                           name="date"
                           id="date"
                           value="<%= selectedDateText %>"
                           required>

                </div>


                <button type="submit" class="filter-button">
                    Generate Report
                </button>

            </form>

        </div>


        <!-- Error message -->

        <% if (reportError != null) { %>

            <div class="error">
                <%= escapeHtml(reportError) %>
            </div>

        <% } else { %>


            <!-- Total consumption -->

            <div class="summary-card">

                <h2>
                    Total Water Consumption
                </h2>

                <div class="total">

                    <%= totalConsumption
                        .stripTrailingZeros()
                        .toPlainString() %>
                    Litres

                </div>

                <p class="date-range">

                    Report Period:

                    <%= startDate.format(
                        DateTimeFormatter.ofPattern("dd MMM yyyy")) %>

                    to

                    <%= endDate.format(
                        DateTimeFormatter.ofPattern("dd MMM yyyy")) %>

                </p>

            </div>


            <% if (dailyTotals.isEmpty()) { %>

                <div class="empty">

                    <h2>No Consumption Records</h2>

                    <p>
                        No water consumption records found for this period.
                    </p>

                </div>

            <% } else { %>


                <!-- Consumption chart -->

                <div class="chart-card">

                    <h2>Daily Consumption Comparison</h2>

                    <div class="chart-container">

                        <canvas id="reportChart"></canvas>

                    </div>

                </div>


                <!-- Daily records table -->

                <div class="table-card">

                    <h2>Consumption Details</h2>

                    <table>

                        <thead>

                            <tr>
                                <th>Date</th>
                                <th>Consumption (Litres)</th>
                            </tr>

                        </thead>

                        <tbody>

                            <% for (Map.Entry<LocalDate, BigDecimal> entry :
                                    dailyTotals.entrySet()) { %>

                                <tr>

                                    <td>
                                        <%= entry.getKey().format(
                                            DateTimeFormatter.ofPattern(
                                                "dd MMM yyyy")) %>
                                    </td>

                                    <td>
                                        <strong>
                                            <%= entry.getValue()
                                                .stripTrailingZeros()
                                                .toPlainString() %>
                                            L
                                        </strong>
                                    </td>

                                </tr>

                            <% } %>

                        </tbody>

                    </table>

                </div>

            <% } %>

        <% } %>


        <!-- Back button -->

        <a class="back-link"
           href="<%= request.getContextPath() %>/dashboard.jsp">
            Back to Dashboard
        </a>

    </div>


    <% if (reportError == null && !dailyTotals.isEmpty()) { %>

        <!-- Safely pass JSON through HTML attributes -->

        <div id="reportData"
             data-labels="<%= escapeHtml(labelsJson.toString()) %>"
             data-values="<%= escapeHtml(valuesJson.toString()) %>"
             hidden>
        </div>


        <script>

            const reportData =
                document.getElementById("reportData");

            const reportLabels =
                JSON.parse(reportData.dataset.labels);

            const reportValues =
                JSON.parse(reportData.dataset.values);


            if (typeof Chart !== "undefined") {

                new Chart(
                    document.getElementById("reportChart"),
                    {

                        type: "bar",

                        data: {

                            labels: reportLabels,

                            datasets: [{

                                label: "Water Consumption (Litres)",

                                data: reportValues,

                                backgroundColor: "#078bd0",

                                borderRadius: 6

                            }]

                        },

                        options: {

                            responsive: true,

                            maintainAspectRatio: false,

                            scales: {

                                y: {

                                    beginAtZero: true,

                                    title: {

                                        display: true,

                                        text: "Litres"

                                    }

                                },

                                x: {

                                    title: {

                                        display: true,

                                        text: "Date"

                                    }

                                }

                            }

                        }

                    }
                );

            } else {

                console.error(
                    "Chart.js library failed to load."
                );

            }

        </script>

    <% } %>

</body>

</html>
