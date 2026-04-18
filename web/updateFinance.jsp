<%@page import="java.sql.*"%>
<%
    String id = request.getParameter("studentId");
    if (id == null || id.isEmpty()) {
        out.print("No Student ID provided");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
        String sql = "UPDATE student_profile SET finance = 1 WHERE student_id = ?";
        PreparedStatement ps = c.prepareStatement(sql);
        ps.setString(1, id);
        
        int rows = ps.executeUpdate();
        if (rows > 0) {
            out.print("success");
        } else {
            out.print("Student not found in database.");
        }
        
        c.close();
    } catch (Exception e) {
        out.print("Database Error: " + e.getMessage());
    }
%>