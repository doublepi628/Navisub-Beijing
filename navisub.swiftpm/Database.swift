//
//  Database.swift
//  navisub
//
//  Created by Shaohan Yu on 2025/2/9.
//

import Foundation
import SQLite
import SwiftUI

class Station: Identifiable, Equatable {
    var id: Int
    var name_cn: String
    var name_eg: String
    var longitude: Double
    var latitude: Double
    var lines: [Line]
    
    init(id: Int, name_cn: String, name_eg: String, longitude: Double, latitude: Double, lines: [Line]) {
        self.id = id
        self.name_cn = name_cn
        self.name_eg = name_eg
        self.longitude = longitude
        self.latitude = latitude
        self.lines = lines
    }
    
    static func == (lhs: Station, rhs: Station) -> Bool {
        return lhs.id == rhs.id
    }
}

class Line: Identifiable, Equatable {
    var id: Int
    var name_cn: String
    var name_eg: String
    var color: Color
    var abbreviation_eg: String
    
    init(id: Int, name_cn: String, name_eg: String, color: Color, abbreviation_eg: String) {
        self.id = id
        self.name_cn = name_cn
        self.name_eg = name_eg
        self.color = color
        self.abbreviation_eg = abbreviation_eg
    }
    
    static func == (lhs: Line, rhs: Line) -> Bool {
        return lhs.id == rhs.id
    }
}

class Platform: Identifiable, Hashable {
    var id: Int
    var line: Line?
    var station: Station?
    
    init(id: Int, line: Line? = nil, station: Station? = nil) {
        self.id = id
        self.line = line
        self.station = station
    }
    
    static func == (lhs: Platform, rhs: Platform) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class Edge {
    var platform1: Platform?
    var platform2: Platform?
    var weight: Int
    
    init(platform1: Platform? = nil, platform2: Platform? = nil, weight: Int) {
        self.platform1 = platform1
        self.platform2 = platform2
        self.weight = weight
    }
}

class Info {
    var id: Int
    var platform: Platform?
    var direction: Character
    var door: Int
    var type: Character
    var arg: String?
    
    init(id: Int, platform: Platform? = nil, direction: Character, door: Int, type: Character, arg: String? = nil) {
        self.id = id
        self.platform = platform
        self.direction = direction
        self.door = door
        self.type = type
        self.arg = arg
    }
}

class History: Hashable {
    var time: String
    var start_id: Int
    var end_id: Int
    
    init(time: String, start_id: Int, end_id: Int) {
        self.time = time
        self.start_id = start_id
        self.end_id = end_id
    }
    
    static func == (lhs: History, rhs: History) -> Bool {
        return lhs.time == rhs.time && lhs.start_id == rhs.start_id && lhs.end_id == rhs.end_id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(time)
    }
}

class Star: Equatable, Hashable {
    var start_id: Int
    var end_id: Int
    
    init(start_id: Int, end_id: Int) {
        self.start_id = start_id
        self.end_id = end_id
    }
    
    static func == (lhs: Star, rhs: Star) -> Bool {
        return lhs.start_id == rhs.start_id && lhs.end_id == rhs.end_id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(start_id * 1000 + end_id))
    }
}

class Database: ObservableObject{
    var dbConn: Connection
    var userDbConn: Connection
    
    let lineTable = Table("Line")
    let li_id = SQLite.Expression<Int>("id")
    let li_name_cn = SQLite.Expression<String>("name_cn")
    let li_name_eg = SQLite.Expression<String>("name_eg")
    let li_color = SQLite.Expression<String>("color")
    let li_abbreviation_eg = SQLite.Expression<String>("abbreviation_eg")

    let stationTable = Table("Station")
    let st_id = SQLite.Expression<Int>("id")
    let st_name_cn = SQLite.Expression<String>("name_cn")
    let st_name_eg = SQLite.Expression<String>("name_eg")
    let st_longitude = SQLite.Expression<Double>("longitude")
    let st_latitude = SQLite.Expression<Double>("latitude")
    
    let platformTable = Table("Platform")
    let pl_id = SQLite.Expression<Int>("id")
    let pl_line = SQLite.Expression<Int>("line")
    let pl_station = SQLite.Expression<Int>("station")
    
    let graphTable = Table("Graph")
    let gr_platform1 = SQLite.Expression<Int>("platform1")
    let gr_platform2 = SQLite.Expression<Int>("platform2")
    let gr_time = SQLite.Expression<Int>("time")
    
    let infoTable = Table("Info")
    let in_id = SQLite.Expression<Int>("id")
    let in_platform_id = SQLite.Expression<Int>("platform_id")
    let in_direction = SQLite.Expression<String>("direction")
    let in_door = SQLite.Expression<Int>("door")
    let in_type = SQLite.Expression<String>("type")
    let in_arg = SQLite.Expression<String?>("arg")
    
    let historyTable = Table("History")
    let hi_time = SQLite.Expression<String>("time")
    let hi_start_id = SQLite.Expression<Int>("start_id")
    let hi_end_id = SQLite.Expression<Int>("end_id")
    
    let starTable = Table("Star")
    let st_start_id = SQLite.Expression<Int>("start_id")
    let st_end_id = SQLite.Expression<Int>("end_id")
    
    @Published var lineMap: [Int:Line] = [:]
    @Published var stationMap: [Int:Station] = [:]
    @Published var platformMap: [Int:Platform] = [:]
    @Published var lines: [Line] = []
    @Published var stations: [Station] = []
    @Published var platforms: [Platform] = []
    @Published var edges: [Edge] = []
    @Published var infos: [Info] = []
    
    @Published var historys: [History] = []
    @Published var stars: [Star] = []
    
    init() throws{
        guard let url = Bundle.main.url(forResource: "identifier", withExtension: "sqlite") else {
            throw NSError(domain: "DatabaseError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Database connection is nil"])
        }
        print("load database successfully.")
        dbConn = try Connection(url.path, readonly: true)
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        userDbConn = try Connection("\(path)/userdb.sqlite3")
        
        createUserDB()
        loadUserDB()
        loadDB()
    }
    
    private func createUserDB() {
        do {
            try userDbConn.run(historyTable.create(ifNotExists: true) { t in
                t.column(hi_time)
                t.column(hi_start_id)
                t.column(hi_end_id)
            })
        }
        catch {
            print("create HistoryTable failed...")
        }
        do {
            try userDbConn.run(starTable.create(ifNotExists: true) { t in
                t.column(st_start_id)
                t.column(st_end_id)
            })
        }
        catch {
            print("create StarTable failed...")
        }
        print("create/read user db successfully.")
    }
    
    private func loadUserDB() {
        stars = []
        do {
            for star in try userDbConn.prepare(starTable) {
                stars.append(Star(start_id: star[st_start_id], end_id: star[st_end_id]))
            }
        }
        catch {
            print("load star table failed.")
        }
        historys = []
        do {
            for history in try userDbConn.prepare(historyTable) {
                historys.append(History(time: history[hi_time], start_id: history[hi_start_id], end_id: history[hi_end_id]))
            }
        }
        catch {
            print("load history table failed.")
        }
    }
    
    public func insertHistory(history: History) {
        do {
            try userDbConn.run(historyTable.insert(hi_time <- history.time, hi_start_id <- history.start_id, hi_end_id <- history.end_id))
        }
        catch {
            print("insert history table failed.")
        }
        loadUserDB()
    }
    
    public func deleteAllHistory() {
        do {
            try userDbConn.run(historyTable.delete())
        }
        catch {
            print("delete all column in history table failed.")
        }
        loadUserDB()
    }
    
    public func insertStar(star: Star) {
        for st in stars {
            if st == star {
                return
            }
        }
        do {
            try userDbConn.run(starTable.insert(st_start_id <- star.start_id, st_end_id <- star.end_id))
        }
        catch {
            print("insert history table failed.")
        }
        loadUserDB()
    }
    
    public func deleteStar(star: Star) {
        let row = starTable.filter(st_start_id == star.start_id && st_end_id == star.end_id)
        do {
            try userDbConn.run(row.delete())
        }
        catch {
            print("delete star record failed.")
        }
        loadUserDB()
    }
    
    public func checkIfStar(star: Star) -> Bool{
        for st in stars {
            if st == star {
                return true
            }
        }
        return false
    }
    
    private func loadDB() {
        do {
            for line in try dbConn.prepare(lineTable) {
                let colorHex = line[li_color].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                let color: Color
                if colorHex.hasPrefix("#"), colorHex.count == 7, let rgbValue = UInt64(colorHex.dropFirst(), radix: 16) {
                    let red = Double((rgbValue >> 16) & 0xFF) / 255.0
                    let green = Double((rgbValue >> 8) & 0xFF) / 255.0
                    let blue = Double(rgbValue & 0xFF) / 255.0
                    color = Color(red: red, green: green, blue: blue)
                }
                else {
                    color = .gray
                }
                lines.append(Line(
                    id: line[li_id],
                    name_cn: line[li_name_cn],
                    name_eg: line[li_name_eg],
                    color: color,
                    abbreviation_eg: line[li_abbreviation_eg]
                    
                ))
                lineMap[line[li_id]] = lines.last
            }
        }
        catch {
            print("load Line table failed.")
        }
        do {
            for station in try dbConn.prepare(stationTable) {
                stations.append(Station(
                    id: station[st_id],
                    name_cn: station[st_name_cn],
                    name_eg: station[st_name_eg],
                    longitude: station[st_longitude],
                    latitude: station[st_latitude],
                    lines: []
                ))
                stationMap[station[st_id]] = stations.last
            }
        }
        catch {
            print("load Station table failed.")
        }
        do {
            for platform in try dbConn.prepare(platformTable) {
                var p = Platform(
                    id: platform[pl_id],
                    line: lineMap[platform[pl_line]],
                    station: stationMap[platform[pl_station]])
                platforms.append(p)
                platformMap[platform[pl_id]] = p
                if let line = p.line {
                    p.station?.lines.append(line)
                }
            }
        }
        catch {
            print("load Platform table failed.")
        }
        do {
            for edge in try dbConn.prepare(graphTable) {
                edges.append(Edge(
                    platform1: platformMap[edge[gr_platform1]],
                    platform2: platformMap[edge[gr_platform2]],
                    weight: edge[gr_time] == 0 ? 6 : edge[gr_time]
                ))
            }
        }
        catch {
            print("load Graph table failed.")
        }
        do {
            for info in try dbConn.prepare(infoTable) {
                infos.append(Info(
                    id: info[in_id],
                    platform: platformMap[info[in_platform_id]],
                    direction: info[in_direction][info[in_direction].startIndex],
                    door: info[in_door],
                    type: info[in_type].first ?? " ",
                    arg: info[in_arg]
                ))
            }
        }
        catch {
            print("load Info table failed.")
        }
    }
    
    public func getStationByLine(line: Line?) -> [Station]{
        guard let line = line else {
            return []
        }
        var selectedStations: [Station] = []
        for st in stations {
            if st.lines.contains(where: { $0.id == line.id }) {
                selectedStations.append(st)
            }
        }
        return selectedStations
    }
    
    public func getPlatform (station: Station, line: Line) -> Platform? {
        for pl in platforms {
            guard let st = pl.station else { continue }
            guard let li = pl.line else { continue }
            if (st.id == station.id && li.id == line.id) {
                return pl
            }
        }
        return nil
    }
    
    public func getInfo(platform: Platform?, direction: Character) -> [Info] {
        guard let platform = platform else { return []}
        var selectedInfo: [Info] = []
        for i in infos {
            guard let pl = i.platform else { continue }
            if (pl.id == platform.id && i.direction == direction) {
                selectedInfo.append(i)
            }
        }
        return selectedInfo
    }
    
    public func getNextPlatform(platform: Platform?, direction: Character) -> Platform? {
        guard let platform = platform else { return nil }

        if platform.id == 0 && direction == "R" {
            return platform
        }

        if platform.id == platforms[platforms.endIndex - 1].id && direction == "L" {
            return platform
        }

        for i in 0..<platforms.count {
            if platform.id == platforms[i].id {
                if direction == "L" {
                    if i + 1 < platforms.count && platform.line == platforms[i + 1].line {
                        return platforms[i + 1]
                    } else {
                        return platforms[i]
                    }
                } else if direction == "R" {
                    if i - 1 >= 0 && platform.line == platforms[i - 1].line {
                        return platforms[i - 1]
                    } else {
                        return platforms[i]
                    }
                }
            }
        }
        return nil
    }
    
    public func getDirectionPlatform(db: Database, platform: Platform?, direction: Character) -> Platform? {
        guard let platform = platform else { return nil }
        let line = platform.line!
        var delta = direction == "L" ? 1 : -1
        var idx = platform.id - 1
        
        if (line.id == 2 || line.id == 10) {
            if (db.platforms[idx + delta].line == line) {
                return db.platforms[idx + delta]
            }
            else {
                delta = -delta
            }
        }
        
        while (db.platforms[idx].line == line) {
            idx += delta
            if (idx == 0 || idx == db.platforms.count-1) {
                return db.platforms[idx]
            }
        }
        return db.platforms[idx - delta]
    }
    
    public func getWeight(platform1: Platform, platform2: Platform) -> Int {
        for edge in edges {
            if platform1 == edge.platform1 && platform2 == edge.platform2 {
                return edge.weight
            }
            else if platform2 == edge.platform1 && platform1 == edge.platform2 {
                return edge.weight
            }
        }
        return Int.max
    }
}
