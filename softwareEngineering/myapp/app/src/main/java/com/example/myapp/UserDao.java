package com.example.myapp;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import java.util.List;

@Dao
public interface UserDao {
    @Insert
    void  insertWords(User... users);//历史遗留问题
    @Update
    int updateUser(User... users);
    @Delete
    void deleteUser(User...users);

    @Query("SELECT * FROM contact")
    List<User> getAllusers();

    @Query("DELETE FROM contact where uid=:uid")
    void delete(int uid);

    @Query("SELECT * FROM contact where uid=:uid")
    List<User> getUserbyId(int uid);

    @Query("SELECT * FROM contact where name LIKE '%'||:name||'%' or phone LIKE '%'||:phone||'%'")
    List<User> getUserchaos(String name,String phone);
}
