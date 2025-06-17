package hk.edu.polyu.eie3109.todolist;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import java.util.ArrayList;

public class RVAdapter extends RecyclerView.Adapter<RVAdapter.myViewHolder> {
    Context context;
    ArrayList<TaskModel> taskModelArrayList;

    public RVAdapter(MainActivity mainActivity, ArrayList<TaskModel> taskModelArrayList) {
        this.context = mainActivity;
        this.taskModelArrayList = taskModelArrayList;
    }

    public Context getContext() {
        return context;
    }


    public static class myViewHolder extends RecyclerView.ViewHolder {
        CheckBox cb;
        public myViewHolder(@NonNull View itemView) {
            super(itemView);
            cb = itemView.findViewById(R.id.CBTask);
        }
    }

    @NonNull
    @Override
    public RVAdapter.myViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.task_row_layout, parent,false);
        return new RVAdapter.myViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RVAdapter.myViewHolder holder, int position) {
        holder.cb.setText(taskModelArrayList.get(holder.getAdapterPosition()).getTaskString());
        holder.cb.setChecked(taskModelArrayList.get(holder.getAdapterPosition()).getCompleted());
        holder.cb.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean isChecked = holder.cb.isChecked();
                taskModelArrayList.get(holder.getAdapterPosition()).setCompleted(isChecked);
            }
        });
    }

    @Override
    public int getItemCount() {
        return taskModelArrayList.size();
    }

    public void deleteItem (int position) {
        taskModelArrayList.remove(position);
        this.notifyItemRemoved(position);
        this.notifyItemRangeChanged(position, getItemCount());

        if (context instanceof MainActivity) {
            ((MainActivity) context).saveTaskListToSharedPreferences();
        }
    }

    public void editItem(int position) {
        TaskModel currentTask = taskModelArrayList.get(position);
        Context context = this.context;

        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle("Edit Task");

        View dialogView = LayoutInflater.from(context).inflate(R.layout.form_layout, null);
        EditText ETNewTask = dialogView.findViewById(R.id.ETTaskText);
        ETNewTask.setText(currentTask.getTaskString());

        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                dialog.dismiss();
                notifyDataSetChanged();

            }
        });

        builder.setView(dialogView);
        AlertDialog dialog = builder.create();

        Button BNSave = dialogView.findViewById(R.id.BNSubmit);
        BNSave.setText("Update");
        BNSave.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String updatedText = ETNewTask.getText().toString();
                currentTask.setTaskString(updatedText);
                notifyDataSetChanged();
                dialog.dismiss();

                if (context instanceof MainActivity) {
                    ((MainActivity) context).saveTaskListToSharedPreferences();
                }
            }
        });
        dialog.show();
    }

}
