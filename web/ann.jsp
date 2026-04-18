<%
            String username = (String) session.getAttribute("username");
            String role = (String) session.getAttribute("role");

            if (username == null || !"Admin".equals(role)) {
                response.sendRedirect("index.jsp");
                return;
            }
        %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Admin - Announcement CRUD</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.3.1.min.js"></script>
        <script src="https://unpkg.com/gijgo@1.9.14/js/gijgo.min.js" type="text/javascript"></script>
        <link href="https://unpkg.com/gijgo@1.9.14/css/gijgo.min.css" rel="stylesheet" type="text/css">
        <link href="./customcss/gradecss.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    </head>
    <body style="background-color: #f8f9fa;">

        <div class="sidebar shadow">
            <img src="./logo/logo.png" alt="Logo" style="width: 100%; margin-bottom: 20px;">
            <h5 class="mb-4 text-center">Admin: <%= username%></h5>
            <nav>
               <a href="loggedMainAdmin.jsp" class="nav-link-custom">🏠 Home</a>
                <a href="ann.jsp" class="nav-link-custom active">🎓 Announcement Panel</a>
                <a href="calendar.jsp" class="nav-link-custom ">📝 Calendar Panel</a>
                <a href="accountAdmin.jsp" class="nav-link-custom">👥 Account Management</a>

                <hr style="border-top: 1px solid black;">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <div class="main-content" style="margin-left: 270px; margin-right:20px; padding-top: 20px;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>Announcements Management</h2>
                <button class="btn btn-dark" onclick="initAddForm()">
                    <i class="bi bi-plus-circle me-2"></i>New Announcement
                </button>
            </div>

            <div class="login-container box-shadow border-radius-8 p-4 rounded" style="background: white;">
                <table class="table table-hover align-middle">
                    <thead class="table-primary">
                        <tr>
                            <th class="text-center">Date</th>
                            <th class="text-center">Topic</th>
                            <th class="text-center">Author</th>
                            <th class="text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                                Statement st = con.createStatement();
                                ResultSet rs = st.executeQuery("SELECT * FROM announcements ORDER BY date_post DESC");
                                while (rs.next()) {
                                    int id = rs.getInt("id");
                                    String topic = rs.getString("topic");
                                    String cleanTopic = topic.replace("'", "\\'").replace("\"", "&quot;");
                                    String rawContent = rs.getString("content");
                                    String cleanContent = rawContent.replace("'", "\\'").replace("\"", "&quot;").replace("\n", "<br>");
                                    String author = (rs.getString("author_name") != null) ? rs.getString("author_name") : "Official News";
                                    String pos = (rs.getString("author_position") != null) ? rs.getString("author_position") : "";
                                    String date = (rs.getString("dateend") != null) ? rs.getString("dateend") : String.valueOf(id);
                        %>
                        <tr>
                            <td class="text-center"><%= date%></td>
                            <td class="fw-bold px-2"><%= topic%></td>
                            <td class="px-2"><%= author%> <br><small class="text-muted"><%= pos%></small></td>
                            <td class="text-center">
                                <button class="btn btn-sm btn-outline-primary me-1" 
                                        onclick="viewDetails('<%=cleanTopic%>', '<%=cleanContent%>', '<%=author%>', '<%=pos%>', '<%=date%>')">
                                    <i class="bi bi-eye"></i>
                                </button>
                                <button class="btn btn-sm btn-outline-dark me-1" 
                                        onclick="editAnnouncement('<%=id%>', '<%=topic%>', '<%=cleanContent%>', '<%=author%>', '<%=pos%>', '<%=date%>')">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <a href="ann?action=delete&id=<%=id%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete?')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <% }
                                con.close();
                            } catch (Exception e) {
                                out.print(e.getMessage());
                            }%>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="modal fade" id="viewModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg" style="border-radius: 15px;">
                    <div class="modal-body p-4">
                        <h3 class="text-primary fw-bold mb-1" id="view_topic"></h3>
                        <p class="text-muted small mb-3">By <span id="view_author"></span> (<span id="view_pos"></span>)</p>
                        <hr>
                        <div class="my-4" style="line-height: 1.6; color: #333;" id="view_content"></div>
                        <div class="d-flex justify-content-end">
                            <button type="button" class="btn btn-secondary px-4 py-2" data-bs-dismiss="modal" style="border-radius: 10px;">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg">
                    <form id="announcementForm" action="ann" method="POST">
                        <div class="modal-header bg-dark text-white p-4">
                            <h5 class="modal-title" id="formModalTitle"><i class="bi bi-pencil-square me-2"></i>New Announcement</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <input type="hidden" name="id" id="form_id">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label fw-bold">Topic</label>
                                    <input type="text" name="topic" id="form_topic" class="form-control" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-bold">Content</label>
                                    <textarea name="content" id="form_content" class="form-control" rows="5" required></textarea>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Author Name</label>
                                    <input type="text" name="author_name" id="form_author" class="form-control" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Author Position</label>
                                    <input type="text" name="author_position" id="form_pos" class="form-control" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Posting Date</label>
                                    <input id="date_post" name="date_post" class="form-control" required>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" id="submitBtn" class="btn btn-primary px-4">Save Announcement</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script>
            $(document).ready(function () {
                $('#date_post').datepicker({
                    format: 'dd/mm/yyyy', 
                    autoclose: true,
                    maxDate: '31/12/2027',
                    showRightIcon: false
                });
            });
            function expandAndRefresh() {
                document.querySelector('.login-container').classList.add('expanded-box');
            }

            function viewDetails(topic, content, author, pos) {
                topic.replace("\\'", "'").replace("&quot;", "\"")
                content.replace("\\'", "'").replace("&quot;", "\"").replace("<br>", "\n");
                expandAndRefresh();
                $('#view_topic').text(topic);
                $('#view_author').text(author);
                $('#view_pos').text(pos);
                $('#view_content').text(content);
                var myModal = new bootstrap.Modal(document.getElementById('viewModal'));
                myModal.show();
            }

            function editAnnouncement(id, topic, content, author, pos, date) {
                expandAndRefresh();

                $('#formModalTitle').html('<i class="bi bi-pencil-square me-2"></i>Edit Announcement');
                $('#submitBtn')
                        .text('Update and Save Changes')
                        .removeClass('btn-primary')
                        .addClass('btn-success');

                $('#form_id').val(id);
                $('#form_topic').val(topic);
                $('#form_content').val(content);
                $('#form_author').val(author);
                $('#form_pos').val(pos);
                $('#date_post').val(date).toString();
                localStorage.setItem("date", $('#date_post').val(date).toString());
                var myModal = new bootstrap.Modal(document.getElementById('editModal'));
                myModal.show();

                $('#submitBtn').off('click').on('click', function (e) {
                    e.preventDefault();


                    fetch(
                            'ann?' +
                            'id=' + encodeURIComponent(id) +
                            '&topic=' + encodeURIComponent($('#form_topic').val()) +
                            '&content=' + encodeURIComponent($('#form_content').val()) +
                            '&author=' + encodeURIComponent($('#form_author').val()) +
                            '&pos=' + encodeURIComponent($('#form_pos').val()) +
                            '&date=' + encodeURIComponent($('#date_post').val()) +
                            '&action=update'
                            )
                            .then(response => response.text())
                            .then(data => {
                                if (data.trim() === "success") {
                                    alert("Announcement updated successfully");
                                    location.reload();
                                } else {
                                    alert("Server error: " + data);
                                }
                            })
                            .catch(error => {
                                console.error('Fetch error:', error);
                                alert("Failed to connect to server");
                            });
                });
            }


            function initAddForm() {
                expandAndRefresh();

                $('#formModalTitle').html('<i class="bi bi-megaphone-fill me-2"></i>New Announcement');
                $('#submitBtn')
                        .text('Publish Announcement')
                        .removeClass('btn-success')
                        .addClass('btn-primary');
                var myModal = new bootstrap.Modal(document.getElementById('editModal'));
                myModal.show();


            }
        </script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>