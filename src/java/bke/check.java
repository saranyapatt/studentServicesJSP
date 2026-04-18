/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package bke;

import at.favre.lib.crypto.bcrypt.BCrypt;
import java.sql.*;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author mix
 */
@WebServlet(name = "check", urlPatterns = {"/check"})
public class check extends HttpServlet {

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
            String username = request.getParameter("username");
            String password = request.getParameter("password");

            if (username != null && password != null) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection c = DriverManager.getConnection("jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false", "root", "1234");
                    String sql = "SELECT * FROM userReg WHERE user = ?";
                    PreparedStatement p = c.prepareStatement(sql);
                    p.setString(1, username);
                    ResultSet r = p.executeQuery();
                    if (r.next()) {
                    BCrypt.Result result = BCrypt.verifyer().verify(password.toCharArray(), r.getString("password"));

                    if (result.verified) {
                        String role = r.getString("role");
                        HttpSession session = request.getSession();
                        session.setAttribute("username", username);
                        session.setAttribute("role", role);
                        Cookie cook = new Cookie("username", username);
                        cook.setMaxAge(60 * 20);

                        response.addCookie(cook);
                        cook = new Cookie("password", password);
                        cook.setMaxAge(60 * 20);
                        response.addCookie(cook);

                        cook = new Cookie("role", (String) session.getAttribute("role"));
                        cook.setMaxAge(60 * 20);
                        response.addCookie(cook);
                        System.out.print("success");
                        if (role.equals("Student")) {
                            response.sendRedirect("loggedMain.jsp");
                        } else if (role.equals("Teacher")) {
                            response.sendRedirect("loggedMainTeacher.jsp");
                        } else if (role.equals("Admin")) {
                            response.sendRedirect("loggedMainAdmin.jsp");
                        }
                    } else {
                        response.sendRedirect("index.jsp?error=invalidPass");
                        Thread.sleep(2000);
                        response.sendRedirect("index.jsp");
                    }
                    
                    c.close();
                    } else {
                        response.sendRedirect("index.jsp?error=userNotFound");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
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
