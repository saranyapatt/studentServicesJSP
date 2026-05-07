<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Forget Password</title>
        <link rel="stylesheet" href="./customcss/style.css">
        <link href="./css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body style="background-color: rgb(230, 230, 230);">

        <div class="login-container flexbox-column box-shadow padding-20 border-radius-8">
            <img src="./logo/logo.png" alt="Logo" class="logo">
            <h3 class="mb-3">Reset Password</h3>

            <% 
                String error = request.getParameter("error");
                if(error != null) {
                    out.print("<div style='color: red; font-size: 14px; margin-bottom: 10px; font-weight: bold;'>");
                    if(error.equals("idNotFound")) {
                        out.print("Error: ID number not found in our system.");
                    } else if(error.equals("wrongDob")) {
                        out.print("Error: Date of Birth is incorrect.");
                    } else if(error.equals("dbError")) {
                        out.print("Error: A system error occurred. Try again.");
                    }
                    out.print("</div>");
                }
            %>

            <form action="resetPassword" method="post" onsubmit="return validatePassword()">
                <div class="login">
                    <input type="text" name="id" placeholder="Username or ID number" 
                           value="<%= request.getParameter("id") != null ? request.getParameter("id") : "" %>" required>    
                    
                    <div style="width: 100%; margin: 0 0 0 18px;">
                        <input id="dob" name="dob" type="text" placeholder="Date of Birth" required>
                        
                        <input type="password" id="new_pass" name="new_pass" placeholder="New Password" required class="form-control mb-2">     
                        
                        <input type="password" id="confirm_pass" name="confirm_pass" placeholder="Confirm New Password" required class="form-control mb-2">
                        
                        <p id="message" style="color: red; font-size: 12px; margin-top: -5px; display: none; font-weight: bold;">
                            Passwords do not match!
                        </p>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-l login" style="width: 90%">Reset Password</button>
                </div>
            </form>
            
            <button onclick="loadLogin()" class="btn btn-light btn-l login" style="width: 90%">Back</button>
        </div>

        <script>
        // Check if passwords match before allowing form submission
        function validatePassword() {
            var pass = document.getElementById("new_pass").value;
            var confirm = document.getElementById("confirm_pass").value;
            var msg = document.getElementById("message");

            if (pass !== confirm) {
                msg.style.display = "block"; // Show red text
                return false; // Prevent form from sending
            } else {
                msg.style.display = "none";
                return true; // Allow form to send
            }
        }

        function loadLogin() {
            window.location.href = "index.jsp";
        }
        </script>
    </body>
</html>