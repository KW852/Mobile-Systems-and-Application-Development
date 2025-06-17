/**
* Exercise - JavaScript and React Native
*/
import React, { useState } from 'react';
import {
  SafeAreaView,
  View,
  TextInput,
  TouchableOpacity,
  Text,
  FlatList,
  StyleSheet,
  Platform,
} from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import ToDoItem from './src/ToDoItem';
import moment from 'moment';

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [task, setTask] = useState('');
  const [dueDate, setDueDate] = useState(new Date());
  const [tempDate, setTempDate] = useState(dueDate);
  const [showPicker, setShowPicker] = useState(false);

  const openPicker = () => {
    setTempDate(dueDate);
    setShowPicker(true);
  };

  const onDateChange = (_, selected) => {
    if (selected) setTempDate(selected);
    if (Platform.OS !== 'ios') {
      setDueDate(selected);
      setShowPicker(false);
    }
  };

  const confirmDate = () => {
    setDueDate(tempDate);
    setShowPicker(false);
  };
  const cancelDate = () => setShowPicker(false);

  const addTask = () => {
    const txt = task.trim();
    if (!txt) return;
    setTasks([...tasks, { text: txt, due: dueDate }]);
    setTask('');
    setDueDate(new Date());
  };

  const deleteTask = idx =>
    setTasks(tasks.filter((_, i) => i !== idx));

  const updateTask = (idx, newText) =>
    setTasks(tasks.map((t, i) =>
      i === idx ? { ...t, text: newText } : t
    ));

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.inputRow}>
        <TextInput
          placeholder="New Task"
          style={styles.input}
          value={task}
          onChangeText={setTask}
        />
        <TouchableOpacity style={styles.dateBtn} onPress={openPicker}>
          <Text style={styles.dateBtnText}>
            {moment(dueDate).format('DD MMM')}
          </Text>
        </TouchableOpacity>
      </View>

      {showPicker && (
        <View style={styles.pickerWrapper}>
          <DateTimePicker
            value={tempDate}
            mode="date"
            display={Platform.OS === 'ios' ? 'spinner' : 'default'}
            onChange={onDateChange}
            style={styles.picker}
          />
          {Platform.OS === 'ios' && (
            <View style={styles.pickerFooter}>
              <TouchableOpacity style={styles.cancelBtn} onPress={cancelDate}>
                <Text style={styles.cancelText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity style={styles.confirmBtn} onPress={confirmDate}>
                <Text style={styles.confirmText}>Confirm</Text>
              </TouchableOpacity>
            </View>
          )}
        </View>
      )}

      <TouchableOpacity style={styles.addBtn} onPress={addTask}>
        <Text style={styles.addBtnText}>Add Task</Text>
      </TouchableOpacity>

      <FlatList
        style={styles.list}
        data={tasks}
        keyExtractor={(_, i) => i.toString()}
        renderItem={({ item, index }) => (
          <ToDoItem
            item={item}
            onDelete={() => deleteTask(index)}
            onEdit={newText => updateTask(index, newText)}  
          />
        )}
      />
    </SafeAreaView>
  );
}

const ACCENT = '#0066CC';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F2F5F8',
    paddingHorizontal: 24,
    paddingTop: 16,
  },
  inputRow: { flexDirection: 'row', alignItems: 'center', marginBottom: 12 },
  input: {
    flex: 1,
    backgroundColor: 'white',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1, shadowRadius: 2, elevation: 1,
  },
  dateBtn: {
    marginLeft: 8,
    backgroundColor: ACCENT,
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    justifyContent: 'center',
    shadowColor: '#000', shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.15, shadowRadius: 3, elevation: 2,
  },
  dateBtnText: { color: 'white', fontWeight: '600' },
  pickerWrapper: {
    backgroundColor: 'white',
    borderRadius: 8,
    overflow: 'hidden',
    marginBottom: 12,
    alignItems: 'center',
  },
  picker: { width: '80%' },
  pickerFooter: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    padding: 8,
    borderTopWidth: 1,
    borderColor: '#eee',
    width: '100%',
  },
  cancelBtn: { paddingHorizontal: 12, paddingVertical: 6 },
  confirmBtn: {
    backgroundColor: ACCENT,
    borderRadius: 4,
    paddingHorizontal: 12,
    paddingVertical: 6,
    marginLeft: 8,
  },
  cancelText: { color: '#333' },
  confirmText: { color: 'white', fontWeight: '600' },
  addBtn: {
    backgroundColor: ACCENT,
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: 'center',
    marginBottom: 8,
    shadowColor: '#000', shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2, shadowRadius: 4, elevation: 3,
  },
  addBtnText: { color: 'white', fontSize: 17, fontWeight: '600' },
  list: { flex: 1, marginTop: 8 },
});