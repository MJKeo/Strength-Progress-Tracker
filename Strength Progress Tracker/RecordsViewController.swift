//
//  RecordsViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/4/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class RecordsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // table view
    @IBOutlet weak var recordsTable: UITableView!
    
    // title
    @IBOutlet weak var titleLabel: UILabel!
    
    // other variables
    var recordsList: [[Any]] = []
    var exerciseList: [[String]] = []
    var userExercises: [String] = []
    var animate: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.recordsTable.delegate = self
        self.recordsTable.dataSource = self
        self.titleLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // do most of my setup here
        self.recordsList = dbManager.getRecordsList()
        
        self.userExercises = UserDefaults.standard.object(forKey: "User Exercise List") as! [String]
        
        createLists()
        recordsTable.reloadData()
        let numVisible = Int(ceil(self.view.frame.height / 140.0))
        var index = 0
        self.animate = []
        while(index < numVisible) {
            animate.append(true)
            index += 1
        }
        
        // animate title in
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
        }, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.titleLabel.alpha = 0
        self.recordsTable.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    /*
        HELPER FUNCTIONS
     */
    
    func createLists() {
        exerciseList = dbManager.getExercises()
        let userExercises = dbManager.getUserExercises()
        for item in userExercises {
            exerciseList.append(item)
        }
    }
    
    /*
        TABLE VIEW FUNCTIONS
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : RecordTableViewCell = recordsTable.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath) as! RecordTableViewCell
        
        let exerciseName = (self.recordsList[indexPath.row][0] as? String)!
        cell.exerciseTitle.text = exerciseName
        let tempList = dbManager.getExercises()
        if (tempList.contains([exerciseName, "bodyweight"]) || tempList.contains([exerciseName, "weights"])) {
            cell.exerciseIcon.image = UIImage(named: exerciseName)
        } else {
            cell.exerciseIcon.image = UIImage(named: "custom")
        }
//        cell.exerciseIcon.image = UIImage(named: "snatch")
        var bestORM = recordsList[indexPath.row][1] as! Double
        let bestORMInt = floor(bestORM * 100)
        bestORM = Double(bestORMInt) / 100.0
        if (exerciseList.firstIndex(of: [recordsList[indexPath.row][0] as! String,"bodyweight"]) == nil) {
            cell.bestORMLabel.text = String(bestORM) + " lbs"
        } else {
            cell.bestORMLabel.text = String(Int(bestORM)) + " reps"
        }
        
        // styling
        cell.iconView.layer.borderWidth = 1
        cell.iconView.layer.borderColor = UIColor.black.cgColor
        cell.iconView.layer.cornerRadius = 37.5
        cell.iconView.clipsToBounds = true
        cell.mainView.layer.borderWidth = 1
        cell.mainView.layer.borderColor = UIColor.gray.cgColor
        cell.StrengthLevelView.layer.cornerRadius = cell.StrengthLevelView.frame.height / 3.1
        cell.StrengthLevelView.layer.borderWidth = 1
        if (indexPath.row < self.animate.count && self.animate[indexPath.row]) {
            cell.alpha = 0
            UIView.animate(withDuration: 0.5, delay: TimeInterval(Double(indexPath.row) / 10), options: .curveEaseOut, animations: {
                cell.alpha = 1
            }, completion: nil)
            self.animate[indexPath.row] = false
        }
        
        self.modifyForStrengthStandards(cell: cell, weight: bestORM, exercise: recordsList[indexPath.row][0] as! String)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return self.view.frame.height / 7.5
//    }
    
    /*
        EXTRA CELL FUNCTIONS
     */
    
    func modifyForStrengthStandards(cell: RecordTableViewCell, weight: Double, exercise: String) {
        let userWeightString = UserDefaults.standard.object(forKey: "User Weight") as! String
        var userWeight = Double(userWeightString.split(separator: " ")[0])!
        if (userWeightString.split(separator: " ")[1] == "kgs") {
            userWeight *= 2.20462
        }
        let userGender = UserDefaults.standard.string(forKey: "User Gender")!
        let userAge = UserDefaults.standard.integer(forKey: "User Age")
        let standards = dbManager.getStrengthStandards(exercise: exercise, weight: Int(userWeight), gender: userGender, age: userAge)
        
        if (standards.count == 1) {
            updateCellLook(cell: cell, level: -1)
        } else {
            var index = 0
            while (index < standards.count) {
                if (weight < standards[index]) {
                    break
                }
                index += 1
            }
            
            updateCellLook(cell: cell, level: index)
        }
    }
    
    func updateCellLook(cell: RecordTableViewCell, level: Int) {
        if (level == 0) {
            cell.StrengthLevelView.layer.backgroundColor = UIColor.gray.cgColor
            cell.StrengthLevelView.layer.borderColor = UIColor.darkGray.cgColor
            cell.StrengthLevelText.text = "Untrained"
            cell.StrengthLevelText.textColor = UIColor.white
        } else if (level == 1) {
            cell.StrengthLevelView.layer.backgroundColor = UIColor(red: (135/255.0), green: (32/255.0), blue: (239/255.0), alpha: 1).cgColor
            cell.StrengthLevelView.layer.borderColor = UIColor(red: (85/255.0), green: (14/255.0), blue: (157/255.0), alpha: 1).cgColor
            cell.StrengthLevelText.text = "Beginner"
            cell.StrengthLevelText.textColor = UIColor.white
            
        } else if (level == 2) {
            cell.StrengthLevelView.layer.backgroundColor = UIColor(red: (74/255.0), green: (127/255.0), blue: (245/255.0), alpha: 1).cgColor
            cell.StrengthLevelView.layer.borderColor = UIColor(red: (41/255.0), green: (81/255.0), blue: (172/255.0), alpha: 1).cgColor
            cell.StrengthLevelText.text = "Novice"
            cell.StrengthLevelText.textColor = UIColor.white
            
        } else if (level == 3) {
            cell.StrengthLevelView.layer.backgroundColor = UIColor(red: (23/255.0), green: (172/255.0), blue: (3/255.0), alpha: 1).cgColor
            cell.StrengthLevelView.layer.borderColor = UIColor(red: (15/255.0), green: (114/255.0), blue: (2.0/255.0), alpha: 1).cgColor
            cell.StrengthLevelText.text = "Intermediate"
            cell.StrengthLevelText.textColor = UIColor.white
            
        } else if (level == 4) {
            cell.StrengthLevelView.layer.backgroundColor = UIColor(red: (240.0/255.0), green: (166/255.0), blue: (0/255.0), alpha: 1).cgColor
            cell.StrengthLevelView.layer.borderColor = UIColor(red: (169.0/255.0), green: (118.0/255.0), blue: (3.0/255.0), alpha: 1).cgColor
            cell.StrengthLevelText.text = "Advanced"
            cell.StrengthLevelText.textColor = UIColor.white
            
        } else if (level == 5) {
            cell.StrengthLevelView.layer.backgroundColor = UIColor(red: (237/255.0), green: (17/255.0), blue: (51/255.0), alpha: 1).cgColor
            cell.StrengthLevelView.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
            cell.StrengthLevelText.text = "Elite"
            cell.StrengthLevelText.textColor = UIColor.white
        } else {
            cell.StrengthLevelView.layer.backgroundColor = UIColor.gray.cgColor
            cell.StrengthLevelView.layer.borderColor = UIColor.darkGray.cgColor
            cell.StrengthLevelText.text = "N/A"
            cell.StrengthLevelText.textColor = UIColor.white
        }
    }

}
