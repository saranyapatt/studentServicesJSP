<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    if (username == null || !"Teacher".equals(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html" pageEncoding="UTF-8" %>

<%
    /* ─────────────────────────────────────────────
       CRUD HANDLER  (runs before HTML output)
       ───────────────────────────────────────────── */
    String action = request.getParameter("action");
    String msg = "";

    if (action != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false",
                    "root", "1234");

            if ("add".equals(action)) {
                String code = request.getParameter("course_code");
                String title = request.getParameter("course_title");
                String exam = request.getParameter("examdate");
                PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO course_name (course_code, course_title, examdate) VALUES (?,?,?)");
                ps.setString(1, code);
                ps.setString(2, title);
                ps.setString(3, exam);
                ps.executeUpdate();
                msg = "Course added successfully.";

            } else if ("update".equals(action)) {
                String originalCode = request.getParameter("original_code"); // PK to identify row
                String newCode = request.getParameter("course_code");
                String title = request.getParameter("course_title");
                String exam = request.getParameter("examdate");
                PreparedStatement ps = con.prepareStatement(
                        "UPDATE course_name SET course_code=?, course_title=?, examdate=? WHERE course_code=?");
                ps.setString(1, newCode);
                ps.setString(2, title);
                ps.setString(3, exam);
                ps.setString(4, originalCode);
                ps.executeUpdate();
                msg = "Course updated successfully.";

            } else if ("delete".equals(action)) {
                String code = request.getParameter("code");
                PreparedStatement ps = con.prepareStatement(
                        "DELETE FROM course_name WHERE course_code=?");
                ps.setString(1, code);
                ps.executeUpdate();
                msg = "Course deleted.";
            }

            con.close();
        } catch (Exception e) {
            msg = "Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Teacher – Course Management</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
        <link rel="stylesheet" href="https://code.jquery.com/ui/1.13.2/themes/base/jquery-ui.css">
        <link href="./customcss/gradecss.css" rel="stylesheet">

        <style>
            .sidebar {
                width: 250px;
                height: 100vh;
                background: white;
                position: fixed;
                box-shadow: 2px 0 10px rgba(0,0,0,0.1);
                padding: 20px;
            }
            .sidebar img {
                width: 100%;
                margin-bottom: 20px;
            }

            .nav-link-custom {
                padding: 12px;
                color: #333;
                text-decoration: none;
                display: block;
                border-radius: 5px;
                margin-bottom: 10px;
            }
            .nav-link-custom:hover {
                background-color: #0d6efd;
                color: white;
            }
            .nav-link-custom.active {
                background-color: #0d6efd;
                color: white;
            }
            .nav-link-custom.text-danger {
                color: #f87171 !important;
            }
            .main-content {
                margin-left: 250px;
                padding: 32px 28px;
                min-height: 100vh;
            }

            .table-mild thead {
                background-color: #f1f4f0;
                color: #555;
            }
            .badge-code {
                background: #e8f0fe;
                color: #3c5fa0;
                border: 1px solid #c5d5f5;
                font-weight: 500;
                font-size: .82rem;
                letter-spacing: .04em;
            }
            .badge-exam {
                background: #fef3e2;
                color: #7a4f00;
                border: 1px solid #f5dcab;
                font-weight: 400;
                font-size: .82rem;
            }

            /* ── Toast ── */
            #toastWrap {
                position: fixed;
                top: 20px;
                right: 24px;
                z-index: 9999;
            }

            /* ── jQuery UI datepicker z-index fix ── */
            .ui-datepicker {
                z-index: 9999 !important;
            }
        </style>
    </head>
    <body style="background-color: #f8f9fa;">

        <div class="sidebar shadow">
            <img src="./logo/logo.png" id="logo" alt="Logo" class="imgmain imgfil">
            <h5 class="mb-4 text-black text-center">Teacher <%= username%></h5> <nav>
                <a href="loggedMainTeacher.jsp" class="nav-link-custom">🏠 Home</a>
                <a href="teacherDashboard.jsp" class="nav-link-custom">📊 Dashboard</a>
                <a href="gradeAdmin.jsp" class="nav-link-custom">🎓 Grading</a>
                <a href="enrollmentAdmin.jsp" class="nav-link-custom">📝 Enrollment Approval</a>
                <a href="courseTeacher.jsp" class="nav-link-custom active">📚 Course Management</a>
                <hr style="border-top: 2px solid black;">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <!-- ───── Main Content ───── -->
        <div class="main-content">

            <!-- Header row -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2 class="p-1 mb-0">Course Management</h2>
                <button class="btn btn-dark px-3 py-2" onclick="initAddForm()">
                    <i class="bi bi-plus-circle me-2"></i>Add New Course
                </button>
            </div>

            <% if (!msg.isEmpty()) {%>
            <div id="toastWrap">
                <div class="toast show align-items-center text-white <%= msg.startsWith("Error") ? "bg-danger" : "bg-success"%> border-0 shadow"
                     role="alert" aria-live="assertive">
                    <div class="d-flex">
                        <div class="toast-body fw-semibold"><%= msg%></div>
                        <button type="button" class="btn-close btn-close-white me-2 m-auto" onclick="this.closest('.toast').remove()"></button>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Course Table -->
            <div class="card border-0 shadow-sm rounded-4 overflow-hidden">
                <table class="table table-hover align-middle mb-0 table-mild">
                    <thead>
                        <tr>
                            <th class="text-center py-3" style="width:15%">#</th>
                            <th class="text-center py-3" style="width:18%">COURSE CODE</th>
                            <th class="py-3">COURSE TITLE</th>
                            <th class="text-center py-3" style="width:18%">EXAM DATE</th>
                            <th class="text-center py-3" style="width:15%">ACTIONS</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int rowNum = 0;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection con2 = DriverManager.getConnection(
                                        "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false",
                                        "root", "1234");
                                Statement st2 = con2.createStatement();
                                ResultSet rs2 = st2.executeQuery(
                                        "SELECT * FROM course_name ORDER BY course_code ASC");

                                while (rs2.next()) {
                                    rowNum++;
                                    String code = rs2.getString("course_code");
                                    String title = rs2.getString("course_title");
                                    String examDate = rs2.getString("examdate");

                                    // escape for JS string literals in onclick attributes
                                    String safeCode = code.replace("'", "\\'").replace("\"", "&quot;");
                                    String safeTitle = title.replace("'", "\\'").replace("\"", "&quot;");
                        %>
                        <tr>
                            <td class="text-center text-muted small fw-semibold"><%= rowNum%></td>

                            <td class="text-center">
                                <span class="badge badge-code rounded-pill px-3 py-2">
                                    <%= code%>
                                </span>
                            </td>

                            <td class="fw-semibold"><%= title%></td>

                            <td class="text-center">
                                <span class="badge badge-exam rounded-pill px-3 py-2">
                                    <i class="bi bi-calendar2-week me-1"></i><%= examDate%>
                                </span>
                            </td>

                            <td class="text-center">
                                <div class="btn-group">
                                    <!-- View -->
                                    <button class="btn btn-sm btn-outline-secondary" title="View"
                                            onclick="viewDetails('<%= safeCode%>', '<%= safeTitle%>', '<%= examDate%>')">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <!-- Edit -->
                                    <button class="btn btn-sm btn-outline-secondary" title="Edit"
                                            onclick="editCourse('<%= safeCode%>', '<%= safeTitle%>', '<%= examDate%>')">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <!-- Delete -->
                                    <a href="courseTeacher.jsp?action=delete&code=<%= safeCode%>"
                                       class="btn btn-sm btn-outline-danger" title="Delete"
                                       onclick="return confirm('Delete course &quot;<%= safeTitle%>&quot;?')">
                                        <i class="bi bi-trash"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                        <%
                            }
                            con2.close();

                            if (rowNum == 0) {
                        %>
                        <tr>
                            <td colspan="5" class="text-center py-5 text-muted">
                                <i class="bi bi-inbox fs-3 d-block mb-2"></i>No courses found. Add your first course!
                            </td>
                        </tr>
                        <%
                            }
                        } catch (Exception e2) {
                        %>
                        <tr>
                            <td colspan="5" class="text-center py-4 text-danger">
                                <i class="bi bi-exclamation-triangle me-1"></i><%= e2.getMessage()%>
                            </td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div><!-- /main-content -->


        <!-- ═══════════════════════════════════
             MODAL – Add / Edit Course
        ═══════════════════════════════════ -->
        <div class="modal fade" id="courseModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <form id="courseForm" action="courseTeacher.jsp" method="POST">
                        <div class="modal-header bg-dark text-white p-4">
                            <h5 class="modal-title" id="modalTitle">Course Event</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <input type="hidden" name="original_code" id="form_original_code">
                            <input type="hidden" name="action"        id="form_action" value="add">

                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label fw-bold small text-muted text-uppercase">Course Code</label>
                                    <input type="text" name="course_code" id="form_code"
                                           class="form-control" placeholder="e.g. CS101" required
                                           maxlength="20">
                                </div>
                                <div class="col-md-8">
                                    <label class="form-label fw-bold small text-muted text-uppercase">Course Title</label>
                                    <input type="text" name="course_title" id="form_title"
                                           class="form-control" placeholder="e.g. Introduction to Computer Science" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold small text-muted text-uppercase">Exam Date</label>
                                    <input type="text" name="examdate" id="form_exam"
                                           class="form-control bg-white" placeholder="YYYY-MM-DD"
                                           readonly required>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer border-0 p-4">
                            <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="bi bi-floppy me-1"></i>Save Course
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>


        <!-- ═══════════════════════════════════
             MODAL – View Course
        ═══════════════════════════════════ -->
        <div class="modal fade" id="viewModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow">
                    <div class="modal-header bg-black text-white p-4">
                        <h5 class="modal-title">Course Details</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <span class="text-muted small fw-bold text-uppercase">Course Code</span>
                            <h5 id="view_code" class="mb-0 mt-1"></h5>
                        </div>
                        <div class="mb-3">
                            <span class="text-muted small fw-bold text-uppercase">Course Title</span>
                            <h4 id="view_title" class="fw-bold mt-1 mb-0"></h4>
                        </div>
                        <div>
                            <span class="text-muted small fw-bold text-uppercase">Exam Date</span><br>
                            <span class="badge badge-exam rounded-pill px-3 py-2 mt-1">
                                <i class="bi bi-calendar2-week me-1"></i>
                                <span id="view_exam"></span>
                            </span>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>


        <!-- ───── Scripts ───── -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://code.jquery.com/ui/1.13.2/jquery-ui.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <script>
                                           let courseModalInst, viewModalInst;

                                           $(document).ready(function () {
                                               courseModalInst = new bootstrap.Modal(document.getElementById('courseModal'));
                                               viewModalInst = new bootstrap.Modal(document.getElementById('viewModal'));

                                               $('#form_exam').datepicker({
                                                   dateFormat: 'yy-mm-dd',
                                                   changeMonth: true,
                                                   changeYear: true
                                               });

                                               setTimeout(() => {
                                                   const t = document.querySelector('#toastWrap .toast');
                                                   if (t)
                                                       t.remove();
                                               }, 4000);
                                           });

                                           /* ── Open ADD form ── */
                                           function initAddForm() {
                                               $('#modalTitle').text('Add New Course');
                                               $('#form_action').val('add');
                                               $('#form_original_code').val('');
                                               $('#form_code').prop('readonly', false);  // code is editable on add
                                               $('#courseForm')[0].reset();
                                               $('#form_exam').val('');
                                               courseModalInst.show();
                                           }

                                           /* ── Open EDIT form ── */
                                           function editCourse(code, title, exam) {
                                               $('#modalTitle').text('Edit Course');
                                               $('#form_action').val('update');
                                               $('#form_original_code').val(code);      // PK sent as original_code
                                               $('#form_code').val(code.replace(/\\'/g, "'").replace(/&quot;/g, '"'));
                                               $('#form_code').prop('readonly', true);  // prevent PK change mid-edit
                                               $('#form_title').val(title.replace(/\\'/g, "'").replace(/&quot;/g, '"'));
                                               $('#form_exam').val(exam);
                                               courseModalInst.show();
                                           }

                                           /* ── Open VIEW modal ── */
                                           function viewDetails(code, title, exam) {
                                               $('#view_code').text(code.replace(/\\'/g, "'").replace(/&quot;/g, '"'));
                                               $('#view_title').text(title.replace(/\\'/g, "'").replace(/&quot;/g, '"'));
                                               $('#view_exam').text(exam);
                                               viewModalInst.show();
                                           }
        </script>
    </body>
</html>
