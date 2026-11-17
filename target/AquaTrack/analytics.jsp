
<%@ page import="java.math.BigDecimal" %>
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
    // Check user session
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect(
            request.getContextPath() + "/login.jsp"
        );
        return;
    }

    // Retrieve analytics data
    Map<String, BigDecimal> categoryTotals =
        (Map<String, BigDecimal>)
        request.getAttribute("categoryTotals");

    BigDecimal overallTotal =
        (BigDecimal) request.getAttribute("overallTotal");

    String analyticsError =
        (String) request.getAttribute("analyticsError");

    if (categoryTotals == null) {
        categoryTotals = new LinkedHashMap<>();
    }

    if (overallTotal == null) {
        overallTotal = BigDecimal.ZERO;
    }

    // Prepare JSON arrays for charts
    StringBuilder labelsJson = new StringBuilder("[");
    StringBuilder valuesJson = new StringBuilder("[");

    int index = 0;

    for (Map.Entry<String, BigDecimal> entry :
            categoryTotals.entrySet()) {

        if (index > 0) {
            labelsJson.append(",");
            valuesJson.append(",");
        }

        // Escape category names for valid JSON
        String category = entry.getKey();

        String escapedCategory = category
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("<", "\\u003c")
            .replace(">", "\\u003e")
            .replace("&", "\\u0026");

        labelsJson.append("\"")
                  .append(escapedCategory)
                  .append("\"");

        valuesJson.append(entry.getValue().toPlainString());

        index++;
    }

    labelsJson.append("]");
    valuesJson.append("]");
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>AquaTrack | Analytics</title>

    <!-- Chart.js Library -->
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
            margin-bottom: 12px;
            font-size: 20px;
        }

        .total {
            color: #078bd0;
            font-size: 32px;
            font-weight: bold;
        }

        /* Charts */

        .charts {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 25px;
        }

        .chart-card {
            background: white;
            padding: 25px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.06);
            min-width: 0;
        }

        .chart-card h2 {
            color: #078bd0;
            font-size: 21px;
            margin-bottom: 20px;
        }

        .chart-container {
            position: relative;
            height: 330px;
        }

        /* Empty state */

        .empty {
            background: white;
            padding: 35px;
            border-radius: 14px;
            text-align: center;
            margin-bottom: 25px;
        }

        /* Error message */

        .error {
            color: #b42318;
            background: #fee4e2;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        /* Back button */

        .back-link {
            display: inline-block;
            margin-top: 25px;
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

        /* Responsive design */

        @media(max-width: 800px) {

            .charts {
                grid-template-columns: 1fr;
            }

            .container {
                width: 92%;
            }

            header {
                padding: 20px;
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


    <!-- Main content -->

    <div class="container">

        <div class="page-heading">

            <h1>Water Consumption Analytics</h1>

            <p>
                Understand your water usage category by category.
            </p>

        </div>


        <!-- Error message -->

        <% if (analyticsError != null) { %>

            <div class="error">
                <%= escapeHtml(analyticsError) %>
            </div>

        <% } %>


        <!-- Total consumption -->

        <div class="summary-card">

            <h2>Total Recorded Consumption</h2>

            <div class="total">
                <%= overallTotal.stripTrailingZeros().toPlainString() %>
                Litres
            </div>

        </div>


        <!-- Charts or empty state -->

        <% if (categoryTotals.isEmpty()) { %>

            <div class="empty">

                <h2>No Consumption Records Yet</h2>

                <p>
                    Add water consumption records to view analytics.
                </p>

                <a class="back-link"
                   href="<%= request.getContextPath() %>/water">
                    Add Consumption
                </a>

            </div>

        <% } else { %>

            <div class="charts">

                <!-- Pie chart -->

                <div class="chart-card">

                    <h2>Category-wise Usage</h2>

                    <div class="chart-container">

                        <canvas id="pieChart"></canvas>

                    </div>

                </div>


                <!-- Bar chart -->

                <div class="chart-card">

                    <h2>Consumption Comparison</h2>

                    <div class="chart-container">

                        <canvas id="barChart"></canvas>

                    </div>

                </div>

            </div>

        <% } %>


        <!-- Back to dashboard -->

        <a class="back-link"
           href="<%= request.getContextPath() %>/dashboard.jsp">
            Back to Dashboard
        </a>

    </div>


    <% if (!categoryTotals.isEmpty()) { %>

        <!-- Corrected JSON data transfer -->

        <div id="chartData"
             data-labels="<%= escapeHtml(labelsJson.toString()) %>"
             data-values="<%= escapeHtml(valuesJson.toString()) %>"
             hidden>
        </div>


        <script>

            // Read chart data from HTML attributes

            const chartDataElement =
                document.getElementById("chartData");

            const categoryLabels = JSON.parse(
                chartDataElement.dataset.labels
            );

            const categoryValues = JSON.parse(
                chartDataElement.dataset.values
            );


            // Check Chart.js availability

            if (typeof Chart === "undefined") {

                console.error("Chart.js library failed to load.");

            } else {


                // PIE CHART

                new Chart(
                    document.getElementById("pieChart"),
                    {

                        type: "pie",

                        data: {

                            labels: categoryLabels,

                            datasets: [{

                                label: "Water Consumption (Litres)",

                                data: categoryValues,

                                backgroundColor: [
                                    "#078bd0",
                                    "#36a2eb",
                                    "#4bc0c0",
                                    "#ffcd56",
                                    "#ff6384",
                                    "#9966ff"
                                ],

                                borderWidth: 2,

                                borderColor: "#ffffff"

                            }]

                        },

                        options: {

                            responsive: true,

                            maintainAspectRatio: false,

                            plugins: {

                                legend: {
                                    position: "bottom"
                                }

                            }

                        }

                    }
                );


                // BAR CHART

                new Chart(
                    document.getElementById("barChart"),
                    {

                        type: "bar",

                        data: {

                            labels: categoryLabels,

                            datasets: [{

                                label: "Consumption in Litres",

                                data: categoryValues,

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

                                        text: "Category"

                                    }

                                }

                            }

                        }

                    }
                );

            }

        </script>

    <% } %>

</body>

</html>
