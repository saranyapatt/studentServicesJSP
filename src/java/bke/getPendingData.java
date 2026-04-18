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
import java.util.*;
import java.sql.*;

/**
 *
 * @author mix
 */
@WebServlet(name = "getPendingData1", urlPatterns = {"/getPendingData"})
public class getPendingData extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet getPendingData</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet getPendingData at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
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
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String id = req.getParameter("studentId");
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();

        if (id == null || id.trim().isEmpty()) {
            out.print("{\"error\":\"No ID provided\"}");
            return;
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234")) {

                // 1. Get Finance Status
                int financeStatus = 0;
                // Changed id_number to student_id to match JSP
                PreparedStatement psFinance = conn.prepareStatement("SELECT finance FROM student_profile WHERE student_id = ?");
                psFinance.setString(1, id);
                ResultSet rsFinance = psFinance.executeQuery();
                if (rsFinance.next()) {
                    financeStatus = rsFinance.getInt("finance");
                }

                // 2. Get Courses
                Map<String, String> courses = new LinkedHashMap<>();
                String sqlCourses = "SELECT course_code, course_title FROM course_name "
                        + "WHERE FIND_IN_SET(course_code, (SELECT pending_courses FROM student_profile WHERE student_id = ?))";
                PreparedStatement psCourses = conn.prepareStatement(sqlCourses);
                psCourses.setString(1, id);
                ResultSet rsCourses = psCourses.executeQuery();
                while (rsCourses.next()) {
                    courses.put(rsCourses.getString("course_code"), rsCourses.getString("course_title"));
                }

                // 3. Build JSON
                StringBuilder json = new StringBuilder();
                json.append("{");
                json.append("\"financeStatus\":").append(financeStatus).append(",");
                json.append("\"courses\": {");
                int count = 0;
                for (Map.Entry<String, String> entry : courses.entrySet()) {
                    json.append("\"").append(entry.getKey()).append("\":\"").append(entry.getValue()).append("\"");
                    if (++count < courses.size()) json.append(",");
                }
                json.append("}}");
                out.print(json.toString());
            }
        } catch (Exception e) {
            out.print("{\"error\":\"" + e.getMessage() + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String id = request.getParameter("studentId");
        String action = request.getParameter("action"); 
        response.setContentType("text/plain");
        PrintWriter out = response.getWriter();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234")) {
                String sql;
                if ("approve".equals(action)) {
                    // Logic: Move pending to registered, then clear pending
                    sql = "UPDATE student_profile SET registered_courses = pending_courses, pending_courses = NULL WHERE student_id = ?";
                } else {
                    sql = "UPDATE student_profile SET pending_courses = NULL WHERE student_id = ?";
                }

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, id);
                
                if (ps.executeUpdate() > 0) {
                    out.print("success");
                } else {
                    out.print("error: student not found");
                }
            }
        } catch (Exception e) {
            out.print("error: " + e.getMessage());
        }
    }
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
   


