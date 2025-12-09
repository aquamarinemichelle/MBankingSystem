<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.NumberFormat" %>
<%
    String outcome = (String) request.getAttribute("outcome");
    String message = (String) request.getAttribute("message");
    Double transferAmount = (Double) request.getAttribute("transferAmount");
    Double oldBalance = (Double) request.getAttribute("oldBalance");
    Double newBalance = (Double) request.getAttribute("newBalance");
    Double fee = (Double) request.getAttribute("fee");
    Double totalDebit = (Double) request.getAttribute("totalDebit");
    String transactionId = (String) request.getAttribute("transactionId");
    Object transactionDate = request.getAttribute("transactionDate");
    Integer fromAccountNumber = (Integer) request.getAttribute("fromAccountNumber");
    String fromAccountHolder = (String) request.getAttribute("fromAccountHolder");
    Integer toAccountNumber = (Integer) request.getAttribute("toAccountNumber");
    String toAccountHolder = (String) request.getAttribute("toAccountHolder");
    String description = (String) request.getAttribute("description");
    
    
    NumberFormat zarFormat = java.text.NumberFormat.getCurrencyInstance();
    zarFormat.setCurrency(java.util.Currency.getInstance("ZAR"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>Transfer Outcome - MBank</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }
        
        body {
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
            color: #fff;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        
        .outcome-container {
            background-color: rgba(0,0,0,0.9);
            padding: 40px;
            border-radius: 15px;
            width: 100%;
            max-width: 700px;
            box-shadow: 0 15px 35px rgba(0,0,0,0.7);
            text-align: center;
        }
        
        .outcome-icon {
            font-size: 80px;
            margin-bottom: 20px;
            animation: pulse 2s infinite;
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }
        
        .success .outcome-icon { 
            color: #2ecc71; 
            text-shadow: 0 0 20px rgba(46, 204, 113, 0.5);
        }
        .error .outcome-icon { 
            color: #e74c3c; 
            text-shadow: 0 0 20px rgba(231, 76, 60, 0.5);
        }
        
        h1 {
            margin-bottom: 20px;
            font-size: 32px;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.5);
        }
        
        .message {
            font-size: 20px;
            margin-bottom: 30px;
            padding: 15px;
            border-radius: 8px;
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
        }
        
        .success .message { 
            border-left: 5px solid #2ecc71;
            box-shadow: 0 0 15px rgba(46, 204, 113, 0.3);
        }
        .error .message { 
            border-left: 5px solid #e74c3c;
            box-shadow: 0 0 15px rgba(231, 76, 60, 0.3);
        }
        
        .transfer-visual {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin: 30px 0;
            padding: 25px;
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            position: relative;
        }
        
        .account-card {
            flex: 1;
            padding: 20px;
            background: rgba(255,255,255,0.1);
            border-radius: 10px;
            min-width: 200px;
            transition: transform 0.3s;
        }
        
        .account-card:hover {
            transform: translateY(-5px);
        }
        
        .sender-card {
            border: 2px solid #e74c3c;
        }
        
        .receiver-card {
            border: 2px solid #2ecc71;
        }
        
        .account-type {
            font-size: 14px;
            color: #bdc3c7;
            margin-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .account-number {
            font-size: 18px;
            font-weight: bold;
            margin: 10px 0;
            color: #f1c40f;
        }
        
        .account-holder {
            font-size: 16px;
            margin-bottom: 15px;
        }
        
        .transfer-arrow {
            font-size: 50px;
            color: #9b59b6;
            margin: 0 20px;
            animation: moveRight 2s infinite;
        }
        
        @keyframes moveRight {
            0%, 100% { transform: translateX(0); }
            50% { transform: translateX(10px); }
        }
        
        .amount-display {
            font-size: 36px;
            font-weight: bold;
            margin: 20px 0;
            padding: 20px;
            border-radius: 12px;
            background: linear-gradient(135deg, rgba(155, 89, 182, 0.3), rgba(142, 68, 173, 0.3));
            display: inline-block;
            min-width: 250px;
            border: 2px solid #9b59b6;
            box-shadow: 0 0 25px rgba(155, 89, 182, 0.4);
        }
        
        .transaction-details {
            background: rgba(255,255,255,0.1);
            padding: 25px;
            border-radius: 10px;
            margin: 25px 0;
            text-align: left;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255,255,255,0.2);
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
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .detail-value {
            text-align: right;
            font-weight: bold;
        }
        
        .fee-note {
            color: #e74c3c;
            font-size: 14px;
            margin-top: 5px;
        }
        
        .balance-summary {
            display: flex;
            justify-content: space-around;
            margin: 25px 0;
            padding: 20px;
            background: rgba(255,255,255,0.05);
            border-radius: 10px;
        }
        
        .balance-box {
            text-align: center;
            padding: 15px;
        }
        
        .balance-label {
            font-size: 14px;
            color: #bdc3c8;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .balance-amount {
            font-size: 22px;
            font-weight: bold;
        }
        
        .balance-old { color: #e74c3c; }
        .balance-new { color: #2ecc71; }
        
        .receipt-section {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid rgba(255,255,255,0.1);
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            font-size: 16px;
            transition: all 0.3s;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            border: none;
            cursor: pointer;
            min-width: 180px;
        }
        
        .btn i {
            font-size: 20px;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #3498db, #2980b9);
            color: white;
        }
        
        .btn-secondary {
            background: linear-gradient(135deg, #9b59b6, #8e44ad);
            color: white;
        }
        
        .btn-success {
            background: linear-gradient(135deg, #2ecc71, #27ae60);
            color: white;
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
        }
        
        .btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            filter: brightness(110%);
        }
        
        .transaction-id {
            font-family: 'Courier New', monospace;
            background: rgba(255,255,255,0.1);
            padding: 10px 20px;
            border-radius: 5px;
            display: inline-block;
            margin: 10px 0;
            letter-spacing: 1px;
            font-weight: bold;
            border: 1px solid rgba(255,255,255,0.3);
        }
        
        .printable-receipt {
            display: none;
        }
        
        @media print {
            body {
                background: white !important;
                color: black !important;
            }
            
            .outcome-container {
                box-shadow: none !important;
                background: white !important;
                color: black !important;
                width: 100% !important;
                max-width: none !important;
            }
            
            .btn, .action-buttons, .receipt-section {
                display: none !important;
            }
        }
        
        @media (max-width: 768px) {
            .outcome-container {
                padding: 20px;
            }
            
            .transfer-visual {
                flex-direction: column;
                gap: 20px;
            }
            
            .transfer-arrow {
                transform: rotate(90deg);
                margin: 10px 0;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
   
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script>
        function printReceipt() {
            const receipt = document.getElementById('printable-receipt');
            receipt.style.display = 'block';
            window.print();
            setTimeout(() => {
                receipt.style.display = 'none';
            }, 100);
        }
        
        function downloadPDF() {
            const element = document.getElementById('printable-receipt');
            element.style.display = 'block';
            
            const opt = {
                margin:       10,
                filename:     'MBank_Transfer_<%= transactionId %>.pdf',
                image:        { type: 'jpeg', quality: 0.98 },
                html2canvas:  { scale: 2, useCORS: true },
                jsPDF:        { unit: 'mm', format: 'a4', orientation: 'portrait' }
            };
            
            html2pdf().set(opt).from(element).save().then(() => {
                element.style.display = 'none';
            });
        }
    </script>
</head>
<body>
    <div class="outcome-container <%= outcome %>">
        <div class="outcome-icon">
            <% if ("success".equals(outcome)) { %>
                <i class="fas fa-exchange-alt"></i>
            <% } else { %>
                <i class="fas fa-times-circle"></i>
            <% } %>
        </div>
        
        <h1><%= "success".equals(outcome) ? "Transfer Successful!" : "Transfer Failed" %></h1>
        
        <div class="message">
            <i class="fas fa-info-circle"></i> <%= message %>
        </div>
        
        <% if ("success".equals(outcome) && transferAmount != null) { %>
            <div class="amount-display">
                <%= zarFormat.format(transferAmount) %>
            </div>
            
            <div class="transfer-visual">
                <div class="account-card sender-card">
                    <div class="account-type">
                        <i class="fas fa-user-circle"></i> From
                    </div>
                    <div class="account-number">
                        #<%= fromAccountNumber %>
                    </div>
                    <div class="account-holder">
                        <%= fromAccountHolder %>
                    </div>
                    <div style="color: #e74c3c; font-weight: bold;">
                        <i class="fas fa-arrow-down"></i> Debit
                    </div>
                </div>
                
                <div class="transfer-arrow">
                    <i class="fas fa-long-arrow-alt-right"></i>
                </div>
                
                <div class="account-card receiver-card">
                    <div class="account-type">
                        <i class="fas fa-user-friends"></i> To
                    </div>
                    <div class="account-number">
                        #<%= toAccountNumber %>
                    </div>
                    <div class="account-holder">
                        <%= toAccountHolder %>
                    </div>
                    <div style="color: #2ecc71; font-weight: bold;">
                        <i class="fas fa-arrow-up"></i> Credit
                    </div>
                </div>
            </div>
            
            <div class="transaction-details">
                <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-receipt"></i> Transaction ID:
                    </span>
                    <span class="detail-value transaction-id">
                        <%= transactionId != null ? transactionId : "N/A" %>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-calendar"></i> Date & Time:
                    </span>
                    <span class="detail-value">
                        <%= transactionDate != null ? transactionDate : new java.util.Date() %>
                    </span>
                </div>
                <% if (description != null && !description.trim().isEmpty()) { %>
                <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-sticky-note"></i> Description:
                    </span>
                    <span class="detail-value">
                        <%= description %>
                    </span>
                </div>
                <% } %>
                <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-money-bill-wave"></i> Transfer Amount:
                    </span>
                    <span class="detail-value">
                        <%= zarFormat.format(transferAmount) %>
                    </span>
                </div>
                <% if (fee != null && fee > 0) { %>
                <div class="detail-row">
                    <span class="detail-label">
                        <i class="fas fa-percentage"></i> Transfer Fee:
                    </span>
                    <span class="detail-value" style="color: #e74c3c;">
                        <%= zarFormat.format(fee) %>
                        <div class="fee-note">(Applies for transfers over R1,000)</div>
                    </span>
                </div>
                <div class="detail-row" style="border-top: 2px solid rgba(255,255,255,0.2); padding-top: 15px; font-size: 18px;">
                    <span class="detail-label">
                        <i class="fas fa-calculator"></i> Total Debit:
                    </span>
                    <span class="detail-value" style="color: #e74c3c; font-size: 20px;">
                        <%= zarFormat.format(totalDebit) %>
                    </span>
                </div>
                <% } %>
            </div>
            
            <div class="balance-summary">
                <div class="balance-box">
                    <div class="balance-label">Your Balance Before</div>
                    <div class="balance-amount balance-old">
                        <%= oldBalance != null ? zarFormat.format(oldBalance) : "R0.00" %>
                    </div>
                </div>
                
                <div style="align-self: center; font-size: 30px; color: #f1c40f;">
                    <i class="fas fa-arrow-right"></i>
                </div>
                
                <div class="balance-box">
                    <div class="balance-label">Your Balance After</div>
                    <div class="balance-amount balance-new">
                        <%= newBalance != null ? zarFormat.format(newBalance) : "R0.00" %>
                    </div>
                </div>
            </div>
            
            <div class="receipt-section">
                <div id="printable-receipt" class="printable-receipt">
                    <h2 style="text-align: center; color: #2c3e50; margin-bottom: 20px;">MBank Transfer Receipt</h2>
                    <div style="border: 2px solid #000; padding: 20px; border-radius: 10px;">
                        <table style="width: 100%; border-collapse: collapse;">
                            <tr>
                                <td colspan="2" style="text-align: center; padding-bottom: 15px; border-bottom: 2px solid #000;">
                                    <strong style="font-size: 18px;">INTER-BANK TRANSFER</strong>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Transaction ID:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= transactionId %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Date & Time:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= transactionDate %></td>
                            </tr>
                            <tr>
                                <td colspan="2" style="padding: 15px 10px; border-bottom: 2px dashed #000;">
                                    <strong>FROM ACCOUNT:</strong>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;">Account Number:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= fromAccountNumber %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;">Account Holder:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= fromAccountHolder %></td>
                            </tr>
                            <tr>
                                <td colspan="2" style="padding: 15px 10px; border-bottom: 2px dashed #000;">
                                    <strong>TO ACCOUNT:</strong>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;">Account Number:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= toAccountNumber %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;">Account Holder:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= toAccountHolder %></td>
                            </tr>
                            <tr>
                                <td colspan="2" style="padding: 15px 10px; border-bottom: 2px dashed #000;">
                                    <strong>TRANSACTION DETAILS:</strong>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;">Transfer Amount:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right; font-weight: bold;">
                                    <%= zarFormat.format(transferAmount) %>
                                </td>
                            </tr>
                            <% if (fee != null && fee > 0) { %>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;">Transfer Fee:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;">
                                    <%= zarFormat.format(fee) %>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; font-weight: bold;">Total Debit:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right; font-weight: bold; color: #e74c3c;">
                                    <%= zarFormat.format(totalDebit) %>
                                </td>
                            </tr>
                            <% } %>
                            <% if (description != null && !description.trim().isEmpty()) { %>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;">Description:</td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= description %></td>
                            </tr>
                            <% } %>
                            <tr>
                                <td style="padding: 10px;">Previous Balance:</td>
                                <td style="padding: 10px; text-align: right;"><%= zarFormat.format(oldBalance) %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; font-weight: bold;">New Balance:</td>
                                <td style="padding: 10px; text-align: right; font-weight: bold;"><%= zarFormat.format(newBalance) %></td>
                            </tr>
                        </table>
                        <div style="margin-top: 30px; padding-top: 15px; border-top: 1px dashed #000; text-align: center;">
                            <p style="font-size: 12px; color: #7f8c8d;">
                                This is an electronic funds transfer receipt.<br>
                                Keep this receipt for your records.<br>
                                For queries: support@mbank.co.za | Phone: 0860 123 456
                            </p>
                        </div>
                    </div>
                </div>
                
                <div class="action-buttons">
                    <button onclick="downloadPDF()" class="btn btn-success">
                        <i class="fas fa-file-pdf"></i> Download PDF
                    </button>
                    <button onclick="printReceipt()" class="btn btn-secondary">
                        <i class="fas fa-print"></i> Print Receipt
                    </button>
                </div>
            </div>
        <% } %>
        
        <div class="action-buttons">
            <a href="dashboard.jsp" class="btn btn-primary">
                <i class="fas fa-home"></i> Dashboard
            </a>
            <% if ("success".equals(outcome)) { %>
                <a href="transfer.jsp" class="btn btn-secondary">
                    <i class="fas fa-redo"></i> Another Transfer
                </a>
            <% } else { %>
                <a href="transfer.jsp" class="btn btn-danger">
                    <i class="fas fa-redo"></i> Try Again
                </a>
            <% } %>
            <a href="statement.jsp" class="btn">
                <i class="fas fa-history"></i> View Statement
            </a>
        </div>
    </div>
</body>
</html>