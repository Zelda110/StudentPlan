//
//  StudentEdit.swift
//  StudentPlan
//
//  Created by ハイラル・ゼルダ on 2025/4/24.
//

import SwiftData
import SwiftUI

enum Gender: String, Codable {
    case male = "男"
    case female = "女"
}

enum Stage: String, Codable {
    case beginner = "启蒙"
    case intermediate = "初级"
    case advanced = "高级"
}

struct Skill: Codable {
    var stage: Stage = .beginner
    var level: Int = 1
}

struct SkillGroup: Codable {
    var 高远球: Skill = Skill()
    var 挑球: Skill = Skill()
    var 发球: Skill = Skill()
    var 杀球: Skill = Skill()
    var 平抽挡: Skill = Skill()
    var 左右步伐: Skill = Skill()
    var 前后步伐: Skill = Skill()
    var 接杀: Skill = Skill()
    var 稳定性: Skill = Skill()
}

struct Plan: Codable {
    var skillGroup: SkillGroup
}

class Student: Codable, Identifiable, Equatable {
    var name: String
    var gender: Gender
    var height: Float
    var weight: Float
    var plans: [Plan]

    init(
        name: String,
        gender: Gender,
        height: Float,
        weight: Float,
        plans: [Plan]
    ) {
        self.name = name
        self.gender = gender
        self.height = height
        self.weight = weight
        self.plans = plans
    }
    
    static func == (lhs:Student,rhs:Student) -> Bool {
        return lhs.name == rhs.name
    }
}

struct StudentEdit: View {
    @AppStorage("student_list") private var studentListData: Data = Data()
    @State var name: String = ""
    @State var gender: Gender = .male
    @State var height: String = ""
    @State var weight: String = ""
    @State var plans: [Plan] = []
    @Binding var editing: Bool
    @Binding var student_list: [Student]
    @State var alerting = false
    var body: some View {
        VStack {
            HStack {
                Text("姓名")
                TextField(name, text: $name)
            }
            HStack {
                Picker("性别",selection: $gender){
                    Text("男").tag(Gender.male)
                    Text("女").tag(Gender.female)
                }
            }
            HStack {
                Text("身高")
                TextField(height, text: $height)
            }
            HStack {
                Text("体重")
                TextField(weight, text: $weight)
            }
            HStack {
                Button {
                    editing = false
                } label: {
                    Text("取消")
                }
                Button {
                    if Float(height) != nil, Float(weight) != nil {
                        student_list.removeAll(where: { $0.name == name })
                        student_list
                            .append(
                                Student(
                                    name: name,
                                    gender: gender,
                                    height: Float(height)!,
                                    weight: Float(weight)!,
                                    plans: plans
                                )
                            )
                        if let encoded = try? JSONEncoder().encode(student_list)
                        {
                            studentListData = encoded
                        }
                        editing = false
                    } else {
                        alerting = true
                    }
                } label: {
                    Text("确定")
                }.alert(isPresented: $alerting) {
                    Alert(title: Text("身高体重格式错误"))
                }
            }
        }
        .padding()
    }
}

#Preview {
    @State var e = true
    @State var stus: [Student] = []
    StudentEdit(editing: $e, student_list: $stus)
}
