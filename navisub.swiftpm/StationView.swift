//
//  StationView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/2/12.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation

@available(iOS 17.0, *)
struct StationView: View {
    let directions: [Character] = ["L", "R"]
    let images: [String] = ["toilet", "accessible-toilet", "elevator", "escalator", "stairs", "stairlift", "aed", "breastfeeding"]
    let names: [String] = ["toilet", "accessible toilet", "elevator", "escalator", "stairs", "stairlift", "aed", "nursing room"]
    let colors: [Color] = [Color(red: 0.71, green: 0.74, blue: 0.00),
                           Color(red: 0.38, green: 0.71, blue: 0.89),
                           Color(red: 0.00, green: 0.44, blue: 0.81),
                           Color(red: 0.89, green: 0.14, blue: 0.10),
                           Color(red: 0.64, green: 0.37, blue: 0.71),
                           Color(red: 0.38, green: 0.71, blue: 0.89),
                           Color(red: 0.89, green: 0.55, blue: 0.00),
                           Color(red: 0.91, green: 0.47, blue: 0.80)]
    
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    @State private var showPopover = false
    @State private var selectedIndex: Int = 0
    @State private var cameraPosition =  MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9180, longitude: 116.3960),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))
    
    private func selectConcatInfo(infos: [Info], t: Int) -> String {
        var numList: [Int] = []
        for i in infos {
            if (t == 0 && i.type == "0") {
                numList.append(i.door)
            }
            if (t == 1 && i.type == "0" && i.arg == "T") {
                numList.append(i.door)
            }
            if (t == 2 && i.type == "2") {
                numList.append(i.door)
            }
            if (t == 3 && i.type == "1") {
                numList.append(i.door)
            }
            if (t == 4 && i.type == "3") {
                numList.append(i.door)
            }
            if (t == 5 && i.type == "3" && i.arg == "T") {
                numList.append(i.door)
            }
            if (t == 6 && i.type == "8") {
                numList.append(i.door)
            }
            if (t == 7 && i.type == "7") {
                numList.append(i.door)
            }
        }
        if (numList.isEmpty) {
            return env.isEnglish ? "No Info" : "暂无信息"
        }
        return numList.map { String($0) }.joined(separator: ", ")
    }
    
    var body: some View {
        ZStack {
            VStack {
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    Marker(env.isEnglish ? env.selectedStation!.name_eg : env.selectedStation!.name_cn, coordinate: CLLocationCoordinate2D(latitude: env.selectedStation!.latitude, longitude: env.selectedStation!.longitude))
                        .tint(.blue)
                }
                .edgesIgnoringSafeArea(.all)
                .frame(height: UIScreen.main.bounds.height / 4 * 1)
                .onAppear{cameraPosition =  MapCameraPosition.region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: env.selectedStation!.latitude, longitude: env.selectedStation!.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))}
                Spacer()
            }
            VStack {
                HStack {
                    Button(action: {
                        env.path.removeLast()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .padding(10)
                    }
                    Spacer()
                }
                Spacer()
            }
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.white)
                    .frame(height: UIScreen.main.bounds.height / 4 * 3)
                    .edgesIgnoringSafeArea(.bottom)
                    .cornerRadius(30)
                    .overlay( 
                        ScrollView {
                            VStack {
                                HStack {
                                    Text(env.isEnglish ? env.selectedStation!.name_eg : env.selectedStation!.name_cn)
                                        .font(.system(size: 30))
                                        .bold()
                                        .padding(.top, 20)
                                        .padding(.leading, 20)
                                        .padding(.trailing, 20)
                                        .padding(.bottom, 0)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Divider()
                                    .background(Color.gray)
                                    .padding(.horizontal)
                                HStack {
                                    ForEach(env.selectedStation!.lines.indices, id: \.self) { index in
                                        let line = env.selectedStation!.lines[index]
                                        if (index == selectedIndex) {
                                            Button(action: {selectedIndex = index}) {
                                                ZStack {
                                                    Circle()
                                                        .fill(line.color)
                                                        .frame(width: 38, height: 38)
                                                    Text("\(line.abbreviation_eg)")
                                                        .font(.system(size: 20))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            .padding(.leading, 5)
                                            .padding(.top, 10)
                                        }
                                        else {
                                            Button(action: {selectedIndex = index}) {
                                                ZStack {
                                                    Circle()
                                                        .stroke(line.color, lineWidth: 3)
                                                        .frame(width: 35, height: 35)
                                                    Text("\(line.abbreviation_eg)")
                                                        .font(.system(size: 20))
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(line.color)
                                                }
                                            }
                                            .padding(.leading, 5)
                                            .padding(.top, 10)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.leading, 15)
                                VStack {
                                    ForEach(directions, id: \.self) { dir in
                                        VStack {
                                            let plat = db.getPlatform(station: env.selectedStation!, line: env.selectedStation!.lines[selectedIndex])
                                            let nextPlat = db.getDirectionPlatform(db: db, platform: plat, direction: dir)
                                            let infos = db.getInfo(platform: plat, direction: dir)
                                            if let nextPlat = nextPlat {
                                                if let st = nextPlat.station {
                                                    Text(env.isEnglish ? "To \(st.name_eg)" : "\(st.name_cn) 方向")
                                                        .font(.system(size: 23))
                                                        .bold()
                                                        .padding(.leading, 20)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                            }
                                            ForEach(0..<names.count/2, id: \.self) { index in
                                                HStack {
                                                    HStack {
                                                        Rectangle()
                                                            .fill(colors[2*index])
                                                            .frame(width: 37, height: 37)
                                                            .cornerRadius(7)
                                                            .overlay(
                                                                Image(images[2*index])
                                                                    .resizable()
                                                                    .frame(width: 25, height: 25)
                                                            )
                                                        Text("\(selectConcatInfo(infos: infos, t: index*2))")
                                                            .padding(.leading, 5)
                                                            .font(.system(size: 23))
                                                            .foregroundColor(.black)
                                                        Spacer()
                                                    }
                                                    .padding(.leading, 30)
                                                    .frame(width: UIScreen.main.bounds.width / 2)
                                                    HStack {
                                                        Rectangle()
                                                            .fill(colors[2*index+1])
                                                            .frame(width: 37, height: 37)
                                                            .cornerRadius(7)
                                                            .overlay(
                                                                Image(images[2*index+1])
                                                                    .resizable()
                                                                    .frame(width: 25, height: 25)
                                                            )
                                                        Text("\(selectConcatInfo(infos: infos, t: index*2+1))")
                                                            .padding(.leading, 5)
                                                            .font(.system(size: 23))
                                                            .foregroundColor(.black)
                                                        Spacer()
                                                    }
                                                    .frame(width: UIScreen.main.bounds.width / 2)
                                                }
                                            }
                                        }
                                        .padding(.top, 10)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                    )
            }
        }
        .navigationBarHidden(true)
    }
}

