<%-- 
    Document   : gradeAdmin
    Created on : Dec 26, 2025, 11:07:09 PM
    Author     : mix
--%>

<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin - Grade Entry</title>
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
                <a href="gradeAdmin.jsp" class="nav-link-custom active">🎓 Grading</a>
                <a href="enrollmentAdmin.jsp" class="nav-link-custom">📝 Enrollment Approval</a>
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
                            <h5 class="mb-3">Select Student</h5>
                            <select id="studentSelect" class="form-select" onchange="fetchRegisteredCourses()">
                                <option value="">-- Choose a Student --</option>
                                <%
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                                        Statement st = c.createStatement();

                                        // 1. Fetch students who have registered courses and their history
                                        String sql = "SELECT student_id, fullname, registered_courses, completed_courses "
                                                + "FROM student_profile "
                                                + "WHERE registered_courses IS NOT NULL AND registered_courses != ''";
                                        ResultSet rs = st.executeQuery(sql);

                                        while (rs.next()) {
                                            String studentId = rs.getString("student_id");
                                            String fullname = rs.getString("fullname");
                                            String registered = rs.getString("registered_courses");
                                            String completed = rs.getString("completed_courses");

                                            // 2. Prepare the completed courses in a Set for fast comparison
                                            java.util.Set<String> completedSet = new java.util.HashSet<>();
                                            if (completed != null && !completed.trim().isEmpty()) {
                                                for (String code : completed.split(",")) {
                                                    completedSet.add(code.trim());
                                                }
                                            }

                                            // 3. Check if there is any course in 'registered' that is NOT in 'completed'
                                            String[] registeredArray = registered.split(",");
                                            boolean needsGrading = false;

                                            for (String course : registeredArray) {
                                                String cleanCourse = course.trim();
                                                if (!completedSet.contains(cleanCourse)) {
                                                    // We found at least one course that hasn't been graded yet
                                                    needsGrading = true;
                                                    break;
                                                }
                                            }

                                            // 4. Skip student if all registered courses are already in completed list
                                            if (needsGrading) {
                                                out.print("<option value='" + studentId + "'>" + studentId + " - " + fullname + "</option>");
                                            }
                                        }
                                        c.close();
                                    } catch (Exception e) {
                                        out.print("<option disabled>Error: " + e.getMessage() + "</option>");
                                    }

                                %>
                            </select>
                        </div>
                    </div>

                    <div class="col-md-8">
                        <div class="card border-0 shadow-sm p-4" id="gradingCard" style="display:none;">
                            <h4>Assign Grades for <span id="displayId" class="text-primary"></span></h4>
                            <div id="courseContainer" class="mt-3"></div>
                            <button class="btn btn-primary mt-3" onclick="submitGrades()">Submit All Grades</button>
                        </div>
                        <div id="placeholder" class="text-center py-5 text-muted">
                            <p>Select a student to view their currently registered courses.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            function fetchRegisteredCourses() {
                const id = document.getElementById('studentSelect').value;
                const container = document.getElementById('courseContainer');
                const card = document.getElementById('gradingCard');
                const placeholder = document.getElementById('placeholder');

                if (!id) {
                    card.style.display = 'none';
                    placeholder.style.display = 'block';
                    return;
                }

                document.getElementById('displayId').innerText = id;
                placeholder.style.display = 'none';
                card.style.display = 'block';
                container.innerHTML = "Loading..."; // It gets stuck here if the fetch fails

                fetch('getGrade?studentId=' + encodeURIComponent(id) + '&type=registered_courses')
                        .then(res => {
                            if (!res.ok)
                                throw new Error('Server returned ' + res.status);
                            return res.json();
                        })
                        .then(data => {
                            if (data.error)
                                throw new Error(data.error);

                            const entries = Object.entries(data.courses || {});
                            if (entries.length === 0) {
                                container.innerHTML = '<div class="alert alert-warning">No registered courses found for this student.</div>';
                                return;
                            }

                            let html = '<table class="table"><thead><tr><th>Course</th><th>Grade</th></tr></thead><tbody>';
                            entries.forEach(([code, title]) => {
                                html += `
                        <tr>
                            <td><strong>${code}</strong><br><small>${title}</small></td>
                            <td>
                                <select class="form-select grade-input" data-course="${code}">
                                    <option value="">-- Grade --</option>
                                    <option value="4">4.0 (A)</option>
                                    <option value="3.5">3.5 (B+)</option>
                                    <option value="3">3.0 (B)</option>
                                    <option value="2.5">2.5 (C+)</option>
                                    <option value="2">2.0 (C)</option>
                                    <option value="1">1.0 (D)</option>
                                </select>
                            </td>
                        </tr>`;
                            });
                            html += '</tbody></table>';
                            container.innerHTML = html;
                        })
                        .catch(err => {
                            console.error(err);
                            container.innerHTML = '<div class="alert alert-danger">Error: ' + err.message + '</div>';
                        });
            }

            function submitGrades() {
                const id = document.getElementById('studentSelect').value;
                const gradeInputs = document.querySelectorAll('.grade-input');
                let gradeData = [];
                let allGraded = true;

                // 1. Validation: Ensure every dropdown has a selection
                gradeInputs.forEach(el => {
                    if (el.value === "") {
                        allGraded = false;
                        el.classList.add('is-invalid'); // Highlight missing grades
                    } else {
                        el.classList.remove('is-invalid');
                        gradeData.push(el.value); // Just push the grade to keep the order
                    }
                });

                if (!allGraded) {
                    alert("Action Required: You must assign a grade to ALL registered courses before submitting.");
                    return;
                }

                // 2. Approval check
                const isApproved = confirm("Grades recorded comfirm?");

                // 3. Send POST request
                fetch('getGrade', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'studentId=' + encodeURIComponent(id) +
                            '&grades=' + encodeURIComponent(gradeData.join(','))
                })
                        .then(res => res.text())
                        .then(msg => {
                            location.reload();
                        });
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

                        // Add click event to select student
                        item.onclick = function () {
                            selectBox.value = options[i].value;
                            document.getElementById('searchInput').value = '';
                            dropdown.classList.remove('show');
                            fetchRegisteredCourses();
                            
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
