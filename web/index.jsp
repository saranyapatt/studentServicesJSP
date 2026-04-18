<!DOCTYPE html>
<!--
Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Html.html to edit this template
-->

<%
    String user = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    if ((user != null && user != "") && (role.equals("student"))) {
        response.sendRedirect("loggedMain.jsp");
    } else if ((user != null && user != "") && (role.equals("admin"))) {
        response.sendRedirect("loggedMainAdmin.jsp");
    }

%>

<html>
    <head>
        <title>Student Services Stop</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="./customcss/style.css">
        <link href="./css/bootstrap.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
        <script src="https://unpkg.com/gijgo@1.9.14/js/gijgo.min.js" type="text/javascript"></script>
        <link href="https://unpkg.com/gijgo@1.9.14/css/gijgo.min.css" rel="stylesheet" type="text/css" />
        <script>
            function getCookie(name) {
                const cookie = (document.cookie).split(";");
                if (cookie !== "") {
                    for (let i = 0; i < cookie.length; i++) {
                        let cookiePair = cookie[i].trim().split("=");
                        let key = cookiePair[0];
                        let value = cookiePair[1];
                        if (key === name) {
                            return value;
                        }
                    }
                }
                return null;
            }
            const user1 = getCookie("username");
            const role1 = getCookie("role");
            const value = localStorage.getItem("username");
        </script>
    </head>
    <body style="background-color: rgb(230, 230, 230);">
        <div class="login-container flexbox-column box-shadow padding-20 border-radius-8">
            <img src="./logo/logo.png" alt="Logo" class="logo">
            <h3>Student Services System</h3>
            <%                
                String error = request.getParameter("error");
                if (error != null) {
                    if (error.equals("userNotFound")) {
                        out.println("<p style='color: red; font-size: 0.9em;'>Error: User does not exist.</p>");
                    } else if (error.equals("invalidPass")) {
                        out.println("<p style='color: red; font-size: 0.9em;'>Error: Incorrect password.</p>");
                    } else if (error.equals("passwordMisMatched")) {
                        out.println("<p style='color: red; font-size: 0.9em;'>Error: Password mismatched.</p>");
                    } else if (error.equals("wrongdob")) {
                        out.println("<p style='color: red; font-size: 0.9em;'>Error: Wrong Date of Birth or User not found.</p>");
                    }
                }
            %>
            <form action="check" method="post" onsubmit="saveLocal()">
                <div class="login">
                    <input type="text" id="username" name="username" placeholder="Username" required>
                    <input type="password" name="password" placeholder="Password" required>
                    <div class="text-end">
                        <a href="#" onclick="goForget()" class="m-3">forget password?</a>
                    </div>
                    <button type="submit" class="btn btn-primary btn-l login" style="width: 90%">Login</button>
                </div>
            </form>
            <button type="submit" onclick="goReg()" class="btn btn-light btn-l login" style="width: 90%">Register</button>
        </div>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                console.log("DOM fully loaded and parsed");
                document.getElementById("username").value = value;
            });
            function saveLocal() {
                localStorage.setItem("username", document.getElementById("username").value);
            }
            function loadLogin() {
                const xhttp = new XMLHttpRequest();
                xhttp.onload = function () {
                    document.body.innerHTML = this.responseText;
                }
                xhttp.open("GET", "index.jsp", true);
                xhttp.send();
            }

            function goReg() {
                const xhttp = new XMLHttpRequest();
                xhttp.onload = function () {
                    document.querySelector('.login-container').classList.add('expanded-box');
                    document.body.innerHTML = this.responseText;
                    $('#dob').datepicker({
                        format: 'dd-mm-yyyy',
                        autoclose: true,
                        minDate: '01-01-1955',
                        maxDate: '31-12-2012',
                        showRightIcon: false
                    });

                }
                xhttp.open("GET", "./login/register.jsp", true);
                xhttp.send();
            }
            function goForget() {
                const xhttp = new XMLHttpRequest();
                xhttp.onload = function () {
                    document.querySelector('.login-container').classList.add('expanded-box');
                    document.body.innerHTML = this.responseText;
                    $('#dob').datepicker({
                        format: 'dd-mm-yyyy',
                        autoclose: true,
                        minDate: '01-01-1955',
                        maxDate: '31-12-2012',
                        showRightIcon: false
                    });

                }
                xhttp.open("GET", "./login/forgetPassword.jsp", true);
                xhttp.send();
            }
            $('#dob').datepicker();

        </script>
    </body>

</html>
