package hk.edu.polyu.eie3109.todolist;

import android.app.Dialog;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.ItemTouchHelper;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.material.floatingactionbutton.FloatingActionButton;

import java.util.ArrayList;

public class MainActivity extends AppCompatActivity {

    RecyclerView RVTaskList;
    ArrayList<TaskModel> taskModelArrayList = new ArrayList<>();
    FloatingActionButton floatingActionButton;
    RVAdapter RVAdapter;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        RVTaskList = findViewById(R.id.RVTaskList);
        floatingActionButton = findViewById(R.id.FABAddTask);
        RVTaskList.setLayoutManager(new LinearLayoutManager(this));

//        setUpTaskModels();
        loadTaskListFromSharedPreferences();
        RVAdapter = new RVAdapter(this, taskModelArrayList);
        RVTaskList.setAdapter(RVAdapter);
        ItemTouchHelper itemTouchHelper = new ItemTouchHelper(new RecyclerItemTouchHelper(RVAdapter));
        itemTouchHelper.attachToRecyclerView(RVTaskList);


        EdgeToEdge.enable(this);

        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        floatingActionButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(getApplicationContext(), "Clicked", Toast.LENGTH_SHORT).show();
                Dialog addForm = new Dialog(MainActivity.this);
                addForm.requestWindowFeature(Window.FEATURE_NO_TITLE);
                addForm.setContentView(R.layout.form_layout);
                Button BNSave = addForm.findViewById(R.id.BNSubmit);
                BNSave.setText("Add");
                BNSave.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        EditText ETNewTask = addForm.findViewById(R.id.ETTaskText);
                        taskModelArrayList.add(new TaskModel(ETNewTask.getText().toString(), false));
                        RVAdapter.notifyDataSetChanged();
                        saveTaskListToSharedPreferences();
                        addForm.dismiss();
                    }
                });
                addForm.show();
            }
        });

    }

    void saveTaskListToSharedPreferences() {
        StringBuilder sb = new StringBuilder();
        for (TaskModel task : taskModelArrayList) {
            sb.append(task.getTaskString()).append("||").append(task.getCompleted()).append(";;");
        }
        getSharedPreferences("tasks", MODE_PRIVATE).edit().putString("task_list", sb.toString()).apply();
    }

    private void loadTaskListFromSharedPreferences() {
        String savedData = getSharedPreferences("tasks", MODE_PRIVATE).getString("task_list", null);
        if (savedData != null) {
            taskModelArrayList.clear();
            String[] entries = savedData.split(";;");
            for (String entry : entries) {
                if (entry.isEmpty()) continue;
                String[] parts = entry.split("\\|\\|");
                if (parts.length == 2) {
                    String text = parts[0];
                    boolean isDone = Boolean.parseBoolean(parts[1]);
                    taskModelArrayList.add(new TaskModel(text, isDone));
                }
            }
        } else {
            setUpTaskModels(); // 初次啟動無資料，用硬編碼初始化
        }
    }


    private void setUpTaskModels() {
        String[] taskStrings = new String[20];
        for (int i = 0; i < 20; i++) {
            taskStrings[i] = "Task "+ i;
        }

        for (int i=0; i < taskStrings.length; i++) {
            taskModelArrayList.add(new TaskModel(taskStrings[i], (i%2==0) ? true : false));
        }
    }
}