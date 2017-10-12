package com.common.entity;

import com.common.PostgreSQL;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class Author {
    private Integer id;
    private String name;
    private static Integer counter=0;
    private static final String statement = "INSERT INTO author(author_id, author_name) VALUES (?,?)";

    public Author() {
        this.id = generateID();
        this.name = null;
    }

    public static Integer generateID(){
        counter++;
        return counter;
    }


    public void setAuthorID(Integer id) {
        this.id = id;
    }

    public Integer getID() {
        return this.id;
    }

    public void setName(String name) {
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

    public String getStatement(){
        return statement;
    }

    public static void main(String[] args) {
        Author author = new Author();
        author.setName("Stefan");

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
