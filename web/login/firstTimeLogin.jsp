<%@ page import="java.sql.*, java.util.Base64" %>
<%
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String name = "";
    String dob = "";
    String studentId = "";
    if (username == null || !"Student".equals(role)) {
        response.sendRedirect("index.jsp");
        return;
    }

%>

<!DOCTYPE html>
<html>
    <head>
        <title>Complete Your Profile</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <%            Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
            String sql = "SELECT * FROM student_profile WHERE id_number = ?";
            PreparedStatement p = c.prepareStatement(sql);
            p.setString(1, username);
            ResultSet r = p.executeQuery();
            String card = "";
            if (r.next()) {
                card = r.getString("id_number");
                name = r.getString("fullname");
                dob = r.getString("dob");
                studentId = r.getString("student_id");
            }
        %>
    </head>
    <body class="bg-light">

        <div class="container py-5">
            <div class="card mx-auto shadow" style="max-width: 800px;">
                <div class="card-body p-4">
                    <h4 class="text-primary fw-bold mb-4">First Time Login: Complete Profile</h4>

                    <form action="../finishreg" method="post" enctype="multipart/form-data">
                        <div class="row">
                            <div class="col-md-4 text-center border-end">
                                <div id="imagePreview" class="mx-auto mb-3" 
                                     style="width: 200px; height: 250px; border: 2px dashed #ccc; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                                    <span class="text-muted">No Image</span>
                                </div>
                                <input type="file" name="pfp" id="pfpInput" class="form-control form-control-sm" accept="image/*" required>
                                <small class="text-muted d-block mt-2">Upload Profile Picture</small>
                            </div>

                            <div class="col-md-8">
                                <h6 class="text-secondary fw-bold mb-3">General Information</h6>
                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold">Fullname</label>
                                        <input type="text" id="user_username" class="form-control" value="<%= name%>" readonly disabled>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold">Email Address</label>
                                        <input type="email" name="email" class="form-control" required>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold">Date of Birth</label>
                                        <input type="text" name="idcard" class="form-control" value="<%= dob%>" readonly disabled>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold">Student ID</label>
                                        <input type="text" name="idcard" class="form-control" value="<%= studentId%>" readonly disabled>
                                    </div>
                                </div>
                                    
            <div class="d-flex align-items-end">
  

    <button type="submit" class="btn btn-primary px-4 ms-auto">Save Profile</button>
</div>        </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script>
            $(document).ready(function () {
                // Image Preview Logic
                $('#pfpInput').change(function () {
                    const file = this.files[0];
                    if (file) {
                        let reader = new FileReader();
                        reader.onload = function (event) {
                            $('#imagePreview').html('<img src="' + event.target.result + '" style="width:100%; height:100%; object-fit:cover;">');
                            $('#imagePreview').css('border-style', 'solid');
                        }
                        reader.readAsDataURL(file);
                    }
                });
                $('#user_username').prop('readOnly', true);
            });
        </script>

    </body>
</html>