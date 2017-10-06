package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;

public class Inproceedings extends Publication {
    private String conf;
    private String statement = "INSERT INTO proceeding(pubid, pubkey, title, year, month, conf) VALUES " + "(?, ?, ?, ?, ?, ?)";

    public Proceeding() {
        super();
        this.conf = null;
    }

    public void setConf(String conf) {
        this.conf = conf;
    }

    @Override
    PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException {
        pst = super.fillPreparedStatement(pst);
        pst.setString(6, this.conf);
        return pst;
    }

    @Override
    public PreparedStatement generateStatement(Connection connection) throws SQLException {
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }
}