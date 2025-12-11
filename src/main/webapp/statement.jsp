<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.text.NumberFormat" %>
<%
   
    Object accountObj = session.getAttribute("account");
    if (accountObj == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
  
    Integer accountNumber = (Integer) request.getAttribute("accountNumber");
    String accountHolder = (String) request.getAttribute("accountHolder");
    Double currentBalance = (Double) request.getAttribute("currentBalance");
    List<Map<String, Object>> transactions = (List<Map<String, Object>>) request.getAttribute("transactions");
    Map<String, Object> summary = (Map<String, Object>) request.getAttribute("summary");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String typeFilter = (String) request.getAttribute("typeFilter");
    
    
    if (accountNumber == null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    
    if (transactions == null) transactions = new ArrayList<>();
    if (summary == null) summary = new HashMap<>();
    
   
    NumberFormat zarFormat = java.text.NumberFormat.getCurrencyInstance();
    zarFormat.setCurrency(java.util.Currency.getInstance("ZAR"));
    
    
    Calendar cal = Calendar.getInstance();
    String defaultEndDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
    cal.add(Calendar.DAY_OF_MONTH, -30);
    String defaultStartDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
    
    if (startDate == null) startDate = defaultStartDate;
    if (endDate == null) endDate = defaultEndDate;
    if (typeFilter == null) typeFilter = "ALL";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Account Statement - MBank</title>
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
        }
        
        .statement-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 0;
            border-bottom: 2px solid rgba(255,255,255,0.1);
            margin-bottom: 30px;
        }
        
        .back-btn {
            padding: 10px 20px;
            background: #f1c40f;
            color: #2c3e50;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
        }
        
        .account-summary {
            background: rgba(0,0,0,0.7);
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }
        
        .summary-box {
            background: rgba(255,255,255,0.1);
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }
        
        .summary-label {
            font-size: 14px;
            color: #bdc3c7;
            margin-bottom: 5px;
            text-transform: uppercase;
        }
        
        .summary-value {
            font-size: 20px;
            font-weight: bold;
        }
        
        .balance { color: #2ecc71; }
        .deposits { color: #2ecc71; }
        .withdrawals { color: #e74c3c; }
        .transfers { color: #9b59b6; }
        .fees { color: #e67e22; }
        
        .filter-section {
            background: rgba(0,0,0,0.7);
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .filter-form {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: flex-end;
        }
        
        .form-group {
            flex: 1;
            min-width: 200px;
        }
        
        label {
            display: block;
            margin-bottom: 5px;
            color: #f1c40f;
            font-weight: bold;
        }
        
        input[type="date"], select {
            width: 100%;
            padding: 10px;
            border: 2px solid #34495e;
            border-radius: 5px;
            background: rgba(255,255,255,0.1);
            color: white;
            font-size: 16px;
        }
        
        button[type="submit"] {
            padding: 10px 25px;
            background: #2ecc71;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: 0.3s;
        }
        
        button[type="submit"]:hover {
            background: #27ae60;
        }
        
        .reset-btn {
            padding: 10px 25px;
            background: #e74c3c;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            transition: 0.3s;
            text-decoration: none;
            display: inline-block;
        }
        
        .reset-btn:hover {
            background: #c0392b;
        }
        
        .transactions-table {
            width: 100%;
            background: rgba(0,0,0,0.7);
            border-radius: 10px;
            overflow: hidden;
            margin-bottom: 30px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        thead {
            background: rgba(52, 73, 94, 0.9);
        }
        
        th {
            padding: 15px;
            text-align: left;
            font-weight: bold;
            color: #f1c40f;
            border-bottom: 2px solid rgba(255,255,255,0.1);
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid rgba(255,255,255,0.05);
        }
        
        tr:hover {
            background: rgba(255,255,255,0.05);
        }
        
        .transaction-type {
            padding: 5px 10px;
            border-radius: 4px;
            font-weight: bold;
            font-size: 12px;
            text-transform: uppercase;
            display: inline-block;
        }
        
        .type-deposit {
            background: rgba(46, 204, 113, 0.2);
            color: #2ecc71;
            border: 1px solid #2ecc71;
        }
        
        .type-withdrawal {
            background: rgba(231, 76, 60, 0.2);
            color: #e74c3c;
            border: 1px solid #e74c3c;
        }
        
        .type-transfer {
            background: rgba(155, 89, 182, 0.2);
            color: #9b59b6;
            border: 1px solid #9b59b6;
        }
        
        .amount {
            font-weight: bold;
            text-align: right;
        }
        
        .amount-positive {
            color: #2ecc71;
        }
        
        .amount-negative {
            color: #e74c3c;
        }
        
        .action-buttons {
            display: flex;
            gap: 15px;
            justify-content: center;
            margin-top: 30px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 12px 25px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-weight: bold;
            transition: 0.3s;
            display: inline-flex;
            align-items: center;
            gap: 10px;
        }
        
        .btn:hover {
            background: #2980b9;
            transform: translateY(-2px);
        }
        
        .btn-print {
            background: #2c3e50;
        }
        
        .btn-download {
            background: #2ecc71;
        }
        
        .no-transactions {
            text-align: center;
            padding: 50px;
            color: #bdc3c7;
        }
        
        .transaction-id {
            font-family: 'Courier New', monospace;
            font-size: 12px;
            color: #bdc3c7;
        }
        
        @media (max-width: 768px) {
            .statement-container {
                padding: 10px;
            }
            
            .filter-form {
                flex-direction: column;
            }
            
            .form-group {
                width: 100%;
            }
            
            table {
                display: block;
                overflow-x: auto;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
        }
        
        .print-only {
            display: none;
        }
        
        @media print {
            body {
                background: white !important;
                color: black !important;
            }
            
            .statement-container {
                box-shadow: none !important;
                background: white !important;
                color: black !important;
            }
            
            .account-summary, .transactions-table {
                border: 1px solid #000 !important;
                background: white !important;
                color: black !important;
            }
            
            .filter-section, .action-buttons {
                display: none !important;
            }
            
            .print-only {
                display: block;
            }
        }
    </style>
    
   
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body>
    <div class="statement-container">
        <div class="header">
            <h1>Account Statement</h1>
            <a href="dashboard.jsp" class="back-btn">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>
        </div>
        
        <div class="account-summary">
            <h2>Account Information</h2>
            <div class="summary-grid">
                <div class="summary-box">
                    <div class="summary-label">Account Number</div>
                    <div class="summary-value">#<%= accountNumber %></div>
                </div>
                <div class="summary-box">
                    <div class="summary-label">Account Holder</div>
                    <div class="summary-value"><%= accountHolder %></div>
                </div>
                <div class="summary-box">
                    <div class="summary-label">Current Balance</div>
                    <div class="summary-value balance"><%= currentBalance != null ? zarFormat.format(currentBalance) : "R0.00" %></div>
                </div>
                <div class="summary-box">
                    <div class="summary-label">Statement Period</div>
                    <div class="summary-value"><%= startDate %> to <%= endDate %></div>
                </div>
            </div>
            
            <div class="summary-grid" style="margin-top: 30px;">
                <div class="summary-box">
                    <div class="summary-label">Total Deposits</div>
                    <div class="summary-value deposits">
                        <%= summary.get("totalDeposits") != null ? zarFormat.format(summary.get("totalDeposits")) : "R0.00" %>
                    </div>
                </div>
                <div class="summary-box">
                    <div class="summary-label">Total Withdrawals</div>
                    <div class="summary-value withdrawals">
                        <%= summary.get("totalWithdrawals") != null ? zarFormat.format(summary.get("totalWithdrawals")) : "R0.00" %>
                    </div>
                </div>
                <div class="summary-box">
                    <div class="summary-label">Total Transfers</div>
                    <div class="summary-value transfers">
                        <%= summary.get("totalTransfers") != null ? zarFormat.format(summary.get("totalTransfers")) : "R0.00" %>
                    </div>
                </div>
                <div class="summary-box">
                    <div class="summary-label">Total Fees</div>
                    <div class="summary-value fees">
                        <%= summary.get("totalFees") != null ? zarFormat.format(summary.get("totalFees")) : "R0.00" %>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="filter-section">
            <form class="filter-form" action="ViewStatementServlet" method="get">
                <div class="form-group">
                    <label for="startDate">From Date</label>
                    <input type="date" id="startDate" name="startDate" value="<%= startDate %>" max="<%= defaultEndDate %>">
                </div>
                
                <div class="form-group">
                    <label for="endDate">To Date</label>
                    <input type="date" id="endDate" name="endDate" value="<%= endDate %>" max="<%= defaultEndDate %>">
                </div>
                
                <div class="form-group">
                    <label for="typeFilter">Transaction Type</label>
                    <select id="typeFilter" name="typeFilter">
                        <option value="ALL" <%= "ALL".equals(typeFilter) ? "selected" : "" %>>All Transactions</option>
                        <option value="DEPOSIT" <%= "DEPOSIT".equals(typeFilter) ? "selected" : "" %>>Deposits Only</option>
                        <option value="WITHDRAWAL" <%= "WITHDRAWAL".equals(typeFilter) ? "selected" : "" %>>Withdrawals Only</option>
                        <option value="TRANSFER" <%= "TRANSFER".equals(typeFilter) ? "selected" : "" %>>Transfers Only</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <button type="submit">
                        <i class="fas fa-filter"></i> Filter
                    </button>
                </div>
                
                <div class="form-group">
                    <a href="ViewStatementServlet" class="reset-btn">
                        <i class="fas fa-redo"></i> Reset
                    </a>
                </div>
            </form>
        </div>
        
        <div class="transactions-table">
            <h2 style="padding: 20px 20px 10px; border-bottom: 1px solid rgba(255,255,255,0.1);">
                Transaction History
                <span style="float: right; font-size: 14px; color: #bdc3c7;">
                    <%= summary.get("transactionCount") != null ? summary.get("transactionCount") : "0" %> transactions
                </span>
            </h2>
            
            <% if (transactions.isEmpty()) { %>
                <div class="no-transactions">
                    <i class="fas fa-exchange-alt" style="font-size: 50px; margin-bottom: 20px; color: #bdc3c7;"></i>
                    <h3>No transactions found</h3>
                    <p>No transactions match your filter criteria</p>
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Date & Time</th>
                            <th>Type</th>
                            <th>Description</th>
                            <th>To/From Account</th>
                            <th>Amount</th>
                            <th>Fee</th>
                            <th>Transaction ID</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> transaction : transactions) { 
                            String type = (String) transaction.get("type");
                            double amount = (Double) transaction.get("amount");
                            String description = (String) transaction.get("description");
                            String toAccount = (String) transaction.get("toAccount");
                            double fee = (Double) transaction.get("fee");
                            String formattedDate = (String) transaction.get("formattedDate");
                            String transactionId = (String) transaction.get("transactionId");
                            
                            String typeClass = "";
                            switch(type) {
                                case "DEPOSIT": typeClass = "type-deposit"; break;
                                case "WITHDRAWAL": typeClass = "type-withdrawal"; break;
                                case "TRANSFER": typeClass = "type-transfer"; break;
                            }
                            
                            String amountClass = (type.equals("WITHDRAWAL") || type.equals("TRANSFER")) ? "amount-negative" : "amount-positive";
                            String amountSign = (type.equals("WITHDRAWAL") || type.equals("TRANSFER")) ? "-" : "+";
                        %>
                            <tr>
                                <td><%= formattedDate %></td>
                                <td>
                                    <span class="transaction-type <%= typeClass %>">
                                        <%= type %>
                                    </span>
                                </td>
                                <td><%= description != null ? description : "N/A" %></td>
                                <td><%= toAccount != null ? "#" + toAccount : "N/A" %></td>
                                <td class="amount <%= amountClass %>">
                                    <%= amountSign %> <%= zarFormat.format(amount) %>
                                </td>
                                <td>
                                    <% if (fee > 0) { %>
                                        <span style="color: #e67e22;"><%= zarFormat.format(fee) %></span>
                                    <% } else { %>
                                        -
                                    <% } %>
                                </td>
                                <td class="transaction-id"><%= transactionId %></td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <div class="action-buttons">
            <a href="#" onclick="window.print()" class="btn btn-print">
                <i class="fas fa-print"></i> Print Statement
            </a>
            <a href="dashboard.jsp" class="btn">
                <i class="fas fa-home"></i> Back to Dashboard
            </a>
            <a href="#" onclick="downloadCSV()" class="btn btn-download">
                <i class="fas fa-download"></i> Export CSV
            </a>
        </div>
        
        
        <div class="print-only">
            <div style="text-align: center; margin: 20px 0;">
                <h2>MBank Statement of Account</h2>
                <p>Account: #<%= accountNumber %> | <%= accountHolder %></p>
                <p>Statement Period: <%= startDate %> to <%= endDate %></p>
                <p>Generated on: <%= new java.util.Date() %></p>
            </div>
        </div>
    </div>
    
    <script>
        function downloadCSV() {
           
            let csv = "Date,Type,Description,Account,Amount,Fee,Transaction ID\n";
            
            
            <% for (Map<String, Object> transaction : transactions) { 
                String type = (String) transaction.get("type");
                double amount = (Double) transaction.get("amount");
                String description = (String) transaction.get("description");
                String toAccount = (String) transaction.get("toAccount");
                double fee = (Double) transaction.get("fee");
                String formattedDate = (String) transaction.get("formattedDate");
                String transactionId = (String) transaction.get("transactionId");
                
                // Format for CSV
                String csvAmount = (type.equals("WITHDRAWAL") || type.equals("TRANSFER") ? "-" : "+") + 
                                 String.format("%.2f", amount);
                String csvFee = fee > 0 ? String.format("%.2f", fee) : "";
            %>
                csv += "<%= formattedDate.replace(",", " ") %>," +
                       "<%= type %>," +
                       "<%= (description != null ? description.replace(",", " ") : "").replaceAll("[\"']", "") %>," +
                       "<%= toAccount != null ? "#" + toAccount : "" %>," +
                       "<%= csvAmount %>," +
                       "<%= csvFee %>," +
                       "<%= transactionId %>\n";
            <% } %>
            
            // Create and download file
            const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement("a");
            const url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "MBank_Statement_<%= accountNumber %>_<%= startDate %>_<%= endDate %>.csv");
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
        
        // Set max date for endDate to today
        document.addEventListener('DOMContentLoaded', function() {
            const today = new Date().toISOString().split('T')[0];
            document.getElementById('endDate').max = today;
            document.getElementById('startDate').max = today;
            
            // Validate date range
            document.getElementById('startDate').addEventListener('change', function() {
                const endDateField = document.getElementById('endDate');
                if (this.value > endDateField.value) {
                    endDateField.value = this.value;
                }
            });
            
            document.getElementById('endDate').addEventListener('change', function() {
                const startDateField = document.getElementById('startDate');
                if (this.value < startDateField.value) {
                    startDateField.value = this.value;
                }
            });
        });
    </script>
</body>
</html>