# 🎓 Student Services System

A dynamic web application for managing academic services, developed using **Java Server Pages (JSP)** and **Bootstrap 5**. The system features a role-based access control (RBAC) mechanism where Students, Teachers, and Admins access a unified platform with content tailored to their specific permissions.

## 🌟 Key Features

### 👤 Student Role
* **Main Dashboard:** Displays a personalized calendar and upcoming school events/announcements.
* **Enrollment Request:** A dedicated interface for students to submit applications for courses.
* **Performance Tracking:** A dashboard to monitor academic grades and overall study progress.

### 👨‍🏫 Teacher Role
* **Grading Management:** Access to view and manage grades for students under their supervision.
* **Student Profiles:** View detailed academic information of students.
* **Enrollment Approval:** An interface to review, approve, or decline student enrollment requests.

### 🛡️ Admin Role
* **Account Management:** Full control to add, update, or manage user accounts (Students, Teachers, and Admins).
* **Event Scheduling:** Ability to manage the system calendar by adding new dates and school-wide events.
* **System Oversight:** Administrative tools to ensure the smooth operation of the service.

---

## 🛠️ Technical Stack

* **Language:** Java
* **Web Technology:** Java Server Pages (JSP)
* **Logic Components:** Java Servlets & JavaBeans
* **Database:** MySQL with JDBC Connectivity
* **Frontend UI:** Bootstrap 5, HTML5, CSS3, and JavaScript

## 📂 Project Structure

* `bke/`: Contains backend Java classes for core logic (Login check, Registration, etc.)
* `login/`: Dedicated JSP files for authentication and user sessions.
* `index.jsp`: The main entry point that dynamically renders content based on user roles.

---
*This project was developed to demonstrate the implementation of role-based web systems using JSP.*
