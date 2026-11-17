
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Add Water Consumption | AquaTrack</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            background: #eff8ff;
            min-height: 100vh;
            color: #243447;
        }

        /* Navigation */
        .navbar {
            background: #0288d1;
            color: white;
            padding: 20px 7%;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .logo {
            font-size: 25px;
            font-weight: bold;
        }

        .nav-links a {
            color: white;
            text-decoration: none;
            margin-left: 20px;
            font-weight: bold;
        }

        /* Main container */
        .container {
            max-width: 650px;
            margin: 55px auto;
            padding: 0 20px;
        }

        .form-card {
            background: white;
            padding: 40px;
            border-radius: 14px;
            box-shadow: 0 5px 25px rgba(0,0,0,0.07);
        }

        h1 {
            color: #0288d1;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #718096;
            margin-bottom: 30px;
            line-height: 1.5;
        }

        /* Form */
        .form-group {
            margin-bottom: 22px;
        }

        label {
            display: block;
            margin-bottom: 9px;
            font-weight: 600;
        }

        input, select, textarea {
            width: 100%;
            padding: 13px;
            border: 1px solid #cbd5e0;
            border-radius: 7px;
            font-size: 15px;
            outline: none;
            background: white;
        }

        input:focus, select:focus, textarea:focus {
            border-color: #0288d1;
            box-shadow: 0 0 0 2px rgba(2,136,209,0.12);
        }

        textarea {
            resize: vertical;
            min-height: 100px;
        }

        .hint {
            display: block;
            margin-top: 7px;
            font-size: 12px;
            color: #718096;
        }

        /* Button */
        .submit-btn {
            width: 100%;
            padding: 15px;
            background: #0288d1;
            color: white;
            border: none;
            border-radius: 7px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: 0.3s;
        }

        .submit-btn:hover {
            background: #0277bd;
        }

        /* Alerts */
        .alert {
            padding: 13px;
            margin-bottom: 22px;
            border-radius: 7px;
            font-size: 14px;
        }

        .success {
            background: #e6f7ed;
            color: #18794e;
        }

        .error {
            background: #ffe9e9;
            color: #c62828;
        }

        .footer {
            text-align: center;
            margin-top: 25px;
        }

        .footer a {
            color: #0288d1;
            text-decoration: none;
            font-weight: bold;
        }

        @media (max-width: 600px) {
            .form-card {
                padding: 25px 20px;
            }

            .navbar {
                padding: 18px 5%;
            }
        }
    </style>
</head>

<body>

    <!-- Navigation -->
    <nav class="navbar">
        <div class="logo">💧 AquaTrack</div>

        <div class="nav-links">
            <a href="<%= request.getContextPath() %>/dashboard.jsp">
                Dashboard
            </a>

            <a href="<%= request.getContextPath() %>/logout">
                Logout
            </a>
        </div>
    </nav>

    <!-- Main content -->
    <div class="container">

        <div class="form-card">

            <h1>Record Water Consumption</h1>

            <p class="subtitle">
                Track your daily water usage and take a step
                towards a more sustainable lifestyle.
            </p>

            <!-- Status messages -->
            <%
                String status = request.getParameter("status");

                if ("success".equals(status)) {
            %>
                <div class="alert success">
                    Water consumption recorded successfully!
                </div>
            <%
                } else if ("invalid".equals(status)) {
            %>
                <div class="alert error">
                    Invalid input. Please check your details and try again.
                </div>
            <%
                } else if ("error".equals(status)) {
            %>
                <div class="alert error">
                    Unable to save your record. Please try again.
                </div>
            <%
                }
            %>

            <!-- Consumption form -->
            <form action="<%= request.getContextPath() %>/water"
                  method="POST">

                <!-- Category -->
                <div class="form-group">

                    <label for="category">
                        Water Usage Category
                    </label>

                    <select id="category" name="category" required>

                        <option value="">Select a category</option>

                        <option value="Drinking">Drinking</option>

                        <option value="Bathing">Bathing</option>

                        <option value="Cooking">Cooking</option>

                        <option value="Washing Clothes">
                            Washing Clothes
                        </option>

                        <option value="Cleaning">Cleaning</option>

                        <option value="Other">Other</option>

                    </select>

                </div>

                <!-- Amount -->
                <div class="form-group">

                    <label for="amount">
                        Water Consumed (Litres)
                    </label>

                    <input
                        type="number"
                        id="amount"
                        name="amount"
                        placeholder="Example: 25.50"
                        min="0.01"
                        max="99999999.99"
                        step="0.01"
                        required
                    >

                    <span class="hint">
                        Enter the amount of water consumed in litres.
                    </span>

                </div>

                <!-- Notes -->
                <div class="form-group">

                    <label for="notes">
                        Additional Notes (Optional)
                    </label>

                    <textarea
                        id="notes"
                        name="notes"
                        maxlength="255"
                        placeholder="Add any additional information..."
                    ></textarea>

                </div>

                <!-- Submit -->
                <button type="submit" class="submit-btn">
                    Save Consumption
                </button>

            </form>

            <div class="footer">
                <a href="<%= request.getContextPath() %>/dashboard.jsp">
                    ← Back to Dashboard
                </a>
            </div>

        </div>

    </div>

</body>
</html>
