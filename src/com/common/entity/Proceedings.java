package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.lang.*;

public class Proceedings extends Publication {
    private String booktitle;
    private String statement = "INSERT INTO proceedings(pub_id, pub_key, title, pub_date, booktitle) VALUES " + "(?, ?, ?, ?, ?)";

    public Proceedings() {
        this.booktitle = null;
    }

    public void setBooktitle(String booktitle) {
        this.booktitle = booktitle;
    }

    @Override
    PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException {
        pst = super.fillPreparedStatement(pst);
        pst.setString(5, this.booktitle);
        return pst;
    }

    @Override
    public PreparedStatement generateStatement(Connection connection) throws SQLException {
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }

}