package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

public class Authored {
    private PreparedStatement authoredStatement;
    private UUID author_id;
    private UUID pub_id;
    private static String statement = "INSERT INTO authored(pub_id, author_id) VALUES (?,?)";

    public Authored() {
        this.pub_id=null;
        this.author_id=null;
    }

    public Authored(UUID pub_id, UUID author_id) {
        this.pub_id=pub_id;
        this.author_id= author_id;
    }

    public void setAuthorId(UUID author_id) {
        this.author_id = author_id;
    }

    public UUID getAuthorId(){
        return this.author_id;
    }


    public void setPubId(UUID pub_id) {
        this.pub_id = pub_id;
    }

    public UUID getPubId() {
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
