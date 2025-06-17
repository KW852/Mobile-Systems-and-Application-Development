/**
* Exercise - JavaScript and React Native
* Author: Wong Kit Yin
* Student ID: 23030554d
*/
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import moment from 'moment';

const ACCENT = '#0066CC';

export default function ToDoItem({ item, onDelete, onEdit }) {
  const [isEditing, setIsEditing] = useState(false);
  const [text, setText] = useState(item.text);

  const saveEdit = () => {
    const trimmed = text.trim();
    if (trimmed) {
      onEdit(trimmed);       
      setIsEditing(false);
    } else {
      setText(item.text);
      setIsEditing(false);
    }
  };

  return (
    <View style={styles.item}>
      <View style={styles.content}>
        {isEditing ? (
          <TextInput
            style={styles.input}
            value={text}
            onChangeText={setText}
            onSubmitEditing={saveEdit}
            returnKeyType="done"
          />
        ) : (
          <Text style={styles.text}>{item.text}</Text>
        )}
        <Text style={styles.due}>
          Due: {moment(item.due).format('DD MMM YYYY')}
        </Text>
      </View>
      <View style={styles.actions}>
        {isEditing ? (
          <TouchableOpacity style={styles.saveBtn} onPress={saveEdit}>
            <Text style={styles.saveText}>Update</Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity
            style={styles.editBtn}
            onPress={() => setIsEditing(true)}
          >
            <Text style={styles.editText}>Edit</Text>
          </TouchableOpacity>
        )}
        <TouchableOpacity style={styles.delBtn} onPress={onDelete}>
          <Text style={styles.delText}>Delete</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  item: {
    backgroundColor: 'white',
    borderRadius: 8,
    padding: 12,
    marginBottom: 8,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 1,
  },
  content: { flex: 1, marginRight: 12 },
  text: { fontSize: 16, marginBottom: 4 },
  input: {
    fontSize: 16,
    borderBottomWidth: 1,
    borderColor: '#ccc',
    paddingVertical: 4,
  },
  due: { fontSize: 12, color: '#666' },
  actions: { flexDirection: 'row', alignItems: 'center' },
  editBtn: {
    backgroundColor: ACCENT,
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 4,
    marginRight: 8,
  },
  editText: { color: 'white' },
  saveBtn: {
    backgroundColor: '#28A745',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 4,
    marginRight: 8,
  },
  saveText: { color: 'white' },
  delBtn: {
    backgroundColor: '#DC3545',
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 4,
  },
  delText: { color: 'white' },
});