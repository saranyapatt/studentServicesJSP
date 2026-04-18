<!DOCTYPE html>
<!--
Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Html.html to edit this template
-->
<html>
    <head>
        <title>Register</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="style.css">
        <link href="./css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body style="background-color: rgb(230, 230, 230);">

        <div class="login-container flexbox-column box-shadow padding-20 border-radius-8">
            <img src="./logo/logo.png" alt="Logo" class="logo">
            <h3>Student Services System - Register</h3>
            <form action="reg" method="post">
                <div class="login">
                    <input type="text" name="name" placeholder="First Name" required>
                    <input type="text" name="surname" placeholder="Last Name" required>
                    <input type="text" name="id" placeholder="ID number" required>
                    <input type="text" name="tel" placeholder="Phone Number" required>
                    <div style="width: 100%; margin: 0 0 0 18px;">
                        <input id="dob" name="dob" type="text" placeholder="Date of Birth" required>
                    </div>
                    <button type="submit" class="btn btn-primary btn-l login" style="width: 90%">Register</button>
                </div>



            </form>
            <button onclick="loadLogin()" class="btn btn-light btn-l login" style="width: 90%">Back</button>
        </div>
        <script>
            function loadLogin() {
                const xhttp = new XMLHttpRequest();
                xhttp.onload = function () {
                    document.body.innerHTML = this.responseText;
                }
                xhttp.open("GET", "../index.jsp", true);
                xhttp.send();
            }
        </script>
    </body>
</html>