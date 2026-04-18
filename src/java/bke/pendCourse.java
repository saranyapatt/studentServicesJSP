/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package bke;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 *
 * @author mix
 */
@WebServlet(name = "pendCourse", urlPatterns = {"/pendCourse"})
public class pendCourse extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Prepare to send a text response back to JavaScript
        response.setContentType("text/plain;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();

        // IMPORTANT: Ensure "saveUser" matches the name you used when the student logged in
        String user = session.getAttribute("username").toString();
        String code = request.getParameter("courseCodes");

        if (user == null || code == null) {
            out.print("error: session expired or no data");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String dbUrl = "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false";

            try (Connection c = DriverManager.getConnection(dbUrl, "root", "1234")) {
                String sql1 = "SELECT pending_courses FROM student_profile WHERE id_number = ?";
                PreparedStatement p1 = c.prepareStatement(sql1);
                p1.setString(1, user);
                ResultSet r = p1.executeQuery();
                if (r.next()) {
                    String pending = r.getString("pending_courses");
                    if (pending != null && !pending.trim().isEmpty()) {
                        out.print("error: already request courses, Please contact the administrator");
                        return;
                    }
                }
                String sql = "UPDATE student_profile SET pending_courses = ? WHERE id_number = ?";
                PreparedStatement p = c.prepareStatement(sql);
                p.setString(1, code);
                p.setString(2, user);

                int rows = p.executeUpdate();
                if (rows > 0) {
                    out.print("success");
                } else {
                    out.print("error: user not found");
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
            out.print("error: " + e.getMessage());
        } finally {
            out.close();
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
