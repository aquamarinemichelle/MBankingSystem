<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.NumberFormat" %>
<%
    String outcome = (String) request.getAttribute("outcome");
    String message = (String) request.getAttribute("message");
    Double withdrawAmount = (Double) request.getAttribute("withdrawAmount");
    Double oldBalance = (Double) request.getAttribute("oldBalance");
    Double newBalance = (Double) request.getAttribute("newBalance");
    String transactionId = (String) request.getAttribute("transactionId");
    Object transactionDate = request.getAttribute("transactionDate");
    Integer accountNumber = (Integer) request.getAttribute("accountNumber");
    String accountHolder = (String) request.getAttribute("accountHolder");
    
    
    NumberFormat zarFormat = java.text.NumberFormat.getCurrencyInstance();
    zarFormat.setCurrency(java.util.Currency.getInstance("ZAR"));
%>
<!DOCTYPE html>
<html>
<head>
    <title>Withdrawal Outcome - MBank</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Arial', sans-serif;
        }
        
        body {
            background: linear-gradient(to right, #e74c3c, #c0392b);
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
            max-width: 600px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.7);
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
        }
        
        .detail-value {
            text-align: right;
            font-weight: bold;
        }
        
        .amount-display {
            font-size: 36px;
            font-weight: bold;
            margin: 20px 0;
            padding: 15px;
            border-radius: 10px;
            background: rgba(255,255,255,0.1);
            display: inline-block;
            min-width: 200px;
        }
        
        .success .amount-display { 
            color: #2ecc71; 
            border: 2px solid #2ecc71;
            box-shadow: 0 0 20px rgba(46, 204, 113, 0.3);
        }
        .error .amount-display { 
            color: #e74c3c; 
            border: 2px solid #e74c3c;
        }
        
        .balance-change {
            display: flex;
            justify-content: space-around;
            align-items: center;
            margin: 25px 0;
            padding: 20px;
            background: rgba(255,255,255,0.05);
            border-radius: 8px;
            position: relative;
        }
        
        .balance-box {
            text-align: center;
            flex: 1;
            padding: 15px;
        }
        
        .balance-label {
            font-size: 14px;
            color: #bdc3c7;
            margin-bottom: 5px;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        
        .balance-amount {
            font-size: 24px;
            font-weight: bold;
        }
        
        .balance-before { color: #e74c3c; }
        .balance-after { color: #2ecc71; }
        
        .arrow {
            font-size: 40px;
            color: #f1c40f;
            animation: moveRight 2s infinite;
        }
        
        @keyframes moveRight {
            0%, 100% { transform: translateX(0); }
            50% { transform: translateX(10px); }
        }
        
        .receipt {
            background: rgba(255,255,255,0.05);
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
            border: 1px dashed rgba(255,255,255,0.2);
            text-align: left;
            backdrop-filter: blur(10px);
        }
        
        .receipt-title {
            text-align: center;
            color: #f1c40f;
            margin-bottom: 15px;
            font-size: 20px;
            border-bottom: 1px solid rgba(255,255,255,0.2);
            padding-bottom: 10px;
            text-transform: uppercase;
            letter-spacing: 2px;
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
            background: linear-gradient(135deg, #f1c40f, #d4ac0d);
            color: #2c3e50;
        }
        
        .btn-danger {
            background: linear-gradient(135deg, #e74c3c, #c0392b);
            color: white;
        }
        
        .btn-success {
            background: linear-gradient(135deg, #2ecc71, #27ae60);
            color: white;
        }
        
        .btn:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.3);
            filter: brightness(110%);
        }
        
        .btn:active {
            transform: translateY(-2px);
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
        
        .print-section {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid rgba(255,255,255,0.1);
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
            
            .btn, .action-buttons, .print-section {
                display: none !important;
            }
            
            .transaction-details, .receipt {
                border: 1px solid black !important;
                background: white !important;
                color: black !important;
            }
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
            
            .btn {
                width: 100%;
            }
        }
    </style>
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- html2pdf library -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script>
        function printReceipt() {
            // Show printable receipt
            const receipt = document.getElementById('printable-receipt');
            receipt.style.display = 'block';
            
            // Print
            window.print();
            
            // Hide after printing
            setTimeout(() => {
                receipt.style.display = 'none';
            }, 100);
        }
        
        function downloadPDF() {
            const element = document.getElementById('printable-receipt');
            
            // Temporarily show the receipt for PDF generation
            element.style.display = 'block';
            
            const opt = {
                margin:       10,
                filename:     'MBank_Withdrawal_<%= transactionId %>.pdf',
                image:        { type: 'jpeg', quality: 0.98 },
                html2canvas:  { 
                    scale: 2,
                    useCORS: true,
                    logging: false
                },
                jsPDF:        { 
                    unit: 'mm', 
                    format: 'a4', 
                    orientation: 'portrait' 
                }
            };
            
            html2pdf().set(opt).from(element).save().then(() => {
                // Hide receipt again
                element.style.display = 'none';
            });
        }
        
        function goBack() {
            window.history.back();
        }
    </script>
</head>
<body>
    <div class="outcome-container <%= outcome %>">
        <div class="outcome-icon">
            <% if ("success".equals(outcome)) { %>
                <i class="fas fa-check-circle"></i>
            <% } else { %>
                <i class="fas fa-times-circle"></i>
            <% } %>
        </div>
        
        <h1><%= "success".equals(outcome) ? "Withdrawal Successful!" : "Withdrawal Failed" %></h1>
        
        <div class="message">
            <i class="fas fa-info-circle"></i> <%= message %>
        </div>
        
        <% if ("success".equals(outcome) && withdrawAmount != null) { %>
            <div class="amount-display">
                - <%= zarFormat.format(withdrawAmount) %>
            </div>
            
            <div class="transaction-details">
                <div class="detail-row">
                    <span class="detail-label"><i class="fas fa-id-card"></i> Account Number:</span>
                    <span class="detail-value"><%= accountNumber != null ? accountNumber : "N/A" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label"><i class="fas fa-user"></i> Account Holder:</span>
                    <span class="detail-value"><%= accountHolder != null ? accountHolder : "N/A" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label"><i class="fas fa-receipt"></i> Transaction ID:</span>
                    <span class="detail-value transaction-id"><%= transactionId != null ? transactionId : "N/A" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label"><i class="fas fa-calendar"></i> Date & Time:</span>
                    <span class="detail-value"><%= transactionDate != null ? transactionDate : new java.util.Date() %></span>
                </div>
            </div>
            
            <div class="balance-change">
                <div class="balance-box">
                    <div class="balance-label">Before</div>
                    <div class="balance-amount balance-before">
                        <%= oldBalance != null ? zarFormat.format(oldBalance) : "R0.00" %>
                    </div>
                </div>
                
                <div class="arrow">
                    <i class="fas fa-long-arrow-alt-right"></i>
                </div>
                
                <div class="balance-box">
                    <div class="balance-label">After</div>
                    <div class="balance-amount balance-after">
                        <%= newBalance != null ? zarFormat.format(newBalance) : "R0.00" %>
                    </div>
                </div>
            </div>
            
            <div class="print-section">
                <div id="printable-receipt" class="printable-receipt">
                    <h2 style="text-align: center; color: #2c3e50; margin-bottom: 20px;">MBank Withdrawal Receipt</h2>
                    <div style="border: 2px solid #000; padding: 20px; border-radius: 10px;">
                        <table style="width: 100%; border-collapse: collapse;">
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Transaction ID:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= transactionId %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Account Number:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= accountNumber %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Account Holder:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= accountHolder %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Date & Time:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;"><%= transactionDate %></td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Amount Withdrawn:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right; font-weight: bold; color: #e74c3c;">
                                    <%= zarFormat.format(withdrawAmount) %>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd;"><strong>Previous Balance:</strong></td>
                                <td style="padding: 10px; border-bottom: 1px solid #ddd; text-align: right;">
                                    <%= zarFormat.format(oldBalance) %>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 10px;"><strong>New Balance:</strong></td>
                                <td style="padding: 10px; text-align: right; font-weight: bold;">
                                    <%= zarFormat.format(newBalance) %>
                                </td>
                            </tr>
                        </table>
                        <div style="margin-top: 30px; padding-top: 15px; border-top: 1px dashed #000; text-align: center;">
                            <p style="font-size: 12px; color: #7f8c8d;">
                                Thank you for banking with MBank.<br>
                                This is an electronic receipt. Please keep it for your records.<br>
                                For any queries, contact: support@mbank.co.za
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
                <a href="withdraw.jsp" class="btn btn-secondary">
                    <i class="fas fa-redo"></i> Another Withdrawal
                </a>
            <% } else { %>
                <a href="withdraw.jsp" class="btn btn-danger">
                    <i class="fas fa-redo"></i> Try Again
                </a>
            <% } %>
            <button onclick="goBack()" class="btn">
                <i class="fas fa-arrow-left"></i> Back
            </button>
        </div>
    </div>
</body>
</html>