package hk.edu.polyu.eie3109.todolist;

public class TaskModel {
    String taskString;
    Boolean completed;

    public TaskModel(String taskString, Boolean completed) {
        this.taskString = taskString;
        this.completed = completed;
    }

    public String getTaskString() {
        return taskString;
    }

    public void setTaskString(String taskString) {
        this.taskString = taskString;
    }

    public Boolean getCompleted() {
        return completed;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }
}
