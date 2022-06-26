package com.example.myapp;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;



@Entity(tableName = "contact")
public class User {

    @ColumnInfo(name = "uid")
    @PrimaryKey(autoGenerate = true)
    public int uid;

    @ColumnInfo(name = "phone")
    public String phone;

    @NonNull
    @ColumnInfo(name = "name")
    public String name;

    @ColumnInfo(name = "email")
    public String email;

    @ColumnInfo(name = "tag")
    public String tag;


    User(String phone,String name,String email,String tag)
    {
        this.phone=phone;
        this.name=name;
        this.email=email;
        this.tag=tag;
    }

    public String getTag() {
        return tag;
    }

    public int getId() {
        return uid;
    }

    public void setId(int id) {
        this.uid = id;
    }

    public String getphone() {
        return phone;
    }

    public void setphone(String phone) {
        this.phone = phone;
    }

    public String getname() {
        return name;
    }

    public void setname(String name) {
        this.name = name;
    }

    public String getemail() {
        return email;
    }

    public void setemail(String email) {
        this.email = email;
    }
}
