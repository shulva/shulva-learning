package com.example.myapp;

import android.content.ClipData;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.List;

public class UserAdapter extends RecyclerView.Adapter<UserAdapter.ViewHolder> {

    private List<User> mData;
    private OnItemClickListener ItemClickListener;

    public UserAdapter(List<User> data) {
        this.mData = data;
    }

    public void updateData(List<User> data) {
        this.mData = data;
        notifyDataSetChanged();
    }

    public static interface OnItemClickListener {//点击事件

        void onItemClick(View view);

        void onItemLongClick(View view);
    }

    public void setOnViewItemClickListener(OnItemClickListener ItemClickListener) {
        this.ItemClickListener = ItemClickListener;
    }

    @NonNull
    @Override
    public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

        View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.recycler_view, parent, false);

        ViewHolder vh = new ViewHolder(view);

        vh.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ItemClickListener.onItemClick(v);
            }
        });
        vh.itemView.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                ItemClickListener.onItemLongClick(v);
                return true;
            }
        });
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
        holder.getTextView().setText(mData.get(position).getname());
    }

    @Override
    public int getItemCount() {
        return mData == null ? 0 : mData.size();
    }

    public static class ViewHolder extends RecyclerView.ViewHolder {
        TextView textView;

        public ViewHolder(@NonNull View itemView) {
            super(itemView);
            textView = (TextView) itemView.findViewById(R.id.item_tv);
        }

        public TextView getTextView() {
            return textView;
        }
    }
}
