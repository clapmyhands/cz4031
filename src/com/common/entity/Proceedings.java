package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;
import java.lang.*;

public class Proceedings extends Publication {
    private String conf;
    private String statement = "INSERT INTO proceeding(pubid, pubkey, title, year, month, conf) VALUES " + "(?, ?, ?, ?, ?, ?)";

    public Proceeding() {
        this.conf = null;
    }

    public void setConf(String conf) {
        this.conf = conf;
    }

    public void createConf() {
        String s = "s";
        StringBuilder sb = new StringBuilder();
        if (super.key.toLowerCase().startWith("conf/")) {
            for(int i = 5; i < super.key.length(); i++) {
                if(super.key.equals("/"))
                    break;
                sb.append(super.key[i]);
            }
        }
        setConf(sb.toString());
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