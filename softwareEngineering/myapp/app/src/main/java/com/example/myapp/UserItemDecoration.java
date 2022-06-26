package com.example.myapp;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.util.TypedValue;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class UserItemDecoration extends RecyclerView.ItemDecoration {

    private int TitleHeight;
    private List<User> userdata;
    private Paint mPaint;
    private Rect mBounds;//用于存放测量文字Rect
    private static int TitleFontSize;

    private static final int COLOR_TITLE_BG = Color.parseColor("#FFDFDFDF");
    private static final int COLOR_TITLE_FONT = Color.parseColor("#FF000000");

    private Paint dividerPaint;
    private int dividerHeight;

    public UserItemDecoration(Context context, List<User> userdata) {
        super();
        this.userdata = userdata;
        mPaint = new Paint();
        mBounds = new Rect();
        mPaint.setAntiAlias(true);

        TitleHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 30, context.getResources().getDisplayMetrics())/2;
        TitleFontSize = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 16, context.getResources().getDisplayMetrics());
        mPaint.setTextSize(TitleFontSize);

        dividerPaint = new Paint();
        dividerPaint.setColor(COLOR_TITLE_BG);
        dividerHeight = context.getResources().getDimensionPixelSize(R.dimen.dp_value);
    }

    @Override
    public void getItemOffsets(@NonNull Rect outRect, @NonNull View view, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
        super.getItemOffsets(outRect, view, parent, state);

        int postion = ((RecyclerView.LayoutParams) view.getLayoutParams()).getViewLayoutPosition();
        if (postion > -1) {
            if (postion == 0) {
                outRect.set(0, TitleHeight, 0, 0);
            }
            //tag不相等
            else if (null != userdata.get(postion).getname() && !(userdata.get(postion).getTag().equals(userdata.get(postion - 1).getTag()))) {
                outRect.set(0, TitleHeight, 0, 0);
            } else {
                outRect.set(0, TitleHeight, 0, 0);
            }
        }
    }

    @Override
    public void onDraw(@NonNull Canvas c,
                       @NonNull RecyclerView parent,
                       @NonNull RecyclerView.State state) {

        super.onDraw(c, parent, state);
        final int left = parent.getPaddingLeft();
        final int right = parent.getWidth() - parent.getPaddingRight();
        final int childCount = parent.getChildCount();

        for (int i = 0; i < childCount; i++) {
            final View child = parent.getChildAt(i);
            final RecyclerView.LayoutParams params = (RecyclerView.LayoutParams) child.getLayoutParams();

            float top=child.getBottom();
            float bottom=child.getBottom()+dividerHeight/10;
            c.drawRect(left, top, right, bottom, dividerPaint);

            int position = params.getViewLayoutPosition();

            if (position > -1) {
                if (position == 0) {
                    drawTitleArea(c, left, right, child, params, position);

                } else {//对首字母分类
                    if (null != userdata.get(position).getTag() && !(userdata.get(position).getTag().charAt(0)==userdata.get(position - 1).getTag().charAt(0))) {
                        //不为空 且跟前一个tag不一样了，说明是新的分类，也要title
                        drawTitleArea(c, left, right, child, params, position);
                    } else {
                        //none
                    }
                }
            }
        }

    }

    private void drawTitleArea(Canvas c, int left, int right, View child, RecyclerView.LayoutParams params, int position) {//最先调用，绘制在最下层
        mPaint.setColor(COLOR_TITLE_BG);
        c.drawRect(left, child.getTop() - params.topMargin - TitleHeight, right, child.getTop() - params.topMargin, mPaint);

        mPaint.setColor(COLOR_TITLE_FONT);
        mPaint.getTextBounds(String.valueOf(userdata.get(position).getTag().charAt(0)), 0, 1, mBounds);
        c.drawText(Character.toString(userdata.get(position).getTag().charAt(0)), child.getPaddingLeft(), child.getTop() - params.topMargin - ((TitleHeight / 2)- (mBounds.height() / 2)), mPaint);
    }

}
