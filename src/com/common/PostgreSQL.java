package com.common;

import java.sql.*;
import java.util.Properties;


public class PostgreSQL {

    private Connection connection;

    public PostgreSQL(){
        try {
            //Class.forName("java.sql.Driver");
            String url = "jdbc:postgresql://localhost:5432/cz4031_project1";
            Properties prop = new Properties();
            prop.setProperty("user", "cz4031");
            //prop.setProperty("password", "cz4031");
            Connection conn = DriverManager.getConnection(url, prop);
            conn.setAutoCommit(false);
            System.out.println("Database successfully connected");

            this.connection = conn;
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Connection getConnection() {
        return this.connection;
    }

    public void closeConnection() throws SQLException{
        this.connection.close();
    }
}
