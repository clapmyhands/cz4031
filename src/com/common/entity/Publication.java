package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;

public class Publication {
    private UUID id;
    private String key;
    private String title;
    private Integer year;
    private Integer month;
    private String statement;

    public Publication() {
        this.id = UUID.randomUUID();
        this.key = null;
        this.title = null;
        this.year = null;
        this.month = null;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public UUID getId(){
        return this.id;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public void setMonth(Integer month) {
        this.month = month;
    }


    PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException{
        pst.setObject(1, this.id);
        pst.setString(2, this.key);
        pst.setString(3, this.title);
        pst.setInt(4, this.year);
        pst.setInt(5, this.month);
        return pst;
    }

    public PreparedStatement generateStatement(Connection connection) throws SQLException{
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }
}
