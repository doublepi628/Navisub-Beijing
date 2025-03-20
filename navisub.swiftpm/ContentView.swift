//
//  ContentView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/1/8.
//

import SwiftUI
import MapKit
import CoreLocation
import Foundation

@available(iOS 17.0, *)
struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    @State private var isFirstLaunch: Bool = false
    
    let defaultLocation = CLLocationCoordinate2D(latitude: 39.9180, longitude: 116.3960)
    let latitudeRange = (min: 39.442078, max: 41.058964)
    let longitudeRange = (min: 115.416827, max: 117.508251)
    
    var body: some View {
        NavigationStack(path: $env.path) {
            ZStack {
                Map(position: $env.cameraPosition) {
                    UserAnnotation()
                    ForEach (db.stations, id: \.id) { station in
                        if (station == env.selectedStart) {
                            Marker("", coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude))
                                .tint(Color(red: 0x08/255.0, green: 0x99/255.0, blue: 0x5B/255.0))
                        }
                        if (station == env.selectedEnd) {
                            Marker("",coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude))
                                .tint(Color(red: 0xE0/255.0, green: 0x0F/255.0, blue: 0x0F/255.0))
                        }
                        Annotation(env.isEnglish ? station.name_eg : station.name_cn, coordinate: CLLocationCoordinate2D(latitude: station.latitude, longitude: station.longitude)) {
                            Menu {
                                Button(env.isEnglish ? "Show Info" : "查看详情") {
                                    env.selectedStation = station
                                    env.path.append("StationView")
                                }
                                Button(env.isEnglish ? "Select As Start" : "设为起点") {
                                    env.setStart(station: station)
                                }
                                Button(env.isEnglish ? "Select As End" : "设为终点") {
                                    env.setEnd(station: station)
                                }
                            } label: {
                                VStack {
                                    if (station == env.selectedStart || station == env.selectedEnd) {
                                        Color.clear
                                            .frame(width: 20, height: 20)
                                    }
                                    else {
                                        Image(systemName: "tram.circle.fill")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            let tmpStation: Station? = env.selectedStart
                            env.selectedStart = env.selectedEnd
                            env.selectedEnd = tmpStation
                        }) {
                            VStack {
                                Image(systemName: "arrow.up.arrow.down")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 20, height: 20)
                                    .padding(.leading, 15)
                                    
                            }
                        }
                        .frame(width: 45, height: 70)
                        VStack(spacing: 0) {
                            Button (action: {
                                env.selectedDir = "S"
                                env.path.append("SearchView")
                            }) {
                                HStack {
                                    Circle()
                                        .fill(Color(red: 0x08/255.0, green: 0x99/255.0, blue: 0x5B/255.0))
                                        .frame(width: 8, height: 8)
                                    if (env.selectedStart == nil) {
                                        Text(env.isEnglish ? "Select Starting Point" : "请选择起点")
                                            .font(.system(size: 18))
                                            .foregroundColor(.gray)
                                    }
                                    else {
                                        Text(env.isEnglish ? env.selectedStart!.name_eg : env.selectedStart!.name_cn)
                                            .font(.system(size: 18))
                                            .foregroundColor(.black)
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width-150, height: 30)
                            Divider()
                                .background(Color.gray)
                                .frame(width: UIScreen.main.bounds.width-150)
                            Button (action: {
                                env.selectedDir = "E"
                                env.path.append("SearchView")
                            }) {
                                HStack {
                                    Circle()
                                        .fill(Color(red: 0xE0/255.0, green: 0x0F/255.0, blue: 0x0F/255.0))
                                        .frame(width: 8, height: 8)
                                    if (env.selectedEnd == nil) {
                                        Text(env.isEnglish ? "Select Ending Point" : "请选择终点")
                                            .font(.system(size: 18))
                                            .foregroundColor(.gray)
                                    }
                                    else {
                                        Text(env.isEnglish ? env.selectedEnd!.name_eg : env.selectedEnd!.name_cn)
                                            .font(.system(size: 18))
                                            .foregroundColor(.black)
                                    }
                                    Spacer()
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width-150, height: 30)
                        }
                        .frame(width: UIScreen.main.bounds.width-150, height: 70)
                        Spacer()
                        Button(action: {
                            if (env.selectedStart != nil && env.selectedEnd != nil && env.selectedStart != env.selectedEnd) {
                                env.path.append("RouteView")
                            }
                        }) {
                            VStack {
                                Image(systemName: "location.fill")
                                    .resizable()
                                    .foregroundColor((env.selectedStart != nil && env.selectedEnd != nil && env.selectedStart != env.selectedEnd) ? Color.blue : Color.gray)
                                    .frame(width: 20, height: 20)
                                    .padding(.trailing, 15)
                            }
                        }
                        .frame(width: 45, height: 70)
                    }
                    .frame(width: UIScreen.main.bounds.width-60, height: 70)
                    .background(Color.white.opacity(0.90))
                    .cornerRadius(10)
                    .shadow(radius: 10)
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            VStack(spacing: 12) {
                                Button(action: {
                                    env.path.append("UserView")
                                }) {
                                    VStack {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(white: 0.4))
                                    }
                                    .frame(width: 40, height: 40)
                                    .background(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 30)
                                }
                                Button(action: {
                                    locationManager.checkLocationAuthorization()
                                    if let location = locationManager.currentLocation {
                                        if isLocationInRange(location: location) {
                                            env.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                                                center: location,
                                                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                                            ))
                                        } else {
                                            env.cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                                                center: defaultLocation,
                                                span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
                                            ))
                                        }
                                    }
                                }) {
                                    VStack {
                                        Image(systemName: "mappin")
                                            .font(.system(size: 25))
                                            .foregroundColor(Color(white: 0.4))
                                    }
                                    .frame(width: 40, height: 40)
                                    .background(.white)
                                    .cornerRadius(10)
                                    .shadow(radius: 30)
                                }
                            }
                            .padding()
                        }
                    }.offset(y: -20)

                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { value in
                if value == "SearchView" {
                    SearchView()
                }
                else if value == "HistoryView" {
                    HistoryView()
                }
                else if value == "StarView" {
                    StarView()
                }
                else if value == "LineView" {
                    LineView()
                }
                else if value == "StationView" {
                    StationView()
                }
                else if value == "RouteView" {
                    RouteView()
                }
                else if value == "UserView" {
                    UserView()
                }
            }
            .sheet(isPresented: Binding<Bool>(
                get: { env.showHelp && isFirstLaunch },
                set: { _ in }
            )) {
                HelpView()
            }
        }
        .onAppear() {
            locationManager.checkLocationAuthorization()
            checkIfFirstLaunch()
            env.isEnglish = UserDefaults.standard.bool(forKey: "English")
        }
    }
    
    func isLocationInRange(location: CLLocationCoordinate2D) -> Bool {
        return location.latitude >= latitudeRange.min && location.latitude <= latitudeRange.max &&
               location.longitude >= longitudeRange.min && location.longitude <= longitudeRange.max
    }
    
    private func checkIfFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}

@available(iOS 17.0, *)
struct HelpView: View {
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    @State private var languageNotSelected: Bool = true
    
    let helpImagesEG = [SampleImage(url: "select-in-map", caption: "Select a subway station from the map"),
                      SampleImage(url: "select-by-search", caption: "Select a subway station through search"),
                      SampleImage(url: "select-in-line", caption: "Select a subway station from the Line page"),
                      SampleImage(url: "navigation", caption: "Get detailed navigation information"),
                      SampleImage(url: "view-detail", caption: "Get detailed station information")]
    let helpImagesCN = [SampleImage(url: "select-in-map-CN", caption: "从地图上选择一个地铁站"),
                      SampleImage(url: "select-by-search-CN", caption: "通过搜索选择一个地铁站"),
                      SampleImage(url: "select-in-line-CN", caption: "从地铁线路页面选择一个地铁站"),
                      SampleImage(url: "navigation-CN", caption: "获取地铁导航具体信息"),
                      SampleImage(url: "view-detail-CN", caption: "获取地铁站的具体信息")]
    
    var body: some View {
        VStack {
            HStack {
                Text(env.isEnglish ? "Navisub 🧭" : "畅铁北京 🧭")
                    .font(.system(size: 30))
                    .bold()
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.bottom, 0)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(env.isEnglish ? "Navisub is a Beijing subway navigation app that uses train door numbers to help passengers locate resources like nursing rooms, accessible elevators, and AEDs.":"畅铁北京（Navisub）是一款北京地铁导航应用，利用列车车门编号帮助乘客查找母婴室、无障碍电梯、AED 等资源。")
                .padding(.leading, 20)
                .padding(.trailing, 20)
            Divider()
                .background(Color.gray)
                .padding(.horizontal)
                .padding(.bottom, 10)
            TabView {
                ForEach(env.isEnglish ? helpImagesEG : helpImagesCN) { img in
                    VStack(spacing: 0) {
                        Image(img.url)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                            .padding()
                        Text(img.caption)
                    }
                }
            }
            .tabViewStyle(.page)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            Button(action: {
                env.showHelp = false
            }) {
                Text(env.isEnglish ? "Done" : "完成")
                   .foregroundColor(.white)
                   .bold()
                   .font(.body)
                   .frame(maxWidth: .infinity, minHeight: 45)
                   .background(Color.blue)
                   .cornerRadius(10)
                   .padding()
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height)
        .background(Color.white)
        .cornerRadius(20)
        .alert("Select Language / 选择语言", isPresented: $languageNotSelected) {
            Button("English") {
                env.isEnglish = true
                languageNotSelected = false
                UserDefaults.standard.set(true, forKey: "English")
            }
            Button("中文") {
                env.isEnglish = false
                languageNotSelected = false
                UserDefaults.standard.set(false, forKey: "English")
            }
        }
    }
}
