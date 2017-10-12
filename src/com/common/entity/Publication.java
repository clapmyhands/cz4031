package com.common.entity;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

public class Publication {
    private Integer id;
    private String key;
    private String title;
    private Calendar cal;
    private String statement;
    private static Integer counter = 2379683;

    public Publication() {
        this.id = generateID();
        this.key = null;
        this.title = null;
        this.cal = Calendar.getInstance(TimeZone.getTimeZone("GMT-0:00"));
    }

    public static Integer generateID(){
        counter++;
        return counter;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getId() {
        return this.id;
    }

    public void setKey(String key) {
        this.key = key;
    }

    public String getKey() {
        return this.key;
    }

    public void setTitle(String title) {
        this.title = cleanText(title);
    }

    public void setYear(int year) {
        this.cal.set(Calendar.YEAR, year);
    }

    public void setMonth(int month) {
        this.cal.set(Calendar.MONTH, month);
    }

    public void setDay(int day) {
        this.cal.set(Calendar.DAY_OF_MONTH, day);
    }

    public void setDate(String date){
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
        df.setTimeZone(TimeZone.getTimeZone("GMT+0:00"));
        try{
            this.cal.setTime(df.parse(date));
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    PreparedStatement fillPreparedStatement(PreparedStatement pst) throws SQLException {
        Date date = new Date(this.cal.getTimeInMillis());
        pst.setObject(1, this.id);
        pst.setString(2, this.key);
        pst.setString(3, this.title);
        pst.setDate(4, date);
        return pst;
    }

    public PreparedStatement generateStatement(Connection connection) throws SQLException {
        PreparedStatement pst = connection.prepareStatement(statement);
        pst = this.fillPreparedStatement(pst);
        return pst;
    }

    private String cleanText(String text) {
        return text.replaceAll("\\<.*?\\>", "");
    }

    private static final Set<String> types = new HashSet<String>(Arrays.asList(
            "article", "book", "incollection", "inproceedings",
            "proceedings", "phdthesis", "mastersthesis"
    ));

    public static boolean checkType(String type){
        return types.contains(type);
    }
}
