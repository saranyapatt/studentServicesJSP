<%@page import="java.time.LocalDate"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.time.*" %>
<%@ page import="java.text.DecimalFormat"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Student Services Dashboard - KBTU</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="./customcss/gradecss.css" rel="stylesheet">
        <%
            if ((session.getAttribute("username") == null) || (!session.getAttribute("role").equals("Student"))) {
                response.sendRedirect("index.jsp");
                return;
            }
        %>

    </head>
    <body style="overflow: hidden;">
        <%
            String name;
            String lastname;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                String sql = "SELECT * FROM student_profile WHERE id_number = ?";
                PreparedStatement p = c.prepareStatement(sql);
                p.setString(1, session.getAttribute("username").toString());
                ResultSet r = p.executeQuery();
                if (r.next()) {
                    Blob pic = r.getBlob("pic");
        %>
        <div class="sidebar shadow">
            <% if (pic != null) {
                    byte[] imageBytes = pic.getBytes(1, (int) pic.length());
                    String base64Image = java.util.Base64.getEncoder().encodeToString(imageBytes);
            %>       <img src="data:image/jpeg;base64,<%= base64Image%>" 
                 style="width: 100%; height: 250px; border-radius: 10%; object-fit: cover;" />
            <%
            } else {
            %>
            <div style="display: flex; height: 250px; align-items: center; justify-content: center; background: #eee;">
                <span>No Image</span>
            </div>
            <%
                }%>
            <h5 class="my-4 text-center">ID: <%= session.getAttribute("student_id")%></h5>
            <nav>
                <a href="loggedMain.jsp" class="nav-link-custom">🏠 Home</a>
                <a href="grade.jsp" class="nav-link-custom active">📊 My Progression</a>
                <a href="enrollment.jsp" class="nav-link-custom ">📝 Enrollment</a>
                <hr style="border-top: 2px solid black;" id="bar">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <div class="main-content" style="margin-left: 270px; margin-right:20px;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="mt-4">Welcome, <%= session.getAttribute("Fullname")%>!</h2>
                <span class="badge bg-primary px-3 py-2 mt-4">Fall Semester 2025</span>
            </div>

            <div class="row g-4 mb-1">
                <div class="col-md-3">
                    <div class="status-card">
                        <h6 class="text-muted">GPA</h6>
                        <h3 class="text-primary"><%
                            double tempGpa = r.getDouble("gpa");
                            DecimalFormat df = new DecimalFormat("0.00");

                            String value = df.format(tempGpa);%>
                            <%=value%></h3>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="status-card">
                        <h6 class="text-muted">Total Credits</h6>
                        <h3 class="text-primary">
                            <%
                                int y = 0;
                                String completedData = r.getString("completed_courses");

                                if (completedData != null && !completedData.trim().isEmpty()) {
                                    String[] x = completedData.split(",");

                                    for (int i = 0; i < x.length; i++) {
                                        y += 3;
                                    }
                                } else {
                                    // If it's null or empty, y remains 0
                                    y = 0;
                                }
                            %>
                            <%=y%> / 127
                        </h3>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="status-card">
                        <h6 class="text-muted">Current Enrollment</h6>
                        <h3 class="text-success">
                            <%= (r.getString("registered_courses") == null || r.getString("registered_courses").isEmpty()) ? "Inactive" : "Active"%>
                        </h3>   
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="status-card">
                        <h6 class="text-muted">Financial Status</h6>
                        <h3 class="text-success"><%if (r.getInt("finance") == 1) {%>Paid<%} else {%>Unpaid<%}%></h3>

                    </div>
                </div>
            </div>

            <div class="login-container box-shadow border-radius-8 pt-4" style="width: 100%; text-align: left;">
                <h4 class="mb-4">Current Course Registration</h4>
                <div class="login-container box-shadow border-radius-8 p-2 rounded" style="background: white;">
                    <table class="table table-hover align-middle">
                        <thead class="table-primary">
                            <tr>
                                <th class="text-center" style="width: 10%;">Code</th>
                                <th style="width: 50%;">Course Title</th>
                                <th class="text-center" style="width: 25%;">Final Exam Date</th>
                                <th class="text-center" style="width: 15%;">Status</th>
                            </tr>
                        </thead>
                        <tbody>

                            <%
                                }
                                java.util.Map<String, String> intersectionMap = new java.util.HashMap<>();

                                String regRaw = r.getString("registered_courses");
                                String compRaw = r.getString("completed_courses");
                                String gradeRaw = r.getString("grade");

                                if (regRaw != null && compRaw != null && gradeRaw != null) {
                                    String[] regArray = regRaw.split(",");
                                    String[] compArray = compRaw.split(",");
                                    String[] gradeArray = gradeRaw.split(",");

                                    java.util.Map<String, String> completedLookup = new java.util.HashMap<>();
                                    for (int i = 0; i < compArray.length; i++) {
                                        if (i < gradeArray.length) {
                                            completedLookup.put(compArray[i].trim(), gradeArray[i].trim());
                                        }
                                    }
                                    for (String regCode : regArray) {
                                        String cleanReg = regCode.trim();
                                        if (completedLookup.containsKey(cleanReg)) {
                                            intersectionMap.put(cleanReg, completedLookup.get(cleanReg));
                                        }
                                    }
                                }
                                java.util.Map<String, String> catalog = new java.util.HashMap<>();
                                java.util.Map<String, String> catalog1 = new java.util.HashMap<>();
                                Statement st = c.createStatement();
                                ResultSet rsCat = st.executeQuery("SELECT * FROM course_name");

                                DateTimeFormatter inputFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                DateTimeFormatter outputFormat = DateTimeFormatter.ofPattern("dd MMMM yyyy", Locale.ENGLISH);

                                while (rsCat.next()) {
                                    catalog.put(rsCat.getString("course_code"), rsCat.getString("course_title"));
                                    String rawDate = rsCat.getString("examdate");
                                    String formattedDate = LocalDate.parse(rawDate, inputFormat).format(outputFormat);
                                    catalog1.put(rsCat.getString("course_code"), formattedDate);
                                }

                                ResultSet rsCom = st.executeQuery("SELECT registered_courses FROM student_profile WHERE id_number = '" + session.getAttribute("username") + "'");
                                if (rsCom.next()) {
                                    String rawCourses = rsCom.getString("registered_courses");

                                    if (rawCourses != null && !rawCourses.isEmpty()) {
                                        String[] codes = rawCourses.split(",");
                                        for (String code : codes) {
                                            String cleanCode = code.trim();
                                            String title = catalog.getOrDefault(cleanCode, "Elective / External Course");
                                            String date = catalog1.getOrDefault(cleanCode, "TBA / Check course syllabus");
                            %>
                            <tr>
                                <td class="text-center"><span class="badge bg-secondary"><%= cleanCode%></span></td>
                                <td class="fw-bold"><%= title%></td>
                                <td class="fw-bold text-center" style="font-size: 16px"><%= date%></td>
                                <td class="fw-bold text-center">
                                    <% if (intersectionMap.containsKey(cleanCode)) {%>
                                    <div class="badge rounded-pill bg-success-subtle text-success border border-success">
                                        Grade: <%= intersectionMap.get(cleanCode)%>
                                    </div>
                                    <% } else { %>
                                    <div class="badge rounded-pill bg-primary-subtle text-primary border border-primary">
                                        Ongoing
                                    </div>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                            }
                                        } else {
                                            out.print("<tr><td colspan='3' class='text-center'>No courses completed yet.</td></tr>");
                                        }
                                    }
                                    c.close();
                                } catch (Exception e) {
                                    out.print("<tr><td colspan='3' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            <p style="font-size: 0.85rem; color: #666; margin-top:15px; text-align: center;">
                Â© 2025 K-Frontier Business & Tech University. All rights reserved.
            </p>
        </div>

    </body>
</html>