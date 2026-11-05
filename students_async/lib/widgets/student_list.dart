import 'package:flutter/material.dart';

import '../api/fake_api.dart';

class StudentList extends StatelessWidget {
  const StudentList(this.students, {super.key, this.compact = false});

  final List<Student> students;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];

        String gpaText = '—';
        if (student.gpa != null) {
          gpaText = student.gpa!.toStringAsFixed(1);
        }

        return ListTile(
          dense: compact,
          leading: CircleAvatar(child: Text(student.name[0])),
          title: Text(student.name),
          subtitle: Text(student.group),
          trailing: Text(gpaText),
        );
      },
    );
  }
}
