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
    private List<UUID> author_ids;
    private UUID pub_id;
    private static String statement = "INSERT INTO authored(pub_id, author_id) VALUES (?,?)";

    public Authored() {
        this.pub_id=null;
        this.author_ids=null;
    }

    public Authored(UUID pub_id, UUID author_id) {
        this.pub_id=pub_id;
        this.author_ids= Arrays.asList(author_id);
    }

    public Authored(UUID pub_id, List<UUID> author_ids) {
        this.pub_id=pub_id;
        this.author_ids=author_ids;
    }

    public void setAuthor_ids(List<UUID> author_ids) {
        this.author_ids = author_ids;
    }

    public List<UUID> getAuthor_ids() {
        return this.author_ids;
    }

    public void setPub_id(UUID pub_id) {
        this.pub_id = pub_id;
    }

    public UUID getPub_id() {
        return this.pub_id;
    }

    private PreparedStatement fillStatement(PreparedStatement pst, UUID pub_id, UUID author_id) throws SQLException{
        pst.setObject(1, pub_id);
        pst.setObject(2, author_id);
        return pst;
    }

    public List<PreparedStatement> generateStatement(Connection connection) throws SQLException {
        List<PreparedStatement> psts = new ArrayList<PreparedStatement>();
        for(UUID author_id : author_ids){
            PreparedStatement pst = connection.prepareStatement(statement);
            pst = this.fillStatement(pst, this.pub_id, author_id);
            psts.add(pst);
        }
        return psts;
    }
}
