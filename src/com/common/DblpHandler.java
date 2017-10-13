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

    private StringBuffer sb = new StringBuffer();

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
                    sb.setLength(0);
                    author=true;
                    break;
                case "title":
                    sb.setLength(0);
                    title=true;
                    break;
                case "year":
                    sb.setLength(0);
                    year = true;
                    break;
                case "month":
                    sb.setLength(0);
                    month = true;
                    break;
                case "booktitle":
                    if(proceedings || inproceedings) {
                        sb.setLength(0);
                        booktitle = true;
                    }
                    break;
                case "journal":
                    if(article) {
                        sb.setLength(0);
                        journal = true;
                    }
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
        } else if(www) return;
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
            } else{
                switch(lowerName){
                    case "author":
                        postgreSQL.setFieldAuthorName(sb.toString());
                        postgreSQL.setFieldAuthored();
                        postgreSQL.generateAuthorStatement();
                        postgreSQL.generateAuthoredStatement();
                        author=false;
                        break;
                    case "title":
                        postgreSQL.setFieldPublicationTitle(sb.toString());
                        title=false;
                        break;
                    case "year":
                        try {
                            postgreSQL.setFieldPublicationYear(Integer.parseInt(sb.toString()));
                        } catch (NumberFormatException e) {e.printStackTrace();}
                        year=false;
                        break;
                    case "month":
                        try{
                            postgreSQL.setFieldPublicationMonth(Integer.parseInt(sb.toString()));
                        } catch (NumberFormatException e) {}
                        month=false;
                        break;
                    case "booktitle":
                        if(proceedings){
                            postgreSQL.setFieldProceedingsBooktitle(sb.toString());
                        } else if(inproceedings){
                            postgreSQL.setFieldInproceedingsBooktitle(sb.toString());
                        }
                        booktitle=false;
                        break;
                    case "journal":
                        if(article){
                            postgreSQL.setFieldArticleJournal(sb.toString());
                        }
                        journal=false;
                        break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(0);
        }
    }

    @Override
    public void characters(char[] ch, int start, int length){
        if(www)
            return;
        try {
            if(author || title || year || month || booktitle || journal){
                sb.append(ch, start, length);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
