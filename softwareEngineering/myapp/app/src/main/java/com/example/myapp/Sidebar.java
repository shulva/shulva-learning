package com.example.myapp;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.view.MotionEvent;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import java.util.Arrays;
import java.util.List;

public class Sidebar extends View {

    private int PressedBackground;
    public static String[] INDEX_STRING = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"};
    private List<String> IndexDatas;
    private int mGapHeight;
    private android.graphics.Paint Paint;
    private int Height;
    private int Width;

    private RecyclerView rv;
    private RecyclerView.State rs;

    private TextView mPressedShowTextView;//用于特写显示正在被触摸的index值
    private List<User> mSourceDatas;//Adapter的数据源
    private RecyclerView.LayoutManager mLayoutManager;


    public Sidebar setDatas(List<User> mSourceDatas) {
        this.mSourceDatas = mSourceDatas;
        return this;
    }

    public Sidebar setTextView(TextView mPressedShowTextView) {
        this.mPressedShowTextView = mPressedShowTextView;
        return this;
    }

    public Sidebar setLayoutManager(RecyclerView.LayoutManager mLayoutManager) {

        this.mLayoutManager = mLayoutManager;
        return this;
    }


    private int getPosByTag(String tag) {
        if (TextUtils.isEmpty(tag)) {
            return -1;
        }
        for (int i = 0; i < mSourceDatas.size(); i++) {

            if (tag.charAt(0)==mSourceDatas.get(i).getTag().charAt(0)) {
                return i;
            }
        }
        return -1;
    }


    public Sidebar(Context context, @Nullable AttributeSet attrs) {//sidebar参数初始化
        super(context, attrs);

        setmOnIndexPressedListener(new onIndexPressedListener() {//sidebar点击事件

            @Override
            public void onIndexPressed(int index, String text) {

                text=text.toLowerCase();
                if (mPressedShowTextView != null) { //显示hintTexView
                    mPressedShowTextView.setVisibility(View.VISIBLE);
                    mPressedShowTextView.setText(text);
                }
                //滑动Rv
                if (mLayoutManager != null) {

                    int position = getPosByTag(text);
                    if (position != -1) {

                        ((LinearLayoutManager)mLayoutManager).scrollToPositionWithOffset(position,0);
                    }
                    else
                    {
                        Toast.makeText(context,"无对应数据！",Toast.LENGTH_LONG).show();
                    }
                }
            }

            @Override
            public void onMotionEventEnd() {
                if (mPressedShowTextView != null) {
                    mPressedShowTextView.setVisibility(View.GONE);
                }
            }
        });

        IndexDatas = Arrays.asList(INDEX_STRING);

        int textSize = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 16, getResources().getDisplayMetrics());//默认的TextSize
        PressedBackground = Color.BLACK;//黑色

        TypedArray typedArray = context.getTheme().obtainStyledAttributes(attrs, R.styleable.IndexBar, 0, 0);
        int n = typedArray.getIndexCount();

        Paint=new Paint();
        Paint.setColor(Color.GRAY);
        Paint.setAntiAlias(true);
        Paint.setTextSize(textSize*2/3);


        for (int i = 0; i < n; i++) {
            int attr = typedArray.getIndex(i);
            switch (attr) {
                case R.styleable.IndexBar_textSize:
                    textSize = typedArray.getDimensionPixelSize(attr, textSize);
                    break;
                case R.styleable.IndexBar_pressBackground:
                    PressedBackground = typedArray.getColor(attr, PressedBackground);
                default:
                    break;
            }
        }
        typedArray.recycle();

    }


    @Override
    public void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {// paint sidebar
        //取出宽高的MeasureSpec  Mode 和Size
        int wMode = MeasureSpec.getMode(widthMeasureSpec);
        int wSize = MeasureSpec.getSize(widthMeasureSpec);
        int hMode = MeasureSpec.getMode(heightMeasureSpec);
        int hSize = MeasureSpec.getSize(heightMeasureSpec);
        int measureWidth = 0, measureHeight = 0;//最终测量出来的宽高

        //得到合适宽度：
        Rect indexBounds = new Rect();//存放每个绘制的index的Rect区域
        String index;//每个要绘制的index内容
        for (int i = 0; i < IndexDatas.size(); i++) {
            index = IndexDatas.get(i);
            Paint.getTextBounds(index, 0, index.length(), indexBounds);//测量计算文字所在矩形，可以得到宽高
            measureWidth = Math.max(indexBounds.width(), measureWidth);//循环结束后，得到index的最大宽度
            measureHeight = Math.max(indexBounds.width(), measureHeight);//循环结束后，得到index的最大高度，然后*size
        }
        measureHeight *= IndexDatas.size();
        switch (wMode) {
            case MeasureSpec.EXACTLY:
                measureWidth = wSize;
                break;
            case MeasureSpec.AT_MOST:
                measureWidth = Math.min(measureWidth, wSize);//wSize此时是父控件能给子View分配的最大空间
                break;
            case MeasureSpec.UNSPECIFIED:
                break;
        }

        //得到合适的高度：
        switch (hMode) {
            case MeasureSpec.EXACTLY:
                measureHeight = hSize;
                break;
            case MeasureSpec.AT_MOST:
                measureHeight = Math.min(measureHeight, hSize);//wSize此时是父控件能给子View分配的最大空间
                break;
            case MeasureSpec.UNSPECIFIED:
                break;
        }

        setMeasuredDimension(measureWidth, measureHeight);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);
        Width = w;
        Height = h;
        mGapHeight = (Height - getPaddingTop() - getPaddingBottom()) / IndexDatas.size();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        int t = getPaddingTop();
        Rect indexBounds = new Rect();
        String index;

        for (int i = 0; i < IndexDatas.size(); i++) {
            index = IndexDatas.get(i);//文字内容

            Paint.getTextBounds(index, 0, index.length(), indexBounds);
            Paint.FontMetrics fontMetrics = Paint.getFontMetrics();
            int baseline = (int) ((mGapHeight - fontMetrics.bottom - fontMetrics.top) / 2);
            canvas.drawText(index, (Width - indexBounds.width())/2 , t + mGapHeight * i + baseline, Paint);
        }
    }


    public interface onIndexPressedListener {
        void onIndexPressed(int index, String text);//Index被按下

        void onMotionEventEnd();//触摸事件结束
    }

    private onIndexPressedListener mOnIndexPressedListener;//监听器

    public onIndexPressedListener getmOnIndexPressedListener() {
        return mOnIndexPressedListener;
    }

    public void setmOnIndexPressedListener(onIndexPressedListener mOnIndexPressedListener) {//初始化时会用到
        this.mOnIndexPressedListener = mOnIndexPressedListener;
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                Paint.setColor(PressedBackground);//press changeto black

            case MotionEvent.ACTION_MOVE:
                float y = event.getY();
                //通过计算判断落点在哪个区域：
                int pressI = (int) ((y - getPaddingTop()) / mGapHeight);
                //边界处理（在手指move时，有可能已经移出边界，防止越界）
                if (pressI < 0) {
                    pressI = 0;
                } else if (pressI >= IndexDatas.size()) {
                    pressI = IndexDatas.size() - 1;
                }
                //回调监听器
                if (null != mOnIndexPressedListener) {
                    mOnIndexPressedListener.onIndexPressed(pressI, IndexDatas.get(pressI));
                }
                break;
            default:
                setBackgroundResource(android.R.color.transparent);//手指抬起时背景恢复透明
                //回调监听器
                if (null != mOnIndexPressedListener) {
                    mOnIndexPressedListener.onMotionEventEnd();
                }
                break;
        }
        return true;
    }
}
