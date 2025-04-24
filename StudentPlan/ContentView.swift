//
//  ContentView.swift
//  StudentPlan
//
//  Created by ハイラル・ゼルダ on 2025/4/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("student_list") private var studentListData: Data = Data()
    @State var student_list: [Student] = []
    var body: some View {
        VStack {
            InputView(student_list: $student_list)
                .padding()
            HStack {
                Button {
                    print("ok")
                } label: {
                    Text("保存")
                }
                .padding()
            }
        }
        .padding()
        .onAppear {
            if let decoded = try? JSONDecoder().decode(
                [Student].self,
                from: studentListData
            ) {
                student_list = decoded
            }
        }
    }
}

struct StudentView: View {
    @Binding var student: Student?
    var body: some View {
        if let student = student {
            VStack(alignment: .leading) {
                Text(student.name).font(.title)
                Text(student.gender.rawValue)
                Text(String(student.height) + "m")
                Text(String(student.weight) + "kg")
            }
        }
    }
}

struct StageChooseView: View {
    @Binding var student: Student?
    var body: some View {
        Menu {
            Button("初级") {
                student!.skillGroup.高远球.stage = .beginner
            }
            Button("中级") {
                student!.skillGroup.高远球.stage = .intermediate
            }
            Button("高级") {
                student!.skillGroup.高远球.stage = .advanced
            }
        } label: {
            Text(student!.skillGroup.高远球.stage?.rawValue ?? "选择水平")
        }
    }
}

struct InputView: View {
    @State var student: Student? = nil
    @State var target: String = ""
    @State var plan = [String](repeating: "", count: 10)
    @State var now_condition = ""
    @State var couch_word = ""
    @State var adding_student = false
    @State var editing_student = false
    @Binding var student_list: [Student]
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        HStack {
            VStack {
                Menu {
                    ForEach(student_list, id: \.name) { stu in
                        Button {
                            student = stu
//                            print(stu.skillGroup.高远球.stage?.rawValue)
                        } label: {
                            Text(stu.name)
                        }
                    }
                } label: {
                    student == nil ? Text("选择学员") : Text(student!.name)
                }
                StudentView(student: $student)
                Button {
                    adding_student = true
                } label: {
                    Text("添加学员")
                }
                .sheet(isPresented: $adding_student) {
                    StudentEdit(
                        editing: $adding_student,
                        student_list: $student_list
                    )
                    .environment(\.modelContext, modelContext)
                }
                if student != nil {
                    Button {
                        editing_student = true
                    } label: {
                        Text("编辑学员")
                    }
                    .sheet(isPresented: $editing_student) {
                        StudentEdit(
                            name: student!.name,
                            gender: student!.gender,
                            height: String(student!.height),
                            weight: String(student!.weight),
                            editing: $editing_student,
                            student_list: $student_list
                        )
                        .environment(\.modelContext, modelContext)
                    }
                }
            }
            .frame(maxWidth: 100)
            if student != nil {
                VStack(alignment: .leading) {
                    Text("技术水平")
                        .font(.title)
                    HStack {
                        Text("高远球")
                        StageChooseView(student: $student)
                    }
                }
            }
            VStack(alignment: .leading) {
                Text("训练计划")
                    .font(.title)
                HStack {
                    Text("训练目标")
                    TextField("", text: $target)
                }
                Text("课程安排")
                    .font(.title2)
                VStack {
                    ForEach(plan.indices) { day in
                        HStack {
                            Text("第" + String(day + 1) + "节")
                            TextField("", text: $plan[day])
                        }
                    }
                }
                Text("教练点评")
                    .font(.title2)
                HStack {
                    Text("学员目前情况")
                    TextField("", text: $now_condition)
                }
                HStack {
                    Text("教练寄语")
                    TextField("", text: $couch_word)
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
