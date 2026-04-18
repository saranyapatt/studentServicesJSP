package bke;

import at.favre.lib.crypto.bcrypt.BCrypt;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.*;

@WebServlet(name = "resetPassword", urlPatterns = {"/resetPassword"})
public class resetPassword extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        String dob = request.getParameter("dob"); // Expected format: yyyy-mm-dd
        String password = request.getParameter("new_pass");
        String passwordCon = request.getParameter("confirm_pass");

        // 1. Basic Validation
        if (id == null || dob == null || password == null || !password.equals(passwordCon)) {
            response.sendRedirect("index.jsp?error=passwordMisMatched");
            return;
        }

        Connection c = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");

            // 2. Hash and Update in one go
            String bcryptHashString = BCrypt.withDefaults().hashToString(12, password.toCharArray());
            
            // We filter by both id and dob. If both match, the row updates.
            String sql = "UPDATE userReg SET password = ? WHERE user = ? AND dob = ?";
            pstmt = c.prepareStatement(sql);
            pstmt.setString(1, bcryptHashString);
            pstmt.setString(2, id);
            pstmt.setString(3, dob);

            int rowsUpdated = pstmt.executeUpdate();

            if (rowsUpdated > 0) {
                // Success
                response.sendRedirect("index.jsp?status=resetSuccess");
            } else {
                // Either ID doesn't exist or DOB is wrong
                response.sendRedirect("index.jsp?error=wrongdob");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=serverError");
        } finally {
            // 3. Always close resources
            try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
            try { if (c != null) c.close(); } catch (Exception e) {}
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }
}