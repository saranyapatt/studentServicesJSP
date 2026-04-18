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
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 *
 * @author mix
 */
@WebServlet(name = "ann", urlPatterns = {"/ann"})
public class ann extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");
        String action = request.getParameter("action");
        String id = request.getParameter("id");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection c = DriverManager.getConnection(
                    "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false",
                    "root",
                    "1234");

            if ("delete".equals(action)) {
                String sql = "DELETE FROM announcements WHERE id = ?";
                PreparedStatement pre = c.prepareStatement(sql);
                pre.setString(1, id);

                int rows = pre.executeUpdate();

                if (rows > 0) {
                    response.sendRedirect("ann.jsp");
                } else {
                    response.getWriter().write("not_found");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("error process");
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
        String id = request.getParameter("id");
        String topic = request.getParameter("topic");
        String content = request.getParameter("content");
        String author = request.getParameter("author");
        String pos = request.getParameter("pos");
        String date = request.getParameter("date");
        String action = request.getParameter("action");

        response.setContentType("text/plain;charset=UTF-8");

        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c = DriverManager.getConnection(
                        "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false",
                        "root",
                        "1234");

                String sql = "UPDATE announcements "
                        + "SET topic = ?, content = ?, author_name = ?, author_position = ?, dateend = ? "
                        + "WHERE id = ?";

                PreparedStatement pre = c.prepareStatement(sql);
                pre.setString(1, topic);
                pre.setString(2, content);
                pre.setString(3, author);
                pre.setString(4, pos);
                pre.setString(5, date);
                pre.setString(6, id);

                int rows = pre.executeUpdate();

                if (rows > 0) {
                    response.getWriter().write("success");
                } else {
                    response.getWriter().write("not_found");
                }

            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("error");
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

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        String topic = request.getParameter("topic");
        String content = request.getParameter("content");
        String author = request.getParameter("author");
        String pos = request.getParameter("pos");
        String date = request.getParameter("date_post");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection c = DriverManager.getConnection(
                    "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false",
                    "root",
                    "1234");

            String sql = "INSERT INTO announcements (topic, content, author_name, author_position, dateend) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pre = c.prepareStatement(sql);
            pre.setString(1, topic);
            pre.setString(2, content);
            pre.setString(3, author);
            pre.setString(4, pos);
            pre.setString(5, date);

            int rows = pre.executeUpdate();

            if (rows > 0) {
                response.sendRedirect("ann.jsp");
            } else {
                response.getWriter().write("failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("error");
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
