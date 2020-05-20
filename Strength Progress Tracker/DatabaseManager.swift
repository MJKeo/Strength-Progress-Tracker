//
//  DatabaseManager.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/15/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import Foundation
import SQLite3

//INSERT INTO LiftData (exercise, body_weight, beginner, novice, intermediate, advanced, elite) VALUES ("bench", 120,51,82,122,170,223)



class DatabaseManager {
    var fileUrl: URL //  for storing pre-made data
    var userUrl: URL // for storing user data
    var db: OpaquePointer?
    var userDb: OpaquePointer?
    
    init() {
        userUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("MyDatabase.sqlite")
//        if (FileManager.default.fileExists(atPath: fileUrl.path)) {
//            print("exists already")
//        }
//        let otherUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
//        print(otherUrl.path)
        print("uh")
        fileUrl = try! Bundle.main.url(forResource: "Database", withExtension: ".sqlite")!
        
    }
    
    func deleteDatabase() {
        let deleteTableQuery = "DROP TABLE StrengthStandards"
        
        sqlite3_exec(db, deleteTableQuery, nil, nil, nil)
    }
    
    func createDatabase() {
        let createTableQuery = "CREATE TABLE IF NOT EXISTS StrengthStandards (id INTEGER PRIMARY KEY AUTOINCREMENT, exercise TEXT, gender TEXT, body_weight INTEGER, beginner INTEGER, novice INTEGER, intermediate INTEGER, advanced INTEGER, elite INTEGER)"
        let createExercisesTableQuery = "CREATE TABLE IF NOT EXISTS ExerciseList (id INTEGER PRIMARY KEY AUTOINCREMENT, exercise TEXT, category TEXT)"
        let createActivityRecordsTableQuery = "CREATE TABLE IF NOT EXISTS UserActivity (id INTEGER PRIMARY KEY AUTOINCREMENT, exercise TEXT, time_recorded DATE, reps INTEGER, weight Text, orm FLOAT)"
        let createCustomExercisesTable = "CREATE TABLE IF NOT EXISTS CustomExerciseList (id INTEGER PRIMARY KEY AUTOINCREMENT, exercise TEXT, category TEXT)"
        let createRecordsTable = "CREATE TABLE IF NOT EXISTS UserRecords (id INTEGER PRIMARY KEY AUTOINCREMENT, exercise TEXT, record DOUBLE)"
        let createGoalsTable = "CREATE TABLE IF NOT EXISTS UserGoals (id INTEGER PRIMARY KEY AUTOINCREMENT, exercise TEXT, goal DOUBLE)"
        print(fileUrl.path)

        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK {
            print("error opening database")
            return
        } else {
            print("successfully created table")
        }
        
        if sqlite3_open(userUrl.path, &userDb) != SQLITE_OK {
            print("error opening database")
            return
        } else {
            print("successfully created table")
        }

        sqlite3_exec(db, createTableQuery, nil, nil, nil)
        sqlite3_exec(db, createExercisesTableQuery, nil, nil, nil)
        sqlite3_exec(userDb, createActivityRecordsTableQuery, nil, nil, nil)
        sqlite3_exec(userDb, createCustomExercisesTable, nil, nil, nil)
        sqlite3_exec(userDb, createRecordsTable, nil, nil, nil)
        sqlite3_exec(userDb, createGoalsTable, nil, nil, nil)
    }
    
    func populateDatabase() {
        // [gender, BW, beginner, novice, intermediate, advanced, elite]
        addListToDatabase(list: getBenchData())
        addListToDatabase(list: getSquatData())
        addListToDatabase(list: getDeadliftData())
        addListToDatabase(list: getOverheadPressData())
        addListToDatabase(list: getHexDeadliftData())
        addListToDatabase(list: getMilitaryPressData())
        addListToDatabase(list: getInclineBenchData())
        addListToDatabase(list: getFrontSquatData())
        addListToDatabase(list: getBentRowData())
        addListToDatabase(list: getPowerCleanData())
        addListToDatabase(list: getCleanData())
        addListToDatabase(list: getCleanJerkData())
        addListToDatabase(list: getSnatchData())
        addListToDatabase(list: getPushupData())
        addListToDatabase(list: getPullUpData())
        addListToDatabase(list: getChinUpData())
        addListToDatabase(list: getDipData())
        addListToDatabase(list: getPistolSquatData())
        
        let exercises = [["Bench Press","w"], ["Back Squat","w"], ["Deadlift","w"], ["Overhead Press","w"], ["Hex Bar Deadlift","w"], ["Military Press","w"], ["Incline Bench Press","w"], ["Front Squat","w"], ["Bent Over Row","w"], ["Power Clean","w"], ["Clean","w"], ["Clean & Jerk","w"], ["Snatch","w"], ["Push Up","b"], ["Pull Up","b"], ["Chin Up","b"], ["Dip","b"], ["Pistol Squat","b"]]
        addToExerciseTable(list: exercises)
    }
    
    func addToExerciseTable(list: [[String]]) {
        var statement: OpaquePointer?

        for exercise in list {
            var addQuery = "INSERT INTO ExerciseList (exercise, category) VALUES ('" + exercise[0] + "','"
            if (exercise[1] == "w") {
                addQuery += "weights')"
            } else {
                addQuery += "bodyweight')"
            }
            
            if sqlite3_prepare(db, addQuery, -1, &statement, nil) != SQLITE_OK {
                print("error binding query")
                return
            }

            if sqlite3_step(statement) == SQLITE_DONE {
                print("saved successfully")
            }
        }
    }
    
    
    
    func addListToDatabase(list: [[Any]]) {
        var index = 0
        while (index < list.count) {
            var point = list[index]
            if (String(point[0] as? String ?? "") == "Bent Over Row") {
                print(point)
            }
            addToDatabase(exercise: point[0] as? String ?? "", gender: point[1] as? String ?? "", bodyWeight: point[2] as? Int ?? 0, beginner: point[3] as? Int ?? 0, novice: point[4] as? Int ?? 0, intermediate: point[5] as? Int ?? 0, advanced: point[6] as? Int ?? 0, elite: point[7] as? Int ?? 0)
            
            index += 1
        }
    }
    
    func getBenchData() -> [[Any]] {
        var bw = 110, beg = 59, nov = 91, inter = 127, adv = 182, el = 236
        // [gender, BW, beginner, novice, intermediate, advanced, elite]
        var benchData: [[Any]]
        benchData = []
        var increases = [10,10,12,15,18,20]
        while (bw < 320) {
            let tempList = ["Bench Press", "male", bw, beg, nov, inter, adv, el] as [Any]
            benchData.append(tempList)
            bw += increases[0]
            beg += increases[1]
            nov += increases[2]
            inter += increases[3]
            adv += increases[4]
            el += increases[5]
            
            // changing increase for beginner
            if (bw == 140 || bw == 210 || bw == 270) {
                increases[1] -= 1
            }
            
            // changing increase for novice
            if (bw == 150 || bw == 190 || bw == 230 || bw == 290) {
                increases[2] -= 1
            }
            
            // changing increase for intermediate
            if (bw == 130 || bw == 140 || bw == 180 || bw == 200 || bw == 250 || bw == 290) {
                increases[3] -= 1
            }
            
            // changing increase for advanced
            if (bw == 120 || bw == 130 || bw == 140 || bw == 170 || bw == 190 || bw == 220 || bw == 250 || bw == 290) {
                increases[4] -= 1
            }
            
            // changing increase for advanced
            if (bw == 110 || bw == 120 || bw == 130 || bw == 150 || bw == 170 || bw == 190 || bw == 210 || bw == 230 || bw == 250 || bw == 290) {
                increases[5] -= 1
            }
            
        }
        
        bw = 90
        beg = 28
        nov = 50
        inter = 77
        adv = 116
        el = 156
        increases = [10,5,6,8,10,11]
        while (bw < 270) {
            let tempList = ["Bench Press", "female", bw, beg, nov, inter, adv, el] as [Any]
            benchData.append(tempList)
            bw += increases[0]
            beg += increases[1]
            nov += increases[2]
            inter += increases[3]
            adv += increases[4]
            el += increases[5]
            
            // changing increase for beginner
            if (bw == 110 || bw == 210) {
                increases[1] -= 1
            }
            
            // changing increase for novice
            if (bw == 120 || bw == 180) {
                increases[2] -= 1
            }
            
            // changing increase for intermediate
            if (bw == 110 || bw == 130 || bw == 190 || bw == 230) {
                increases[3] -= 1
            }
            
            // changing increase for advanced
            if (bw == 100 || bw == 120 || bw == 140 || bw == 190 || bw == 230) {
                increases[4] -= 1
            }
            
            // changing increase for advanced
            if (bw == 110 || bw == 130 || bw == 150 || bw == 180 || bw == 210) {
                increases[5] -= 1
            }
        }
        
        return benchData
    }
    
    func getSquatData() -> [[Any]] {
        var bw = 110, beg = 80, nov = 119, inter = 170, adv = 238, el = 307
        // [gender, BW, beginner, novice, intermediate, advanced, elite]
        var squatData: [[Any]]
        squatData = []
        var increases = [10,13,16,20,23,26]
        while (bw < 320) {
            let tempList = ["Back Squat", "male", bw, beg, nov, inter, adv, el] as [Any]
            squatData.append(tempList)
            bw += increases[0]
            beg += increases[1]
            nov += increases[2]
            inter += increases[3]
            adv += increases[4]
            el += increases[5]
            
            // changing increase for beginner
            if (bw == 170 || bw == 200 || bw == 250) {
                increases[1] -= 1
            }
            
            // changing increase for novice
            if (bw == 140 || bw == 170 || bw == 180 || bw == 230) {
                increases[2] -= 1
            }
            
            // changing increase for intermediate
            if (bw == 120 || bw == 130 || bw == 170 || bw == 200 || bw == 210 || bw == 230 || bw == 250 || bw == 270) {
                increases[3] -= 1
            }
            
            // changing increase for advanced
            if (bw == 120 || bw == 130 || bw == 150 || bw == 170 || bw == 180 || bw == 200 || bw == 230 || bw == 250) {
                increases[4] -= 1
            }
            
            // changing increase for advanced
            if (bw == 120 || bw == 130 || bw == 150 || bw == 150 || bw == 160 || bw == 180 || bw == 190 || bw == 210 || bw == 220 || bw == 240 || bw == 250) {
                increases[5] -= 1
            }
            
        }
        
        squatData.append(["Back Squat", "female", 90, 45, 76, 118, 170, 228]) // 90
        squatData.append(["Back Squat", "female", 100, 51, 85, 128, 182, 242]) // 100
        squatData.append(["Back Squat", "female", 110, 57, 92, 138, 193, 256])
        squatData.append(["Back Squat", "female",120, 63, 100, 147, 204, 268])
        squatData.append(["Back Squat", "female",130, 68, 107, 156, 214, 280])
        squatData.append(["Back Squat", "female",140, 74, 113, 164, 224, 291])
        squatData.append(["Back Squat", "female",150, 79, 120, 172, 233, 201])
        squatData.append(["Back Squat", "female",160, 84, 126, 179, 242, 311])
        squatData.append(["Back Squat", "female",170, 89, 125, 186, 250, 321])
        squatData.append(["Back Squat", "female",180, 93, 138, 193, 258, 330])
        squatData.append(["Back Squat", "female",190, 98, 143, 200, 266, 339])
        squatData.append(["Back Squat", "female",200, 102, 149, 206, 274, 347])
        squatData.append(["Back Squat", "female",210, 107, 154, 212, 281, 355])
        squatData.append(["Back Squat", "female",220, 111, 159, 218, 288, 363])
        squatData.append(["Back Squat", "female",230, 115, 164, 224, 294, 370])
        squatData.append(["Back Squat", "female",240, 119, 169, 230, 301, 378])
        squatData.append(["Back Squat", "female",250, 123, 174, 235, 307, 385])
        squatData.append(["Back Squat", "female",260, 127, 178, 241, 313, 392])
        
        return squatData
    }
    
    func getDeadliftData() -> [[Any]] {
        var deadliftData: [[Any]]
        deadliftData = []
        
        deadliftData.append(["Deadlift", "male" , 110, 94, 141, 201, 272, 349])
        deadliftData.append(["Deadlift", "male" , 120, 109, 160, 223, 297, 377])
        deadliftData.append(["Deadlift", "male" , 130, 124, 177, 244, 321, 404])
        deadliftData.append(["Deadlift", "male" , 140, 138, 195, 264, 344, 430])
        deadliftData.append(["Deadlift", "male" , 150, 152, 211, 283, 366, 455])
        deadliftData.append(["Deadlift", "male" , 160, 166, 228, 302, 388, 479])
        deadliftData.append(["Deadlift", "male" , 170, 180, 243, 321, 408, 502])
        deadliftData.append(["Deadlift", "male" , 180, 193, 259, 338, 428, 524])
        deadliftData.append(["Deadlift", "male" , 190, 206, 274, 355, 447, 545])
        deadliftData.append(["Deadlift", "male" , 200, 219, 289, 372, 466, 566])
        deadliftData.append(["Deadlift", "male" , 210, 231, 303, 388, 484, 586])
        deadliftData.append(["Deadlift", "male" , 220, 244, 317, 404, 502, 605])
        deadliftData.append(["Deadlift", "male" , 230, 256, 331, 420, 519, 624])
        deadliftData.append(["Deadlift", "male" , 240, 267, 344, 435, 536, 642])
        deadliftData.append(["Deadlift", "male" , 250, 279, 357, 449, 552, 660])
        deadliftData.append(["Deadlift", "male" , 260, 290, 370, 463, 568, 677])
        deadliftData.append(["Deadlift", "male" , 270, 301, 382, 477, 583, 694])
        deadliftData.append(["Deadlift", "male" , 280, 312, 394, 491, 598, 711])
        deadliftData.append(["Deadlift", "male" , 290, 323, 406, 504, 613, 727])
        deadliftData.append(["Deadlift", "male" , 300, 333, 418, 518, 627, 742])
        deadliftData.append(["Deadlift", "male" , 310, 343, 430, 530, 642, 758])
        
        deadliftData.append(["Deadlift", "female", 90, 54, 91, 140, 199, 265])
        deadliftData.append(["Deadlift", "female", 100, 61, 100, 151, 212, 280])
        deadliftData.append(["Deadlift", "female", 110, 68, 109, 161, 225, 294])
        deadliftData.append(["Deadlift", "female", 120, 75, 117, 171, 236, 308])
        deadliftData.append(["Deadlift", "female", 130, 81, 125, 181, 247, 320])
        deadliftData.append(["Deadlift", "female", 140, 87, 132, 190, 258, 332])
        deadliftData.append(["Deadlift", "female", 150, 93, 139, 198, 268, 344])
        deadliftData.append(["Deadlift", "female", 160, 98, 146, 207, 277, 354])
        deadliftData.append(["Deadlift", "female", 170, 104, 153, 214, 286, 365])
        deadliftData.append(["Deadlift", "female", 180, 109, 159, 222, 295, 374])
        deadliftData.append(["Deadlift", "female", 190, 114, 165, 229, 303, 384])
        deadliftData.append(["Deadlift", "female", 200, 119, 171, 236, 311, 393])
        deadliftData.append(["Deadlift", "female", 210, 124, 177, 243, 319, 401])
        deadliftData.append(["Deadlift", "female", 220, 128, 182, 249, 326, 410])
        deadliftData.append(["Deadlift", "female", 230, 133, 188, 256, 334, 418])
        deadliftData.append(["Deadlift", "female", 240, 137, 193, 262, 341, 426])
        deadliftData.append(["Deadlift", "female", 250, 142, 198, 268, 347, 433])
        deadliftData.append(["Deadlift", "female", 260, 146, 203, 273, 354, 440])
        
        var index = 0
        while (index < deadliftData.count) {
            deadliftData[index][3] = (deadliftData[index][3] as? Int ?? 0) + 5
            deadliftData[index][4] = (deadliftData[index][4] as? Int ?? 0) + 5
            deadliftData[index][5] = (deadliftData[index][5] as? Int ?? 0) + 4
            deadliftData[index][6] = (deadliftData[index][6] as? Int ?? 0) + 3
            deadliftData[index][7] = (deadliftData[index][7] as? Int ?? 0) + 2
            
            index += 1
        }
        
        return deadliftData
    }
    
    func getOverheadPressData() -> [[Any]] {
        var overheadPressData: [[Any]]
        overheadPressData = []
        
        overheadPressData.append(["Overhead Press", "male", 110, 32, 53, 80, 113, 150])
        overheadPressData.append(["Overhead Press", "male", 120, 38, 61, 90, 125, 164])
        overheadPressData.append(["Overhead Press", "male", 130, 44, 68, 99, 136, 176])
        overheadPressData.append(["Overhead Press", "male", 140, 50, 76, 108, 146, 188])
        overheadPressData.append(["Overhead Press", "male", 150, 56, 83, 117, 156, 199])
        overheadPressData.append(["Overhead Press", "male", 160, 62, 90, 125, 166, 211])
        overheadPressData.append(["Overhead Press", "male", 170, 68, 97, 134, 176, 221])
        overheadPressData.append(["Overhead Press", "male", 180, 74, 104, 142, 185, 232])
        overheadPressData.append(["Overhead Press", "male", 190, 79, 111, 149, 194, 241])
        overheadPressData.append(["Overhead Press", "male", 200, 85, 117, 157, 202, 251])
        overheadPressData.append(["Overhead Press", "male", 210, 90, 124, 165, 211, 260])
        overheadPressData.append(["Overhead Press", "male", 220, 96, 130, 172, 219, 270])
        overheadPressData.append(["Overhead Press", "male", 230, 101, 136, 179, 227, 278])
        overheadPressData.append(["Overhead Press", "male", 240, 106, 142, 186, 235, 287])
        overheadPressData.append(["Overhead Press", "male", 250, 111, 148, 192, 242, 295])
        overheadPressData.append(["Overhead Press", "male", 260, 116, 154, 199, 250, 303])
        overheadPressData.append(["Overhead Press", "male", 270, 121, 160, 205, 257, 311])
        overheadPressData.append(["Overhead Press", "male", 280, 126, 165, 212, 264, 319])
        overheadPressData.append(["Overhead Press", "male", 290, 131, 171, 218, 271, 327])
        overheadPressData.append(["Overhead Press", "male", 300, 136, 176, 224, 277, 334])
        overheadPressData.append(["Overhead Press", "male", 310, 140, 181, 230, 284, 341])
        
        overheadPressData.append(["Overhead Press", "female", 90, 17, 31, 51, 76, 104])
        overheadPressData.append(["Overhead Press", "female", 100, 20, 35, 56, 82, 111])
        overheadPressData.append(["Overhead Press", "female", 110, 22, 39, 60, 87, 117])
        overheadPressData.append(["Overhead Press", "female", 120, 25, 42, 65, 92, 123])
        overheadPressData.append(["Overhead Press", "female", 130, 27, 45, 68, 97, 128])
        overheadPressData.append(["Overhead Press", "female", 140, 30, 48, 72, 101, 133])
        overheadPressData.append(["Overhead Press", "female", 150, 32, 51, 76, 105, 138])
        overheadPressData.append(["Overhead Press", "female", 160, 34, 54, 79, 109, 143])
        overheadPressData.append(["Overhead Press", "female", 170, 36, 56, 82, 113, 147])
        overheadPressData.append(["Overhead Press", "female", 180, 38, 59, 86, 117, 151])
        overheadPressData.append(["Overhead Press", "female", 190, 40, 62, 89, 120, 155])
        overheadPressData.append(["Overhead Press", "female", 200, 42, 64, 92, 124, 159])
        overheadPressData.append(["Overhead Press", "female", 210, 44, 66, 94, 127, 163])
        overheadPressData.append(["Overhead Press", "female", 220, 46, 69, 97, 130, 167])
        overheadPressData.append(["Overhead Press", "female", 230, 48, 71, 100, 133, 170])
        overheadPressData.append(["Overhead Press", "female", 240, 50, 73, 102, 136, 173])
        overheadPressData.append(["Overhead Press", "female", 250, 52, 75, 105, 139, 177])
        overheadPressData.append(["Overhead Press", "female", 260, 53, 77, 107, 142, 180])
        
        var index = 0
        while (index < overheadPressData.count) {
            overheadPressData[index][3] = (overheadPressData[index][3] as? Int ?? 0) + 5
            overheadPressData[index][4] = (overheadPressData[index][4] as? Int ?? 0) + 5
            overheadPressData[index][5] = (overheadPressData[index][5] as? Int ?? 0) + 4
            overheadPressData[index][6] = (overheadPressData[index][6] as? Int ?? 0) + 3
            overheadPressData[index][7] = (overheadPressData[index][7] as? Int ?? 0) + 2
            
            index += 1
        }
        
        return overheadPressData
    }
    
    func getMilitaryPressData() -> [[Any]] {
        var militaryPressData: [[Any]]
        militaryPressData = []
        
        militaryPressData.append(["Military Press", "male", 110, 34, 54, 80, 111, 145])
        militaryPressData.append(["Military Press", "male", 120, 40, 62, 90, 122, 158])
        militaryPressData.append(["Military Press", "male", 130, 47, 70, 99, 134, 171])
        militaryPressData.append(["Military Press", "male", 140, 53, 78, 109, 144, 183])
        militaryPressData.append(["Military Press", "male", 150, 60, 86, 118, 155, 195])
        militaryPressData.append(["Military Press", "male", 160, 66, 93, 126, 165, 206])
        militaryPressData.append(["Military Press", "male", 170, 72, 101, 135, 175, 217])
        militaryPressData.append(["Military Press", "male", 180, 78, 108, 143, 184, 228])
        militaryPressData.append(["Military Press", "male", 190, 84, 115, 151, 193, 238])
        militaryPressData.append(["Military Press", "male", 200, 90, 122, 159, 202, 248])
        militaryPressData.append(["Military Press", "male", 210, 96, 128, 167, 211, 257])
        militaryPressData.append(["Military Press", "male", 220, 102, 135, 174, 219, 266])
        militaryPressData.append(["Military Press", "male", 230, 107, 141, 182, 227, 275])
        militaryPressData.append(["Military Press", "male", 240, 113, 148, 189, 235, 284])
        militaryPressData.append(["Military Press", "male", 250, 118, 154, 196, 243, 293])
        militaryPressData.append(["Military Press", "male", 260, 124, 160, 203, 251, 301])
        militaryPressData.append(["Military Press", "male", 270, 129, 166, 209, 258, 309])
        militaryPressData.append(["Military Press", "male", 280, 134, 172, 216, 265, 317])
        militaryPressData.append(["Military Press", "male", 290, 139, 177, 222, 272, 325])
        militaryPressData.append(["Military Press", "male", 300, 144, 183, 229, 279, 332])
        militaryPressData.append(["Military Press", "male", 310, 149, 188, 235, 286, 340])
        
        militaryPressData.append(["Military Press", "female", 90, 17, 31, 51, 75, 102])
        militaryPressData.append(["Military Press", "female", 100, 20, 35, 56, 81, 109])
        militaryPressData.append(["Military Press", "female", 110, 23, 39, 61, 87, 116])
        militaryPressData.append(["Military Press", "female", 120, 26, 43, 66, 93, 123])
        militaryPressData.append(["Military Press", "female", 130, 29, 47, 70, 98, 129])
        militaryPressData.append(["Military Press", "female", 140, 32, 50, 74, 103, 135])
        militaryPressData.append(["Military Press", "female", 150, 34, 54, 78, 108, 140])
        militaryPressData.append(["Military Press", "female", 160, 37, 57, 82, 112, 145])
        militaryPressData.append(["Military Press", "female", 170, 40, 60, 86, 117, 150])
        militaryPressData.append(["Military Press", "female", 180, 42, 63, 90, 121, 155])
        militaryPressData.append(["Military Press", "female", 190, 45, 66, 93, 125, 160])
        militaryPressData.append(["Military Press", "female", 200, 47, 69, 97, 129, 164])
        militaryPressData.append(["Military Press", "female", 210, 49, 72, 100, 133, 169])
        militaryPressData.append(["Military Press", "female", 220, 51, 74, 103, 137, 173])
        militaryPressData.append(["Military Press", "female", 230, 54, 77, 106, 140, 177])
        militaryPressData.append(["Military Press", "female", 240, 56, 80, 109, 144, 181])
        militaryPressData.append(["Military Press", "female", 250, 58, 82, 112, 147, 184])
        militaryPressData.append(["Military Press", "female", 260, 60, 85, 115, 150, 188])
        
        var index = 0
        while (index < militaryPressData.count) {
            militaryPressData[index][3] = (militaryPressData[index][3] as? Int ?? 0) + 5
            militaryPressData[index][4] = (militaryPressData[index][4] as? Int ?? 0) + 5
            militaryPressData[index][5] = (militaryPressData[index][5] as? Int ?? 0) + 4
            militaryPressData[index][6] = (militaryPressData[index][6] as? Int ?? 0) + 3
            militaryPressData[index][7] = (militaryPressData[index][7] as? Int ?? 0) + 2
            
            index += 1
        }
        
        return militaryPressData
    }
    
    func getFrontSquatData() -> [[Any]] {
        var frontSquatData: [[Any]]
        frontSquatData = []
        
        frontSquatData.append(["Front Squat", "male", 110, 66, 100, 142, 193, 248])
        frontSquatData.append(["Front Squat", "male", 120, 76, 112, 157, 209, 267])
        frontSquatData.append(["Front Squat", "male", 130, 85, 123, 170, 225, 285])
        frontSquatData.append(["Front Squat", "male", 140, 95, 134, 184, 240, 302])
        frontSquatData.append(["Front Squat", "male", 150, 104, 145, 196, 255, 318])
        frontSquatData.append(["Front Squat", "male", 160, 113, 156, 209, 269, 334])
        frontSquatData.append(["Front Squat", "male", 170, 122, 166, 220, 282, 349])
        frontSquatData.append(["Front Squat", "male", 180, 130, 176, 232, 295, 363])
        frontSquatData.append(["Front Squat", "male", 190, 139, 186, 243, 308, 377])
        frontSquatData.append(["Front Squat", "male", 200, 147, 196, 254, 320, 390])
        frontSquatData.append(["Front Squat", "male", 210, 155, 205, 265, 332, 403])
        frontSquatData.append(["Front Squat", "male", 220, 163, 214, 275, 343, 416])
        frontSquatData.append(["Front Squat", "male", 230, 170, 223, 285, 355, 428])
        frontSquatData.append(["Front Squat", "male", 240, 178, 231, 294, 365, 440])
        frontSquatData.append(["Front Squat", "male", 250, 185, 240, 304, 376, 452])
        frontSquatData.append(["Front Squat", "male", 260, 192, 248, 313, 386, 463])
        frontSquatData.append(["Front Squat", "male", 270, 200, 256, 322, 396, 474])
        frontSquatData.append(["Front Squat", "male", 280, 206, 264, 331, 406, 484])
        frontSquatData.append(["Front Squat", "male", 290, 213, 271, 339, 415, 495])
        frontSquatData.append(["Front Squat", "male", 300, 220, 279, 348, 425, 505])
        frontSquatData.append(["Front Squat", "male", 310, 227, 286, 356, 434, 515])
            
        frontSquatData.append(["Front Squat", "female", 90, 47, 72, 104, 142, 183])
        frontSquatData.append(["Front Squat", "female", 100, 52, 78, 111, 150, 193])
        frontSquatData.append(["Front Squat", "female", 110, 56, 83, 118, 158, 201])
        frontSquatData.append(["Front Squat", "female", 120, 61, 89, 124, 165, 209])
        frontSquatData.append(["Front Squat", "female", 130, 65, 94, 130, 171, 217])
        frontSquatData.append(["Front Squat", "female", 140, 69, 98, 135, 178, 224])
        frontSquatData.append(["Front Squat", "female", 150, 72, 103, 140, 184, 231])
        frontSquatData.append(["Front Squat", "female", 160, 76, 107, 145, 189, 237])
        frontSquatData.append(["Front Squat", "female", 170, 79, 111, 150, 195, 243])
        frontSquatData.append(["Front Squat", "female", 180, 83, 115, 155, 200, 249])
        frontSquatData.append(["Front Squat", "female", 190, 86, 119, 159, 205, 254])
        frontSquatData.append(["Front Squat", "female", 200, 89, 123, 163, 210, 260])
        frontSquatData.append(["Front Squat", "female", 210, 92, 126, 167, 214, 265])
        frontSquatData.append(["Front Squat", "female", 220, 95, 129, 171, 219, 270])
        frontSquatData.append(["Front Squat", "female", 230, 98, 133, 175, 223, 274])
        frontSquatData.append(["Front Squat", "female", 240, 101, 136, 179, 227, 279])
        frontSquatData.append(["Front Squat", "female", 250, 103, 139, 182, 231, 283])
        frontSquatData.append(["Front Squat", "female", 260, 106, 142, 186, 235, 288])
        
        var index = 0
        while (index < frontSquatData.count) {
            frontSquatData[index][3] = (frontSquatData[index][3] as? Int ?? 0) + 5
            frontSquatData[index][4] = (frontSquatData[index][4] as? Int ?? 0) + 5
            frontSquatData[index][5] = (frontSquatData[index][5] as? Int ?? 0) + 4
            frontSquatData[index][6] = (frontSquatData[index][6] as? Int ?? 0) + 3
            frontSquatData[index][7] = (frontSquatData[index][7] as? Int ?? 0) + 2
            
            index += 1
        }
        
        return frontSquatData
    }
    
    func getHexDeadliftData() -> [[Any]] {
        var hexDeadliftData: [[Any]]
        hexDeadliftData = []
        
        var string = """
110    118    170    234    309    390
120    133    188    256    334    418
130    148    206    276    357    444
140    163    223    296    379    469
150    177    239    315    401    493
160    191    255    333    422    515
170    204    271    351    441    537
180    217    286    368    460    558
190    230    301    385    479    579
200    242    315    401    497    598
210    254    328    416    514    617
220    266    342    431    531    635
230    278    355    446    547    653
240    289    368    460    563    670
250    300    380    474    578    687
260    311    392    487    593    703
270    321    404    501    608    719
280    332    416    513    622    735
290    342    427    526    636    750
300    352    438    538    649    764
310    362    449    550    662    779
"""
        var split = string.split(separator: "\n")
        var index = 0
        while (index < split.count) {
            var thing = split[index].split(separator: " ")
            var thing0 = (Int(String(thing[0])) ?? 0)
            let thing1 = (Int(String(thing[1])) ?? 0) + 5
            let thing2 = (Int(String(thing[2])) ?? 0) + 5
            let thing3 = (Int(String(thing[3])) ?? 0) + 4
            let thing4 = (Int(String(thing[4])) ?? 0) + 3
            let thing5 = (Int(String(thing[5])) ?? 0) + 2
            hexDeadliftData.append(["Hex Bar Deadlift", "male", thing0, thing1, thing2, thing3, thing4, thing5])
            index += 1
        }
        
        string = """
        90    67    106    156    215    281
        100    75    115    167    229    297
        110    82    125    178    242    311
        120    89    133    189    254    325
        130    96    141    198    265    338
        140    102    149    208    276    350
        150    108    157    216    286    361
        160    114    164    225    295    372
        170    120    170    233    304    382
        180    126    177    240    313    392
        190    131    183    248    321    401
        200    136    189    255    330    410
        210    141    195    261    337    419
        220    146    201    268    345    427
        230    151    207    274    352    435
        240    155    212    281    359    443
        250    160    217    287    366    450
        260    164    222    292    372    458
"""
        
        split = string.split(separator: "\n")
        index = 0
        while (index < split.count) {
            var thing = split[index].split(separator: " ")
            var thing0 = (Int(String(thing[0])) ?? 0)
            let thing1 = (Int(String(thing[1])) ?? 0) + 5
            let thing2 = (Int(String(thing[2])) ?? 0) + 5
            let thing3 = (Int(String(thing[3])) ?? 0) + 4
            let thing4 = (Int(String(thing[4])) ?? 0) + 3
            let thing5 = (Int(String(thing[5])) ?? 0) + 2
            hexDeadliftData.append(["Hex Bar Deadlift", "female", thing0, thing1, thing2, thing3, thing4, thing5])
            index += 1
        }
        
        return hexDeadliftData
    }
    
    func getBentRowData() -> [[Any]] {
        var bentRowData: [[Any]]
        bentRowData = []
        
        var string = """
110    46    74    111    156    205
120    54    85    124    171    223
130    62    95    136    185    239
140    70    105    148    199    254
150    78    114    159    212    269
160    86    124    171    225    284
170    94    133    181    237    298
180    101    142    192    249    311
190    109    151    202    261    324
200    116    159    212    272    337
210    123    168    222    283    349
220    130    176    231    294    360
230    137    184    240    304    372
240    144    192    249    314    383
250    150    199    258    324    394
260    157    207    266    333    404
270    163    214    275    343    414
280    170    221    283    352    424
290    176    228    291    361    434
300    182    235    298    369    444
310    188    242    306    378    453
"""
        var split = string.split(separator: "\n")
        var index = 0
        while (index < split.count) {
            var thing = split[index].split(separator: " ")
            var thing0 = (Int(String(thing[0])) ?? 0)
            let thing1 = (Int(String(thing[1])) ?? 0) + 5
            let thing2 = (Int(String(thing[2])) ?? 0) + 5
            let thing3 = (Int(String(thing[3])) ?? 0) + 4
            let thing4 = (Int(String(thing[4])) ?? 0) + 3
            let thing5 = (Int(String(thing[5])) ?? 0) + 2
            bentRowData.append(["Bent Over Row", "male", thing0, thing1, thing2, thing3, thing4, thing5])
            index += 1
        }
        
        string = """
        90    24    44    71    104    143
        100    26    47    75    110    149
        110    29    50    79    114    154
        120    31    53    83    119    160
        130    33    56    86    123    165
        140    35    59    90    127    169
        150    37    61    93    131    174
        160    39    64    96    135    178
        170    41    66    99    138    182
        180    43    69    102    141    185
        190    45    71    104    145    189
        200    46    73    107    148    192
        210    48    75    109    150    196
        220    50    77    112    153    199
        230    51    79    114    156    202
        240    53    81    116    158    205
        250    54    82    118    161    208
        260    55    84    120    163    210
"""
        
        split = string.split(separator: "\n")
        index = 0
        while (index < split.count) {
            var thing = split[index].split(separator: " ")
            var thing0 = (Int(String(thing[0])) ?? 0)
            let thing1 = (Int(String(thing[1])) ?? 0) + 5
            let thing2 = (Int(String(thing[2])) ?? 0) + 5
            let thing3 = (Int(String(thing[3])) ?? 0) + 4
            let thing4 = (Int(String(thing[4])) ?? 0) + 3
            let thing5 = (Int(String(thing[5])) ?? 0) + 2
            bentRowData.append(["Bent Over Row", "female", thing0, thing1, thing2, thing3, thing4, thing5])
            index += 1
        }
        
        print(bentRowData)
        return bentRowData
    }
    
    func getInclineBenchData() -> [[Any]] {
        var inclineBenchData: [[Any]]
        inclineBenchData = []
        
        var string = """
110    48    74    107    147    191
120    57    85    121    163    209
130    67    97    135    179    227
140    76    108    148    194    243
150    85    119    161    208    260
160    94    130    173    222    276
170    103    140    185    236    291
180    112    150    197    249    305
190    121    160    208    262    320
200    129    170    219    275    333
210    138    180    230    287    347
220    146    189    241    299    360
230    154    199    251    310    373
240    162    208    261    322    385
250    170    216    271    333    397
260    177    225    281    343    409
270    185    234    291    354    420
280    192    242    300    364    431
290    200    250    309    374    442
300    207    258    318    384    453
310    214    266    327    394    463
"""
                var split = string.split(separator: "\n")
                var index = 0
                while (index < split.count) {
                    var thing = split[index].split(separator: " ")
                    var thing0 = (Int(String(thing[0])) ?? 0)
                    let thing1 = (Int(String(thing[1])) ?? 0) + 5
                    let thing2 = (Int(String(thing[2])) ?? 0) + 5
                    let thing3 = (Int(String(thing[3])) ?? 0) + 4
                    let thing4 = (Int(String(thing[4])) ?? 0) + 3
                    let thing5 = (Int(String(thing[5])) ?? 0) + 2
                    inclineBenchData.append(["Incline Bench Press", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                    index += 1
                }
                
                string = """
        90    12    30    58    94    136
        100    16    36    65    103    148
        110    19    41    72    112    158
        120    23    46    79    120    168
        130    27    51    86    129    178
        140    30    56    92    136    187
        150    34    61    98    144    196
        160    37    66    104    151    204
        170    41    70    109    158    212
        180    44    74    115    164    219
        190    47    79    120    171    227
        200    51    83    125    177    234
        210    54    87    130    183    240
        220    57    91    135    188    247
        230    60    95    140    194    253
        240    63    99    145    199    260
        250    66    102    149    205    266
        260    69    106    153    210    271
        """
                
                split = string.split(separator: "\n")
                index = 0
                while (index < split.count) {
                    var thing = split[index].split(separator: " ")
                    var thing0 = (Int(String(thing[0])) ?? 0)
                    let thing1 = (Int(String(thing[1])) ?? 0) + 5
                    let thing2 = (Int(String(thing[2])) ?? 0) + 5
                    let thing3 = (Int(String(thing[3])) ?? 0) + 4
                    let thing4 = (Int(String(thing[4])) ?? 0) + 3
                    let thing5 = (Int(String(thing[5])) ?? 0) + 2
                    inclineBenchData.append(["Incline Bench Press", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                    index += 1
                }
        
        return inclineBenchData
    }
    
    func getPowerCleanData() -> [[Any]] {
            var powerCleanData: [[Any]]
            powerCleanData = []
            
            var string = """
110    60    90    129    175    225
120    68    100    141    188    240
130    76    110    152    201    255
140    83    119    163    214    269
150    91    128    173    226    282
160    98    136    183    237    295
170    105    145    193    248    307
180    112    153    202    258    319
190    119    160    211    269    330
200    125    168    220    278    341
210    132    175    228    288    351
220    138    183    236    297    362
230    144    190    244    306    371
240    150    197    252    315    381
250    156    203    260    323    390
260    162    210    267    332    399
270    167    216    274    340    408
280    173    222    281    347    417
290    178    229    288    355    425
300    183    235    295    362    433
310    189    240    302    370    441
"""
                    var split = string.split(separator: "\n")
                    var index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        powerCleanData.append(["Power Clean", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
                    
                    string = """
        90    42    62    89    120    153
        100    46    68    95    127    162
        110    50    72    101    133    169
        120    54    77    106    140    176
        130    57    81    111    145    182
        140    61    85    116    151    189
        150    64    89    120    156    194
        160    67    93    125    161    200
        170    70    97    129    166    205
        180    73    100    133    170    210
        190    76    104    137    175    215
        200    79    107    140    179    220
        210    82    110    144    183    224
        220    84    113    147    187    228
        230    87    116    151    190    232
        240    89    119    154    194    236
        250    91    121    157    197    240
        260    94    124    160    201    244
"""
                    
                    split = string.split(separator: "\n")
                    index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        powerCleanData.append(["Power Clean", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
            
            return powerCleanData
        }
    
    func getCleanData() -> [[Any]] {
            var cleanData: [[Any]]
            cleanData = []
            
            var string = """
110    67    96    132    175    220
120    76    107    145    189    236
130    84    117    156    202    251
140    92    126    168    215    265
150    101    136    178    227    278
160    108    145    189    238    291
170    116    154    199    250    304
180    123    162    209    261    316
190    131    171    218    271    327
200    138    179    227    281    338
210    145    186    236    291    349
220    151    194    244    301    360
230    158    202    253    310    370
240    164    209    261    319    380
250    171    216    269    328    389
260    177    223    277    336    398
270    183    230    284    344    407
280    189    236    291    352    416
290    195    243    299    360    425
300    200    249    306    368    433
310    206    255    312    376    441
"""
                    var split = string.split(separator: "\n")
                    var index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        cleanData.append(["Clean", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
                    
                    string = """
        90    52    72    97    126    157
        100    56    77    103    133    165
        110    60    82    108    139    171
        120    63    86    113    144    178
        130    67    90    118    150    184
        140    70    94    123    155    189
        150    74    98    127    160    194
        160    77    101    131    164    199
        170    80    105    135    168    204
        180    82    108    138    172    209
        190    85    111    142    176    213
        200    88    114    145    180    217
        210    90    117    148    184    221
        220    93    120    151    187    225
        230    95    122    155    191    228
        240    97    125    157    194    232
        250    100    127    160    197    235
        260    102    130    163    200    239
"""
                    
                    split = string.split(separator: "\n")
                    index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        cleanData.append(["Clean", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
            
            return cleanData
        }
    
    func getCleanJerkData() -> [[Any]] {
            var cleanJerkData: [[Any]]
            cleanJerkData = []
            
            var string = """
110    56    88    130    179    234
120    64    98    141    193    250
130    71    107    153    207    265
140    79    116    164    219    280
150    86    125    174    232    294
160    93    134    185    243    307
170    100    142    194    254    319
180    107    151    204    265    331
190    114    158    213    276    343
200    120    166    222    286    354
210    127    174    231    296    365
220    133    181    239    305    376
230    139    188    247    314    386
240    145    195    255    323    396
250    151    202    263    332    405
260    157    208    270    340    415
270    162    215    278    349    424
280    168    221    285    357    433
290    173    227    292    365    441
300    178    233    299    372    450
310    184    239    305    380    458
"""
                    var split = string.split(separator: "\n")
                    var index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        cleanJerkData.append(["Clean & Jerk", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
                    
                    string = """
        90    47    69    97    129    164
        100    51    74    102    135    171
        110    54    78    107    140    177
        120    57    81    111    145    182
        130    60    85    115    150    187
        140    63    88    119    154    192
        150    65    91    122    158    197
        160    68    94    126    162    201
        170    70    97    129    166    205
        180    73    99    132    169    209
        190    75    102    135    172    213
        200    77    104    138    176    216
        210    79    107    140    179    220
        220    81    109    143    182    223
        230    83    111    146    185    226
        240    85    113    148    187    229
        250    86    115    150    190    232
        260    88    117    153    192    235
"""
                    
                    split = string.split(separator: "\n")
                    index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        cleanJerkData.append(["Clean & Jerk", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
            
            return cleanJerkData
        }
    
    func getSnatchData() -> [[Any]] {
            var snatchData: [[Any]]
            snatchData = []
            
            var string = """
110    42    70    106    151    200
120    48    77    116    162    213
130    54    85    125    173    226
140    60    92    134    183    237
150    65    99    142    193    248
160    71    106    150    202    259
170    76    112    158    211    269
180    81    119    165    220    279
190    86    125    172    228    288
200    91    131    180    236    297
210    96    137    186    244    306
220    101    142    193    251    314
230    106    148    199    259    323
240    110    153    206    266    330
250    115    158    212    273    338
260    119    163    218    279    346
270    123    168    223    286    353
280    127    173    229    292    360
290    132    178    234    299    367
300    136    183    240    305    374
310    140    187    245    311    380
"""
                    var split = string.split(separator: "\n")
                    var index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        snatchData.append(["Snatch", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
                    
                    string = """
        90    32    50    74    101    131
        100    35    54    78    106    137
        110    38    57    82    111    142
        120    40    60    85    115    147
        130    43    63    89    119    151
        140    45    66    92    123    156
        150    47    68    95    126    160
        160    49    71    98    129    163
        170    51    73    101    133    167
        180    53    76    103    136    170
        190    55    78    106    139    174
        200    57    80    108    141    177
        210    58    82    111    144    180
        220    60    84    113    147    183
        230    62    86    115    149    185
        240    63    87    117    151    188
        250    65    89    119    154    191
        260    66    91    121    156    193
"""
                    
                    split = string.split(separator: "\n")
                    index = 0
                    while (index < split.count) {
                        var thing = split[index].split(separator: " ")
                        var thing0 = (Int(String(thing[0])) ?? 0)
                        let thing1 = (Int(String(thing[1])) ?? 0) + 5
                        let thing2 = (Int(String(thing[2])) ?? 0) + 5
                        let thing3 = (Int(String(thing[3])) ?? 0) + 4
                        let thing4 = (Int(String(thing[4])) ?? 0) + 3
                        let thing5 = (Int(String(thing[5])) ?? 0) + 2
                        snatchData.append(["Snatch", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                        index += 1
                    }
            
            return snatchData
        }
    
    func getPushupData() -> [[Any]] {
                var pushupData: [[Any]]
                pushupData = []
                
                var string = """
110    1    15    41    74    110
120    1    16    41    72    107
130    1    17    42    71    104
140    1    18    41    70    102
150    2    18    41    69    99
160    2    19    41    67    96
170    3    19    40    66    94
180    4    19    40    64    91
190    4    19    39    63    89
200    4    19    39    62    87
210    5    19    38    60    85
220    5    19    37    59    83
230    5    18    37    58    81
240    5    18    36    57    79
250    5    18    35    55    77
260    5    18    35    54    75
270    5    18    34    53    74
280    5    17    33    52    72
290    5    17    33    51    70
300    5    17    32    50    69
310    5    16    32    49    67
"""
                        var split = string.split(separator: "\n")
                        var index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            pushupData.append(["Push Up", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                        
                        string = """
        90    1    5    20    39    61
        100    1    6    20    38    58
        110    1    6    20    37    56
        120    1    6    19    36    54
        130    1    6    19    35    52
        140    1    6    18    33    50
        150    1    6    18    32    48
        160    1    6    17    31    46
        170    1    6    16    30    44
        180    1    6    16    29    42
        190    1    6    15    28    41
        200    1    5    15    27    39
        210    1    5    14    26    38
        220    1    5    13    25    37
        230    1    4    13    24    35
        240    1    4    12    23    34
        250    1    4    12    22    33
        260    1    3    11    21    32
"""
                        
                        split = string.split(separator: "\n")
                        index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            pushupData.append(["Push Up", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                
                return pushupData
            }
    
    func getPullUpData() -> [[Any]] {
                var pullUpData: [[Any]]
                pullUpData = []
                
                var string = """
110    1    5    14    26    38
120    1    5    14    25    37
130    1    6    14    25    36
140    1    6    14    24    35
150    1    6    14    24    34
160    1    6    13    23    33
170    1    6    13    22    32
180    1    6    13    22    31
190    1    6    12    21    30
200    1    6    12    20    29
210    1    5    12    20    28
220    1    5    11    19    27
230    1    5    11    18    26
240    1    5    10    18    26
250    1    4    10    17    25
260    1    4    10    17    24
270    1    4    9    16    23
280    1    4    9    16    23
290    1    3    9    15    22
300    1    3    9    14    21
310    1    3    8    14    20
"""
                        var split = string.split(separator: "\n")
                        var index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            pullUpData.append(["Pull Up", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                        
                        string = """
        90    0    1    6    14    24
        100    0    1    6    14    23
        110    0    1    6    14    23
        120    0    1    6    13    22
        130    0    1    6    13    21
        140    0    1    6    12    20
        150    0    1    6    12    19
        160    0    1    6    11    19
        170    0    1    5    11    18
        180    0    1    5    10    17
        190    0    1    5    10    16
        200    0    1    4    10    15
        210    0    1    4    9    15
        220    0    1    4    9    14
        230    0    1    3    8    13
        240    0    1    3    8    13
        250    0    1    2    8    12
        260    0    1    2    7    11
"""
                        
                        split = string.split(separator: "\n")
                        index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            pullUpData.append(["Pull Up", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                
                return pullUpData
            }
    
    func getChinUpData() -> [[Any]] {
                var chinUpData: [[Any]]
                chinUpData = []
                
                var string = """
110    1    6    15    25    36
120    1    7    15    25    36
130    1    7    15    24    35
140    1    7    14    24    34
150    1    7    14    23    33
160    1    7    14    22    32
170    1    7    13    22    31
180    1    7    13    21    30
190    1    7    13    20    29
200    1    6    12    20    28
210    1    6    12    19    27
220    1    6    11    19    26
230    1    6    11    18    25
240    1    6    11    17    24
250    1    5    10    17    23
260    1    5    10    16    23
270    1    5    10    16    22
280    1    4    9    15    21
290    1    4    9    14    21
300    1    4    9    14    20
310    1    4    8    13    19
"""
                        var split = string.split(separator: "\n")
                        var index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            chinUpData.append(["Chin Up", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                        
                        string = """
        90    0    1    6    12    20
        100    0    1    6    12    19
        110    0    1    6    12    19
        120    0    1    6    12    18
        130    0    1    6    11    18
        140    0    1    6    11    17
        150    0    1    6    10    16
        160    0    1    6    10    16
        170    0    1    5    10    15
        180    0    1    5    9    14
        190    0    1    5    9    14
        200    0    1    5    9    13
        210    0    1    4    8    12
        220    0    1    4    8    12
        230    0    1    3    8    11
        240    0    1    3    7    11
        250    0    1    3    7    10
        260    0    1    2    6    10
"""
                        
                        split = string.split(separator: "\n")
                        index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            chinUpData.append(["Chin Up", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                
                return chinUpData
            }
    
    func getDipData() -> [[Any]] {
                var dipData: [[Any]]
                dipData = []
                
                var string = """
110    0    6    18    33    49
120    0    7    19    33    48
130    0    8    19    33    47
140    0    9    19    33    47
150    0    9    19    32    46
160    0    9    19    32    45
170    1    9    19    31    44
180    1    9    19    31    43
190    1    9    19    30    42
200    2    9    19    29    41
210    2    9    18    29    40
220    2    9    18    28    39
230    2    9    18    28    38
240    2    9    17    27    37
250    2    9    17    26    36
260    2    9    16    26    35
270    2    9    16    25    34
280    2    8    16    25    34
290    2    8    15    24    33
300    2    8    15    23    32
310    1    8    15    23    31
"""
                        var split = string.split(separator: "\n")
                        var index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            dipData.append(["Dip", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                        
                        string = """
        90    0    1    10    22    36
        100    0    1    10    22    35
        110    0    1    10    22    34
        120    0    1    10    21    33
        130    0    1    10    20    32
        140    0    1    10    20    31
        150    1    2    10    19    30
        160    0    1    9    18    28
        170    0    1    9    18    27
        180    0    1    9    17    26
        190    0    1    9    16    25
        200    0    1    8    16    24
        210    0    1    8    15    23
        220    0    1    8    14    23
        230    0    1    7    14    22
        240    0    1    7    13    21
        250    0    1    7    13    20
        260    0    1    6    12    19
"""
                        
                        split = string.split(separator: "\n")
                        index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 1
                            dipData.append(["Dip", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                
                return dipData
            }
    
    func getPistolSquatData() -> [[Any]] {
                var pistolSquatData: [[Any]]
                pistolSquatData = []
                
                var string = """
110    0    1    9    27    47
120    0    1    10    28    47
130    0    1    12    28    47
140    0    1    12    28    46
150    0    1    13    29    46
160    0    1    13    29    45
170    1    2    14    28    45
180    1    3    14    28    44
190    1    3    14    28    43
200    1    4    14    28    42
210    1    4    14    27    42
220    1    4    14    27    41
230    1    4    14    27    40
240    1    4    14    26    39
250    1    4    14    26    39
260    1    4    13    25    38
270    1    4    13    25    37
280    1    4    13    24    36
290    1    4    13    24    36
300    1    4    13    23    35
310    1    4    12    23    34
"""
                        var split = string.split(separator: "\n")
                        var index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 2
                            pistolSquatData.append(["Pistol Squat", "male", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                        
                        string = """
        90    0    1    9    25    44
        100    0    1    10    26    43
        110    0    1    11    26    42
        120    0    1    11    26    42
        130    0    1    12    26    41
        140    0    1    12    25    40
        150    1    2    12    25    39
        160    1    2    12    24    38
        170    1    2    12    24    37
        180    1    2    11    23    35
        190    1    3    11    22    34
        200    1    3    11    22    34
        210    1    3    11    21    33
        220    1    2    10    21    32
        230    1    2    10    20    31
        240    1    2    10    20    30
        250    1    2    10    19    29
        260    1    2    10    18    28
"""
                        
                        split = string.split(separator: "\n")
                        index = 0
                        while (index < split.count) {
                            var thing = split[index].split(separator: " ")
                            var thing0 = (Int(String(thing[0])) ?? 0)
                            let thing1 = (Int(String(thing[1])) ?? 0) + 0
                            let thing2 = (Int(String(thing[2])) ?? 0) + 0
                            let thing3 = (Int(String(thing[3])) ?? 0) + 1
                            let thing4 = (Int(String(thing[4])) ?? 0) + 1
                            let thing5 = (Int(String(thing[5])) ?? 0) + 2
                            pistolSquatData.append(["Pistol Squat", "female", thing0, thing1, thing2, thing3, thing4, thing5])
                            index += 1
                        }
                
                return pistolSquatData
            }
    
    func addToDatabase(exercise: String, gender: String, bodyWeight: Int, beginner: Int, novice: Int, intermediate: Int, advanced: Int, elite: Int) {
        var statement: OpaquePointer?
        print(exercise)
        
        var addQuery = "INSERT INTO StrengthStandards (exercise, gender, body_weight, beginner, novice, intermediate, advanced, elite) VALUES ("
        addQuery += "'" + exercise + "',"
        addQuery += "'" + gender + "',"
        addQuery += String(bodyWeight) + "," + String(beginner) + "," + String(novice) + "," + String(intermediate) + "," + String(advanced) + "," + String(elite) + ")"
        
        if sqlite3_prepare(db, addQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("saved successfully")
        }
    }
    
    func readFromDatabase() {
        var readStatement: OpaquePointer?
        let readQuery = "SELECT * FROM StrengthStandards"
        
        if sqlite3_prepare(db, readQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return }
                guard let gender = sqlite3_column_text(readStatement, 2) else { return }
                let bodyWeight = sqlite3_column_int(readStatement, 3)
                let beginner = sqlite3_column_int(readStatement, 4)
                let novice = sqlite3_column_int(readStatement, 5)
                let intermediate = sqlite3_column_int(readStatement, 6)
                let advanced = sqlite3_column_int(readStatement, 7)
                let elite = sqlite3_column_int(readStatement, 8)
                print(String(rowId) + "|" + String(cString: exercise) + "|" + String(cString: gender) + "|" + String(bodyWeight) + "|" + String(beginner) + "|" + String(novice) + "|" + String(intermediate) + "|" + String(advanced) + "|" + String(elite))
            }
        }
    }
    
    func test() {
        var readStatement: OpaquePointer?
        var selectQuery = "SELECT * FROM ExerciseList"
        
        if sqlite3_prepare(db, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return }
                guard let category = sqlite3_column_text(readStatement, 2) else { return }
                print(String(rowId) + "|" + String(cString: exercise) + "|" + String(cString: category))
            }
        }
        
    }
    
    
    // RETRIEVAL FUNCTIONS
    func getExercises() -> [[String]] {
        var exercises: [[String]] = []
        var readStatement: OpaquePointer?
        var selectQuery = "SELECT * FROM ExerciseList ORDER BY exercise"
        
        if sqlite3_prepare(db, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return [] }
                guard let category = sqlite3_column_text(readStatement, 2) else { return [] }
                exercises.append([String(cString: exercise), String(cString: category)])
            }
        }
    
        return exercises
    }
    
    func getStrengthStandards(exercise: String, weight: Int, gender: String, age: Int) -> [Double] {
        // make sure weight is within the bounds
        var newWeight = weight
        if (gender == "male") {
            if (weight > 310) {
                newWeight = 310
            } else if (weight < 110) {
                newWeight = 110
            }
        } else {
            if (weight > 260) {
                newWeight = 260
            } else if (weight < 90) {
                newWeight = 90
            }
        }
        
        var standards: [[Double]] = []
        var readStatement: OpaquePointer?
        
        let readQuery = "SELECT * FROM StrengthStandards WHERE gender == '" + gender + "' AND exercise == '" + exercise + "' AND ABS(body_weight - " + String(newWeight) + ") < 10 ORDER BY body_weight"
        var ageMultipliers = [[17, 0.87], [23, 0.98], [39, 1.0], [49, 0.95], [59, 0.83], [69, 0.69], [79, 0.55]]
        // last is 1.56
        print(readQuery)
        
        if sqlite3_prepare(db, readQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return [] }
                guard let gender = sqlite3_column_text(readStatement, 2) else { return [] }
                let bodyWeight = sqlite3_column_int(readStatement, 3)
                let beginner = sqlite3_column_int(readStatement, 4)
                let novice = sqlite3_column_int(readStatement, 5)
                let intermediate = sqlite3_column_int(readStatement, 6)
                let advanced = sqlite3_column_int(readStatement, 7)
                let elite = sqlite3_column_int(readStatement, 8)
                print(String(rowId) + "|" + String(cString: exercise) + "|" + String(cString: gender) + "|" + String(bodyWeight) + "|" + String(beginner) + "|" + String(novice) + "|" + String(intermediate) + "|" + String(advanced) + "|" + String(elite))
                standards.append([Double(bodyWeight), Double(beginner), Double(novice), Double(intermediate), Double(advanced), Double(elite)])
            }
        }
        
        var i = 0
        var ageMultiplier = 0.0
        while (i < ageMultipliers.count) {
            if (age <= Int(ageMultipliers[i][0])) {
                ageMultiplier = ageMultipliers[i][1]
                break
            } else if (age >= 80) {
                ageMultiplier = 0.44
                break
            }
            i += 1
        }
        print(ageMultiplier)
        print("STANDARDS")
        print(standards)
        
        if (standards.count == 0) {
            return [-1.0]
        }
        
        var toBeReturned: [Double] = []
        if (standards.count > 1) {
            var lowerFactor = Double(abs(Int(Double(newWeight) - standards[0][0]))) / 10.0
            var upperFactor = Double(abs(Int(Double(newWeight) - standards[0][0]))) / 10.0
            if (lowerFactor + upperFactor < 1) {
                lowerFactor += 1 - (lowerFactor + upperFactor)
            }
            var index = 1
            while (index < standards[0].count) {
                toBeReturned.append((standards[0][index] * lowerFactor + standards[1][index] * upperFactor) * ageMultiplier)
                index += 1
            }
        } else {
            var index = 1
            while (index < standards[0].count) {
                toBeReturned.append(standards[0][index] * ageMultiplier)
                index += 1
            }
        }
        
        print(toBeReturned)
        
        return toBeReturned
    }
    
    func addUserActivity(exercise: String, reps: Int, weight: String, orm: Double) {
        var statement: OpaquePointer?
        var addQuery = "INSERT INTO UserActivity (exercise, time_recorded, reps, weight, orm) VALUES ("
        addQuery += "'" + exercise + "',"
        addQuery += "date()," + String(reps) + ",'"
        addQuery += weight + "'," + String(orm) + ")"
        print(addQuery)
        
        if sqlite3_prepare(userDb, addQuery, -1, &statement, nil) != SQLITE_OK {
           print("error binding query")
           return
       }
       
       if sqlite3_step(statement) == SQLITE_DONE {
           print("saved user data successfully")
       }
        
    }
    
    func readFromUserDB() {
        var readStatement: OpaquePointer?
        var selectQuery = "SELECT * FROM UserActivity"
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return }
                guard let timeRecorded = sqlite3_column_text(readStatement, 2) else { return }
                let reps = sqlite3_column_int(readStatement, 3)
                guard let weight = sqlite3_column_text(readStatement, 4) else { return }
                let orm = sqlite3_column_double(readStatement, 5)
                print(String(rowId) + "|" + String(cString: exercise) + "|" + String(cString: timeRecorded) + "|" + String(reps) + "|" + String(cString: weight) + "|" + String(orm))
            }
        }
    }
    
    func addToCustomExerciseList(exercise: String, category: String) {
        var statement: OpaquePointer?
        let addQuery = "INSERT INTO CustomExerciseList (exercise, category) VALUES ('" + exercise + "','" + category + "')"
        print(addQuery)
        
        if sqlite3_prepare(userDb, addQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("saved custom exercise successfully")
        }
        
    }
    
    func readFromCustomExercises() {
        var readStatement: OpaquePointer?
        let selectQuery = "SELECT * FROM CustomExerciseList"
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return }
                guard let category = sqlite3_column_text(readStatement, 2) else { return }
                print(String(rowId) + "|" + String(cString: exercise) + "|" + String(cString: category))
            }
        }
    }
    
    func getUserExercises() -> [[String]] {
        var exercises: [[String]] = []
        var readStatement: OpaquePointer?
        let selectQuery = "SELECT * FROM CustomExerciseList"
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return [[]] }
                guard let category = sqlite3_column_text(readStatement, 2) else { return [[]] }
                print(String(rowId) + "|" + String(cString: exercise) + "|" + String(cString: category))
                exercises.append([String(cString: exercise), String(cString: category)])
            }
        }
    
        return exercises
    }
    
    func getRecentActivity(exercise: String, timeFrame: String) -> [[String]] {
        var readStatement: OpaquePointer?
        var selectQuery = "SELECT * FROM UserActivity WHERE exercise = '" + exercise + "'"
        
        // do time frame filtering
        if (timeFrame != "all") {
            selectQuery += " AND (time_recorded BETWEEN date('now','" + timeFrame + "') AND date()) ORDER BY time_recorded"
        } else {
            selectQuery += " ORDER BY time_recorded"
        }
        print(selectQuery)
        
        var toBeReturned: [[String]] = []
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let rowId = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return [] }
                guard let timeRecorded = sqlite3_column_text(readStatement, 2) else { return [] }
                let reps = sqlite3_column_int(readStatement, 3)
                guard let weight = sqlite3_column_text(readStatement, 4) else { return [] }
                let orm = sqlite3_column_double(readStatement, 5)
                let entry = [String(cString: timeRecorded), String(orm), String(rowId)]
                toBeReturned.append(entry)
            }
        }
        
        return toBeReturned
    }
    
    func getRecord(exercise: String) -> Double {
        var readStatement: OpaquePointer?
        let selectQuery = "SELECT record FROM UserRecords WHERE exercise = '" + exercise + "'"
        var toBeReturned = -1.0
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let amount = sqlite3_column_double(readStatement, 0)
                print(amount)
                toBeReturned = amount
            }
        }
        
        return toBeReturned
    }
    
    func setRecord(exercise: String, value: Double) {
       var updateStatement: OpaquePointer?
       let updateQuery = "UPDATE UserRecords SET record = " + String(value) + " WHERE exercise = '" + exercise + "'"
        
       print(updateQuery)
       
       if sqlite3_prepare(userDb, updateQuery, -1, &updateStatement, nil) != SQLITE_OK {
           print("error binding query")
           return
       }
       
       if sqlite3_step(updateStatement) == SQLITE_DONE {
           print("saved user record")
       }
    }
    
    func insertRecord(exercise: String, value: Double) {
        var statement: OpaquePointer?
        let addQuery = "INSERT INTO UserRecords (exercise, record) VALUES ('" + exercise + "'," + String(value) + ")"
        print(addQuery)
        
        if sqlite3_prepare(userDb, addQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("saved user record")
        }
    }
    
    func getRecordsList() -> [[Any]] {
        var readStatement: OpaquePointer?
        let selectQuery = "SELECT * FROM UserRecords order by exercise"
        var toBeReturned: [[Any]] = []
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let index = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return [] }
                let record = sqlite3_column_double(readStatement, 2)
                toBeReturned.append([String(cString: exercise), record])
            }
        }
        
        return toBeReturned
    }
    
    func addToGoals(exercise: String, value: Double) {
        var statement: OpaquePointer?
        let addQuery = "INSERT INTO UserGoals (exercise, goal) VALUES ('" + exercise + "'," + String(value) + ")"
        print(addQuery)
        
        if sqlite3_prepare(userDb, addQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("saved user goal")
        }
    }
    
    func updateGoal(exercise: String, value: Double) {
        var updateStatement: OpaquePointer?
        let updateQuery = "UPDATE UserGoals SET goal = " + String(value) + " WHERE exercise = '" + exercise + "'"
         
        print(updateQuery)
        
        if sqlite3_prepare(userDb, updateQuery, -1, &updateStatement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(updateStatement) == SQLITE_DONE {
            print("updated user goal")
        }
    }
    
    func getGoal(exercise: String) -> Double {
        var readStatement: OpaquePointer?
        let selectQuery = "SELECT goal FROM UserGoals WHERE exercise = '" + exercise + "'"
        var toBeReturned = -1.0
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let amount = sqlite3_column_double(readStatement, 0)
                print(amount)
                toBeReturned = amount
            }
        }
        
        return toBeReturned
    }
    
    func getGoalsList() -> [[Any]] {
        var readStatement: OpaquePointer?
        let selectQuery = "SELECT * FROM UserGoals order by exercise"
        var toBeReturned: [[Any]] = []
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                let index = sqlite3_column_int(readStatement, 0)
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return [] }
                let record = sqlite3_column_double(readStatement, 2)
                toBeReturned.append([String(cString: exercise), record])
            }
        }
        
        return toBeReturned
    }
    
    func getMostRecentExercise() -> String {
        var readStatement: OpaquePointer?
        let selectQuery = "SELECT * FROM UserActivity ORDER BY id desc"
        print(selectQuery)
        
        if sqlite3_prepare(userDb, selectQuery, -1, &readStatement, nil) == SQLITE_OK {
            while sqlite3_step(readStatement) == SQLITE_ROW {
                guard let exercise = sqlite3_column_text(readStatement, 1) else { return "" }
                return String(cString: exercise)
            }
        }
        
        return ""
    }
    
    func deleteActivity(index: String) {
        var statement: OpaquePointer?
        let deleteQuery = "DELETE FROM UserActivity WHERE id = " + index
        print(deleteQuery)
        
        if sqlite3_prepare(userDb, deleteQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("deleted activity")
        }
    }
    
    func updateExerciseType(exercise: String, newType: String) {
        var statement: OpaquePointer?
        let updateQuery = "UPDATE CustomExerciseList SET category = '" + newType + "' WHERE exercise = '" + exercise + "'"
        print(updateQuery)
        
        if sqlite3_prepare(userDb, updateQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("updated exercise type")
        }
    }
    
    func deleteExercise(exercise: String) {
        // 1. recorded activities
        // 2. personal bests
        // 3. goals
        // 4. exerciseList
        var statement: OpaquePointer?
        let firstQuery = "DELETE FROM UserActivity WHERE exercise = '" + exercise + "'"
        let secondQuery = "DELETE FROM CustomExerciseList WHERE exercise = '" + exercise + "'"
        let thirdQuery = "DELETE FROM UserRecords WHERE exercise = '" + exercise + "'"
        let fourthQuery = "DELETE FROM UserGoals WHERE exercise = '" + exercise + "'"
        
        if sqlite3_prepare(userDb, firstQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("deleted from activities")
        }
        
        if sqlite3_prepare(userDb, secondQuery, -1, &statement, nil) != SQLITE_OK {
            print("error")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("deleted from list")
        }
        
        if sqlite3_prepare(userDb, thirdQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("deleted from records")
        }
        
        if sqlite3_prepare(userDb, fourthQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("deleted from goals")
        }
    }
    
    func updateExerciseName(oldName: String, newName: String) {
        //let updateQuery = "UPDATE UserRecords SET record = " + String(value) + " WHERE exercise = '" + exercise + "'"
        // 1. recorded activities
        // 2. personal bests
        // 3. goals
        // 4. exerciseList
        var statement: OpaquePointer?
        let firstQuery = "UPDATE UserActivity SET exercise = '" + newName + "' WHERE exercise = '" + oldName + "'"
        let secondQuery = "UPDATE CustomExerciseList SET exercise = '" + newName + "' WHERE exercise = '" + oldName + "'"
        let thirdQuery = "UPDATE UserRecords SET exercise = '" + newName + "' WHERE exercise = '" + oldName + "'"
        let fourthQuery = "UPDATE UserGoals SET exercise = '" + newName + "' WHERE exercise = '" + oldName + "'"
        
        if sqlite3_prepare(userDb, firstQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("updated in activities")
        }
        
        if sqlite3_prepare(userDb, secondQuery, -1, &statement, nil) != SQLITE_OK {
            print("error")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("updated in list")
        }
        
        if sqlite3_prepare(userDb, thirdQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("updated in records")
        }
        
        if sqlite3_prepare(userDb, fourthQuery, -1, &statement, nil) != SQLITE_OK {
            print("error binding query")
            return
        }
        
        if sqlite3_step(statement) == SQLITE_DONE {
            print("updated in goals")
        }
    }
}
