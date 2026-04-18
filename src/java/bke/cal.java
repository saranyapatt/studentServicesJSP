package bke;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 *
 * @author mix
 */
@WebServlet(urlPatterns = {"/cal"})
public class cal extends HttpServlet {

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
                String sql = "DELETE FROM academic_calendar WHERE event_id = ?";
                PreparedStatement pre = c.prepareStatement(sql);
                pre.setString(1, id);

                int rows = pre.executeUpdate();

                if (rows > 0) {
                    response.sendRedirect("calendar.jsp");
                } else {
                    response.getWriter().write("not_found");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("error process from delete");
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
        String topic = request.getParameter("topic");
        String content = request.getParameter("content");
        String date = request.getParameter("start_date");
        String edate = request.getParameter("end_date");
        String action = (request.getParameter("action"));
        if (action == null) {
            action = "add";
        }
        if ("delete".equals(action)) {
            handleDelete(request, response);
        } else {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c = DriverManager.getConnection(
                        "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false",
                        "root",
                        "1234");
                String sql = "INSERT INTO academic_calendar (start_date, end_date, short_info, details) VALUES (?, ?, ?, ?)";
                PreparedStatement pre = c.prepareStatement(sql);
                pre.setString(1, date);
                pre.setString(2, edate);
                pre.setString(3, topic);
                pre.setString(4, content);
                int rows = pre.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect("calendar.jsp");
                } else {
                    response.getWriter().write("not_found");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("error process from add");
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

        String id = request.getParameter("id");
        String topic = request.getParameter("topic");
        String content = request.getParameter("content");
        String date = request.getParameter("start_date");
        String edate = request.getParameter("end_date");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection c = DriverManager.getConnection(
                    "jdbc:mysql://localhost/studentServices?allowPublicKeyRetrieval=true&useSSL=false",
                    "root",
                    "1234");

            String sql = "UPDATE academic_calendar SET start_date = ?, end_date = ?, short_info = ?, details = ? WHERE event_id = ?";
            PreparedStatement pre = c.prepareStatement(sql);
            pre.setString(1, date);
            pre.setString(2, edate);
            pre.setString(3, topic);
            pre.setString(4, content);
            pre.setString(5, id);
            int rows = pre.executeUpdate();

            if (rows > 0) {
                response.sendRedirect("calendar.jsp");
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
