package com.common;

import org.xml.sax.helpers.DefaultHandler;

import javax.xml.stream.events.*;

public class DblpHandler extends DefaultHandler{

    private PostgreSQL postgreSQL;

    public DblpHandler(PostgreSQL postgreSQL) {
        this.postgreSQL = postgreSQL;
    }

    public void StartElement(){

    }

    public void EndElement(){

    }

    public void Characters(){

    }

}
