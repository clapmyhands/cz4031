package com.common.entity;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.UUID;

public class WWWW extends Publication {
    private String statement = "INSERT INTO www(pubid, pubkey, title, year, month) VALUES " + "(?, ?, ?, ?, ?)";

    public WWW() {
    }
    
    @Override
    PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException {
        pst = super.fillPreparedStatement(pst);
        return pst;
    }

    @Override
    public PreparedStatement generateStatement(Connection connection) throws SQLException {
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }
}