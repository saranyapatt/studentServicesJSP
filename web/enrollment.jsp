<%@page import="java.util.HashMap"%>
<%@page import="java.io.File"%>
<%@page import="java.math.BigDecimal"%>
<%@page import="java.sql.*"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Course Enrollment - KBTU</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="./customcss/enrollcss.css">
        <%
            String username = (String) session.getAttribute("username");
            String role = (String) session.getAttribute("role");

            if (username == null || !"Student".equals(role)) {
                response.sendRedirect("index.jsp");
                return;
            }
        %>
    </head>
    <body style="overflow: hidden;">

        <div class="sidebar shadow" style="overflow: hidden;">
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                    String sql = "SELECT * FROM student_profile WHERE id_number = ?";
                    PreparedStatement p = c.prepareStatement(sql);
                    p.setString(1, session.getAttribute("username").toString());
                    ResultSet r = p.executeQuery();
                    if (r.next()) {
                        Blob pic = r.getBlob("pic");
                        if (pic != null) {
                            byte[] imageBytes = pic.getBytes(1, (int) pic.length());
                            String base64Image = java.util.Base64.getEncoder().encodeToString(imageBytes);
            %>       
            <img src="data:image/jpeg;base64,<%= base64Image%>" 
                 style="width: 100%; height: 250px; border-radius: 10%; object-fit: cover;" />
            <%
            } else {
            %>
            <div style="display: flex; height: 250px; align-items: center; justify-content: center; background: #eee;">
                <span>No Image</span>
            </div>
            <%
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

            %>            
            <h5 class="my-4 text-center">ID: <%= session.getAttribute("student_id")%></h5>
            <nav>
                <a href="loggedMain.jsp" class="nav-link-custom">🏠 Home</a>
                <a href="grade.jsp" class="nav-link-custom">📊 My Progression</a>
                <a href="enrollment.jsp" class="nav-link-custom active">📝 Enrollment</a>
                <hr style="border-top: 1px solid black;">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <div class="main-content" style="margin-left: 250px; padding: 15px;">
            <div class="row">
                <div class="col-md-8">
                    <div class="login-container box-shadow border-radius-8 p-4 rounded" style="background: white;">
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <h4 class="m-0">Available Courses</h4>
                            <input type="text" id="searchBar" class="form-control w-50" placeholder="Search course name or code..." onkeyup="filterTable()">
                        </div>
                        <div class="table-scroll-container">
                            <table class="table table-hover align-middle" id="courseTable">
                                <thead class="table-light">
                                    <tr>
                                        <th class="text-center" style="width: 15%;">Code</th>
                                        <th style="width: 70%;">Course Title</th>
                                        <th class="text-center style="width: 15%;">Record</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        // Initialize with empty arrays so loops don't crash
                                        String[] completedList = new String[0];
                                        String[] gradeArr = new String[0];
                                        String[] currentCourses = new String[0];
                                        HashMap<String, String> catGrade = new HashMap<>();

                                        try {
                                            Class.forName("com.mysql.cj.jdbc.Driver");
                                            Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");

                                            // 1. Fetch Completed Courses and Grades
                                            PreparedStatement ps = c.prepareStatement("SELECT completed_courses, grade FROM student_profile WHERE id_number = ?");
                                            ps.setString(1, username);
                                            ResultSet rs = ps.executeQuery();

                                            if (rs.next()) {
                                                String rawComp = rs.getString("completed_courses");
                                                String rawGrade = rs.getString("grade");

                                                // SAFE CHECK: Only split if strings are not null and not empty
                                                if (rawComp != null && !rawComp.isEmpty()) {
                                                    completedList = rawComp.split(",");
                                                }
                                                if (rawGrade != null && !rawGrade.isEmpty()) {
                                                    gradeArr = rawGrade.split(",");
                                                }

                                                // Map numeric grades to Letters
                                                if (completedList.length > 0 && completedList.length == gradeArr.length) {
                                                    for (int i = 0; i < gradeArr.length; i++) {
                                                        String g = gradeArr[i].trim();
                                                        String letter;
                                                        if (g.equals("4.0") || g.equals("4") || g.equals("4.00")) {
                                                            letter = "A";
                                                        } else if (g.equals("3.5")) {
                                                            letter = "B+";
                                                        } else if (g.equals("3.0") || g.equals("3") || g.equals("3.00")) {
                                                            letter = "B";
                                                        } else if (g.equals("2.5")) {
                                                            letter = "C+";
                                                        } else if (g.equals("2.0") || g.equals("2") || g.equals("2.00")) {
                                                            letter = "C";
                                                        } else if (g.equals("1.5")) {
                                                            letter = "D+";
                                                        } else if (g.equals("1.0") || g.equals("1") || g.equals("1.00")) {
                                                            letter = "D";
                                                        } else {
                                                            letter = "F";
                                                        }

                                                        catGrade.put(completedList[i].trim(), letter);
                                                    }
                                                }
                                            }

                                            // 2. Fetch Registered Courses
                                            PreparedStatement ps1 = c.prepareStatement("SELECT registered_courses FROM student_profile WHERE id_number = ?");
                                            ps1.setString(1, username);
                                            ResultSet rs1 = ps1.executeQuery();
                                            if (rs1.next()) {
                                                String regData = rs1.getString("registered_courses");
                                                if (regData != null && !regData.trim().isEmpty()) {
                                                    currentCourses = regData.split(",");
                                                }
                                            }

                                            // 3. Loop through Course Catalog
                                            Statement st = c.createStatement();
                                            ResultSet rsCat = st.executeQuery("SELECT * FROM course_name");

                                            while (rsCat.next()) {
                                                String code = rsCat.getString("course_code");
                                                String title = rsCat.getString("course_title");

                                                // Check status
                                                boolean isDone = catGrade.containsKey(code);
                                                String gradeChar = isDone ? catGrade.get(code) : "";

                                                boolean isCurrent = false;
                                                for (String i : currentCourses) {
                                                    if (i.trim().equals(code)) {
                                                        isCurrent = true;
                                                        break;
                                                    }
                                                }

                                                // Now you can render your HTML table row using code, title, isDone, and isCurrent
                                    %>
                                    <tr style="height:40px;">
                                        <td class="text-center"><span id="code" class="badge bg-secondary"><%= code%></span></td>
                                        <td class="course-name"><%= title%></td>
                                        <td class="text-center">
                                            <% if (isDone) {%>
                                            <span class="text-success small fw-bold"><%=gradeChar%></span>
                                            <% } else if (isCurrent) {%>
                                            <span class="badge bg-secondary" style="min-width: 60px;">Current</span>                                        
                                            <% } else {%>
                                            <button id="addbtn<%=code%>" 
                                                    class="btn btn-sm btn-outline-primary" 
                                                    style=""
                                                    data-code="<%=code%>" 
                                                    data-title="<%=title%>"
                                                    onclick="addToCart('<%= code%>', '<%= title%>')">Add</button>                                      
                                            <% } %>

                                        </td>
                                    </tr>
                                    <%
                                            }
                                            c.close();
                                        } catch (Exception e) {
                                            out.print(e);
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="selection-card">
                        <h5>Enrollment Selection</h5>
                        <p class="text-muted small">Max 7 courses per semester</p>
                        <hr>
                        <div id="cartList" class="mb-3">
                            <p class="text-center text-muted py-3">No courses selected</p>
                        </div>

                        <div class="d-flex justify-content-between mb-2">
                            <span>Selected:</span>
                            <strong id="countDisplay">0 / 7</strong>
                        </div>

                        <button onclick="pendCourse()" class="btn btn-success w-100 py-2 mt-2" id="confirmBtn" disabled>
                            Confirm Registration
                        </button>
                    </div>
                </div>

            </div>

        </div>

        <div class="modal fade" id="summaryModal" tabindex="-1" aria-labelledby="summaryModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-light">
                        <h5 class="modal-title" id="summaryModalLabel">Confirm Enrollment</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p class="text-muted small">You have selected the following courses for this semester:</p>
                        <ul id="summaryList" class="list-group list-group-flush mb-3">
                        </ul>
                        <div class="alert alert-info py-2 small m-0">
                            <strong>Total:</strong> <span id="modalCount">0</span> / 7 Courses
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Change Selection</button>
                        <button type="button" id="finalConfirmBtn" class="btn btn-success" onclick="executeFinalRegistration()">Confirm & Submit</button>
                    </div>
                </div>
            </div>
        </div>
        <p style="font-size: 0.55rem; color: #666; margin-top:-15px; margin-left: 270px;text-align: center;">
            © 2025 K-Frontier Business & Tech University. All rights reserved.
        </p>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>

                            let selectedCourses = [];
                            const MAX_COURSES = 7;

                            function addToCart(code, title) {
                                if (selectedCourses.length >= MAX_COURSES) {
                                    alert(`You can only select up to \${MAX_COURSES} courses.`);
                                    return;
                                }
                                if (selectedCourses.some(c => c.code === code)) {
                                    alert("Course already selected.");
                                    return;
                                }
                                selectedCourses.push({code: code, title: title});
                                renderCart();
                            }

                            function removeFromCart(code) {
                                selectedCourses = selectedCourses.filter(c => c.code !== code);
                                renderCart();
                            }

                            function renderCart() {
                                const list = document.getElementById('cartList');
                                const count = document.getElementById('countDisplay');
                                const hiddenInput = document.getElementById('finalCourses');
                                const btn = document.getElementById('confirmBtn');

                                document.querySelectorAll('[id^="addbtn"]').forEach(tBtn => {
                                    const code = tBtn.getAttribute('data-code');
                                    const title = tBtn.getAttribute('data-title');

                                    tBtn.disabled = false;
                                    tBtn.innerText = "Add";
                                    tBtn.classList.remove('btn-danger', 'btn-secondary');
                                    tBtn.classList.add('btn-outline-primary');
                                    tBtn.setAttribute('onclick', `addToCart('\${code}', '\${title}')`);
                                });

                                if (selectedCourses.length === 0) {
                                    list.innerHTML = '<p class="text-center text-muted py-3">No courses selected</p>';
                                    btn.disabled = true;
                                } else {
                                    list.innerHTML = selectedCourses.map(c => `
            <div class="d-flex justify-content-between align-items-center bg-light p-2 mb-2 rounded border">
                <div class="small">
                    <strong>\${c.code}</strong><br>\${c.title}
                </div>
                <button class="btn btn-sm text-danger" onclick="removeFromCart('\${c.code}')">✕</button>
            </div>
        `).join('');
                                    btn.disabled = false;
                                }
                                selectedCourses.forEach(c => {
                                    const targetBtn = document.getElementById('addbtn' + c.code);
                                    if (targetBtn) {
                                        targetBtn.innerText = "Remove";
                                        targetBtn.classList.replace('btn-outline-primary', 'btn-danger');
                                        targetBtn.setAttribute('onclick', `removeFromCart('\${c.code}')`);
                                    }
                                });
                                count.innerText = `\${selectedCourses.length} / 7`;
                                if (hiddenInput) {
                                    hiddenInput.value = selectedCourses.map(c => c.code).join(',');
                                }
                            }

                            function filterTable() {
                                let input = document.getElementById("searchBar").value.toUpperCase();
                                let rows = document.getElementById("courseTable").getElementsByTagName("tr");
                                for (let i = 1; i < rows.length; i++) {
                                    let text = rows[i].innerText.toUpperCase();
                                    rows[i].style.display = text.indexOf(input) > -1 ? "" : "none";
                                }
                            }

                            function pendCourse() {
                                const listContainer = document.getElementById('summaryList');
                                const modalCount = document.getElementById('modalCount');

                                if (!listContainer)
                                    return;

                                listContainer.innerHTML = "";
                                modalCount.innerText = selectedCourses.length;

                                selectedCourses.forEach(course => {
                                    let li = document.createElement('li');
                                    li.className = "list-group-item d-flex justify-content-between align-items-center small";
                                    li.innerHTML = `<span><b>\${course.code}</b> - \${course.title}</span>`;
                                    listContainer.appendChild(li);
                                });

                                var myModal = new bootstrap.Modal(document.getElementById('summaryModal'));
                                myModal.show();
                            }

                            function executeFinalRegistration() {
                                const btn = document.getElementById('finalConfirmBtn');
                                const modalElement = document.getElementById('summaryModal'); // FIX: Define modalElement

                                btn.disabled = true;
                                btn.innerHTML = `
        <span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
        Sending Request...
    `;

                                const codesOnly = selectedCourses.map(c => c.code).join(',');

                                fetch('pendCourse?courseCodes=' + encodeURIComponent(codesOnly))
                                        .then(response => response.text())
                                        .then(data => {
                                            if (data.trim() === "success") {
                                                btn.innerHTML = "Process...";
                                                btn.classList.replace('btn-success', 'btn-primary');

                                                setTimeout(() => {
                                                    const modalInstance = bootstrap.Modal.getInstance(modalElement);
                                                    if (modalInstance) {
                                                        modalInstance.hide();
                                                    }
                                                    alert("Registration Submitted! Redirecting to home...");
                                                    location.reload();
                                                }, 1000);

                                            } else {
                                                alert("Server Error: " + data);
                                                btn.disabled = false;
                                                btn.innerHTML = "Confirm & Submit";
                                            }
                                        })
                                        .catch(err => {
                                            console.error("Fetch error:", err);
                                            alert("Connection lost. Please check your internet.");
                                            btn.disabled = false;
                                            btn.innerHTML = "Confirm & Pay";
                                        });
                            }
        </script>
    </body>
</html>