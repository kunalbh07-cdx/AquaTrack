
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>AquaTrack | Create Account</title>

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
            margin-bottom: 10px;
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
            font-size: 14px;
        }

        label {
            display: block;
            margin-bottom: 7px;
            color: #37474f;
            font-size: 14px;
        }

        input {
            width: 100%;
            padding: 12px;
            margin-bottom: 18px;
            border: 1px solid #cfd8dc;
            border-radius: 7px;
            outline: none;
        }

        input:focus {
            border-color: #0288d1;
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
            margin-bottom: 15px;
            border-radius: 6px;
            font-size: 13px;
            display: none;
        }

        .success {
            background: #e8f5e9;
            color: #2e7d32;
        }

        .error {
            background: #ffebee;
            color: #c62828;
        }

        .login {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
        }

        .login a {
            color: #0288d1;
            text-decoration: none;
            font-weight: bold;
        }
    </style>
</head>

<body>

    <div class="container">

        <div class="logo">💧 AquaTrack</div>

        <h2>Create Account</h2>

        <p class="subtitle">
            Start monitoring your water consumption
        </p>

        <div id="message" class="message"></div>

        <form action="${pageContext.request.contextPath}/register"
              method="POST">

            <label>Full Name</label>
            <input type="text"
                   name="fullName"
                   placeholder="Enter your full name"
                   maxlength="100"
                   required>

            <label>Email Address</label>
            <input type="email"
                   name="email"
                   placeholder="Enter your email"
                   maxlength="150"
                   required>

            <label>Password</label>
            <input type="password"
                   name="password"
                   placeholder="Create a password"
                   minlength="8"
                   required>

            <button type="submit">Create Account</button>

        </form>

        <div class="login">
            Already have an account?
            <a href="login.jsp">Login</a>
        </div>

    </div>

    <script>
        const params = new URLSearchParams(window.location.search);
        const status = params.get("status");
        const message = document.getElementById("message");

        const messages = {
            success: ["Registration successful!", "success"],
            exists: ["This email is already registered.", "error"],
            invalid: ["Please complete all required fields.", "error"],
            error: ["Registration failed. Please try again.", "error"]
        };

        if (messages[status]) {
            message.textContent = messages[status][0];
            message.classList.add(messages[status][1]);
            message.style.display = "block";
        }
    </script>

</body>
</html>
