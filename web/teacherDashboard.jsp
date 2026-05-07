<%@page import="java.util.HashMap"%>
<%@page import="java.util.Map"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Teacher Dashboard - KBTU</title>
        <link href="./css/bootstrap.min.css" rel="stylesheet">
        <link href="./customcss/gradecss.css" rel="stylesheet"> 
        <style>
            .search-container {
                position: relative;
                max-width: 400px;
            }
            .detail-label {
                font-weight: bold;
                color: #555;
                font-size: 0.85rem;
                text-transform: uppercase;
            }
            .detail-value {
                margin-bottom: 12px;
                display: block;
                font-size: 1.05rem;
                color: #222;
            }
            .modal-xl {
                max-width: 1100px;
            }
            #studentTable tr.hidden {
                display: none;
            }
        </style>
    </head>
    <body style="background-color: #f8f9fa;">

        <%
            if (session.getAttribute("username") == null || !session.getAttribute("role").equals("Teacher")) {
                response.sendRedirect("index.jsp");
                return;
            }
            Object sessionValue = session.getAttribute("class");

            int sclass = 0;

            if (sessionValue != null) {
                try {
                    sclass = Integer.parseInt(sessionValue.toString());
                } catch (NumberFormatException e) {
                    sclass = 0;
                }
            }
            Connection c = null;
            Statement st = null;
            Map<String, String> courseTitles = new HashMap<>();

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?useSSL=false", "root", "1234");
                st = c.createStatement();
                ResultSet rsCourses = st.executeQuery("SELECT course_code, course_title FROM course_name");
                while (rsCourses.next()) {
                    courseTitles.put(rsCourses.getString("course_code").trim(), rsCourses.getString("course_title").trim());
                }
        %>

        <div class="sidebar shadow">
            <img src="./logo/logo.png" alt="Logo" style="width: 100%; margin-bottom: 20px;">
            <h5 class="mb-4 text-center">Teacher <%=session.getAttribute("name")%></h5>
            <nav>
                <a href="loggedMainTeacher.jsp" class="nav-link-custom">🏠 Home</a>
                <a href="teacherDashboard.jsp" class="nav-link-custom active">📊 Dashboard</a>
                <a href="gradeAdmin.jsp" class="nav-link-custom">🎓 Grading</a>
                <a href="enrollmentAdmin.jsp" class="nav-link-custom">📝 Enrollment Approval</a>
                <a href="courseTeacher.jsp" class="nav-link-custom">📚 Course Management</a>
                <hr style="border-top: 2px solid black;">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <div class="main-content" style="margin-left: 270px; margin-right:20px; padding-top: 20px;">
            <div class="d-flex justify-content-between align-items-center mb-2 sticky-top" style="background-color: #f8f9fa">
                <div>
                    <h2>Student Registry</h2>
                    <p class="text-muted">Select a student to view their academic records.</p>
                </div>
                <div class="search-container" style="width: 450px">
                    <input type="text" id="searchInput" class="form-control shadow-sm" placeholder="Search by Name or ID..." onkeyup="filterStudents()">
                </div>
            </div>

            <div class="card border-0 mb-3 shadow-sm overflow-hidden">
                <table class="table table-hover mb-0 align-middle" id="studentTable">
                    <thead class="table-primary">
                        <tr>
                            <th class="text-center" style="width: 10%">Student ID</th>
                            <th class="ps-4 text-center" style="width: 50%">Full Name</th>
                            <th class="text-center" style="width: 10%">Year/Class</th>
                            <th class="text-center" style="width: 10%">Finance</th>
                            <th class="text-center" style="width: 20%">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            String classsql;
                            if (sclass != 5) {
                                classsql = "SELECT * FROM student_profile WHERE class = " + sclass;
                            } else {
                                classsql = "SELECT * FROM student_profile";
                            }
                            ResultSet rsList = st.executeQuery(classsql);
                            while (rsList.next()) {
                                String sid = rsList.getString("student_id");
                                String fname = rsList.getString("fullname");
                                String sClass = rsList.getString("class");
                                int finance = rsList.getInt("finance");

                                String idNumber = rsList.getString("id_number");
                                String telephone = rsList.getString("telephone");
                                String dob = rsList.getString("dob");
                                String gpa = rsList.getString("gpa");
                                String compRaw = rsList.getString("completed_courses");
                                String gradeRaw = rsList.getString("grade");
                                String regRaw = rsList.getString("registered_courses");
                                String penRaw = rsList.getString("pending_courses");
                        %>
                        <tr class="student-row">
                            <td class="px-4 text-center fw-bold text-primary"><%= sid%></td>
                            <td class="px-4 student-name"><%= fname%></td>
                            <td class="text-center"><%= (sClass != null) ? sClass : "N/A"%></td>
                            <td class="text-center align-middle">
                                <% if (finance == 1) { %>
                                <span class="badge bg-success-subtle text-success border border-success">Paid</span>
                                <% } else { %>
                                <span class="badge bg-danger-subtle text-danger border border-danger">Unpaid</span>
                                <% }%>
                            </td>

                            <td class="text-center">
                                <button class="btn btn-sm btn-dark px-3" data-bs-toggle="modal" data-bs-target="#modal<%=sid%>">View Details</button>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <%
                rsList = st.executeQuery("SELECT * FROM student_profile");
                while (rsList.next()) {
                    String sid = rsList.getString("student_id");
                    String fname = rsList.getString("fullname");
                    String idNumber = rsList.getString("id_number");
                    String telephone = rsList.getString("telephone");
                    String dob = rsList.getString("dob");
                    String gpa = rsList.getString("gpa");
                    String compRaw = rsList.getString("completed_courses");
                    String gradeRaw = rsList.getString("grade");
                    String regRaw = rsList.getString("registered_courses");
                    String penRaw = rsList.getString("pending_courses");
                    Blob pic = rsList.getBlob("pic");
            %>

            <div class="modal fade" id="modal<%=sid%>" tabindex="-1" aria-hidden="true">
                <div class="modal-dialog modal-xl modal-dialog-centered">
                    <div class="modal-content border-0 shadow-lg">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title">Record: <%= fname%> (<%= sid%>)</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <div class="row">
                                <div class="col-md-3 border-end">
                                    <div class="mx-auto mb-3" style="width: 230px; height: 300px; border: 1px solid black; overflow: hidden;"> 
                                        <%
                                            try {
                                                if (pic != null) {
                                                    byte[] imageBytes = pic.getBytes(1, (int) pic.length());
                                                    String base64Image = java.util.Base64.getEncoder().encodeToString(imageBytes);
                                        %>
                                        <img src="data:image/jpeg;base64,<%= base64Image%>" 
                                             style="width: 100%; height: 100%; object-fit: cover;" />
                                        <%
                                        } else {
                                        %>
                                        <div style="display: flex; height: 100%; align-items: center; justify-content: center; background: #eee;">
                                            <span>No Image</span>
                                        </div>
                                        <%
                                                }
                                            } catch (Exception e) {
                                                out.print("Error");
                                            }
                                        %>
                                    </div>
                                    <h6 class="text-primary fw-bold mb-3">General Information</h6>
                                    <span class="detail-label">Full Name</span><span class="detail-value"><%= fname%></span>
                                    <span class="detail-label">ID Number</span><span class="detail-value"><%= idNumber%></span>
                                    <span class="detail-label">Telephone</span><span class="detail-value"><%= telephone%></span>
                                    <span class="detail-label">DOB</span><span class="detail-value"><%= dob%></span>
                                    <span class="detail-label">Current GPA</span><span class="detail-value text-primary fw-bold"><%= gpa%></span>
                                </div>

                                <div class="col-md-9">
                                    <h6 class="text-success fw-bold mb-2">Completed Courses</h6>
                                    <table class="table table-bordered table-sm mb-4">
                                        <thead class="table-light">
                                            <tr><th>Code</th><th>Course Title</th><th class="text-center">Grade</th></tr>
                                        </thead>
                                        <tbody>
                                            <%
                                                if (compRaw != null && !compRaw.isEmpty()) {
                                                    String[] codes = compRaw.split(",");
                                                    String[] grades = (gradeRaw != null) ? gradeRaw.split(",") : new String[0];
                                                    for (int i = 0; i < codes.length; i++) {
                                                        String code = codes[i].trim();
                                                        String grade = (i < grades.length) ? grades[i] : "N/A";
                                            %>
                                            <tr>
                                                <td><span class="badge bg-secondary"><%= code%></span></td>
                                                <td><%= courseTitles.getOrDefault(code, "General Elective")%></td>
                                                <td class="text-center fw-bold text-success"><%= grade%></td>
                                            </tr>
                                            <% }
                                            } else { %> <tr><td colspan="3" class="text-center">No history</td></tr> <% } %>
                                        </tbody>
                                    </table>

                                    <div class="row">
                                        <div class="col-md-6">
                                            <h6 class="text-info fw-bold mb-2">Ongoing (Registered)</h6>
                                            <ul class="list-group list-group-flush border rounded">
                                                <%
                                                    if (regRaw != null && !regRaw.isEmpty()) {
                                                        for (String r : regRaw.split(",")) {
                                                            String rCode = r.trim();
                                                %>
                                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                                    <small><%= courseTitles.getOrDefault(rCode, "Course")%></small>
                                                    <span class="badge bg-info-subtle text-info"><%= rCode%></span>
                                                </li>
                                                <% }
                                                } else { %> <li class="list-group-item text-muted">None</li> <% } %>
                                            </ul>
                                        </div>
                                        <div class="col-md-6">
                                            <h6 class="text-warning fw-bold mb-2">Pending Approval</h6>
                                            <ul class="list-group list-group-flush border rounded">
                                                <%
                                                    if (penRaw != null && !penRaw.isEmpty()) {
                                                        for (String p : penRaw.split(",")) {
                                                            String pCode = p.trim();
                                                %>
                                                <li class="list-group-item d-flex justify-content-between align-items-center">
                                                    <small><%= courseTitles.getOrDefault(pCode, "Pending")%></small>
                                                    <span class="badge bg-warning-subtle text-warning"><%= pCode%></span>
                                                </li>
                                                <% }
                                                } else { %> <li class="list-group-item text-muted">None</li> <% } %>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <% } %>
        </tbody>
    </table>
</div>
</div>

<%
    } catch (Exception e) {
        out.print("<div class='alert alert-danger m-4'>Error: " + e.getMessage() + "</div>");
    } finally {
        if (st != null) {
            st.close();
        }
        if (c != null) {
            c.close();
        }
    }
%>

<script>
    function filterStudents() {
        let input = document.getElementById("searchInput").value.toLowerCase();
        let rows = document.querySelectorAll(".student-row");

        rows.forEach(row => {
            let id = row.cells[0].innerText.toLowerCase();
            let name = row.cells[1].innerText.toLowerCase();

            if (id.includes(input) || name.includes(input)) {
                row.style.display = "";
            } else {
                row.style.display = "none";
            }
        });
    }
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>