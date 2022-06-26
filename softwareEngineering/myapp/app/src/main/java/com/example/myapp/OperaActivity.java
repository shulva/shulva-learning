package com.example.myapp;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import java.io.UnsupportedEncodingException;
import java.util.List;

public class OperaActivity extends AppCompatActivity {

    UserDao userdao;
    User user;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_opera);

        //返回
        Toolbar myChildToolbar =
                (Toolbar) findViewById(R.id.toolbar2_o);
        myChildToolbar.setTitle("联系人信息");
        myChildToolbar.setTitleTextColor(0xffffffff);
        setSupportActionBar(myChildToolbar);
        // Get a support ActionBar corresponding to this toolbar
        ActionBar ab = getSupportActionBar();
        ab.setDisplayHomeAsUpEnabled(true);

        Intent intent = getIntent();
        int uid=intent.getIntExtra("uid",0);

        UserDataBase db = UserDataBase.getInstance(this);
        userdao = db.getUserDao();//userdao被初始化

        //查询
        List<User> LU=userdao.getUserbyId(uid);
        user=LU.get(0);//user被初始化

        TextView tv=(TextView)findViewById(R.id.textView7);
        tv.setText(user.getname());

        EditText editText1 = (EditText) findViewById(R.id.editTextTextPersonName2_o);
        editText1.setText(user.getname());

        EditText editText2 = (EditText) findViewById(R.id.editTextTextPersonName3_o);
        editText2.setText(user.getphone());

        EditText editText3= (EditText) findViewById(R.id.editTextTextPersonName5_o);
        editText3.setText(user.getemail());

    }
    public void update(View view) {

        EditText editText1 = (EditText) findViewById(R.id.editTextTextPersonName2_o);
        String name=editText1.getText().toString();

        EditText editText2 = (EditText) findViewById(R.id.editTextTextPersonName3_o);
        String phone=editText2.getText().toString();

        EditText editText3= (EditText) findViewById(R.id.editTextTextPersonName5_o);
        String email=editText3.getText().toString();

        user.setname(name);
        user.setphone(phone);
        user.setemail(email);

        userdao.updateUser(user);

        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.item2, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {

            case R.id.action_delete:

                userdao.deleteUser(user);
                //对MainActivity的数据库内容显示
                Intent intent = new Intent(this, MainActivity.class);
                startActivity(intent);
                return true;
            default:
                return super.onOptionsItemSelected(item);

        }
    }
}