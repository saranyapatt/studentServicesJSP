/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package bke;

import at.favre.lib.crypto.bcrypt.BCrypt;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author mix
 */
@WebServlet(name = "reg", urlPatterns = {"/reg"})
public class reg extends HttpServlet {

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
        String name = request.getParameter("name");
        String lastname = request.getParameter("surname");
        String phone = request.getParameter("tel");
        String id = request.getParameter("id");
        String dob = request.getParameter("dob");
        String user = id;
        String role = "Student";
        String password = phone;        
        String bcryptHashString = BCrypt.withDefaults().hashToString(12, password.toCharArray());
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */

//            String name = request.getParameter("name");
//            String lastname = request.getParameter("surname");
//            String phone = request.getParameter("tel");
//            String id = request.getParameter("id");
//            String dob = request.getParameter("dob");
//            String user = id;
//            String role = "Student";
//            String password = phone;
//            String bcryptHashString = BCrypt.withDefaults().hashToString(12, password.toCharArray());
            long sid = 670500000;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                String sql = "SELECT * FROM studentServices.userReg WHERE user = ? AND password = ?";
                String sql2 = "SELECT COUNT(*) AS total FROM studentServices.student_profile";
                PreparedStatement p1 = c.prepareStatement(sql2);
                ResultSet r1 = p1.executeQuery();
                if (r1.next()) {
                    int i = r1.getInt(1);
                    sid = sid + i;
                }
                PreparedStatement p = c.prepareStatement(sql);
                p.setString(1, user);
                p.setString(2, password);
                ResultSet r = p.executeQuery();
                if (!r.next()) {
                    String sql1 = "INSERT INTO studentServices.userReg (user, password, name, surname, phone, id, dob, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement pstmt = c.prepareStatement(sql1);
                    pstmt.setString(1, user);
                    pstmt.setString(2, bcryptHashString);
                    pstmt.setString(3, name);
                    pstmt.setString(4, lastname);
                    pstmt.setString(5, phone);
                    pstmt.setString(6, id);
                    pstmt.setString(7, dob);
                    pstmt.setString(8, role);
                    pstmt.executeUpdate();
                    response.sendRedirect("index.jsp");
                }
                String sql1 = "INSERT INTO studentServices.student_profile SET fullname = ?, telephone = ?, id_number = ?, dob = ?, registered_courses = ?, completed_courses = ?, gpa = ?, student_id = ?, finance = ?, grade = ?, pending_courses = ?";
                PreparedStatement newStudent = c.prepareStatement(sql1);
                newStudent.setString(1, name + " " + lastname);
                newStudent.setString(2, phone);
                newStudent.setString(3, id);
                newStudent.setString(4, dob);
                newStudent.setString(5, "COS1101, COS1103, RAM1111, MTH1101, RAM1101");
                newStudent.setString(6, "");
                newStudent.setString(7, "0.00");
                newStudent.setString(8, String.valueOf(sid));
                newStudent.setString(9, "1");
                newStudent.setString(10, "");
                newStudent.setString(11, "");
                newStudent.executeUpdate();
                c.close();
            } catch (Exception e) {
                out.println("<script>alert('Error occurred during registration');</script>");
                response.sendRedirect("index.jsp");

            }

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
