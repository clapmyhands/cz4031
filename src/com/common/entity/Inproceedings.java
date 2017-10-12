package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

public class Inproceedings extends Publication {
    private String conf;
    private String booktitle;
    private String statement = "INSERT INTO inproceedings(pub_id, pub_key, title, pub_date, booktitle) VALUES " + "(?, ?, ?, ?, ?)";

    public Inproceedings() {
        this.conf = null;
    }

    public void setConf(String conf) {
        this.conf = conf;
    }

    public String getConf() {
        return this.conf;
    }

    public void createConf() {
        String s = "s";
        StringBuilder sb = new StringBuilder();
        if (super.getKey().toLowerCase().startsWith("conf/")) {
            for(int i = 5; i < super.getKey().length(); i++) {
                if(super.getKey().charAt(i) == '/')
                    break;
                sb.append(super.getKey().charAt(i));
            }
        }
        setConf(sb.toString());
    }

    public void setBooktitle(String booktitle) {
        this.booktitle = booktitle;
    }

    @Override
    PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException {
        pst = super.fillPreparedStatement(pst);
        pst.setString(5, this.conf);
        return pst;
    }

    @Override
    public PreparedStatement generateStatement(Connection connection) throws SQLException {
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }
}