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
import java.sql.*;
import java.util.*;

/**
 *
 * @author mix
 */
@WebServlet(name = "getGrade", urlPatterns = {"/getGrade"})
public class getGrade extends HttpServlet {

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
            out.println("<title>Servlet getGrade</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet getGrade at " + request.getContextPath() + "</h1>");
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
        String type = req.getParameter("type");
        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");
        PrintWriter out = res.getWriter();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?useSSL=false", "root", "1234")) {

                // Step 1: Get the list of IDs from the student profile
                String courseCodes = "";
                PreparedStatement ps1 = c.prepareStatement("SELECT " + type + " FROM student_profile WHERE student_id = ?");
                ps1.setString(1, id);
                ResultSet rs1 = ps1.executeQuery();
                if (rs1.next()) {
                    courseCodes = rs1.getString(type);
                }

                StringBuilder json = new StringBuilder("{\"courses\": {");

                // Step 2: If we have codes, look up the titles in course_name
                if (courseCodes != null && !courseCodes.trim().isEmpty()) {
                    // Remove spaces to prevent FIND_IN_SET failure
                    courseCodes = courseCodes.replace(" ", "");

                    String sql = "SELECT course_code, course_title FROM course_name WHERE FIND_IN_SET(course_code, ?)";
                    PreparedStatement ps2 = c.prepareStatement(sql);
                    ps2.setString(1, courseCodes);
                    ResultSet rs2 = ps2.executeQuery();

                    boolean first = true;
                    while (rs2.next()) {
                        if (!first) {
                            json.append(",");
                        }
                        json.append("\"").append(rs2.getString("course_code")).append("\":\"")
                                .append(rs2.getString("course_title")).append("\"");
                        first = false;
                    }
                }

                json.append("}}");
                out.print(json.toString());
            }
        } catch (Exception e) {
            out.print("{\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        String studentId = req.getParameter("studentId");
        String newGrades = req.getParameter("grades");
        PrintWriter out = res.getWriter();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?useSSL=false", "root", "1234");

            // 1. Fetch current long strings
            String regStr = "", compStr = "", gradeStr = "";
            PreparedStatement psFetch = c.prepareStatement(
                    "SELECT registered_courses, completed_courses, grade, finance FROM student_profile WHERE student_id = ?"
            );
            psFetch.setString(1, studentId);
            ResultSet rs = psFetch.executeQuery();

            if (rs.next()) {
                compStr = (rs.getString("completed_courses") != null) ? rs.getString("completed_courses") : "";
                gradeStr = (rs.getString("grade") != null) ? rs.getString("grade") : "";
                regStr = (rs.getString("registered_courses") != null) ? rs.getString("registered_courses") : "";
            }
            String updatedComp = compStr;
            if (!regStr.isEmpty()) {
                updatedComp = compStr.isEmpty() ? regStr : compStr + "," + regStr;
            }

            String updatedGradeHistory = gradeStr;
            if (newGrades != null && !newGrades.isEmpty()) {
                updatedGradeHistory = gradeStr.isEmpty() ? newGrades : gradeStr + "," + newGrades;
            }

            double gpa = 0;
            if (!updatedGradeHistory.isEmpty()) {
                String[] gpas = updatedGradeHistory.split(",");
                double total = 0;
                for (String g : gpas) {
                    total += Double.parseDouble(g.trim());
                }
                gpa = total / gpas.length;
            }

            // 5. Update Database
            PreparedStatement psUpdate = c.prepareStatement(
                    "UPDATE student_profile SET completed_courses = ?, grade = ?, gpa = ?, finance = 0 WHERE student_id = ?"
            );
            psUpdate.setString(1, updatedComp.isEmpty() ? null : updatedComp);
            psUpdate.setString(2, updatedGradeHistory.isEmpty() ? null : updatedGradeHistory);
            psUpdate.setDouble(3, gpa); // Use setDouble for GPA
            psUpdate.setString(4, studentId);

            psUpdate.executeUpdate();

        } catch (Exception e) {
            out.print("System Error: " + e.getMessage());
        }
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
