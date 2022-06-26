package com.example.myapp;

import java.io.UnsupportedEncodingException;

import net.sourceforge.pinyin4j.PinyinHelper;

public class cn_to_en {
    // 国标码和区位码转换常量

    public static String getPinYinHeadChar(String str) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < str.length(); i++) {
            char word = str.charAt(i);
            String[] pinyinArray = PinyinHelper.toHanyuPinyinStringArray(word);

            if (pinyinArray != null) {
                sb.append(pinyinArray[0].charAt(0));
            }
            else {
                sb.append(word);
            }
            System.out.println((int)pinyinArray[0].charAt(0));
        }

        System.out.println(sb.toString());
        return sb.toString();
    }

    public static String getFirstLetter(String oriStr) throws UnsupportedEncodingException {
        String str = oriStr.toLowerCase();

        if(str.charAt(0)>='0'&&str.charAt(0)<='9')
        {
            str="#";
        }
        else if(str.charAt(0)>='a'&&str.charAt(0)<='z')
        {
            str=str;
        }
        else
        {
            str = getPinYinHeadChar(oriStr);
        }
        return str;
    }
}