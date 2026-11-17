
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    if (session.getAttribute("userId") != null) {
        response.sendRedirect(
            request.getContextPath() + "/dashboard.jsp"
        );
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>AquaTrack | Login</title>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }

        body {
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            background: linear-gradient(135deg, #e0f7fa, #bbdefb);
        }

        .container {
            width: 400px;
            max-width: calc(100% - 32px);
            background: white;
            padding: 35px;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.12);
        }

        .logo {
            text-align: center;
            font-size: 30px;
            font-weight: bold;
            color: #0288d1;
            margin-bottom: 20px;
        }

        h2 {
            text-align: center;
            margin-bottom: 10px;
            color: #263238;
        }

        .subtitle {
            text-align: center;
            color: #78909c;
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            color: #37474f;
        }

        input {
            width: 100%;
            padding: 12px;
            margin-bottom: 20px;
            border: 1px solid #cfd8dc;
            border-radius: 7px;
        }

        button {
            width: 100%;
            padding: 13px;
            border: none;
            border-radius: 7px;
            background: #0288d1;
            color: white;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }

        button:hover {
            background: #01579b;
        }

        .message {
            padding: 10px;
            margin-bottom: 18px;
            border-radius: 6px;
            display: none;
            font-size: 14px;
        }

        .error {
            background: #ffebee;
            color: #c62828;
        }

        .register {
            text-align: center;
            margin-top: 22px;
            font-size: 14px;
        }

        a {
            color: #0288d1;
            text-decoration: none;
            font-weight: bold;
        }
    </style>
</head>

<body>

<div class="container">

    <div class="logo">💧 AquaTrack</div>

    <h2>Welcome Back</h2>

    <p class="subtitle">
        Login to monitor your water consumption
    </p>

    <div id="message" class="message"></div>

    <form action="${pageContext.request.contextPath}/login"
          method="POST">

        <label>Email Address</label>
        <input type="email"
               name="email"
               placeholder="Enter your email"
               maxlength="150"
               required>

        <label>Password</label>
        <input type="password"
               name="password"
               placeholder="Enter your password"
               required>

        <button type="submit">Login</button>

    </form>

    <div class="register">
        Don't have an account?
        <a href="register.jsp">Register</a>
    </div>

</div>

<script>
    const params = new URLSearchParams(window.location.search);
    const status = params.get("status");
    const message = document.getElementById("message");

    if (status === "invalid") {
        message.textContent = "Invalid email or password.";
    } else if (status === "error") {
        message.textContent = "Login failed. Please try again.";
    }

    if (message.textContent) {
        message.classList.add("error");
        message.style.display = "block";
    }
</script>

</body>
</html>
