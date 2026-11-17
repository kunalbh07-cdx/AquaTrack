
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.aquatrack.model.WaterConsumption" %>

<%!
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
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    List<WaterConsumption> records =
        (List<WaterConsumption>) request.getAttribute("consumptionRecords");

    String errorMessage =
        (String) request.getAttribute("errorMessage");

    SimpleDateFormat dateFormat =
        new SimpleDateFormat("dd MMM yyyy, hh:mm a");
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>AquaTrack | Usage History</title>

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

        .header-links a {
            background: white;
            color: #078bd0;
            text-decoration: none;
            padding: 11px 18px;
            border-radius: 7px;
            margin-left: 10px;
            font-weight: bold;
        }

        .container {
            width: 87%;
            max-width: 1400px;
            margin: 45px auto;
        }

        .page-title {
            margin-bottom: 25px;
        }

        .page-title h1 {
            color: #078bd0;
            font-size: 32px;
            margin-bottom: 10px;
        }

        .page-title p {
            color: #555;
            font-size: 17px;
        }

        .history-card {
            background: white;
            padding: 30px;
            border-radius: 14px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.06);
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 650px;
        }

        th {
            background: #078bd0;
            color: white;
            padding: 16px;
            text-align: left;
        }

        td {
            padding: 16px;
            border-bottom: 1px solid #e5e5e5;
        }

        tr:hover {
            background: #f4faff;
        }

        .amount {
            color: #078bd0;
            font-weight: bold;
        }

        .empty {
            text-align: center;
            padding: 45px 15px;
            color: #666;
            font-size: 17px;
        }

        .error {
            background: #ffe8e8;
            color: #b42318;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .add-button {
            display: inline-block;
            margin-top: 25px;
            background: #078bd0;
            color: white;
            text-decoration: none;
            padding: 12px 20px;
            border-radius: 7px;
        }

        .add-button:hover {
            background: #006eaa;
        }

        @media(max-width: 600px) {
            header {
                padding: 18px;
            }

            .container {
                width: 94%;
                margin: 30px auto;
            }

            .history-card {
                padding: 15px;
            }

            .page-title h1 {
                font-size: 26px;
            }
        }
    </style>

</head>

<body>

    <header>

        <div class="logo">
            💧 AquaTrack
        </div>

        <div class="header-links">
            <a href="<%= request.getContextPath() %>/dashboard.jsp">
                Dashboard
            </a>

            <a href="<%= request.getContextPath() %>/logout">
                Logout
            </a>
        </div>

    </header>


    <div class="container">

        <div class="page-title">

            <h1>Usage History</h1>

            <p>
                View and monitor your previous water consumption records.
            </p>

        </div>


        <% if (errorMessage != null) { %>

            <div class="error">
                <%= escapeHtml(errorMessage) %>
            </div>

        <% } %>


        <div class="history-card">

            <% if (records != null && !records.isEmpty()) { %>

                <table>

                    <thead>
                        <tr>
                            <th>Record ID</th>
                            <th>Date & Time</th>
                            <th>Category</th>
                            <th>Amount (Litres)</th>
                            <th>Notes</th>
                        </tr>
                    </thead>

                    <tbody>

                        <% for (WaterConsumption record : records) { %>

                            <tr>

                                <td>
                                    <%= record.getConsumptionId() %>
                                </td>

                                <td>
                                    <%= record.getRecordedAt() != null
                                        ? dateFormat.format(record.getRecordedAt())
                                        : "N/A" %>
                                </td>

                                <td>
                                    <%= escapeHtml(record.getCategory()) %>
                                </td>

                                <td class="amount">
                                    <%= record.getAmountLiters() != null
                                        ? record.getAmountLiters().stripTrailingZeros().toPlainString()
                                        : "0" %>
                                </td>

                                <td>
                                    <%= escapeHtml(record.getNotes()) %>
                                </td>

                            </tr>

                        <% } %>

                    </tbody>

                </table>

            <% } else if (errorMessage == null) { %>

                <div class="empty">
                    <h3>No consumption records found.</h3>

                    <p>
                        Start recording your water consumption to see your history here.
                    </p>
                </div>

            <% } %>

        </div>


        <a class="add-button"
           href="<%= request.getContextPath() %>/water">
            + Add New Consumption
        </a>

    </div>

</body>

</html>
