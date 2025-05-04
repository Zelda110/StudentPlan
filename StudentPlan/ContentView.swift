//
//  ContentView.swift
//  StudentPlan
//
//  Created by ハイラル・ゼルダ on 2025/4/24.
//

import AppKit
import SwiftUI

struct ContentView: View {
    @AppStorage("student_list") private var studentListData: Data = Data()
    @State var student_list: [Student] = []
    var body: some View {
            VStack() {
                Text("炫飞羽毛球教练评价系统").font(.title)
                Text("version 1.3").font(.footnote)
                InputView(student_list: $student_list)
            }
            .onAppear {
                if let decoded = try? JSONDecoder().decode(
                    [Student].self,
                    from: studentListData
                ) {
                    student_list = decoded
                }
            }
            .frame(minWidth:500)
            .padding(.vertical)
    }
}

struct StudentView: View {
    @Binding var student: Student
    var body: some View {
        VStack(alignment: .leading) {
            Text(student.name).font(.title)
            Text(student.gender.rawValue)
            Text(
                String(Calendar.current.component(.year, from: Date())-student.birthday)+"岁"
            )
        }
    }
}

struct InputView: View {
    private struct StagePicker: View {
        @Binding var skill: Skill
        var text: String
        var body: some View {
            HStack {
                Picker(text, selection: $skill.stage) {
                    Text(Stage.beginner.rawValue).tag(Stage.beginner)
                    Text(Stage.intermediate.rawValue).tag(Stage.intermediate)
                    Text(Stage.advanced.rawValue).tag(Stage.advanced)
                }
                .frame(maxWidth: 150)
                Stepper(value: $skill.level, in: 1...3) {
                    Text(String(skill.level))
                }
            }
        }
    }

    @AppStorage("student_list") private var studentListData: Data = Data()
    @State var selectedStudentIndex: Int? = nil
    @State var target: String = ""
    @State var plans = [[Bool]](
        repeating: [Bool](repeating: false, count: ALL_TRAINS.count),
        count: 10
    )
    @State var train_edting = [Bool](repeating: false, count: 10)
    @State var pasting = [Bool](repeating: false, count: 10)
    @State var now_condition = ""
    @State var couch_word = ""
    @State var adding_student = false
    @State var editing_student = false
    @State var skills = SkillGroup()
    @Binding var student_list: [Student]
    @Environment(\.modelContext) private var modelContext
    @State var showing = false
    @State var choosing_student_alert = false
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Menu {
                        ForEach(student_list, id: \.name) { stu in
                            Button {
                                selectedStudentIndex = student_list.firstIndex(
                                    where: { $0.name == stu.name })
                                if student_list[selectedStudentIndex!].plans
                                    .isEmpty
                                {
                                    skills = SkillGroup()
                                } else {
                                    skills =
                                        student_list[selectedStudentIndex!]
                                        .plans[
                                            student_list[selectedStudentIndex!]
                                                .plans.count - 1
                                        ].skillGroup
                                }
                            } label: {
                                Text(stu.name)
                            }
                        }
                    } label: {
                        selectedStudentIndex == nil
                            ? Text("选择学员")
                            : Text(student_list[selectedStudentIndex!].name)
                    }
                    if let index = selectedStudentIndex {
                        StudentView(student: $student_list[index])
                    }
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
                    if selectedStudentIndex != nil {
                        Button {
                            editing_student = true
                        } label: {
                            Text("编辑学员")
                        }
                        .sheet(isPresented: $editing_student) {
                            StudentEdit(
                                name: student_list[selectedStudentIndex!].name,
                                gender: student_list[selectedStudentIndex!]
                                    .gender,
                                plans: student_list[selectedStudentIndex!]
                                    .plans,
                                birthday:String(student_list[selectedStudentIndex!]
                                    .birthday),
                                editing: $editing_student,
                                student_list: $student_list
                            )
                            .environment(\.modelContext, modelContext)
                            .onDisappear {
                                selectedStudentIndex = nil
                            }
                        }
                    }
                }
                .frame(maxWidth: 100)
                VStack(alignment: .leading) {
                    Text("技术水平").font(.title)
                    StagePicker(skill: $skills.高远球, text: "高远球")
                    StagePicker(skill: $skills.挑球, text: "挑球")
                    StagePicker(skill: $skills.发球, text: "发球")
                    StagePicker(skill: $skills.杀球, text: "杀球")
                    StagePicker(skill: $skills.平抽挡, text: "平抽挡")
                    StagePicker(skill: $skills.左右步伐, text: "左右步伐")
                    StagePicker(skill: $skills.前后步伐, text: "前后步伐")
                    StagePicker(skill: $skills.接杀, text: "接杀")
                    StagePicker(skill: $skills.稳定性, text: "稳定性")
                }
                VStack(alignment: .leading) {
                    Text("训练计划")
                        .font(.title)
                        .padding(.bottom)
                    Text("教练点评")
                        .font(.title2)
                    HStack {
                        Text("学员目前情况")
                        TextField("", text: $now_condition)
                    }
                    .padding(.bottom)
                    HStack {
                        Text("训练目标")
                        TextField("", text: $target)
                    }
                    .padding(.bottom)
                    Text("课程安排")
                        .font(.title2)
                    VStack(alignment: .leading) {
                        ForEach(plans.indices) { day in
                            HStack {
                                Text("第\(day + 1)节")
                                HStack {
                                    ForEach(plans[day].indices) { i in
                                        if plans[day][i] {
                                            Button {
                                                plans[day][i] = false
                                            } label: {
                                                HStack {
                                                    Text(ALL_TRAINS[i].name)
                                                    Image(systemName: "xmark")
                                                }
                                            }
                                        }
                                    }
                                }
                                Button {
                                    train_edting[day].toggle()
                                } label: {
                                    Image(systemName: "plus")
                                }
                                .sheet(isPresented: $train_edting[day]) {
                                    TrainChooseView(
                                        checked: $plans[day],
                                        viewing: $train_edting[day]
                                    )
                                }
                                Button {
                                    pasting = plans[day]
                                } label: {
                                    Image(systemName: "document.on.document")
                                }
                                Button {
                                    plans[day] = pasting
                                } label: {
                                    Image(systemName: "document.on.clipboard")
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    HStack {
                        Text("教练寄语")
                        TextField("", text: $couch_word)
                    }
                }
                .padding()
            }
        }
        Button {
            if selectedStudentIndex != nil {
                student_list[selectedStudentIndex!].plans
                    .append(Plan(skillGroup: skills))
                if let encoded = try? JSONEncoder().encode(student_list) {
                    studentListData = encoded
                }
                showing = true
            } else {
                choosing_student_alert = true
            }
        } label: {
            Text("保存")
        }
        .sheet(isPresented: $showing) {
            ShowingView(
                selectedStudentIndex: selectedStudentIndex,
                target: target,
                plans: plans,
                now_condition: now_condition,
                couch_word: couch_word,
                skills: skills,
                student_list: $student_list,
                showing: $showing
            )
        }
        .alert(isPresented: $choosing_student_alert) {
            Alert(title: Text("请选择学员"))
        }
        .padding()
    }
}

struct ShowingView: View {
    private struct StagePicker: View {
        @State var skill: Skill
        var text: String
        var body: some View {
            HStack {
                HStack {
                    Text(text)
                    Spacer()
                }.frame(width: 60)
                Text(skill.stage.rawValue)
                    .frame(width: 30)
                Text(String(skill.level) + "级")
            }
        }
    }

    @State var selectedStudentIndex: Int?
    @State var target: String
    @State var plans: [[Bool]]
    @State var now_condition: String
    @State var couch_word: String
    @State var skills: SkillGroup
    @Binding var student_list: [Student]
    @Binding var showing: Bool
    @State var display_button: Bool = true
    @State var cgimage: CGImage?
    @State var outputing = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                let student = student_list[selectedStudentIndex!]
                Text(student.name + "训练计划")
                    .font(.title)
                Text(student.gender.rawValue)
                Text(
                    String(Calendar.current.component(.year, from: Date())-student.birthday)+"岁"
                )
                .padding(.bottom)
                VStack(alignment: .leading) {
                    Text("技术水平").font(.title).padding(.bottom)
                    StagePicker(skill: skills.高远球, text: "高远球")
                    StagePicker(skill: skills.挑球, text: "挑球")
                    StagePicker(skill: skills.发球, text: "发球")
                    StagePicker(skill: skills.杀球, text: "杀球")
                    StagePicker(skill: skills.平抽挡, text: "平抽挡")
                    StagePicker(skill: skills.左右步伐, text: "左右步伐")
                    StagePicker(skill: skills.前后步伐, text: "前后步伐")
                    StagePicker(skill: skills.接杀, text: "接杀")
                    StagePicker(skill: skills.稳定性, text: "稳定性")
                }
                .padding(.bottom)
                VStack(alignment: .leading) {
                    Text("教练点评")
                        .font(.title2)
                    HStack {
                        Text("学员目前情况")
                        Text(now_condition)
                    }
                    .padding(.bottom)
                    HStack {
                        Text("训练目标")
                        Text(target)
                    }
                    .padding(.bottom)
                    Text("训练计划")
                        .font(.title)
                        .padding(.bottom)
                    Text("课程安排")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(plans.indices) { day in
                            HStack(alignment: .top) {
                                Text("第\(day + 1)节")
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(plans[day].indices) { i in
                                        if plans[day][i] {
                                            VStack(
                                                alignment: .leading,
                                                spacing: 0
                                            ) {
                                                Text(ALL_TRAINS[i].name)
                                                Text(ALL_TRAINS[i].description)
                                                    .font(.footnote)
                                                    .foregroundStyle(.gray)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    HStack {
                        Text("教练寄语")
                        Text(couch_word)
                    }
                }
            }
            .background {
                VStack(spacing: 200) {
                    ForEach(0..<50) { item in
                        Image("bg")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.5)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            if display_button {
                HStack {
                    Button("完成") {
                        showing = false
                    }
                    if let cgimage {
                        Button("导出") {
                            outputing = true
                            let nsImage = NSImage(cgImage: cgimage, size: .zero)
                            if let tiffData = nsImage.tiffRepresentation,
                                let bitmap = NSBitmapImageRep(data: tiffData),
                                let pngData = bitmap.representation(
                                    using: .png,
                                    properties: [:]
                                )
                            {
                                let panel = NSSavePanel()
                                panel.allowedFileTypes = ["png"]
                                panel.nameFieldStringValue =
                                    "\(student_list[selectedStudentIndex!].name)训练计划.png"
                                let response = panel.runModal()
                                if response == .OK, let url = panel.url {
                                    do {
                                        try pngData.write(to: url)
                                    } catch {
                                        print("导出失败：\(error)")
                                    }
                                }
                            }
                            outputing = false
                        }
                        .sheet(isPresented: $outputing){
                            HStack {
                                Text("导出中")
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .padding()
        .onAppear {
            let render = ImageRenderer(
                content: get_sharing_view(
                    selectedStudentIndex: selectedStudentIndex,
                    target: target,
                    plans: plans,
                    now_condition: now_condition,
                    couch_word: couch_word,
                    skills: skills,
                    student_list: student_list
                )
            )
            render.scale = 2
            cgimage = render.cgImage
        }
    }
}

struct SharingStagePicker: View {
    @State var skill: Skill
    var text: String
    var body: some View {
        HStack {
            HStack {
                Text(text)
                Spacer()
            }.frame(width: 60)
            Text(skill.stage.rawValue)
                .frame(width: 30)
            Text(String(skill.level) + "级")
        }
    }
}

func get_sharing_view(
    selectedStudentIndex: Int?,
    target: String,
    plans: [[Bool]],
    now_condition: String,
    couch_word: String,
    skills: SkillGroup,
    student_list: [Student]
) -> some View {
    VStack {
        VStack(alignment: .leading) {
            let student = student_list[selectedStudentIndex!]
            Text(student.name + "训练计划")
                .font(.title)
            Text(student.gender.rawValue)
            Text(
                String(Calendar.current.component(.year, from: Date())-student.birthday)+"岁"
            )
            .padding(.bottom)
            VStack(alignment: .leading) {
                Text("技术水平").font(.title).padding(.bottom)
                SharingStagePicker(skill: skills.高远球, text: "高远球")
                SharingStagePicker(skill: skills.挑球, text: "挑球")
                SharingStagePicker(skill: skills.发球, text: "发球")
                SharingStagePicker(skill: skills.杀球, text: "杀球")
                SharingStagePicker(skill: skills.平抽挡, text: "平抽挡")
                SharingStagePicker(skill: skills.左右步伐, text: "左右步伐")
                SharingStagePicker(skill: skills.前后步伐, text: "前后步伐")
                SharingStagePicker(skill: skills.接杀, text: "接杀")
                SharingStagePicker(skill: skills.稳定性, text: "稳定性")
            }
            .padding(.bottom)
            VStack(alignment: .leading) {
                Text("教练点评")
                    .font(.title2)
                HStack {
                    Text("学员目前情况")
                    Text(now_condition)
                }
                .padding(.bottom)
                HStack {
                    Text("训练目标")
                    Text(target)
                }
                .padding(.bottom)
                Text("训练计划")
                    .font(.title)
                    .padding(.bottom)
                Text("课程安排")
                    .font(.title2)
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(plans.indices) { day in
                        HStack(alignment: .top) {
                            Text("第\(day + 1)节")
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(plans[day].indices) { i in
                                    if plans[day][i] {
                                        VStack(alignment: .leading, spacing: 0)
                                        {
                                            Text(ALL_TRAINS[i].name)
                                            Text(ALL_TRAINS[i].description)
                                                .font(.footnote)
                                                .foregroundStyle(.gray)
                                                .lineLimit(nil)
                                                .fixedSize(
                                                    horizontal: false,
                                                    vertical: true
                                                )
                                                .multilineTextAlignment(
                                                    .leading
                                                )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom)
                HStack {
                    Text("教练寄语")
                    Text(couch_word)
                }
            }
        }
        .padding()
    }
    .frame(width: 400)
    .fixedSize(horizontal: false, vertical: true)
    .background {
        ZStack {
            Color.white
            VStack(spacing: 200) {
                ForEach(0..<50) { item in
                    Image("bg")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.5)
                }
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    .padding(.vertical)
}

#Preview {
    ContentView()
}
