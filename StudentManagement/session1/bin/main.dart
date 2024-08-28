import 'dart:convert';
import 'dart:io';

// Cấu trúc đối tượng môn học
class Subject {
  String name;
  List<int> scores;

  Subject({required this.name, required this.scores});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      name: json['name'],
      scores: List<int>.from(json['scores']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scores': scores,
    };
  }
}

// Cấu trúc đối tượng sinh viên
class Student {
  int id;
  String name;
  List<Subject> subjects;

  Student({required this.id, required this.name, required this.subjects});

  factory Student.fromJson(Map<String, dynamic> json) {
    var list = json['subjects'] as List;
    List<Subject> subjectsList = list.map((i) => Subject.fromJson(i)).toList();
    return Student(
      id: json['id'],
      name: json['name'],
      subjects: subjectsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subjects': subjects.map((subject) => subject.toJson()).toList(),
    };
  }
}

// Đọc dữ liệu từ file JSON
List<Student> loadStudents() {
  final file = File('Student.json');
  final contents = file.readAsStringSync();
  final jsonData = json.decode(contents);
  return (jsonData['students'] as List)
      .map((data) => Student.fromJson(data))
      .toList();
}

// Lưu dữ liệu vào file JSON
void saveStudents(List<Student> students) {
  final file = File('Student.json');
  final jsonData = {
    'students': students.map((student) => student.toJson()).toList(),
  };
  file.writeAsStringSync(json.encode(jsonData));
}

// Hiển thị danh sách sinh viên
void displayStudents(List<Student> students) {
  for (var student in students) {
    print('ID: ${student.id}, Name: ${student.name}');
    for (var subject in student.subjects) {
      print('  Subject: ${subject.name}, Scores: ${subject.scores}');
    }
  }
}

// Thêm sinh viên mới
void addStudent(List<Student> students) {
  print('Nhập ID sinh viên:');
  int id = int.parse(stdin.readLineSync()!);

  // Kiểm tra ID trùng lặp
  bool idExists = students.any((student) => student.id == id);
  if (idExists) {
    print('ID đã tồn tại. Vui lòng nhập ID khác.');
    return;
  }

  print('Nhập tên sinh viên:');
  String name = stdin.readLineSync()!;

  List<Subject> subjects = [];
  while (true) {
    print('Nhập tên môn học (hoặc "done" để hoàn thành):');
    String subjectName = stdin.readLineSync()!;
    if (subjectName.toLowerCase() == 'done') break;

    List<int> scores = [];
    print('Nhập điểm (cách nhau bằng dấu phẩy, điểm không vượt quá 10):');
    scores = stdin
        .readLineSync()!
        .split(',')
        .map((score) {
          int parsedScore = int.parse(score.trim());
          if (parsedScore > 10) {
            print('Điểm không được vượt quá 10. Vui lòng nhập lại điểm cho môn học "$subjectName".');
            return 0; // Đặt điểm sai để yêu cầu người dùng nhập lại
          }
          return parsedScore;
        })
        .toList();

    subjects.add(Subject(name: subjectName, scores: scores));
  }

  students.add(Student(id: id, name: name, subjects: subjects));
  saveStudents(students);
  print('Thêm sinh viên thành công!');
}

// Sửa thông tin sinh viên
void editStudent(List<Student> students) {
  print('Nhập ID sinh viên để sửa:');
  int id = int.parse(stdin.readLineSync()!);

  var student = students.firstWhere((student) => student.id == id,
      orElse: () => Student(id: 0, name: '', subjects: []));
  if (student.id == 0) {
    print('Sinh viên không tồn tại!');
    return;
  }

  print('Nhập tên mới (để trống để giữ nguyên: ${student.name}):');
  String? newName = stdin.readLineSync();
  if (newName!.isNotEmpty) {
    student.name = newName;
  }

  while (true) {
    print('Nhập tên môn học để sửa (hoặc "done" để hoàn thành):');
    String subjectName = stdin.readLineSync()!;
    if (subjectName.toLowerCase() == 'done') break;

    var subject = student.subjects.firstWhere(
        (subject) => subject.name == subjectName,
        orElse: () => Subject(name: '', scores: []));
    if (subject.name.isEmpty) {
      print('Môn học không tồn tại! Thêm môn học mới...');
      List<int> scores = [];
      print('Nhập điểm (cách nhau bằng dấu phẩy, điểm không vượt quá 10):');
      scores = stdin
          .readLineSync()!
          .split(',')
          .map((score) {
            int parsedScore = int.parse(score.trim());
            if (parsedScore > 10) {
              print('Điểm không được vượt quá 10. Vui lòng nhập lại điểm cho môn học "$subjectName".');
              return 0; // Đặt điểm sai để yêu cầu người dùng nhập lại
            }
            return parsedScore;
          })
          .toList();
      student.subjects.add(Subject(name: subjectName, scores: scores));
    } else {
      print('Nhập điểm mới (cách nhau bằng dấu phẩy, để trống để giữ nguyên: ${subject.scores}):');
      String newScores = stdin.readLineSync()!;
      if (newScores.isNotEmpty) {
        subject.scores = newScores
            .split(',')
            .map((score) {
              int parsedScore = int.parse(score.trim());
              if (parsedScore >= 10) {
                print('Điểm không được vượt quá 10. Vui lòng nhập lại điểm.');
                return 0; // Đặt điểm sai để yêu cầu người dùng nhập lại
              }
              return parsedScore;
            })
            .toList();
      }
    }
  }

  saveStudents(students);
  print('Thông tin sinh viên đã được cập nhật thành công!');
}

// Tìm kiếm sinh viên theo tên hoặc ID
void searchStudent(List<Student> students) {
  print('Nhập tên hoặc ID sinh viên:');
  String query = stdin.readLineSync()!;

  var results = students.where((student) =>
      student.name.toLowerCase().contains(query.toLowerCase()) ||
      student.id.toString() == query).toList();

  if (results.isEmpty) {
    print('Không tìm thấy sinh viên.');
  } else {
    displayStudents(results);
  }
}

// Menu chính của chương trình
void main() {
  List<Student> students = loadStudents();

  while (true) {
    print('''
1. Hiển thị tất cả sinh viên
2. Thêm sinh viên mới
3. Sửa thông tin sinh viên
4. Tìm kiếm sinh viên theo tên hoặc ID
5. Thoát
Chọn tùy chọn:''');

    String? choice = stdin.readLineSync();
    if (choice == '1') {
      displayStudents(students);
    } else if (choice == '2') {
      addStudent(students);
    } else if (choice == '3') {
      editStudent(students);
    } else if (choice == '4') {
      searchStudent(students);
    } else if (choice == '5') {
      print('Thoát...');
      break;
    } else {
      print('Tùy chọn không hợp lệ. Vui lòng chọn lại.');
    }
  }
}
