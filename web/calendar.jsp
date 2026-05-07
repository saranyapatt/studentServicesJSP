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
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Admin - Calendar Panel</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
        <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
        <link href="./customcss/gradecss.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">


        <style>
            .table-mild thead {
                background-color: #f1f4f0;
                color: #555;
            }
            .badge-date {
                background-color: #eef2f7;
                color: #556b85;
                border: 1px solid #d1d9e6;
                font-weight: 400;
            }
        </style>
    </head>
    <body style="background-color: #f8f9fa;">

        <div class="sidebar shadow">
            <img src="./logo/logo.png" alt="Logo" style="width: 100%; margin-bottom: 20px;">
            <h5 class="mb-4 text-center">Admin: <%= username%></h5>
            <nav>
                <a href="loggedMainAdmin.jsp" class="nav-link-custom">🏠 Home</a>
                <a href="ann.jsp" class="nav-link-custom">🎓 Announcement Panel</a>
                <a href="calendar.jsp" class="nav-link-custom active">📝 Calendar Panel</a>
                <a href="accountAdmin.jsp" class="nav-link-custom">👥 Account Management</a>
                <hr style="border-top: 1px solid black;">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <div class="main-content" style="margin-left: 250px; padding: 10px;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="p-3">Academic Calendar</h2>
                <button class="btn btn-dark p-2" onclick="initAddForm()">
                    <i class="bi bi-plus-circle me-2"></i>Add New Event
                </button>
            </div>

            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <table class="table table-hover align-middle mb-0 table-mild">
                    <thead>
                        <tr>
                            <th class="text-center py-3" style="width: 25%">DATE RANGE</th>
                            <th class="py-3 text-center">EVENT</th>
                            <th class="py-3 text-center">DESCRIPTION</th>
                            <th class="text-center py-3">ACTIONS</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                                Statement st = con.createStatement();
                                ResultSet rs = st.executeQuery("SELECT * FROM academic_calendar ORDER BY event_id DESC");
                                while (rs.next()) {
                                    int id = rs.getInt("event_id");
                                    String topic = rs.getString("short_info");
                                    String cleanTopic = topic.replace("'", "\\'").replace("\"", "&quot;");
                                    String rawContent = rs.getString("details");
                                    String cleanContent = rawContent.replace("'", "\\'").replace("\"", "&quot;").replace("\n", " ").replace("\r", "");
                                    String startDate = rs.getString("start_date");
                                    String endDate = rs.getString("end_date");
                        %>
                        <tr>
                            <td class="text-center">
                                <span class="badge badge-date rounded-pill px-3 py-2"><%= startDate%></span>
                                <span class="text-muted small mx-1">-</span>
                                <span class="badge badge-date rounded-pill px-3 py-2"><%= endDate%></span>
                            </td>

                            <td class="fw-bold"><%= topic%></td>
                            <td class="text-muted small"><%= (rawContent.length() > 60) ? rawContent.substring(0, 60) + "..." : rawContent%></td>
                            <td class="text-center">
                                <div class="btn-group">
                                    <button class="btn btn-sm btn-outline-secondary" title="View" 
                                            onclick="viewDetails('<%=cleanTopic%>', '<%=cleanContent%>', '<%=startDate%>', '<%=endDate%>')">
                                        <i class="bi bi-eye"></i>
                                    </button>

                                    <button class="btn btn-sm btn-outline-secondary" title="Edit" onclick="editEvent('<%=id%>', '<%=cleanTopic%>', '<%=cleanContent%>', '<%=startDate%>', '<%=endDate%>')">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <a href="cal?action=delete&id=<%=id%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Delete this event?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <% }
                                con.close();
                            } catch (Exception e) {
                                out.print("<tr><td colspan='4' class='text-center py-4 text-danger'>" + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="modal fade" id="editModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <form id="calendarForm" action="cal" method="POST">
                        <div class="modal-header bg-dark text-white p-4">
                            <h5 class="modal-title" id="formModalTitle">Calendar Event</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <input type="hidden" name="id" id="form_id">
                            <input type="hidden" name="action" id="form_action" value="add">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label fw-bold small text-muted text-uppercase">Event Name</label>
                                    <input type="text" name="topic" id="form_topic" class="form-control" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-bold small text-muted text-uppercase">Full Details</label>
                                    <textarea name="content" id="form_content" class="form-control" rows="4" required></textarea>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted text-uppercase">Start Date</label>
                                    <input type="text" id="start_date" name="start_date" class="form-control bg-white" readonly required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted text-uppercase">End Date</label>
                                    <input type="text" id="end_date" name="end_date" class="form-control bg-white" readonly required>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4">
                            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" id="submitBtn" class="btn btn-primary px-4">Save Event</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>


        <div class="modal fade" id="viewModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-black text-white p-4">
                        <h5 class="modal-title">Event Information</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <h4 id="display_topic" class="fw-bold mb-3"></h4>
                        <div class="mb-4">
                            <span class="badge badge-date rounded-pill px-3 py-2" id="display_start"></span>
                            <span class="mx-2 text-muted">-</span>
                            <span class="badge badge-date rounded-pill px-3 py-2" id="display_end"></span>
                        </div>
                        <label class="form-label fw-bold small text-muted text-uppercase">Description</label>
                        <p id="display_content" class="text-secondary" style="white-space: pre-wrap;"></p>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

        <script>
                                        let calendarModal; // สำหรับ Add/Edit
                                        let viewModalInstance; // สำหรับ View

                                        $(document).ready(function () {
                                            calendarModal = new bootstrap.Modal(document.getElementById('editModal'));
                                            viewModalInstance = new bootstrap.Modal(document.getElementById('viewModal'));

                                            $("#start_date, #end_date").datepicker({
                                                dateFormat: 'yy-mm-dd',
                                                changeMonth: true,
                                                changeYear: true
                                            });
                                        });

                                        function viewDetails(topic, content, sdate, edate) {
                                            let cleanT = topic.replace(/\\'/g, "'").replace(/&quot;/g, '"');
                                            let cleanC = content.replace(/\\'/g, "'").replace(/&quot;/g, '"');
                                            $('#display_topic').text(cleanT);
                                            $('#display_content').text(cleanC);
                                            $('#display_start').text(sdate);
                                            $('#display_end').text(edate);
                                            viewModalInstance.show();
                                        }

                                        // ฟังก์ชัน Add/Edit อื่นๆ ยังคงเดิม
                                        function initAddForm() {
//                                            let idsender = 'cal?id=new';
                                            $('#form_id').val('');
                                            $('#form_action').val('add');
                                            $('#formModalTitle').text('New Calendar Event');
                                            $('#calendarForm')[0].reset();
//                                            $('#calendarForm').attr('action', idsender);
                                            $('#calendarForm').attr('method', 'GET');
                                            calendarModal.show();
                                        }

                                        function editEvent(id, topic, content, start, end) {
                                            $('#form_id').val(id);
                                            $('#form_action').val('update');
                                            $('#formModalTitle').text('Edit Event');
                                            $('#form_topic').val(topic);
                                            $('#form_content').val(content);
                                            $('#start_date').val(start);
                                            $('#end_date').val(end);
                                            $('#calendarForm').attr('method', 'POST');
                                            calendarModal.show();

                                        }
        </script>
    </body>
</html>