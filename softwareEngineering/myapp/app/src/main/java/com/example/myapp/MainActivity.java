package com.example.myapp;

import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.Toolbar;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.room.Room;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.SearchView;
import android.widget.TextView;
import android.widget.Toast;

import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;


public class MainActivity extends AppCompatActivity {
    public static final String EXTRA_MESSAGE = "com.example.myapp.MESSAGE";
    UserDao userdao;

    private RecyclerView myRecyclerView;
    private UserAdapter myAdapter;
    private RecyclerView.LayoutManager myLayoutManager;
    List<User> list;

    UserItemDecoration UID;
    Context context;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        context = this;
        Sidebar index = (Sidebar) findViewById(R.id.sidebar);

        UserDataBase db = UserDataBase.getInstance(this);

        userdao = db.getUserDao();
        list = userdao.getAllusers();

        Collections.sort(list, new Comparator<User>() {
            @Override
            public int compare(User o1, User o2) {
                if (o1.getTag().charAt(0) == '#')
                    return 1;
                else if (o2.getTag().charAt(0) == '#')
                    return -1;
                else
                    return o1.getTag().compareTo(o2.getTag());
            }
        });

        initdata(list);
        initview();//初始化recycler

        Intent ointent = new Intent(this, OperaActivity.class);

        UID = new UserItemDecoration(this, list);
        myRecyclerView.addItemDecoration(UID);

        myAdapter.setOnViewItemClickListener(new UserAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(View view) {
                int position = myRecyclerView.getChildAdapterPosition(view);
                int uid = list.get(position).getId();
                ointent.putExtra("uid", uid);
                startActivity(ointent);
            }

            @Override
            public void onItemLongClick(View view) {
                int position = myRecyclerView.getChildAdapterPosition(view);

            }
        });

        index.setDatas(list);
        index.setLayoutManager(myLayoutManager);

        TextView et = (TextView) findViewById(R.id.textView6);
        et.setText("共有" + String.valueOf(list.size()) + "位联系人");

        Toolbar myChildToolbar =
                (Toolbar) findViewById(R.id.toolbar);
        myChildToolbar.setTitle("联系人");
        myChildToolbar.setTitleTextColor(0xffffffff);
        setSupportActionBar(myChildToolbar);

        SearchView sv = (SearchView) findViewById(R.id.searchView);

        sv.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
            @Override
            public boolean onQueryTextSubmit(String query) {


                return false;
            }

            @Override
            public boolean onQueryTextChange(String newText) {
                //实现文本变化+模糊搜索
                if (!newText.isEmpty())
                    list = userdao.getUserchaos(newText, newText);
                else {
                    list = userdao.getAllusers();
                }
                Collections.sort(list, new Comparator<User>() {
                    @Override
                    public int compare(User o1, User o2) {
                        if (o1.getTag().charAt(0) == '#')
                            return 1;
                        else if (o2.getTag().charAt(0) == '#')
                            return -1;
                        else
                            return o1.getTag().compareTo(o2.getTag());
                    }
                });
                myRecyclerView.removeItemDecoration(UID);
                UID = new UserItemDecoration(context, list);
                myRecyclerView.addItemDecoration(UID);
                initdata(list);
                initview();

                TextView et = (TextView) findViewById(R.id.textView6);
                et.setText("共有" + String.valueOf(list.size()) + "位联系人");

                return false;
            }
        });

    }

    public void sendMessage(View view) {

        Intent intent = new Intent(this, AddActivity.class);
        startActivity(intent);
    }

    private void initdata(List<User> list) {
        myLayoutManager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        myAdapter = new UserAdapter(list);
    }

    private void initview() {
        myRecyclerView = (RecyclerView) findViewById(R.id.recyclerView);

        myRecyclerView.setLayoutManager(myLayoutManager);
        myRecyclerView.setAdapter(myAdapter);
    }

}
