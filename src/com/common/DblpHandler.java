package com.common;

import com.common.entity.Publication;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

import java.util.UUID;

public class DblpHandler extends DefaultHandler{

    private PostgreSQL postgreSQL;

    // entity
    private boolean article=false;
    private boolean proceedings=false;
    private boolean inproceedings=false;
    private boolean www=false;

    // attribute tag
    private boolean author = false;
    private boolean title = false;
    private boolean journal = false;
    private boolean year = false;
    private boolean month = false;
    private boolean booktitle = false;

    public DblpHandler(PostgreSQL postgreSQL) {
        this.postgreSQL = postgreSQL;
    }

    @Override
    public void startElement(String uri, String localName, String qName, Attributes atts) throws SAXException{
        String lowerName = qName.toLowerCase();
        String key;
        String date;
        if(www)
            return;
        try {
            key = atts.getValue("key");
            date = atts.getValue("mdate");
            switch(lowerName){
                case "author":
                    postgreSQL.generateAuthorRecord();
                    postgreSQL.generateAuthoredRecord();
                    author=true;
                    break;
                case "title":
                    title=true;
                    break;
                case "year":
                    year = true;
                    break;
                case "month":
                    month = true;
                    break;
                case "booktitle":
                    if(proceedings || inproceedings)
                        booktitle = true;
                    break;
                case "journal":
                    if(article)
                        journal = true;
                    break;
                case "article":
                    article=true;
                    postgreSQL.generateArticleRecord();
                    break;
                case "proceedings":
                    proceedings = true;
                    postgreSQL.generateProceedingsRecord();
                    break;
                case "inproceedings":
                    inproceedings=true;
                    postgreSQL.generateInproceedingsRecord();
                    break;
                case "book":
                    postgreSQL.generateBookRecord();
                    break;
                case "incollection":
                    postgreSQL.generateIncollectionRecord();
                    break;
                case "phdthesis":
                    postgreSQL.generatePhdThesisRecord();
                    break;
                case "mastersthesis":
                    postgreSQL.generateMastersThesisRecord();
                    break;
                case "www":
                    www=true;
                    break;
            }
            if(Publication.checkType(lowerName)){
                postgreSQL.setFieldPublicationPubkey(key);
                if(date!=null){
                    postgreSQL.setFieldPublicationDate(date);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void endElement(String uri, String localName, String qName){
        String lowerName = qName.toLowerCase();
        if(lowerName.equalsIgnoreCase("www")){
            www=false;
            return;
        }
        try {
            if(Publication.checkType(lowerName)){
                article=false;
                proceedings=false;
                inproceedings=false;
                www=false;
                author = false;
                title = false;
                journal = false;
                year = false;
                month = false;
                booktitle = false;
                postgreSQL.generatePublicationStatement();
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(0);
        }
    }

    @Override
    public void characters(char[] ch, int start, int length){
        String value = new String(ch, start, length);
        if(www)
            return;
        try {
            if(author){
                postgreSQL.setFieldAuthorName(value);
                postgreSQL.setFieldAuthored();
                postgreSQL.generateAuthorStatement();
                postgreSQL.generateAuthoredStatement();
                author=false;
            } else if(title){
                postgreSQL.setFieldPublicationTitle(value);
                title=false;
            } else if(year){
                postgreSQL.setFieldPublicationYear(Integer.parseInt(value));
                year=false;
            } else if(month){
                postgreSQL.setFieldPublicationMonth(Integer.parseInt(value));
                month=false;
            } else if(booktitle){
                if(proceedings){
                    postgreSQL.setFieldProceedingsBooktitle(value);
                } else if(inproceedings){
                    postgreSQL.setFieldInproceedingsBooktitle(value);
                }
                booktitle=false;
            } else if(journal){
                if(article){
                    postgreSQL.setFieldArticleJournal(value);
                }
                journal=false;
            }
        } catch (Exception e) {
        }
    }

}
