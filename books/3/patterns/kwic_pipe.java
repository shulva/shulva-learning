package patterns;

import java.io.*;
import java.util.ArrayList;
import java.util.Comparator;

public class kwic_pipe {
    public static void main(String[] args) throws IOException {

        File input = new File("D:\\software engineering\\patterns\\input.txt");
        File output = new File("D:\\software engineering\\patterns\\output.txt");

        pipeline pipe1 = new pipeline();// 创建管道类
        pipeline pipe2 = new pipeline();

        reader reader1 = new reader(input, pipe1);// 创建过滤器类
        sorter sorter1 = new sorter(pipe1, pipe2);
        writer writer1 = new writer(pipe2, output);

        reader1.process();// 处理文本
        sorter1.process();
        writer1.process();

    }
}

class pipeline {// 管道

    ArrayList<String> list = new ArrayList<String>();

    public void pass_data(String data)// 面向字符串
    {
        list.add(data);
    }

    public void show() {// 调试用
        for (String string : list) {
            System.out.println(string);
        }
    }

    public ArrayList<String> get() {// 对外调用的接口
        return list;
    }

}

abstract class filter {// 过滤器

    protected pipeline input;
    protected pipeline output;

    public filter(pipeline iPipeline, pipeline outPipeline) {// 初始化文本及管道
        this.input = iPipeline;
        this.output = outPipeline;
    }

    public void show() {// 调试用
        input.show();
        output.show();
    }

    public abstract void process() throws IOException;// 抽象方法

}

class reader extends filter {

    BufferedReader br = null;
    String data = null;
    File name = null;

    public reader(File file, pipeline outPipeline) throws IOException {
        super(null, outPipeline);
        name = file;
        br = new BufferedReader(new InputStreamReader(new FileInputStream(name)));// 读取文件文本
    }

    @Override
    public void process() throws IOException {
        while ((data = br.readLine()) != null) {// 按行读入
            output.pass_data(data);
        }
        br.close();
    }

}

class sorter extends filter {

    String[] split1 = null;
    String temp = "";

    ArrayList<String> list = new ArrayList<String>();
    ArrayList<String> outputlist = new ArrayList<String>();

    public sorter(pipeline iPipeline, pipeline outPipeline) {
        super(iPipeline, outPipeline);// input,output
    }

    @Override
    public void process() {

        for (String data : input.get()) {

            split1 = data.split(" ");// 分割句子
            for (int i = 0; i < split1.length; i++) {
                list.add(split1[i]);
            }

            for (int j = 0; j < split1.length; j++) {// 构造循环移位
                temp = "";

                for (String string : list) {
                    temp += string + " ";
                }
                outputlist.add(temp);// 这一步其实可以省掉

                list.add(list.get(0));// 在list的尾巴上加上头
                list.remove(0);// 删除头部，构造循环
            }

            newsort();// 给outputlist排序
            for (String string : outputlist) {
                output.pass_data(string);
            }

            outputlist.clear();
            list.clear();
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

}

class writer extends filter {

    BufferedWriter bw = null;
    String data = null;
    File name = null;

    public writer(pipeline iPipeline, File flie) throws IOException {
        super(iPipeline, null);
        name = flie;
        bw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(name)));// 文件写入
    }

    @Override
    public void process() throws IOException {// 一行一行写入
        for (int i = 0; i < input.get().size(); i++) {
            bw.write(input.get().get(i));
            bw.newLine();
            bw.flush();
        }

        bw.close();
    }

}