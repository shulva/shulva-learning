package patterns;

import java.io.*;
import java.util.ArrayList;
import java.util.*;

public class kwic_oo {
    public static void main(String[] args) throws IOException {

        txt_sorter test_Sorter = new txt_sorter();

        txt_reader test = new txt_reader("D:\\software engineering\\patterns\\input.txt", test_Sorter);
        test.read();

        txt_writer tw = new txt_writer(test_Sorter, "D:\\software engineering\\patterns\\output.txt");
        tw.write();
    }
}

class txt_reader {// 读入类

    BufferedReader br = null;
    String data = null;
    txt_sorter sorter;

    public txt_reader(String name, txt_sorter sorter) throws IOException {
        br = new BufferedReader(new InputStreamReader(new FileInputStream(name)));// 读入字符流
        this.sorter = sorter;
    }

    public void read() throws IOException {
        while ((data = br.readLine()) != null) {// 按行读取
            sorter.process(data);
        }
        br.close();
    }

}

class txt_sorter {// 处理类

    ArrayList<String> list = new ArrayList<String>();
    ArrayList<String> outputlist = new ArrayList<String>();
    ArrayList<String> list2 = new ArrayList<String>();

    String[] split1 = null;
    String temp = "";

    public void process(String data) {

        split1 = data.split(" ");// 分割句子
        for (int i = 0; i < split1.length; i++) {
            list.add(split1[i]);
        }

        for (int j = 0; j < split1.length; j++) {// 构造循环移位
            temp = "";

            for (String string : list) {
                temp += string + " ";
            }
            outputlist.add(temp);

            list.add(list.get(0));// 在list的尾巴上加上头
            list.remove(0);// 删除头部，构造循环
        }

        newsort();// 给outputlist排序
        for (String string : outputlist) {
            list2.add(string);
        }

        outputlist.clear();
        list.clear();
    }

    public void show() {// 打印outputlist中的内容
        for (String string : outputlist) {
            System.out.println(string);
        }
    }

    public void newsort() {// 覆写sort函数
        outputlist.sort(new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                o1 = o1.toLowerCase();
                o2 = o2.toLowerCase();
                return o1.charAt(0) > o2.charAt(0) ? 1 : -1;
            }
        });
    }

    public ArrayList<String> get() {// 对writer的接口

        return list2;
    }

}

class txt_writer {// 写入类

    txt_sorter ts = null;
    String name;
    BufferedWriter bw = null;

    public txt_writer(txt_sorter tSorter, String name) {
        this.ts = tSorter;
        this.name = name;
    }

    public void write() throws IOException {
        bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(name)));// 写入文件

        for (int i = 0; i < ts.get().size(); i++) {
            bw.write(ts.get().get(i));// 按行写入
            bw.newLine();
            bw.flush();// 冲刷buffer
        }

        bw.close();
    }

}