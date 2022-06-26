package com.example.myapp;


import android.content.Context;
import android.util.Log;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;

@Database(entities = {User.class},version = 1, exportSchema = false)
public abstract class UserDataBase extends RoomDatabase {

    private static final String DATABASE_NAME = "contact";

    private static UserDataBase databaseInstance;

    //单例模式
    public static synchronized  UserDataBase getInstance(Context context) {
        if (databaseInstance == null) {
            databaseInstance = Room
                    .databaseBuilder(context, UserDataBase.class, DATABASE_NAME)
                    .allowMainThreadQueries()
                    .build();
        }

        return databaseInstance;
    }

    public abstract UserDao getUserDao();
}