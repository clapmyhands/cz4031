package com.common;

import javax.xml.parsers.*;
import org.xml.sax.helpers.*;

import java.io.File;
import java.sql.SQLException;


public class Application {
    public static void main(String[] args){
        PostgreSQL postgreSQL = null;
        try {
            postgreSQL = new PostgreSQL();
            SAXParserFactory spf = SAXParserFactory.newInstance();
            SAXParser parser = spf.newSAXParser();

            DefaultHandler handler = new DblpHandler(postgreSQL);
            File file = new File("xaa.xml");
            parser.parse(file, handler);
            postgreSQL.executeBatch();
            postgreSQL.closeConnection();
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if(postgreSQL!=null){
                    postgreSQL.closeConnection();
                }
            } catch(SQLException e) {
                e.printStackTrace();
            }

        }
    }
}
