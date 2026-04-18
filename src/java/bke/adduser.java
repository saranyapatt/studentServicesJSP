/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package bke;

import at.favre.lib.crypto.bcrypt.BCrypt;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 *
 * @author mix
 */
@WebServlet(name = "adduser", urlPatterns = {"/adduser"})
@MultipartConfig(maxFileSize = 16177215)
public class adduser extends HttpServlet {

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
            out.println("<title>Servlet adduser</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet adduser at " + request.getContextPath() + "</h1>");
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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String username = request.getParameter("id");

        PrintWriter out = response.getWriter();
        if (action.equals("delete")) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");

                Connection con = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                String sql = "DELETE FROM admin_teacher WHERE user = ?";
                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, username);
                int rowsUpdated = ps.executeUpdate();
                if (rowsUpdated > 0) {
                    response.sendRedirect("accountAdmin.jsp");
                }

            } catch (Exception e) {
                out.print(e);
            }
        }
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
        String action = request.getParameter("action");
        String username = request.getParameter("username");
        String fname = request.getParameter("fname");
        String lname = request.getParameter("lname");
        String email = request.getParameter("email");
        String idCard = request.getParameter("id_card");
        String phone = request.getParameter("phone");
        String dob = request.getParameter("dob");
        String role = request.getParameter("role");
        String password = request.getParameter("password");
        Part filePart = request.getPart("profile_pic");
        InputStream pic = filePart.getInputStream();

        if (password == null || password.trim().isEmpty()) {
            password = phone;
        }
        String bcryptHashString = BCrypt.withDefaults().hashToString(12, password.toCharArray());
        if (action.equals("update")) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");

                // --- 1. UPDATE admin_teacher ---
                // Build SQL dynamically based on whether a new picture was uploaded
                boolean hasNewPic = (filePart != null && filePart.getSize() > 0);
                String sql = "UPDATE admin_teacher SET name = ?, surname = ?, tel = ?, dob = ?, role = ?, email = ?"
                        + (hasNewPic ? ", picture = ?" : "") + " WHERE user = ?";

                PreparedStatement ps = con.prepareStatement(sql);
                ps.setString(1, fname);
                ps.setString(2, lname);
                ps.setString(3, phone);
                ps.setString(4, dob);
                ps.setString(5, role);
                ps.setString(6, email);

                if (hasNewPic) {
                    ps.setBinaryStream(7, filePart.getInputStream());
                    ps.setString(8, username);
                } else {
                    ps.setString(7, username);
                }
                ps.executeUpdate();

                String sql1 = "UPDATE userReg SET password = ?, name = ?, surname = ?, phone = ?, role = ?, dob = ? WHERE user = ?";
                PreparedStatement ps1 = con.prepareStatement(sql1);
                ps1.setString(1, bcryptHashString);
                ps1.setString(2, fname);
                ps1.setString(3, lname);
                ps1.setString(4, phone);
                ps1.setString(5, role);
                ps1.setString(6, dob);
                ps1.setString(7, username);

                int rowsUpdated = ps1.executeUpdate();
                if (rowsUpdated > 0) {
                    response.sendRedirect("accountAdmin.jsp");
                }

                con.close();
            } catch (Exception e) {
                response.getWriter().print(e + " from update");
            }
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                String sql = "INSERT INTO userReg (user, password, name, surname, phone, id, dob, role) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = con.prepareStatement(sql);

                ps.setString(1, username);         // user
                ps.setString(2, bcryptHashString);     // password
                ps.setString(3, fname);         // name
                ps.setString(4, lname);      // surname
                ps.setString(5, phone);        // phone
                ps.setString(6, idCard);      // id
                ps.setString(7, dob);          // dob
                ps.setString(8, role);         // role

                int rowsUpdated = ps.executeUpdate();
                if (rowsUpdated > 0) {
                    System.out.println("Update successful!");
                }
                String sql1 = "INSERT INTO admin_teacher (teacher_id, name, surname, card_id, picture, role, email, tel, dob, user) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                String sql2 = "Select COUNT(*) from admin_teacher where role = 'teacher'";
                PreparedStatement ps2 = con.prepareStatement(sql2);
                ResultSet rs = ps2.executeQuery();
                int tid = 1000;

                if (rs.next()) {
                    tid = tid + rs.getInt(1);
                }
                PreparedStatement ps1 = con.prepareStatement(sql1);
                ps1.setString(1, String.valueOf(tid));
                ps1.setString(2, fname);
                ps1.setString(3, lname);
                ps1.setString(4, idCard);
                ps1.setBinaryStream(5, pic);
                ps1.setString(6, role);
                ps1.setString(7, email);
                ps1.setString(8, phone);
                ps1.setString(9, dob);
                ps1.setString(10, username);
                rowsUpdated = ps1.executeUpdate();
                if (rowsUpdated > 0) {
                    System.out.println("Update successful!");
                    response.sendRedirect("accountAdmin.jsp");
                }

            } catch (Exception e) {
                PrintWriter out = response.getWriter();
                out.print(e);
            }
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
