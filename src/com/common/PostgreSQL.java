package com.common;

import com.common.entity.*;

import java.sql.*;
import java.util.ArrayList;
import java.util.Properties;


public class PostgreSQL {

    private Connection connection;

    private ArrayList<PreparedStatement> listOfPreparedStatement = new ArrayList<PreparedStatement>();

    private Publication publicationRecord;
    private Author authorRecord;
    private Authored authoredRecord;
    private int counter;

    public PostgreSQL(){
        try {
            //Class.forName("java.sql.Driver");
            String url = "jdbc:postgresql://localhost:5432/cz4031_project1";
            Properties prop = new Properties();
            prop.setProperty("user", "cz4031");
            //prop.setProperty("password", "cz4031");
            Connection conn = DriverManager.getConnection(url, prop);
            conn.setAutoCommit(false);
            System.out.println("Database successfully connected");

            this.connection = conn;
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Connection getConnection() {
        return this.connection;
    }

    public void closeConnection() throws SQLException{
        this.connection.close();
    }

    // generator
    public void generateAuthorRecord(){
        this.authorRecord = new Author();
    }

    public void generateAuthoredRecord(){
        this.authoredRecord = new Authored();
    }

    public void generateArticleRecord(){
        this.publicationRecord = new Article();
    }

    public void generateBookRecord() {
        this.publicationRecord = new Book();
    }

    public void generateIncollectionRecord() {
        this.publicationRecord = new Incollection();
    }

    public void generateInproceedingsRecord() {
        this.publicationRecord = new Inproceedings();
    }

    public void generateProceedingsRecord() {
        this.publicationRecord = new Proceedings();
    }

    public void generatePhdThesisRecord() {
        this.publicationRecord = new PhdThesis();
    }

    public void generateMastersThesisRecord() {
        this.publicationRecord = new MastersThesis();
    }

    // authored field
    public void setFieldAuthored(){
        if(this.authorRecord!=null && this.publicationRecord!=null){
            if(this.authoredRecord==null){
                this.generateAuthoredRecord();
            }
            this.authoredRecord.setAuthorId(this.authorRecord.getID());
            this.authoredRecord.setPubId(this.publicationRecord.getId());
        }
    }

    // author field
    public void setFieldAuthorName(String name){
        this.authorRecord.setName(name);
    }

    // publication field
    public void setFieldPublicationPubkey(String pubkey){
        this.publicationRecord.setKey(pubkey);
    }

    public void setFieldPublicationTitle(String title) {
        this.publicationRecord.setTitle(title);
    }

    public void setFieldPublicationYear(Integer year) {
        this.publicationRecord.setYear(year);
    }

    public void setFieldPublicationMonth(Integer month){
        this.publicationRecord.setMonth(month);
    }

    public void setFieldPublicationDate(String date){
        this.publicationRecord.setDate(date);
    }

    public void setFieldArticleJournal(String journal){
        if(this.publicationRecord instanceof Article){
            ((Article) this.publicationRecord).setJournal(journal);
        }
    }

    public void setFieldInproceedingsBooktitle(String booktitle){
        if(this.publicationRecord instanceof  Inproceedings){
            ((Inproceedings) this.publicationRecord).setBooktitle(booktitle);
        }
    }

    public void setFieldProceedingsBooktitle(String booktitle){
        if(this.publicationRecord instanceof  Proceedings){
            ((Proceedings) this.publicationRecord).setBooktitle(booktitle);
        }
    }

    // generate Prepared Statement
    public void generateAuthorStatement() throws SQLException{
        this.addToBatch(this.authorRecord.generateStatement(this.connection));
        this.authorRecord = null;
    }

    public void generateAuthoredStatement() throws SQLException{
        this.addToBatch(this.authoredRecord.generateStatement(this.connection));
        this.authoredRecord = null;
    }

    public void generatePublicationStatement() throws SQLException{
        this.addToBatch(this.publicationRecord.generateStatement(this.connection));
        this.publicationRecord = null;
    }

    public void addToBatch(PreparedStatement pst){
        this.listOfPreparedStatement.add(pst);
        ++counter;
        System.out.println(String.format("%d: %s", counter, pst.toString()));
        if(counter%1000==0){
            //executeBatch();
            listOfPreparedStatement = new ArrayList<PreparedStatement>();
        }
    }

    public void executeBatch(){
        try {
            for (PreparedStatement pst : listOfPreparedStatement) {
                System.out.println(pst.toString());
                //pst.executeBatch();
            }
        } catch (Exception e){
            e.printStackTrace();
        }
    }

}
