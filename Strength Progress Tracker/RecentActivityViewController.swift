//
//  RecentActivityViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/19/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class RecentActivityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // table view
    @IBOutlet weak var myTable: UITableView!
    
    // variables
    var exercise: String!
    var activity: [[String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.exercise = UserDefaults.standard.object(forKey: "Selected Exercise") as? String
        
        getRecentActivity()

        myTable.delegate = self
        myTable.dataSource = self
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
        REGULAR FUNCTIONALITY
     */
    func getRecentActivity() {
        self.activity = dbManager.getRecentActivity(exercise: self.exercise, timeFrame: "all")
    }
    
    func removeActivity(index: String) {
        let alertController = UIAlertController(title: "Are you sure you want to delete this activity?", message: nil, preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            dbManager.deleteActivity(index: index)
            self.refreshData()
            self.updateORM()
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateORM() {
        var maxORM = -1.0
        var index = 0
        while (index < self.activity.count) {
            var num = Double(self.activity[index][1].split(separator: " ")[0])!
            if (num > maxORM) {
                maxORM = num
            }
            index += 1
        }
        print(maxORM)
        maxORM = round(maxORM * 10) / 10.0
        dbManager.setRecord(exercise: self.exercise, value: maxORM)
    }
    
    func refreshData() {
        getRecentActivity()
        myTable.reloadData()
    }

    /*
        TABLE VIEW METHODS
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activity.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RecentActivityTableViewCell = myTable.dequeueReusableCell(withIdentifier: "recentCell") as! RecentActivityTableViewCell
        let index = self.activity.count - indexPath.row - 1
        let initialDateString = self.activity[index][0]
        let splitDate = initialDateString.split(separator: "-")
        var finalDate = splitDate[1] + "/" + splitDate[2]
        finalDate += "/" + splitDate[0]
        cell.TimeLabel.text = "Recorded: " + finalDate
        if (UserDefaults.standard.string(forKey: "Suffix")! == "kgs") {
            var num = Double(self.activity[index][1])! / 2.20462
            num = round(num * 10) / 10.0
            cell.ORMLabel.text = "ORM: " + String(num) + " kgs"
        } else if (UserDefaults.standard.string(forKey: "Suffix")! == "reps") {
            var num = Int(Double(self.activity[index][1])!)
            cell.ORMLabel.text = "ORM: " + String(num) + " reps"
        } else {
            var num = Double(self.activity[index][1])!
            num = round(num * 10) / 10.0
            cell.ORMLabel.text = "ORM: " + String(num) + " lbs"
        }
        cell.id = self.activity[index][2]
        cell.onClick = removeActivity
        return cell
    }

}
