package com.example.myapp;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;

import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.widget.EditText;

import java.io.UnsupportedEncodingException;


public class AddActivity extends AppCompatActivity {

    UserDao userdao;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_add);

        // Get the Intent that started this activity and extract the string
        Intent intent = getIntent();
        String message = intent.getStringExtra(MainActivity.EXTRA_MESSAGE);

        Toolbar myChildToolbar =
                (Toolbar) findViewById(R.id.toolbar2);
        myChildToolbar.setTitle("新建联系人");
        myChildToolbar.setTitleTextColor(0xffffffff);
        setSupportActionBar(myChildToolbar);

        UserDataBase db=UserDataBase.getInstance(this);
        userdao=db.getUserDao();

        // Get a support ActionBar corresponding to this toolbar
        ActionBar ab = getSupportActionBar();

        // Enable the Up button
        ab.setDisplayHomeAsUpEnabled(true);

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        MenuInflater inflater = getMenuInflater();
        inflater.inflate(R.menu.item, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        switch (item.getItemId()) {

            case R.id.action_create:

                EditText editText1 = (EditText) findViewById(R.id.editTextTextPersonName2);
                String name=editText1.getText().toString();

                EditText editText2 = (EditText) findViewById(R.id.editTextTextPersonName3);
                String phone=editText2.getText().toString();

                EditText editText3= (EditText) findViewById(R.id.editTextTextPersonName5);
                String email=editText3.getText().toString();

                User user= null;
                try {
                    user = new User(phone,name,email, cn_to_en.getFirstLetter(name));
                } catch (UnsupportedEncodingException e) {
                    e.printStackTrace();
                }
                userdao.insertWords(user);

                //对MainActivity的数据库内容显示

                Intent intent = new Intent(this, MainActivity.class);
                startActivity(intent);
                return true;

            default:
                // If we got here, the user's action was not recognized.
                // Invoke the superclass to handle it.
                return super.onOptionsItemSelected(item);

        }
    }

}






