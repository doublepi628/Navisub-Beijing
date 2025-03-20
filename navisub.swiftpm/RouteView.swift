//
//  RouteView.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/2/16.
//

import SwiftUI

@available(iOS 17.0, *)
class Route {
    @Published var route: [[Platform]]
    @Published var costs: [Int]

    var totCost: Int
    
    init(route: [[Platform]], totCost: Int, costs: [Int]) {
        self.route = route
        self.totCost = totCost
        self.costs = costs
    }
    
    func getDir (idx: Int) -> Character {
        if (idx < route.count) {
            let subroute = route[idx]
            if (subroute.count > 1) {
                return subroute[1].id - subroute[0].id > 0 ? "L" : "R"
            }
        }
        return "E"
    }
}

@available(iOS 17.0, *)
struct RouteView: View {
    @EnvironmentObject var db: Database
    @EnvironmentObject var env: EnvObjects
    @State var route: Route = Route(route: [[]], totCost: 0, costs: [])
    @State var display: [Bool] = Array(repeating: false, count: 100)
    
    let images: [String] = ["elevator", "escalator", "stairs", "stairlift"]
    let colors: [Color] = [Color(red: 0.00, green: 0.44, blue: 0.81),
                           Color(red: 0.89, green: 0.14, blue: 0.10),
                           Color(red: 0.64, green: 0.37, blue: 0.71),
                           Color(red: 0.38, green: 0.71, blue: 0.89)]
    
    private func selectConcatInfo(infos: [Info], t: Int, transfer: Int) -> String {
        var numList: [String] = []
        for i in infos {
            if (t == 0 && i.type == "2") {
                numList.append(String(i.door))
            }
            if (t == 1 && i.type == "1" ) {
                numList.append(String(i.door))
            }
            if (t == 2 && i.type == "3") {
                numList.append(String(i.door))
            }
            if (t == 3 && i.type == "3" && i.arg == "T") {
                numList.append(String(i.door))
            }
            if (t == 4 && i.type == "4" && i.arg == String(transfer)) {
                numList.append(String(i.door))
            }
            if (t == 4 && i.type == "5" && i.arg == String(transfer)) {
                numList.append("same platform transfer")
            }
        }
        return numList.joined(separator: ", ")
    }
    
    var body: some View {
        VStack() {
            HStack {
                Button(action: {
                    env.path.removeLast()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.gray)
                        .padding(10)
                        .padding(.leading, 5)
                }
                Spacer()
                Text(env.isEnglish ? "Total Duration: \(route.totCost) minutes" : "预计时长: \(route.totCost) 分钟")
                    .font(.system(size: 20))
                    .padding(.top,3)
                Spacer()
                Button(action: {
                    if (db.checkIfStar(star: Star(start_id: env.selectedStart!.id, end_id: env.selectedEnd!.id))) {
                        db.deleteStar(star: Star(start_id: env.selectedStart!.id, end_id: env.selectedEnd!.id))
                    }
                    else {
                        db.insertStar(star: Star(start_id: env.selectedStart!.id, end_id: env.selectedEnd!.id))
                    }
                }) {
                    Image(systemName: db.checkIfStar(star: Star(start_id: env.selectedStart!.id, end_id: env.selectedEnd!.id)) ? "star.fill" : "star")
                        .foregroundColor(Color(red: 255/255, green: 215/255, blue: 0/255))
                        .padding(10)
                        .padding(.trailing, 5)
                }
            }
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<route.route.count, id: \.self) { i in
                        let subroute = route.route[i]
                        VStack (spacing: 0) {
                            ForEach(0..<subroute.count, id: \.self) { j in
                                if (display[i] || j == 0 || j == subroute.count - 1) {
                                    HStack (spacing: 0) {
                                        VStack(spacing: 0) {
                                            Circle()
                                                .stroke(subroute[j].line!.color, lineWidth: 5)
                                                .frame(width: 17, height: 17)
                                                .padding(.leading, 5)
                                            Rectangle()
                                                .fill(j != subroute.count-1 ? subroute[j].line!.color : .clear)
                                                .frame(width: 15, height: (!display[i] && j == 0) ? 85 : (j == 0 || j == subroute.count - 2) ? 30:15)
                                                .padding(.leading, 5)
                                        }
                                        VStack {
                                            HStack {
                                                Button(action: {
                                                    env.selectedStation = subroute[j].station!
                                                    env.path.append("StationView")
                                                }) {
                                                    if (j == 0 || j == subroute.count - 1) {
                                                        Text("\(env.isEnglish ? subroute[j].station!.name_eg : subroute[j].station!.name_cn)")
                                                            .font(.system(size: 24))
                                                            .foregroundColor(.black)
                                                            .bold()
                                                            .padding(.top, -3)
                                                            .lineLimit(1)
                                                            .frame(maxWidth: UIScreen.main.bounds.width-150, alignment: .leading)
                                                            .fixedSize(horizontal: true, vertical: false)
                                                    }
                                                    else {
                                                        Text("\(env.isEnglish ? subroute[j].station!.name_eg : subroute[j].station!.name_cn)")
                                                            .font(.system(size: 20))
                                                            .foregroundColor(.black)
                                                            .lineLimit(1)
                                                            .frame(maxWidth: UIScreen.main.bounds.width-150, alignment: .leading)
                                                            .fixedSize(horizontal: true, vertical: false)
                                                            
                                                    }
                                                }
                                                .padding(.leading, 20)
                                                if (j == 0 && subroute.count > 2) {
                                                    Button(action: {
                                                        display[i].toggle()
                                                    }) {
                                                        Image(systemName: display[i] ? "chevron.down":"chevron.right")
                                                            .foregroundColor(.gray)
                                                    }
                                                    .padding(.leading, 10)
                                                }
                                                Spacer()
                                            }
                                            .padding(.top, -3)
                                            if (!display[i] && j == 0) {
                                                HStack {
                                                    ZStack {
                                                        Rectangle()
                                                            .fill(subroute[j].line!.color)
                                                            .frame(width: 20, height: 20)
                                                            .cornerRadius(5)
                                                        Text("\(subroute[j].line!.abbreviation_eg)")
                                                            .font(.system(size: 12))
                                                            .fontWeight(.semibold)
                                                            .foregroundColor(.white)
                                                    }
                                                    Text(env.isEnglish ? "To \(db.getDirectionPlatform(db: db, platform: subroute[0], direction: "L")!.station!.name_eg)" : "\(db.getDirectionPlatform(db: db, platform: subroute[0], direction: "L")!.station!.name_cn)方向")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.gray)
                                                        .padding(.leading, 3)
                                                    Spacer()
                                                }
                                                .padding(.leading, 20)
                                                .padding(.top, 1)
                                                HStack {
                                                    Text(env.isEnglish ? "\(subroute.count) stations, \(route.costs[i]) min" : "\(subroute.count) 站, \(route.costs[i]) 分钟")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.gray)
                                                        .padding(.leading, 3)
                                                    Spacer()
                                                }
                                                .padding(.leading, 50)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                        VStack {
                            let infos = db.getInfo(platform: subroute.last, direction: route.getDir(idx: i))
                            ForEach(0..<images.count, id: \.self) { index in
                                let str = selectConcatInfo(infos: infos, t: index, transfer: -1)
                                if (str != "") {
                                    HStack {
                                        Rectangle()
                                            .fill(colors[index])
                                            .frame(width: 30, height: 30)
                                            .cornerRadius(7)
                                            .overlay(
                                                Image(images[index])
                                                    .resizable()
                                                    .frame(width: 20, height: 20)
                                            )
                                        Text("\(str)")
                                            .padding(.leading, 5)
                                            .font(.system(size: 20))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                }
                            }
                            let str = selectConcatInfo(infos: infos, t: 4, transfer: (i+1 < route.route.count) ? route.route[i+1][0].line!.id : -1)
                            if (str != "") {
                                HStack {
                                    Rectangle()
                                        .fill(route.route[i+1][0].line!.color)
                                        .frame(width: 30, height: 30)
                                        .cornerRadius(7)
                                        .overlay(
                                            Text("\(route.route[i+1][0].line!.abbreviation_eg)")
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                        )
                                    Text("\(str)")
                                        .padding(.leading, 5)
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                            }
                        }
                        .padding(.leading, 40)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, 30)
                .padding(.leading, 80)
            }
            .background(Color(red: 240/255.0, green: 240/255.0, blue: 245/255.0))
            .edgesIgnoringSafeArea(.bottom)
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear() {
            route = dijkstra(db: db, station1: env.selectedStart!, station2: env.selectedEnd!)
            db.insertHistory(history: History(time: formattedCurrentTime(), start_id: env.selectedStart!.id, end_id: env.selectedEnd!.id))
        }
        .navigationBarHidden(true)
    }
}

private func formattedCurrentTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter.string(from: Date())
}

@available(iOS 17.0, *)
func splitPath(db: Database, path: [Platform], cost: Int) -> Route {
    var route: [[Platform]] = []
    var costs: [Int] = []
    var dirs: [Character] = []
    var prev: Platform? = nil
    var tmp: Int = 0
    
    for idx in 0..<path.count {
        let p = path[idx]
        if (prev == nil || p.line!.id != prev!.line!.id) {
            if (tmp != 0) {
                costs.append(tmp)
                dirs.append(route[route.endIndex-1][1].id - route[route.endIndex-1][0].id > 0 ? "L" : "R")
            }
            route.append([])
            tmp = 0
        }
        
        route[route.endIndex-1].append(p)
        if (idx < path.count - 1 && p.line!.id == path[idx+1].line!.id) {
            tmp += db.getWeight(platform1: p, platform2: path[idx+1])
        }
        prev = p
    }
    costs.append(tmp)
    dirs.append(route[route.endIndex-1][1].id - route[route.endIndex-1][0].id > 0 ? "L" : "R")
    return Route(route: route, totCost: cost, costs: costs)
}

@available(iOS 17.0, *)
func dijkstra(db: Database, station1: Station, station2: Station) -> Route {
    var platform1: Platform = db.platforms[0]
    var platform2: Platform = db.platforms[0]
    var distances: [Platform: Int] = [:]
    var previous: [Platform: Platform?] = [:]
    var unvisited: Set<Platform> = Set(db.platforms)
    
    for platform in db.platforms {
        if platform.station == station1 {
            platform1 = platform
        }
        if platform.station == station2 {
            platform2 = platform
        }
    }
    
    // Step 1: Initialize distances and previous node tracking
    for platform in db.platforms {
        distances[platform] = Int.max
        previous[platform] = nil
    }
    
    distances[platform1] = 0
    
    // Step 2: Main loop - Find the platform with the smallest distance
    while !unvisited.isEmpty {
        var current: Platform? = nil
        var minDistance = Int.max
        
        for platform in unvisited {
            if let dist = distances[platform], dist < minDistance {
                minDistance = dist
                current = platform
            }
        }
        
        guard let currentPlatform = current else {
            break
        }
        
        // Step 3: Remove current platform from unvisited set
        unvisited.remove(currentPlatform)
        
        // Step 4: Process neighbors (edges)
        let neighbors = db.edges.filter { $0.platform1 == currentPlatform || $0.platform2 == currentPlatform }
        for edge in neighbors {
            let neighbor: Platform
            if edge.platform1 == currentPlatform {
                neighbor = edge.platform2!
            } else {
                neighbor = edge.platform1!
            }
            
            if unvisited.contains(neighbor) {
                let newDist = distances[currentPlatform]! + edge.weight
                if newDist < distances[neighbor]! {
                    distances[neighbor] = newDist
                    previous[neighbor] = currentPlatform
                }
            }
        }
        
        // Step 5: Early exit if we reach platform2
        if currentPlatform == platform2 {
            break
        }
    }
    
    // Step 6: Reconstruct the path from platform1 to platform2
    var path: [Platform] = []
    var current = platform2
    
    while let prev = previous[current] {
        path.insert(current, at: 0)
        if prev == platform1 {
            path.insert(platform1, at: 0)
            break
        }
        current = prev!
    }
    
    var cost = distances[platform2]!
    
    while path.count >= 2 && path[0].station == path[1].station {
        cost -= db.getWeight(platform1: path[0], platform2: path[1])
        path.remove(at: 0)
    }
    
    while path.count >= 2 && path[path.endIndex-2].station == path[path.endIndex-1].station {
        cost -= db.getWeight(platform1: path[path.endIndex-2], platform2: path[path.endIndex-1])
        path.remove(at: path.endIndex-1)
    }
    
    return splitPath(db: db, path: path, cost: cost)
}
