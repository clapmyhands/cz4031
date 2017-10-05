package com.common.entity;

import com.common.PostgreSQL;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;

public class Author {
    private UUID id;
    private String name;
    private static String statement = "INSERT INTO author(pub_id, name) VALUES (?,?)";

    public Author() {
        this.id = null;
        this.name = null;
    }

    public Author(UUID id) {
        this.id = id;
        this.name = null;
    }

    public void setAuthorID(UUID id) {
        this.id = id;
    }

    public UUID getAuthorID() {
        return this.id;
    }

    public void setAuthorName(String name) {
        this.name = name;
    }

    PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException {
        pst.setObject(1, this.id);
        pst.setString(2, this.name);
        return pst;
    }

    public PreparedStatement generateStatement(Connection connection) throws SQLException{
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }

    public static void main(String[] args) {
        Author author = new Author();
        author.setAuthorName("Stefan");

        PostgreSQL postgreSQL = new PostgreSQL();
        Connection conn = postgreSQL.getConnection();
        try{
            PreparedStatement pst = author.generateStatement(conn);
            System.out.println(pst.toString());
            pst.close();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

    }

}
