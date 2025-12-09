<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Deposit Outcome</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 10px #ccc;
            max-width: 500px;
            margin: auto;
        }
        h2 {
            color: #2E8B57;
        }
        .error {
            color: red;
        }
        .info {
            font-size: 18px;
        }
        a.button {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 20px;
            background-color: #2E8B57;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        a.button:hover {
            background-color: #246b45;
        }
    </style>
</head>
<body>
<div class="container">
    <h2>Deposit Result</h2>

    <%
    String error = (String) request.getAttribute("error");
    if(error != null) {
    %>
    <p class="error"><%= error %></p>
    <%
    } else {
    int accountNumber = (Integer) request.getAttribute("accountNumber");
    double balance = (Double) request.getAttribute("balance");
    %>
    <p class="info">Account Number: <strong><%= accountNumber %></strong></p>
    <p class="info">Updated Balance: <strong>$<%= balance %></strong></p>
    <%
    }
    %>

    <a class="button" href="deposit.html">Make Another Deposit</a>
    <a class="button" href="dashboard.jsp">Back to Dashboard</a>
</div>
</body>
</html>
