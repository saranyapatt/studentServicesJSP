<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    if (username == null || !"Admin".equals(role)) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.sql.*" %>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Admin - Account Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
        <link href="./customcss/gradecss.css" rel="stylesheet">

        <link href="https://unpkg.com/gijgo@1.9.14/css/gijgo.min.css" rel="stylesheet" type="text/css" />
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://unpkg.com/gijgo@1.9.14/js/gijgo.min.js" type="text/javascript"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

        <style>
            .status-active {
                color: #198754;
                font-weight: bold;
            }
            .status-locked {
                color: #dc3545;
                font-weight: bold;
            }
            .table-container {
                background: white;
                border-radius: 10px;
                padding: 20px;
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
                <a href="calendar.jsp" class="nav-link-custom ">📝 Calendar Panel</a>
                <a href="accountAdmin.jsp" class="nav-link-custom active">👥 Account Management</a>
                <hr style="border-top: 1px solid black;">
                <a href="logout" class="nav-link-custom text-danger">🚪 Logout</a>
            </nav>
        </div>

        <div class="main-content" style="margin-left: 270px; margin-right:20px; padding-top: 20px;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h2>User Account Management</h2>
                <button class="btn btn-dark" onclick="openAddModal()">
                    <i class="bi bi-person-plus-fill me-2"></i>Create New Account
                </button>
            </div>

            <div class="table-container shadow-sm">
                <table class="table table-hover align-middle">
                    <thead class="table-dark">
                        <tr>
                            <th class="text-center" style="width:35%">Fullname</th>
                            <th class="text-center" style="width:20%">Username</th>
                            <th class="text-center" style="width:20%">Email</th>
                            <th class="text-center" style="width:10%">Role</th>
                            <th class="text-center" style="width:15%">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                Connection con = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                                Statement st = con.createStatement();
                                ResultSet rs = st.executeQuery("SELECT * FROM admin_teacher");
                                while (rs.next()) {
                                    String id = rs.getString("teacher_id");
                                    String name = rs.getString("name") + " " + rs.getString("surname");
                                    String fname = rs.getString("name");
                                    String surname = rs.getString("surname");
                                    String card = rs.getString("card_id");
                                    String role_t = rs.getString("role");
                                    String tel = rs.getString("tel");
                                    String dob = rs.getString("dob");
                                    String email = rs.getString("email");
                                    String user = rs.getString("user");
                                    Blob blob = rs.getBlob("picture");
                                    String base64Image = "./logo/user.jpg";
                                    if (blob != null && blob.length() > 0) {

                                        byte[] imageBytes = blob.getBytes(1, (int) blob.length());
                                        String encoded = java.util.Base64.getEncoder().encodeToString(imageBytes);
                                        base64Image = "data:image/png;base64," + encoded;
                                    }
                        %>
                        <tr>
                            <td><%= name%></td>
                            <td class="fw-bold"><%= user%></td>
                            <td>
                                <%= email%>


                            </td>
                            <td class="text-center"><span class="badge bg-secondary"><%= role_t%></span></td>

                            <td class="text-center">
                                <button class="btn btn-sm btn-outline-success me-1" 
                                        onclick="viewUser('<%=id%>', '<%=user%>', '<%=email%>', '<%=role_t%>', '<%=dob%>', '<%=card%>', '<%=tel%>', '<%=fname%>', '<%=surname%>', '<%= base64Image%>')">
                                    <i class="bi bi-eye"></i>
                                </button>

                                <button class="btn btn-sm btn-outline-primary me-1" 
                                        onclick="editUser('<%=id%>', '<%=user%>', '<%=email%>', '<%=role_t%>', '<%=dob%>', '<%=card%>', '<%=tel%>', '<%=fname%>', '<%=surname%>', '<%= base64Image%>')">
                                    <i class="bi bi-pencil"></i>
                                </button>

                                <a href="adduser?action=delete&id=<%= user%>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure?')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <%
                                }
                                con.close();
                            } catch (Exception e) {
                                out.print("<tr><td colspan='6' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="modal fade" id="accountModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-lg"> <div class="modal-content border-0 shadow-lg">
                    <form id="accountForm" action="adduser" method="POST" enctype="multipart/form-data">
                        <div class="modal-header bg-dark text-white">
                            <h5 class="modal-title" id="modalTitle">Account Details</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body p-4">
                            <input type="hidden" name="id" id="user_id">
                            <input type="hidden" name="action" id="form_action" value="insert">

                            <div class="row">
                                <div class="col-md-4 text-center mb-3">
                                    <label class="form-label fw-bold d-block">Profile Picture</label>
                                    <div class="mb-2">
                                        <img id="imgPreview" src="assets/img/default-avatar.png" class="rounded-circle img-thumbnail" style="width: 150px; height: 150px; object-fit: cover;">
                                    </div>
                                    <input type="file" name="profile_pic" id="user_pic" class="form-control form-control-sm mt-3" accept="image/*" onchange="previewImage(this)">                                </div>

                                <div class="col-md-8">
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Username</label>
                                            <input type="text" name="username" id="user_username" class="form-control" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Email Address</label>
                                            <input type="email" name="email" id="user_email" class="form-control" required>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">First name</label>
                                            <input type="text" name="fname" id="fname" class="form-control" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Last name</label>
                                            <input type="text" name="lname" id="lname" class="form-control" required>
                                        </div>
                                    </div>



                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">ID Card Number</label>
                                            <input type="text" name="id_card" id="user_id_card" class="form-control" maxlength="13" placeholder="13 digits">
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Phone Number</label>
                                            <input type="tel" name="phone" id="user_phone" class="form-control" placeholder="08xxxxxxxx">
                                        </div>
                                    </div>

                                    <div class="row">
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Date of Birth</label>
                                            <input id="dob" name="dob" type="text" class="form-control p-2" style="height: 38px; border: 1px solid #dee2e6;" placeholder="  Date of Birth" required>
                                        </div>
                                        <div class="col-md-6 mb-3">
                                            <label class="form-label fw-bold">Role</label>
                                            <select name="role" id="user_role" class="form-select">
                                                <option value="Admin">Admin</option>
                                                <option value="Teacher">Teacher</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="mb-3" id="passwordSection">
                                        <label class="form-label fw-bold">Password</label>
                                        <input type="password" name="password" class="form-control" placeholder="Leave blank to use phone number">
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer bg-light">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                            <button type="submit" class="btn btn-primary">Save Changes</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>


        <script>
            $(document).ready(function () {
                $('#dob').datepicker({
                    format: 'dd-mm-yyyy',
                    autoclose: true,
                    minDate: '01-01-1955',
                    maxDate: '31-12-2011',
                    showRightIcon: false
                });
            });
            const accountModal = new bootstrap.Modal(document.getElementById('accountModal'));


            function openAddModal() {
                $('#modalTitle').text('Create New Account');
                $('#form_action').val('insert');
                $('#user_id').val('');
                $('#accountForm')[0].reset();

                // Ensure DOB is editable for new users
                $('#dob').prop('readonly', false).removeClass('bg-light').prop('disabled', false);

                $('#accountForm input, #accountForm select').prop('disabled', false);
                $('#accountForm .btn-primary').show();
                $('#user_pic').show();
                $('#passwordSection').show();

                $('#imgPreview').attr('src', 'assets/img/default-avatar.png');
                $('#user_username').prop('readonly', false).removeClass('bg-light');
                $('#user_id_card').prop('readonly', false).removeClass('bg-light');

                accountModal.show();
            }

            function editUser(id, username, email, role, dob, card, tel, fname, lname, pic) {
                $('#modalTitle').text('Edit Account: ' + username);
                $('#form_action').val('update');

                // RE-ENABLE FIELDS
                $('#accountForm input, #accountForm select').prop('disabled', false);
                $('#accountForm .btn-primary').show();
                $('#user_pic').show();
                $('#passwordSection').show();

                // Set Data
                $('#user_id').val(id);
                $('#fname').val(fname);
                $('#lname').val(lname);
                $('#user_username').val(username).attr('readonly', true).addClass('bg-light');
                $('#user_id_card').val(card).prop('readonly', true).addClass('bg-light');

                $('#user_email').val(email);
                $('#user_role').val(role);
                $('#user_phone').val(tel);
                $('#dob').val(dob).prop('readonly', true).addClass('bg-light');
                $('#imgPreview').attr('src', pic);

                $('#passwordSection label').text('Reset Password (Optional)');
                accountModal.show();
            }

            function previewImage(input) {
                if (input.files && input.files[0]) {
                    var reader = new FileReader();
                    reader.onload = function (e) {
                        document.getElementById('imgPreview').src = e.target.result;
                    }
                    reader.readAsDataURL(input.files[0]);
                }
            }

            function viewUser(id, username, email, role, dob, card, tel, fname, lname, pic) {
                $('#modalTitle').text('View Account: ' + username);
                $('#accountModal .modal-footer .btn-primary').hide();
                $('#passwordSection').hide();
                $('#user_pic').hide()
                $('#accountForm input, #accountForm select').prop('disabled', true);
                $('#user_id').val(id);
                $('#fname').val(fname);
                $('#lname').val(lname);
                $('#imgPreview').attr('src', pic);
                $('#user_username').val(username);
                $('#user_email').val(email);
                $('#user_role').val(role);
                $('#user_id_card').val(card);
                $('#user_phone').val(tel);
                $('#dob').val(dob);
                accountModal.show();
            }
        </script>
    </body>
</html>