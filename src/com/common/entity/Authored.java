package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class Authored {
    private PreparedStatement authoredStatement;
    private Integer author_id;
    private Integer pub_id;
    private static String statement = "INSERT INTO authored(pub_id, author_id) VALUES (?,?)";

    public Authored() {
        this.pub_id=null;
        this.author_id=null;
    }

    public Authored(Integer pub_id, Integer author_id) {
        this.pub_id=pub_id;
        this.author_id= author_id;
    }

    public void setAuthorId(Integer author_id) {
        this.author_id = author_id;
    }

    public Integer getAuthorId(){
        return this.author_id;
    }


    public void setPubId(Integer pub_id) {
        this.pub_id = pub_id;
    }

    public Integer getPubId() {
        return this.pub_id;
    }

    private PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException{
        pst.setObject(1, this.pub_id);
        pst.setObject(2, this.author_id);
        return pst;
    }

    public PreparedStatement generateStatement(Connection connection) throws SQLException{
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }


}
