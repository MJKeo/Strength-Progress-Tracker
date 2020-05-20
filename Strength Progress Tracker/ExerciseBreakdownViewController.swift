//
//  ExerciseBreakdownViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/26/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit
import Charts

class ExerciseBreakdownViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, ChartViewDelegate {
    
    // title
    @IBOutlet weak var titleLabel: UILabel!
    
    // graph
    @IBOutlet weak var progressChart: LineChartView!
    @IBOutlet weak var activityDetailLabel: UILabel!
    
    // record activity button
    @IBOutlet weak var recordActivityButton: UIButton!
    
    // time frame buttons
    @IBOutlet var timeFrameButtons: [UIButton]!
    
    // table view
    @IBOutlet weak var myTableView: UITableView!
    
    // record activity stuff
    @IBOutlet weak var recordActivityView: UIView!
    @IBOutlet weak var recordBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var repsButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var darkBackgroundView: UIView!
    @IBOutlet weak var darkBackgroundWidth: NSLayoutConstraint!
    @IBOutlet weak var darkBackgroundHeight: NSLayoutConstraint!
    
    // picker stuff
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var dataPicker: UIPickerView!
    
    // variables
    var exercise: String = ""
    var activity: [[String]] = []
    let numItems = 2
    var personalBest = 0.0
    var goal = 315
    var viewingUnits = "lbs"
    var timeFrame = "-6 days"
    var startTime: Date = Date()
    var endTime: Date = Date()
    var axisDates: [String] = []
    
    
    var options: [String] = []
    var repsList: [String] = []
    var weightList: [String] = []
    let weightUnits = ["lbs", "kgs"]
    var selectedUnit = "lbs"
    var numComponents = 1
    var selectedButton: UIButton!
    var isGoalSelected = false
    var goalUnit = "lbs"
    
    var exerciseList: [[String]] = []
    var userExercises: [String] = []
    var standards: [Double] = []
    
    let redTextAttrs = [
    NSAttributedString.Key.foregroundColor : UIColor(red: (207/255.0), green: (41/255.0), blue: (29/255.0), alpha: 1),
    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
    NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
    let blackTextAttrs = [
    NSAttributedString.Key.foregroundColor : UIColor.black,
    NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
    NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.exercise = UserDefaults.standard.object(forKey: "Selected Exercise") as! String
        print("bruhbruh")
        self.titleLabel.text = exercise
        self.personalBest = dbManager.getRecord(exercise: self.exercise)
        if (self.personalBest < 0) {
            self.personalBest = 0
        }
        
        doStyling()
        
        // get my standards
        getStandards()
        
        // prepare table view to get data from this file
        self.myTableView.delegate = self
        self.myTableView.dataSource = self
        
        // do the same for the picker
        self.dataPicker.delegate = self
        self.dataPicker.dataSource = self
        
        // delegate for my graph
        self.progressChart.delegate = self
        
        // allows tap on screen to get rid of popups and pickers
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        self.view.addGestureRecognizer(tap)
        
        // populate graph
        updateGraph()
        
        // refresh everything
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func refresh() {
        self.changeTimeFrameOneWeek(self)
        
        self.setupPickerLists()
        
        self.recordBottomConstraint.constant = -1 * self.view.frame.height / 2
        
        
        // get exercise list
        exerciseList = dbManager.getExercises()
        let userExercises = dbManager.getUserExercises()
        for item in userExercises {
            exerciseList.append(item)
        }
        
        if (exerciseList.firstIndex(of: [self.exercise,"bodyweight"]) != nil) {
            let userWeight = UserDefaults.standard.object(forKey: "User Weight")
            self.weightButton.setTitle(userWeight as? String, for: .normal)
            self.weightButton.setTitleColor(UIColor.gray, for: .normal)
            self.weightButton.isEnabled = false
        }
        // do goal thing
        self.goal = Int(dbManager.getGoal(exercise: self.exercise))
        if (self.goal == -1) {
            if (self.weightButton.isEnabled) {
                self.goal = 315
                dbManager.addToGoals(exercise: self.exercise, value: 315.0)
            } else {
                self.goal = 5
                
            }
        }
        
        // setup my strength standards
        getStandards()
        
        // make sure my numbers are accurate
        refreshData()
    }
    
    /*
        MAIN FUNCTIONALITY
     */
    func updateGraph() {
        self.activity = dbManager.getRecentActivity(exercise: self.exercise, timeFrame: self.timeFrame)
        print(self.activity)
        
        var myDataEntries: [ChartDataEntry] = []
        var dataDates: [String] = []
        var myGoalEntries: [ChartDataEntry] = []
        
        var standardsSets: [[ChartDataEntry]] = [[],[],[],[],[]]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "MM/dd/yyyy"
        
        let endTimeString = yearFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: self.endTime)!)
        
        var tiem = self.startTime
        var numDates = 0
        while(yearFormatter.string(from: tiem) != endTimeString) {
//            print(formatter.string(from: tiem))
            tiem = Calendar.current.date(byAdding: .day, value: 1, to: tiem)!
            numDates += 1
        }
        
        
        var index = 0
        var entryIndex = 0
        var time = self.startTime
//        print(endTimeString)
        while (yearFormatter.string(from: time) != endTimeString) {
            // add date
            if (!dataDates.contains(formatter.string(from: time))) {
                dataDates.append(formatter.string(from: time))
            }
            // add goals and standards
            if (UserDefaults.standard.string(forKey: "Display Units") == "kgs" && self.weightButton.isEnabled) {
                UserDefaults.standard.set("kgs", forKey: "Suffix")
                if (self.goalUnit == "kgs") {
                    let goalPoint = ChartDataEntry(x: Double(index), y: Double(self.goal))
                    myGoalEntries.append(goalPoint)
                } else {
                    var num = Double(self.goal) / 2.20462
                    num = round(num * 10) / 10.0
                    let goalPoint = ChartDataEntry(x: Double(index), y: num)
                    myGoalEntries.append(goalPoint)
                }
            } else {
                if (self.goalUnit == "kgs" && self.weightButton.isEnabled) {
                    UserDefaults.standard.set("lbs", forKey: "Suffix")
                    var num = Double(self.goal) * 2.20462
                    num = round(num * 10) / 10.0
                    let goalPoint = ChartDataEntry(x: Double(index), y: num)
                    myGoalEntries.append(goalPoint)
                } else {
                    if (self.weightButton.isEnabled) {
                        UserDefaults.standard.set("lbs", forKey: "Suffix")
                    }
                    let goalPoint = ChartDataEntry(x: Double(index), y: Double(self.goal))
                    myGoalEntries.append(goalPoint)
                }
            }
            
            // EZPZ
            var i = 0
            while (i < self.standards.count) {
                var rounded = round(self.standards[i] * 10) / 10.0
                if (UserDefaults.standard.string(forKey: "Display Units") == "kgs" && self.weightButton.isEnabled) {
                    rounded /= 2.20462
                    rounded = round(rounded * 10) / 10.0
                }
                let point = ChartDataEntry(x: Double(index), y: rounded)
                standardsSets[i].append(point)
                i += 1
            }
            // determine if we add this data
            if (entryIndex < activity.count) {
                let entry = activity[entryIndex]
                let splitDates = entry[0].split(separator: "-")
                let newStrings = splitDates[1] + "/" + splitDates[2] + "/" + splitDates[0]
                if (newStrings == yearFormatter.string(from: time)) {
                    // entry = [date recorded, ORM]
                    let weight = entry[1]
                    let splitWeight = weight.split(separator: ".")
                    let wholeWeight = Int(splitWeight[0])!
                    let decimalWeight = Int(splitWeight[1])!
                    var overallWeight = Double(wholeWeight) + (Double(decimalWeight) / 100)
                    if (UserDefaults.standard.string(forKey: "Display Units") == "kgs" && self.weightButton.isEnabled) {
                        overallWeight /= 2.20462
                        overallWeight = round(overallWeight * 10) / 10.0
                    }
                    
                    let dataPoint = ChartDataEntry(x: Double(index), y: overallWeight)
                    myDataEntries.append(dataPoint)
                    entryIndex += 1
                    index -= 1
                } else {
                    time = Calendar.current.date(byAdding: .day, value: 1, to: time)!
                }
            } else {
                time = Calendar.current.date(byAdding: .day, value: 1, to: time)!
            }
            
            index += 1
        }
        
//        print(dataDates)
        
        let myDataSet = LineChartDataSet(entries: myDataEntries, label: "One Rep Maxes")
        myDataSet.colors = [UIColor(red: (237/255.0), green: (17/255.0), blue: (51/255.0), alpha: 1)]
        myDataSet.circleColors = [UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1)]
        myDataSet.drawValuesEnabled = false
        if (numDates >= 8) {
            myDataSet.drawCirclesEnabled = false
        }
        let myData = LineChartData(dataSet: myDataSet)
        let goalDataSet = LineChartDataSet(entries: myGoalEntries, label: "Goal")
        let beginnerDataSet = LineChartDataSet(entries: standardsSets[0], label: "Beginner")
        let noviceDataSet = LineChartDataSet(entries: standardsSets[1], label: "Novice")
        let intermediateDataSet = LineChartDataSet(entries: standardsSets[2], label: "Intermediate")
        let advancedDataSet = LineChartDataSet(entries: standardsSets[3], label: "Advanced")
        let eliteDataSet = LineChartDataSet(entries: standardsSets[4], label: "Elite")
        
        // setup and add goal set
        goalDataSet.colors = [UIColor.black]
        goalDataSet.drawCirclesEnabled = false
        goalDataSet.drawValuesEnabled = false
        goalDataSet.lineWidth = 3
        myData.addDataSet(goalDataSet)

        // add all other sets
        let sets = [beginnerDataSet, noviceDataSet, intermediateDataSet, advancedDataSet, eliteDataSet]
        let colors = [UIColor(red: (135/255.0), green: (32/255.0), blue: (239/255.0), alpha: 1), UIColor(red: (74/255.0), green: (127/255.0), blue: (245/255.0), alpha: 1), UIColor(red: (23/255.0), green: (172/255.0), blue: (3/255.0), alpha: 1), UIColor(red: (240.0/255.0), green: (166/255.0), blue: (0/255.0), alpha: 1), UIColor(red: (237/255.0), green: (17/255.0), blue: (51/255.0), alpha: 1)]
        index = 0
        while (index < sets.count) {
            sets[index].colors = [colors[index]]
            sets[index].drawCirclesEnabled = false
            sets[index].drawValuesEnabled = false
            sets[index].lineWidth = 2
            myData.addDataSet(sets[index])
            index += 1
        }

        self.progressChart.xAxis.valueFormatter = DefaultAxisValueFormatter { (value, axis) -> String in return "l" }
        self.progressChart.data = myData
        
        // styling for the graph
        self.progressChart.rightAxis.drawAxisLineEnabled = false
        self.progressChart.rightAxis.drawLabelsEnabled = false
        self.progressChart.rightAxis.drawGridLinesEnabled = false
        self.progressChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.progressChart.leftAxis.axisMinimum = 0
        self.progressChart.xAxis.spaceMin = 0.2
        self.progressChart.xAxis.spaceMax = 0.2
        self.progressChart.xAxis.granularityEnabled = true
        self.progressChart.xAxis.granularity = 1
        self.progressChart.doubleTapToZoomEnabled = false
        self.progressChart.pinchZoomEnabled = false
        
        if (numDates > 7) {
            self.progressChart.xAxis.labelCount = 8
        } else {
            self.progressChart.xAxis.labelCount = numDates
        }
        
        self.axisDates = dataDates
        
        self.progressChart.xAxis.valueFormatter = DefaultAxisValueFormatter { (value, axis) -> String in return self.labelHandler(index: Int(value), dates: dataDates) }
    }
    
    func refreshData() {
        self.updateGraph()
        self.personalBest = dbManager.getRecord(exercise: self.exercise)

        if (self.personalBest < 0) {
            self.personalBest = 0
        }
        self.myTableView.reloadData()
//        print(dbManager.getRecordsList())
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(highlight.dataSetIndex)
        var description = ""
        let units = UserDefaults.standard.string(forKey: "Display Units")!
        if (highlight.dataSetIndex == 0) { // USER DATA SET
            description = "Date: " + self.axisDates[Int(entry.x)] + "  ORM: "
            if (self.weightButton.isEnabled) {
                description += String(entry.y) + " " + units
            } else {
                description += String(Int(entry.y)) + " reps"
            }
        } else if (highlight.dataSetIndex == 1) { // GOAL SET
            if (self.weightButton.isEnabled) {
                description = "My Goal: " + String(entry.y) + " " + units
            } else {
                description += "My Goal: " + String(Int(entry.y)) + " reps"
            }
        } else { // STANDARDS
            let standardNames = ["Beginner", "Novice", "Intermediate", "Advanced", "Elite"]
            if (self.weightButton.isEnabled) {
                description = standardNames[highlight.dataSetIndex - 2] + " Standard: " + String(entry.y) + " " + units
            } else {
                description += standardNames[highlight.dataSetIndex - 2] + " Standard: " + String(Int(entry.y)) + " reps"
            }
        }
        
        self.activityDetailLabel.text = description
    }
    
    /*
        HELPER METHODS
     */
    
    func labelHandler(index: Int, dates: [String]) -> String {
        return dates[index]
    }
    
    
    @IBAction func goToSettings(_ sender: Any) {
        // get extra info on my exercise
        if (self.weightButton.isEnabled) {
            UserDefaults.standard.set("weights", forKey: "Exercise Type")
        } else {
            UserDefaults.standard.set("bodyweight", forKey: "Exercise Type")
        }
        let userExercises = dbManager.getUserExercises()
        if (userExercises.contains([self.exercise, "bodyweight"]) || userExercises.contains([self.exercise, "weightlifting"])) {
            UserDefaults.standard.set("custom", forKey: "Exercise Category")
        } else {
            UserDefaults.standard.set("regular", forKey: "Exercise Category")
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "editExercise")
        self.present(setupViewController, animated:true, completion:nil)
    }
    
    func getStandards() {
        let userWeightString = UserDefaults.standard.object(forKey: "User Weight") as! String
        print(userWeightString)
        var userWeight = Double(userWeightString.split(separator: " ")[0])!
        if (userWeightString.split(separator: " ")[1] == "kgs") {
            userWeight *= 2.20462
        }
//        print(userWeight)
        let userGender = UserDefaults.standard.string(forKey: "User Gender")!
        let userAge = UserDefaults.standard.integer(forKey: "User Age")
        self.standards = dbManager.getStrengthStandards(exercise: self.exercise, weight: Int(userWeight), gender: userGender, age: userAge)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.hideRecordActivity()
        self.hidePicker(self)
        self.view.endEditing(true)
    }
    
    @IBAction func changeTimeFrameOneWeek(_ sender: Any) {
        // update button looks
        var title = NSMutableAttributedString(string: "1 Week", attributes: self.redTextAttrs)
        self.timeFrameButtons[0].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Month", attributes: self.blackTextAttrs)
        self.timeFrameButtons[1].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "6 Months", attributes: self.blackTextAttrs)
        self.timeFrameButtons[2].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Year", attributes: self.blackTextAttrs)
        self.timeFrameButtons[3].setAttributedTitle(title, for: .normal)
        // modify time frame
        self.timeFrame = "-6 days"
        self.startTime = Calendar.current.date(byAdding: .day, value: -6, to: Date())!
        self.endTime = Date()
        // update graph
        self.updateGraph()
    }
    
    @IBAction func changeTimeFrameOneMonth(_ sender: Any) {
        // update button looks
        var title = NSMutableAttributedString(string: "1 Week", attributes: self.blackTextAttrs)
        self.timeFrameButtons[0].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Month", attributes: self.redTextAttrs)
        self.timeFrameButtons[1].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "6 Months", attributes: self.blackTextAttrs)
        self.timeFrameButtons[2].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Year", attributes: self.blackTextAttrs)
        self.timeFrameButtons[3].setAttributedTitle(title, for: .normal)
        // modify time frame
        self.timeFrame = "-1 month"
        self.startTime = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        self.endTime = Date()
        // update graph
        self.updateGraph()
    }
    
    @IBAction func changeTimeFramSixMonth(_ sender: Any) {
        // update button looks
        var title = NSMutableAttributedString(string: "1 Week", attributes: self.blackTextAttrs)
        self.timeFrameButtons[0].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Month", attributes: self.blackTextAttrs)
        self.timeFrameButtons[1].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "6 Months", attributes: self.redTextAttrs)
        self.timeFrameButtons[2].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Year", attributes: self.blackTextAttrs)
        self.timeFrameButtons[3].setAttributedTitle(title, for: .normal)
        // modify time frame
        self.timeFrame = "-6 months"
        self.startTime = Calendar.current.date(byAdding: .month, value: -6, to: Date())!
        self.endTime = Date()
        // update graph
        self.updateGraph()
    }
    
    @IBAction func changeTimeFrameOneYear(_ sender: Any) {
        // update button looks
        var title = NSMutableAttributedString(string: "1 Week", attributes: self.blackTextAttrs)
        self.timeFrameButtons[0].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Month", attributes: self.blackTextAttrs)
        self.timeFrameButtons[1].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "6 Months", attributes: self.blackTextAttrs)
        self.timeFrameButtons[2].setAttributedTitle(title, for: .normal)
        title = NSMutableAttributedString(string: "1 Year", attributes: self.redTextAttrs)
        self.timeFrameButtons[3].setAttributedTitle(title, for: .normal)
        // modify time frame
        self.timeFrame = "-1 year"
        self.startTime = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        self.endTime = Date()
        // update graph
        self.updateGraph()
    }
    
    @IBAction func recordActivity(_ sender: Any) {
        // set up dark background to fade in
        self.darkBackgroundHeight.constant = self.view.frame.height
        self.darkBackgroundWidth.constant = self.view.frame.width
        self.darkBackgroundView.frame.origin.x = self.view.frame.origin.x
        self.darkBackgroundView.frame.origin.y = self.view.frame.origin.y
        self.darkBackgroundView.alpha = 0
        
        // reset numbers
        self.repsButton.setTitle("5", for: .normal)
        if (self.weightButton.isEnabled) {
            self.weightButton.setTitle("200 lbs", for: .normal)
        }
        self.selectedUnit = "lbs"
        
        // show the record activity view
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.recordActivityView.frame.origin.y = self.view.frame.height / 2 - (self.recordActivityView.frame.height / 2)
            self.darkBackgroundView.alpha = 0.3
        }, completion: nil)
        self.recordBottomConstraint.constant = self.view.frame.height / 2 - (self.recordActivityView.frame.height / 2)
    }
    
    @IBAction func submitActivity(_ sender: Any) {
        // hide record activity view
        let orm = self.calculateORM()
        var ormNumber = Double(orm.split(separator: " ")[0])!
        // store all numbers as lbs so we can accurately compare
        if (orm.split(separator: " ").count > 1 && orm.split(separator: " ")[1] == "kgs") {
            ormNumber *= 2.20462
        }
        ormNumber = round(ormNumber * 10) / 10.0
        
//        print("ORM")
//        print(ormNumber)
        if (dbManager.getRecord(exercise: self.exercise) == -1.0) {
            dbManager.insertRecord(exercise: self.exercise, value: ormNumber)
        } else if (ormNumber > self.personalBest) {
            dbManager.setRecord(exercise: self.exercise, value: ormNumber)
        }
        
        let weightText = weightButton.title(for: .normal)
        let reps = Int(repsButton.title(for: .normal)!)!
        dbManager.addUserActivity(exercise: self.exercise, reps: reps, weight: weightText!, orm: ormNumber)
        self.refreshData()
        self.hideRecordActivity()
        self.hidePicker(self)
    }
    
    func calculateORM() -> String {
        // gather my data
        let weightText = weightButton.title(for: .normal)
        let weight = Double(weightText!.split(separator: " ")[0])!
        let units = String(weightText!.split(separator: " ")[1])
        let reps = Double(repsButton.title(for: .normal)!)!
        
        // perform calculation
        // Formula for ORM: (100 x weight) / (48.8 + (53.8 x e^(-0.075 x reps)))
        var ORM = (100.0 * weight)
        let secondHalf = (48.8 + (53.8 * pow(M_E,-0.075 * reps)))
        ORM /= secondHalf
        ORM = round(ORM * 10) / 10.0
        if (weightButton.isEnabled == false) {
            ORM = reps
            return String(Int(ORM))
        }
//        print(ORM)

        return String(ORM) + " " + units
    }
    
    func hideRecordActivity() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.recordActivityView.frame.origin.y = self.view.frame.height + 10
            self.darkBackgroundView.alpha = 0
        }, completion: {(finished: Bool) in
            self.darkBackgroundHeight.constant = 10
        })
        
        self.recordBottomConstraint.constant = -1 * self.view.frame.height / 2
    }
    
    @IBAction func preparePicker(_ sender: UIButton){
        self.isGoalSelected = false
        if (sender == self.repsButton) {
            self.numComponents = 1
            self.options = self.repsList
            self.selectedButton = self.repsButton
            self.dataPicker.reloadAllComponents()
            
            let selectedReps = self.repsButton.title(for: .normal)
            self.dataPicker.selectRow(self.options.firstIndex(of: selectedReps!)!, inComponent: 0, animated: false)
            
        } else if (sender == self.weightButton) {
            self.numComponents = 2
            self.options = self.weightList
            self.selectedButton = self.weightButton
            self.dataPicker.reloadAllComponents()
            
            let selectedWeight = String(self.weightButton.title(for: .normal)!.split(separator: " ")[0])
            let sselectedUnit = String(self.weightButton.title(for: .normal)!.split(separator: " ")[1])
            self.dataPicker.selectRow(self.options.firstIndex(of: selectedWeight)!, inComponent: 0, animated: false)
            self.dataPicker.selectRow(self.weightUnits.firstIndex(of: sselectedUnit)!, inComponent: 1, animated: false)
            
        }
        
        self.showPicker()
    }
    
    func goalClick() {
        self.isGoalSelected = true
        if (self.weightButton.isEnabled) {
            self.numComponents = 2
        } else {
            self.numComponents = 1
        }
        self.options = self.weightList
        
        let selectedWeight = String(self.goal)
//        print(selectedWeight)
        
        self.dataPicker.reloadAllComponents()
        self.dataPicker.selectRow(self.options.firstIndex(of: selectedWeight)!, inComponent: 0, animated: false)
        if (numComponents == 2) {
            self.dataPicker.selectRow(self.weightUnits.firstIndex(of: self.goalUnit)!, inComponent: 1, animated: false)
        }
        self.showPicker()
    }
    
    func setupPickerLists() {
        // clear previous data in it
        self.repsList = []
        self.weightList = []
        
        var index = 0
        while index < 100 {
            self.repsList.append(String(index))
            index += 1
        }
        index = 0
        while (index < 1000) {
            self.weightList.append(String(index))
            index += 1
        }
    }
    
    
//    @IBAction func goBack(_ sender: Any) {
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
//        self.present(setupViewController, animated:true, completion:nil)
//    }
    
    func doStyling() {
        // record activity button
        recordActivityButton.layer.borderWidth = 2
        recordActivityButton.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
        recordActivityButton.layer.cornerRadius = 15
        
        // update strengthLevel
//        strengthLevelView.layer.borderWidth = 1
//        changeStrengthCategoryView(level: 1)
        
        // record activity view
        self.recordActivityView.layer.cornerRadius = 15
        self.recordActivityView.layer.borderWidth = 1.5
        self.recordActivityView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    func changeStrengthCategoryView(level: Int, cell: BreakdownStrengthLevelTableViewCell) {
        if (level == 0) {
            cell.strengthLevelButton.layer.backgroundColor = UIColor.gray.cgColor
            cell.strengthLevelButton.layer.borderColor = UIColor.darkGray.cgColor
            cell.strengthLevelButton.setTitle("Untrained", for: .normal)
        } else if (level == 1) {
            cell.strengthLevelButton.layer.backgroundColor = UIColor(red: (135/255.0), green: (32/255.0), blue: (239/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.layer.borderColor = UIColor(red: (85/255.0), green: (14/255.0), blue: (157/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.setTitle("Beginner", for: .normal)
            
        } else if (level == 2) {
            cell.strengthLevelButton.layer.backgroundColor = UIColor(red: (74/255.0), green: (127/255.0), blue: (245/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.layer.borderColor = UIColor(red: (41/255.0), green: (81/255.0), blue: (172/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.setTitle("Novice", for: .normal)
            
        } else if (level == 3) {
            cell.strengthLevelButton.layer.backgroundColor = UIColor(red: (23/255.0), green: (172/255.0), blue: (3/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.layer.borderColor = UIColor(red: (15/255.0), green: (114/255.0), blue: (2.0/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.setTitle("Intermediate", for: .normal)
            
        } else if (level == 4) {
            cell.strengthLevelButton.layer.backgroundColor = UIColor(red: (240.0/255.0), green: (166/255.0), blue: (0/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.layer.borderColor = UIColor(red: (169.0/255.0), green: (118.0/255.0), blue: (3.0/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.setTitle("Advanced", for: .normal)
            
        } else if (level == 5) {
            cell.strengthLevelButton.layer.backgroundColor = UIColor(red: (237/255.0), green: (17/255.0), blue: (51/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
            cell.strengthLevelButton.setTitle("Elite", for: .normal)
        } else {
            cell.strengthLevelButton.layer.backgroundColor = UIColor.gray.cgColor
            cell.strengthLevelButton.layer.borderColor = UIColor.darkGray.cgColor
            cell.strengthLevelButton.setTitle("N/A", for: .normal)
        }
    }
    
    /*
        PICKER METHODS
     */
    @IBAction func hidePicker(_ sender: Any) {
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: 185)
        }, completion: nil)
    }
    
    func showPicker() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: -185)
        }, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return self.options.count
        }
        return 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return self.options[row]
        }
        return self.weightUnits[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (isGoalSelected) {
            if (component == 0) {
                self.goal = Int(options[row])!
                print(self.goal)
            } else {
                self.goalUnit = weightUnits[row]
            }
            let prevGoal = dbManager.getGoal(exercise: self.exercise)
            if (prevGoal == -1) {
                var goalNum = Double(self.goal)
                if (self.goalUnit == "kgs") {
                    goalNum *= 2.20462
                }
                dbManager.addToGoals(exercise: self.exercise, value: goalNum)
            } else {
                var goalNum = Double(self.goal)
                if (self.goalUnit == "kgs") {
                    goalNum *= 2.20462
                }
                dbManager.updateGoal(exercise: self.exercise, value: goalNum)
            }
//            print(dbManager.getGoal(exercise: self.exercise))
            self.myTableView.reloadData()
            self.updateGraph()
        } else if (numComponents == 1) {
            selectedButton.setTitle(options[row], for: .normal)
        } else {
            if (component == 0) {
                selectedButton.setTitle(options[row] + " " + selectedUnit, for: .normal)
            } else {
                selectedUnit = weightUnits[row]
                if (selectedButton.title(for: .normal) == "") {
                    selectedButton.setTitle("150 " + selectedUnit, for: .normal)
                } else {
                    let curWeight = String(self.selectedButton.title(for: .normal)!.split(separator: " ")[0])
                    selectedButton.setTitle(curWeight + " " + selectedUnit, for: .normal)
                }
            }
            
        }
    }
    
    /*
        TABLE VIEW METHODS
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell : BreakdownORMTableViewCell = myTableView.dequeueReusableCell(withIdentifier: "breakdownCell", for: indexPath) as! BreakdownORMTableViewCell
            // content
            cell.imageIcon.image = UIImage(named: "dumbbell")
            if (self.weightButton.isEnabled) {
                var num = self.personalBest
                if (UserDefaults.standard.string(forKey: "Display Units") == "kgs") {
                    num /= 2.20462
                    num = round(num * 10) / 10.0
                }
                cell.weightLabel.text = String(num) + " " + UserDefaults.standard.string(forKey: "Display Units")!
            } else {
                cell.weightLabel.text = String(Int(self.personalBest)) + " reps"
            }
            
            // styling
            cell.cellImageView.layer.borderWidth = 1
            cell.cellImageView.layer.borderColor = UIColor.black.cgColor
            cell.cellImageView.layer.cornerRadius = 28
            cell.cellImageView.clipsToBounds = true
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.gray.cgColor
            cell.mainView.layer.cornerRadius = 10
            
            return cell
        } else if (indexPath.row == 1) {
            let cell : BreakdownGoalTableViewCell = myTableView.dequeueReusableCell(withIdentifier: "breakdownGoalCell", for: indexPath) as! BreakdownGoalTableViewCell
            
            // content
            cell.imageIcon.image = UIImage(named: "medal")
            if (self.weightButton.isEnabled) {
                cell.weightButton.setTitle(String(self.goal) + " " + self.goalUnit, for: .normal)
            } else {
                print("oh")
                cell.weightButton.setTitle(String(self.goal) + " reps", for: .normal)
                UserDefaults.standard.set("reps", forKey: "Suffix")
            }
            
            // styling
            cell.cellImageView.layer.borderWidth = 1
            cell.cellImageView.layer.borderColor = UIColor.black.cgColor
            cell.cellImageView.layer.cornerRadius = 24
            cell.cellImageView.clipsToBounds = true
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.gray.cgColor
            cell.mainView.layer.cornerRadius = 10
            
            // onclick
            cell.onClick = self.goalClick
            
            return cell
        } else {
            let cell : BreakdownStrengthLevelTableViewCell = myTableView.dequeueReusableCell(withIdentifier: "breakdownSLCell", for: indexPath) as! BreakdownStrengthLevelTableViewCell
            
            // content
            cell.imageIcon.image = UIImage(named: "chart")
            
            // styling
            cell.cellImageView.layer.borderWidth = 1
            cell.cellImageView.layer.borderColor = UIColor.black.cgColor
            cell.cellImageView.layer.cornerRadius = 24
            cell.cellImageView.clipsToBounds = true
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = UIColor.gray.cgColor
            cell.mainView.layer.cornerRadius = 10
            cell.strengthLevelButton.layer.borderWidth = 1
            cell.strengthLevelButton.layer.cornerRadius = 15
            
            self.modifyCellStrength(cell: cell)
            
            return cell
        }
    }
    
    func modifyCellStrength(cell: BreakdownStrengthLevelTableViewCell) {
        let weight = self.personalBest
        
        if (self.standards.count == 1) {
            self.changeStrengthCategoryView(level: -1, cell: cell)
        } else {
            var index = 0
            while (index < self.standards.count) {
                if (weight < self.standards[index]) {
                    break
                }
                index += 1
            }
            
            self.changeStrengthCategoryView(level: index, cell: cell)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.myTableView.frame.height / 3.1
    }

}
