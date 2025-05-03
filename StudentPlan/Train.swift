//
//  Train.swift
//  StudentPlan
//
//  Created by ハイラル・ゼルダ on 2025/5/1.
//

import Foundation
import SwiftUI

struct Train: Codable {
    var name:String
    var description:String
    init(_ name: String, _ description: String) {
        self.name = name
        self.description = description
    }
}

let ALL_TRAINS = [
    Train("定点连贯挥拍高远球","高远球分解挥拍，丢球挥拍练习，连贯高远球挥拍动作练习，定点高远球连贯挥拍击球练习"),
    Train("定点挑球","挑球分解挥拍动作练习，连贯挑球挥拍练习，定点挑球连贯挥拍击球练习"),
    Train("定点发球","发球分解挥拍动作练习，连贯发球挥拍练习，定点丢球发球连贯挥拍击球练习"),
    Train("移动高远球上网挑球","一个高远球一个挑球结合练习，高远球、挑球发力和击球落点如果达到目前阶段标准可以往下一阶段练习，如果高远球没有达到目前阶段标准，将会对进行中场小区域高远球的击球练习，提高高远球的发力，如果挑球没有达到目前阶段的水平，将多进行定点挑球的练习，提高挑球的发力"),
    Train("移动高远球上网放网","学习放网动作，后场一个高远球网前上网一个放网的结合训练，目前阶段主要针对放网进行训练，提高放网的击球点和稳定性，如果放网不够稳定多进行定点放网的练习"),
    Train("吊球上网放网","进行吊球动作学习，定点吊球练习，后场一个吊球结合网前上网放网的结合练习，如果吊球掌握不牢多进行定点吊球的练习提高稳定性"),
    Train("杀球上网放网","进行杀球动作学习，定点杀球练习，后场一个杀球结合网前上网放网的结合练习，如果杀球掌握不牢多进行定点杀球的练习提高稳定性"),
    Train("网前两点挑球","学习网前两点挑球的步伐，进行步伐练习，学习正反手挑球换拍练习，结合步伐进行网前两点正反手挑球练习，如果反手挑球不稳定多进行原地反手挑球的练习"),
    Train("后场两边高远球","学习后场两边高远球的步伐，进行步伐训练，移动后场两边高远球击球练习，根据击球质量多练习薄弱侧高远球"),
    Train("半场随机","进行半场随机的步伐学习，练习半场随机步伐，进行半场随机多球训练，根据半场随机击球质量进行针对性训练，如果后场高球质量差，提高后场高球多球频率练习，如果上网挑球质量差，提高网前挑球多球频率练习"),
    Train("全场四点上直退斜","进行上直退斜全场步伐学习，练习上直退斜全场步伐练习，结合多球训练根据击球质量做出训练调整，后场击球质量差多进行后场两边高球的训练，网前击球质量差多进行网前两点挑球的训练"),
    Train("跳绳","纵跳（一分钟计时），跳绳辅助器（一分钟），纵跳单摇"),
    Train("步伐（10个高远球上网）","网前两边，后场两边，全场4点摸球，手指4点步伐。移动专项步伐，原地专项步伐"),
    Train("颠球","手握球颠球一次（依次叠加），教练丢球接球，向上丢球颠球"),
    Train("两边推球","两边摸线（推球），移动专项步伐，原地专项步伐，手指步伐，折返跑摸线"),
    Train("跳绳（双摇）","跳绳辅助器（一分钟），纵跳双摇，半蹲跳，半蹲跳双摇"),
    Train("步伐（4点20个）","网前两边，后场两边，全场4点摸球，手指4点步伐。移动专项步伐，原地专项步伐"),
    Train("20次低重心训练","4点摸球，折返跑依次摸线，移动专项步伐，原地专项步伐。手指步伐"),
    Train("两边推球","两边摸线（推球），两边接杀球步伐训练，移动专项步伐，原地专项步伐，手指步伐，折返跑摸线")
]

struct TrainChooseView:View {
    @Binding var checked: [Bool]
    @Binding var viewing: Bool
    var body: some View {
        VStack(alignment: .leading,spacing: 5){
            ForEach(ALL_TRAINS.indices){ i in
                VStack(alignment: .leading) {
                    Toggle(isOn: $checked[i]){
                        Text(ALL_TRAINS[i].name)
                        Text(ALL_TRAINS[i].description).font(.footnote)
                    }
                }
            }
            HStack {
                Spacer()
                Button("完成"){
                    viewing = false
                }
            }
        }.padding()
    }
}

#Preview {
    @State var plans = [Bool](repeating:false,count:ALL_TRAINS.count)
    @State var viewing = true
    TrainChooseView(checked: $plans,viewing: $viewing)
}
