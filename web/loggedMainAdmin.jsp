<%@page import="java.util.Locale"%>
<%@page import="java.time.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.time.LocalDateTime"%>
<%@page import="java.time.format.DateTimeFormatter"%>
<%@page import="bke.logout"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Home - KBTU Student Services</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <link href="./customcss/maincss.css" rel="stylesheet">
        <%
            String username = (String) session.getAttribute("username");
            String role = (String) session.getAttribute("role");

            if (username == null || !"Admin".equals(role)) {
                response.sendRedirect("index.jsp");
                return;
            }
        %>

    </head>
    <body>
        <%
            String name = "";
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                String sql = "SELECT * FROM admin_teacher WHERE user = ?";
                PreparedStatement p = c.prepareStatement(sql);
                p.setString(1, session.getAttribute("username").toString());
                ResultSet r = p.executeQuery();
                if (r.next()) {
                    session.setAttribute("Fullname", r.getString("name") + " " + r.getString("surname"));
                    session.setAttribute("teacer_id", r.getString("teacher_id"));
                    name = r.getString("name") + " " + r.getString("surname");
                } else {
                    session.setAttribute("Fullname", "Admin");
                    session.setAttribute("student_id", "admin");
                }

        %>
        <button class="hamburger-btn" id="hamburgerBtn" onclick="toggleSidebar()">☰</button>
        <div class="sidebar-overlay" id="sidebarOverlay" onclick="toggleSidebar()"></div>
        <div id="bgCarousel" class="bgCarousel carousel slide carousel-fade" data-bs-ride="carousel">
            <div class="carousel-inner">
                <div class="carousel-item active"><img src="./logo/bg1.jpg" alt="1"></div>
                <div class="carousel-item"><img src="./logo/bg2.jpg" alt="2"></div>
                <div class="carousel-item"><img src="./logo/bg3.jpg" alt="3"></div>
                <div class="carousel-item"><img src="./logo/bg4.jpg" alt="4"></div>
            </div>
        </div>

        <div class="sidebar shadow">
            <img src="./logo/logo.png" id="logo" alt="Logo" class="imgmain imgfil">
            <h5 class="mb-4 text-white text-center">Welcome, <%= r.getString("name")%></h5>

            <nav>
                <a href="loggedMainAdmin.jsp" class="nav-link-custom active">🏠 Home</a>
                <a href="ann.jsp" class="nav-link-custom">🎓 Announcement Panel</a>
                <a href="calendar.jsp" class="nav-link-custom ">📝 Calendar Panel</a>
                <a href="accountAdmin.jsp" class="nav-link-custom">👥 Account Management</a>
                <hr style="border-top: 2px solid white;" id="bar">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <section>
            <div class="glass-box-an shadow-lg">
                <h1 style="font-size: 1.2rem; font-weight: 700; margin: 0;">
                    <%= LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"))%>
                </h1>
            </div>
            <div class="glass-box shadow-lg">
                <h1 style="font-size: 1.5rem; font-weight: 800; margin: 0;">
                    Welcome, <%= session.getAttribute("Fullname")%>!
                </h1>
                <p class="small mb-0" style="letter-spacing: 2px; opacity: 0.8;">KBTU TEACHER SERVICES</p>
            </div>

            <div class="scroll-indicator">
                <p class="small mb-1 fw-bold">SCROLL DOWN FOR ANNOUNCEMENTS</p>
                <div class="bounce-arrow">↓</div>
            </div>
        </section>

        <section class="justify-content-center item-alignment-center">
            <div class="content-card shadow-lg">
                <div class="row g-4">
                    <div class="col-md-7">
                        <h3 class="mb-4 text-primary fw-bold">Latest Announcements</h3>
                        <div style="max-height: 500px; overflow-y: auto; padding-right: 15px;">
                            <%
                                String sql1 = "SELECT * FROM announcements ORDER BY date_post DESC";
                                PreparedStatement p1 = c.prepareStatement(sql1);
                                ResultSet r1 = p1.executeQuery();
                                while (r1.next()) {
                                    String topic = r1.getString("topic");
                                    String cleanTopic = topic.replace("'", "\\'").replace("\"", "&quot;");
                                    String rawContent = r1.getString("content");
                                    String cleanContent = rawContent.replace("'", "\\'").replace("\"", "&quot;").replace("\n", "<br>");
                                    String author = (r1.getString("author_name") != null) ? r1.getString("author_name") : "Official News";
                                    String pos = (r1.getString("author_position") != null) ? r1.getString("author_position") : "";

                            %>
                            <div class="p-4 bg-white border rounded shadow-sm mb-3">
                                <div class="d-flex justify-content-between">
                                    <h5 class="fw-bold text-dark"><%= topic%></h5>
                                    <small class="text-muted"><%= r1.getString("date_post")%></small>
                                </div>
                                <p class="text-secondary small mb-2">
                                    <strong class="text-primary"><%= author%></strong> <%= pos.isEmpty() ? "" : "- " + pos%>
                                </p>
                                <div class="text-muted small line-clamp-3 mb-3"><%= rawContent%></div>
                                <button class="btn btn-sm btn-outline-primary rounded-pill px-3" 
                                        onclick="openAnnouncement('<%= cleanTopic%>', '<%= cleanContent%>', '<%= author%>', '<%= pos%>')">
                                    Read Full Article
                                </button>
                            </div>
                            <%
                                    }
                                    c.close();
                                } catch (Exception e) {
                                    out.println(e);
                                }
                            %>
                        </div>
                    </div>

                    <div class="col-md-5">
                        <div class="p-4 bg-dark academic-calendar-container text-white rounded h-100 d-flex flex-column shadow" style="max-height: 560px; flex-grow: 1;">
                            <h5 class="fw-bold">Academic Calendar</h5>
                            <div style="height: 530px; display: flex; flex-direction: column; overflow: hidden;overflow-y: auto; padding-right:10px;margin-right:-15px; margin-bottom:20px;">
                                <ul class="list-unstyled mt-3 flex-grow-1">
                                    <%
                                        try {
                                            DateTimeFormatter inputFormat = DateTimeFormatter.ofPattern("yyyy-MM-dd");
                                            DateTimeFormatter outputFormat = DateTimeFormatter.ofPattern("dd MMMM yyyy", Locale.ENGLISH);
                                            Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                                            String sql2 = "SELECT * FROM academic_calendar ORDER BY event_id ASC";
                                            PreparedStatement p2 = c.prepareStatement(sql2);
                                            ResultSet r2 = p2.executeQuery();
                                            while (r2.next()) {
                                                String rawStart = r2.getString("start_date");
                                                String rawEnd = r2.getString("end_date");

                                                // 2. Format them to "24 December 2025"
                                                String formattedStart = LocalDate.parse(rawStart, inputFormat).format(outputFormat);
                                                String formattedEnd = (rawEnd != null) ? LocalDate.parse(rawEnd, inputFormat).format(outputFormat) : "";

                                                String calendarDetails = r2.getString("details") != null ? r2.getString("details").replace("'", "\\'").replace("\n", "<br>").replace("\"", "&quot;") : "No additional details.";
                                                String calendarTopic = r2.getString("short_info").replace("'", "\\'").replace("\"", "&quot;");
                                    %>
                                    <li class="mb-3 border-bottom border-secondary pb-3">
                                        <span class="text-info fw-bold" style="font-size: 0.9rem;">
                                            <%= formattedStart%> <%= !formattedEnd.isEmpty() && !formattedEnd.equals(formattedStart) ? " - " + formattedEnd : ""%>
                                        </span><br>

                                        <div class="d-flex justify-content-between align-items-start mt-1">
                                            <span class="text-white"><%= r2.getString("short_info")%></span>

                                            <button class="btn btn-sm btn-link text-info p-0 ms-2" 
                                                    style="text-decoration: none; font-size: 0.75rem;"
                                                    onclick="openAnnouncement('<%= calendarTopic%>', '<%= calendarDetails%>', 'Academic Office', 'Calendar Event')">
                                                View Details
                                            </button>
                                        </div>
                                    </li>
                                    <%
                                            }
                                            c.close();
                                        } catch (Exception e) {
                                            out.println(e);
                                        }
                                    %>
                                </ul>
                            </div>
                            <div class="mt-auto text-center">
                                <button class="btn btn-info btn-sm w-100 fw-bold" onclick="openAnnouncement('Contact IT Support', 'kbtubkk@kbtu.edu.com\n+66 123456789', 'KBTU Support Team', '')">Contact IT Support</button>
                            </div>
                        </div>
                    </div>
                </div> 
            </div>

        </section>
        <p style="font-size: 0.85rem; color: #666; margin-top:-35px; text-align: center; margin-left:270px;">
            © 2025 K-Frontier Business & Tech University. All rights reserved.
        </p>
        <div class="modal fade" id="announcementModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg">
                <div class="modal-content shadow-lg">
                    <div class="modal-header d-block bg-light">
                        <h4 class="modal-title fw-bold text-primary" id="m-topic"></h4>
                        <p class="mb-0 text-muted small" id="m-author"></p>
                    </div>
                    <div class="modal-body p-4" id="m-content" style="white-space: pre-line;"></div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>
        <script>
            function openAnnouncement(topic, content, name, pos) {
                document.getElementById('m-topic').innerText = topic;
                document.getElementById('m-author').innerText = "By " + name + (pos ? " (" + pos + ")" : "");
                document.getElementById('m-content').innerHTML = content;
                new bootstrap.Modal(document.getElementById('announcementModal')).show();
            }
            function toggleSidebar() {
                document.querySelector('.sidebar').classList.toggle('open');
                document.getElementById('sidebarOverlay').classList.toggle('open');
            }
        </script>

    </body>
</html>