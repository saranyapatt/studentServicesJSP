<%-- 
    Document   : enrollmentAdmin
    Created on : Dec 26, 2025, 2:17:47 AM
    Author     : mix
--%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin - Enrollment Check</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="./customcss/enrollcss.css"> 
        <%
            String username = (String) session.getAttribute("username");
            String role = (String) session.getAttribute("role");

            if (username == null || !"Teacher".equals(role)) {
                response.sendRedirect("index.jsp");
                return;
            }
        %>
    </head>

    <body class="bg-light">

        <div class="sidebar shadow">
            <img src="./logo/logo.png" alt="Logo" style="width: 100%; margin-bottom: 20px;">
            <h5 class="mb-4 text-center">Teacher <%=session.getAttribute("name")%></h5>
            <nav>
                <a href="loggedMainTeacher.jsp" class="nav-link-custom">🏠 Home</a>
                <a href="teacherDashboard.jsp" class="nav-link-custom">📊 Dashboard</a>
                <a href="gradeAdmin.jsp" class="nav-link-custom">🎓 Grading</a>
                <a href="enrollmentAdmin.jsp" class="nav-link-custom active">📝 Enrollment Approval</a>
                <a href="courseTeacher.jsp" class="nav-link-custom">📚 Course Management</a>
                <hr style="border-top: 2px solid black;">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <div class="main-content">
            <div class="container-fluid">

                <div class="row">
                    <div class="row-md-4 px-4 pb-4 search-container">
                        <input type="text" id="searchInput" class="form-control shadow-sm" 
                               placeholder="Search by Name or ID..." 
                               onkeyup="filterStudents()" 
                               autocomplete="off">
                        <div id="searchDropdown"></div>
                    </div>
                    <div class="col-md-4">
                        <div class="card border-0 shadow-sm p-4">
                            <h5 class="mb-3">Search Student</h5>
                            <div class="mb-3">
                                <label class="form-label small text-muted">Select Student ID</label>
                                <select id="studentSelect" class="form-select" onchange="fetchPendingCourses()">
                                    <option value="">-- Choose a Student --</option>
                                    <%
                                        try {
                                            Class.forName("com.mysql.cj.jdbc.Driver");
                                            Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                                            Statement st = c.createStatement();
                                            // Only show students who actually have pending courses
                                            ResultSet rs = st.executeQuery("SELECT student_id, fullname FROM student_profile WHERE pending_courses IS NOT NULL AND pending_courses != ''");
                                            while (rs.next()) {
                                                String id = rs.getString("student_id");
                                                String name = rs.getString("fullname");
                                                out.print(name);
                                                out.print("<option value='" + id + "'>" + id + " - " + name + "</option>");
                                            }
                                            c.close();
                                        } catch (Exception e) {
                                            out.print("<option disabled>Error: " + e.getMessage() + "</option>");
                                        }
                                    %>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-8">
                        <div class="card border-0 shadow-sm p-4" id="resultsCard" style="display:none;">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h4 class="m-0">Pending Enrollment for <span id="displayId" class="text-primary"></span></h4>
                                <span class="badge bg-warning text-dark">Awaiting Approval</span>
                            </div>

                            <div id="pendingContainer">
                            </div>


                        </div>

                        <div id="placeholder" class="text-center py-5 text-muted">
                            <img src="https://cdn-icons-png.flaticon.com/512/1150/1150643.png" style="width:100px; opacity:0.3;" alt="select">
                            <p class="mt-3">Select a student from the list to view their requested courses.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function fetchPendingCourses() {
                const id = document.getElementById('studentSelect').value;
                const container = document.getElementById('pendingContainer');
                const resultsCard = document.getElementById('resultsCard');
                const placeholder = document.getElementById('placeholder');
                const displayId = document.getElementById('displayId');
                if (!id) {
                    resultsCard.style.display = 'none';
                    placeholder.style.display = 'block';
                    return;
                }

                displayId.innerText = id;
                placeholder.style.display = 'none';
                resultsCard.style.display = 'block';
                container.innerHTML = "Loading...";
                fetch('getPendingData?studentId=' + id)
                        .then(res => res.json())
                        .then(data => {
                            const entries = Object.entries(data.courses);
                            let financeBadge = data.financeStatus === 1
                                    ? '<span class="badge bg-success">Finance Cleared</span>'
                                    : '<span class="badge bg-danger">Payment Pending</span>';
                            if (entries.length === 0) {
                                container.innerHTML = '<div class="alert alert-info">No pending courses found.</div>';
                                return;
                            }

                            let html = `<div class="mb-3">${financeBadge}</div><ul class="list-group mb-4">`;
                            entries.forEach(([code, title]) => {
                                html += `<li class="list-group-item"><strong>${code}</strong> - ${title}</li>`;
                            });
                            html += '</ul>';
                            // Disable button if not paid
                            const btnState = data.financeStatus === 1 ? '' : 'disabled';
                            html += `
                            <div class="d-flex gap-2">
                                <button class="btn btn-success" onclick="processApproval('approve')" ${btnState}>Approve All</button>
                                <button class="btn btn-outline-danger" onclick="processApproval('reject')">Reject All</button>

                            `;
                            const btnState1 = data.financeStatus === 0 ? '' : 'disabled';
                            html += `
 
                                <button class="btn btn-outline-success" onclick="makePaid()" ${btnState1}>Mark Paid</button>

                            </div>`;
                            container.innerHTML = html;
                        });
            }

            function makePaid() {
                const id = document.getElementById('studentSelect').value;

                if (!id) {
                    alert("Please select a student first.");
                    return;
                }

                if (!confirm("Confirm payment update for Student ID: " + id + "?"))
                    return;

                // We send the request to a backend handler (updateFinance.jsp)
                fetch('updateFinance.jsp?studentId=' + encodeURIComponent(id))
                        .then(response => response.text())
                        .then(data => {
                            if (data.trim() === "success") {
                                alert("Finance status updated to PAID!");
                                fetchPendingCourses(); // Refresh the UI to enable buttons
                            } else {
                                alert("Error: " + data);
                            }
                        })
                        .catch(err => console.error("Error:", err));
            }
            function processApproval(action) {
                const id = document.getElementById('studentSelect').value;
                const container = document.getElementById('pendingContainer');
                if (!id) {
                    alert("Please select a student first.");
                    return;
                }

                const confirmMsg = action === 'approve' ? "Approve all pending courses and move them to Registered?" : "Reject and clear these pending courses?";
                if (!confirm(confirmMsg))
                    return;
                // Use standard concatenation to avoid JSP ${} conflicts
                const requestBody = "studentId=" + encodeURIComponent(id) + "&action=" + encodeURIComponent(action);
                fetch('getPendingData', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: requestBody
                })
                        .then(res => res.text())
                        .then(data => {
                            if (data.trim() === "success") {
                                alert("Action Processed Successfully!");
                                location.reload();
                            } else {
                                alert("Server Error: " + data);
                            }
                        })
                        .catch(err => alert("Fetch Error: " + err));
            }
            function filterStudents() {
                let input = document.getElementById("searchInput").value.toLowerCase();
                let dropdown = document.getElementById("searchDropdown");
                let selectBox = document.getElementById("studentSelect");

                dropdown.innerHTML = '';

                if (input === '') {
                    dropdown.classList.remove('show');
                    return;
                }

                let matchCount = 0;
                let options = selectBox.options;

                // Loop through all options in the select box
                for (let i = 1; i < options.length; i++) { // Start from 1 to skip "-- Choose a Student --"
                    let optionText = options[i].text.toLowerCase();
                    let optionValue = options[i].value.toLowerCase();

                    if (optionText.includes(input) || optionValue.includes(input)) {
                        matchCount++;

                        // Create dropdown item
                        let item = document.createElement('div');
                        item.className = 'dropdown-item-custom';
                        item.innerHTML = `
                <span class="student-id-badge">${options[i].value}</span>
                <span class="student-name-text">${options[i].text.split(' - ')[1] || options[i].text}</span>
            `;

                        item.onclick = function () {
                            selectBox.value = options[i].value;
                            document.getElementById('searchInput').value = '';
                            dropdown.classList.remove('show');
                            fetchPendingCourses();

                        };

                        dropdown.appendChild(item);
                    }
                }

                // Show dropdown if there are matches
                if (matchCount > 0) {
                    dropdown.classList.add('show');
                } else {
                    dropdown.innerHTML = '<div class="dropdown-item-custom text-muted">No matches found</div>';
                    dropdown.classList.add('show');
                }
            }

            document.addEventListener('click', function (event) {
                let searchContainer = document.querySelector('.search-container');
                if (searchContainer && !searchContainer.contains(event.target)) {
                    document.getElementById('searchDropdown').classList.remove('show');
                }
            });
        </script>
    </body>
</html>