<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.NumberFormat" %>
<%
    String outcome = (String) request.getAttribute("outcome");
    String message = (String) request.getAttribute("message");
    Double depositAmount = (Double) request.getAttribute("depositAmount");
    Double oldBalance = (Double) request.getAttribute("oldBalance");
    Double newBalance = (Double) request.getAttribute("newBalance");
    String transactionId = (String) request.getAttribute("transactionId");
    Object transactionDate = request.getAttribute("transactionDate");
    Integer accountNumber = (Integer) request.getAttribute("accountNumber");
    String accountHolder = (String) request.getAttribute("accountHolder");
    
    // Format currency
    NumberFormat zarFormat = java.text.NumberFormat.getCurrencyInstance();
    zarFormat.setCurrency(java.util.Currency.getInstance("ZAR"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>Deposit Outcome - MBank</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }
        
        body {
            background: linear-gradient(to right, #3498db, #2c3e50);
            color: #fff;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .outcome-container {
            background-color: rgba(0,0,0,0.8);
            padding: 40px;
            border-radius: 15px;
            width: 100%;
            max-width: 600px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
            text-align: center;
        }
        
        .outcome-icon {
            font-size: 80px;
            margin-bottom: 20px;
        }
        
        .success .outcome-icon { color: #2ecc71; }
        .error .outcome-icon { color: #e74c3c; }
        
        h1 {
            margin-bottom: 20px;
            font-size: 32px;
        }
        
        .message {
            font-size: 20px;
            margin-bottom: 30px;
            padding: 15px;
            border-radius: 8px;
            background: rgba(255,255,255,0.1);
        }
        
        .success .message { border-left: 5px solid #2ecc71; }
        .error .message { border-left: 5px solid #e74c3c; }
        
        .transaction-details {
            background: rgba(255,255,255,0.1);
            padding: 25px;
            border-radius: 10px;
            margin: 25px 0;
            text-align: left;
        }
        
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 12px;
            padding-bottom: 12px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }
        
        .detail-label {
            color: #f1c40f;
            font-weight: bold;
        }
        
        .detail-value {
            text-align: right;
        }
        
        .amount {
            font-size: 28px;
            font-weight: bold;
            margin: 20px 0;
        }
        
        .success .amount { color: #2ecc71; }
        
        .balance-change {
            display: flex;
            justify-content: space-around;
            margin: 25px 0;
            padding: 20px;
            background: rgba(255,255,255,0.05);
            border-radius: 8px;
        }
        
        .balance-box {
            text-align: center;
        }
        
        .balance-label {
            font-size: 14px;
            color: #bdc3c7;
            margin-bottom: 5px;
        }
        
        .balance-amount {
            font-size: 22px;
            font-weight: bold;
        }
        
        .arrow {
            font-size: 30px;
            color: #f1c40f;
            align-self: center;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
        }
        
        .btn {
            padding: 12px 30px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            font-size: 16px;
            transition: 0.3s;
            display: inline-block;
        }
        
        .btn-primary {
            background: #3498db;
            color: white;
        }
        
        .btn-secondary {
            background: #f1c40f;
            color: #2c3e50;
        }
        
        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        
        .btn-primary:hover { background: #2980b9; }
        .btn-secondary:hover { background: #d4ac0d; }
        
        .transaction-id {
            font-family: monospace;
            background: rgba(255,255,255,0.1);
            padding: 8px 15px;
            border-radius: 5px;
            display: inline-block;
            margin: 10px 0;
            letter-spacing: 1px;
        }
        
        @media (max-width: 768px) {
            .outcome-container {
                padding: 20px;
            }
            
            .balance-change {
                flex-direction: column;
                gap: 20px;
            }
            
            .arrow {
                transform: rotate(90deg);
            }
            
            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <div class="outcome-container <%= outcome %>">
        <div class="outcome-icon">
            <% if ("success".equals(outcome)) { %>
                ✓
            <% } else { %>
                ✗
            <% } %>
        </div>
        
        <h1><%= "success".equals(outcome) ? "Deposit Successful!" : "Deposit Failed" %></h1>
        
        <div class="message">
            <%= message %>
        </div>
        
        <% if ("success".equals(outcome) && depositAmount != null) { %>
            <div class="amount">+ <%= zarFormat.format(depositAmount) %></div>
            
            <div class="transaction-details">
                <div class="detail-row">
                    <span class="detail-label">Account Number:</span>
                    <span class="detail-value"><%= accountNumber != null ? accountNumber : "N/A" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Account Holder:</span>
                    <span class="detail-value"><%= accountHolder != null ? accountHolder : "N/A" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Transaction ID:</span>
                    <span class="detail-value transaction-id"><%= transactionId != null ? transactionId : "N/A" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Date & Time:</span>
                    <span class="detail-value"><%= transactionDate != null ? transactionDate : new java.util.Date() %></span>
                </div>
            </div>
            
            <div class="balance-change">
                <div class="balance-box">
                    <div class="balance-label">Previous Balance</div>
                    <div class="balance-amount"><%= oldBalance != null ? zarFormat.format(oldBalance) : "R0.00" %></div>
                </div>
                
                <div class="arrow">→</div>
                
                <div class="balance-box">
                    <div class="balance-label">New Balance</div>
                    <div class="balance-amount"><%= newBalance != null ? zarFormat.format(newBalance) : "R0.00" %></div>
                </div>
            </div>
        <% } %>
        
        <div class="action-buttons">
            <a href="dashboard.jsp" class="btn btn-primary">Back to Dashboard</a>
            <a href="deposit.jsp" class="btn btn-secondary">Make Another Deposit</a>
        </div>
    </div>
</body>
</html>