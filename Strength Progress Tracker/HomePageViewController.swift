//
//  HomePageViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/12/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit
import Charts

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, ChartViewDelegate {
    // Recent activity stuff
    @IBOutlet weak var recentExerciseLabel: UILabel!
    @IBOutlet weak var recentGraph: LineChartView!
    @IBOutlet weak var noActivityLabel: UILabel!
    
    // closest goal
    @IBOutlet weak var closestGoalButton: UIButton!
    
    // Collection View
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    @IBOutlet weak var exerciseCVHeight: NSLayoutConstraint!
    
    // variables
    var userExerciseList: [String] = ["ONE", "TWO", "THREE"]
    var exerciseList: [[String]] = []
    var closestExercise = ""
    var mostRecentExercise = ""
    var activity: [[String]] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(dbManager.getUserExercises())
        print(dbManager.getRecordsList())
        print(dbManager.getGoalsList())
        
        exerciseCollectionView.delegate = self
        exerciseCollectionView.dataSource = self

        self.userExerciseList = UserDefaults.standard.object(forKey: "User Exercise List") as! [String]
        self.exerciseList = dbManager.getExercises()
        
        let userExercises = dbManager.getUserExercises()
        for exercise in userExercises {
            self.exerciseList.append(exercise)
        }
        
        self.recentGraph.delegate = self
        
        let itemSize = exerciseCollectionView.frame.width / 3.4
        // update height of my view to account for the items
        var numRows = 0
        if ((userExerciseList.count + 1) % 3 == 0) {
            numRows = (userExerciseList.count + 1) / 3
        } else {
//            print("yeah")
            numRows = (userExerciseList.count + 1) / 3 + 1
        }
        
//        print(numRows)
        exerciseCVHeight.constant = (itemSize + 15) * CGFloat(numRows)
        
        // set layout for "my lifts" collection view
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 1, bottom: 5, right: 1)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        exerciseCollectionView.collectionViewLayout = layout

        // get that goal thing set up
        self.getClosestGoal()
        
        // setup my graph
        self.mostRecentExercise = dbManager.getMostRecentExercise()
        if (self.mostRecentExercise == "") {
            self.recentExerciseLabel.alpha = 0
            self.recentGraph.alpha = 0
            self.noActivityLabel.alpha = 1
        } else {
            self.recentExerciseLabel.alpha = 1
            self.recentGraph.alpha = 1
            self.recentExerciseLabel.text = self.mostRecentExercise
            self.noActivityLabel.alpha = 0
            updateGraph()
        }
        
        doStyling()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.mostRecentExercise = dbManager.getMostRecentExercise()
        if (self.mostRecentExercise == "") {
            self.recentExerciseLabel.alpha = 0
            self.recentGraph.alpha = 0
            self.noActivityLabel.alpha = 1
        } else {
            self.recentExerciseLabel.alpha = 1
            self.recentGraph.alpha = 1
            self.recentExerciseLabel.text = self.mostRecentExercise
            self.noActivityLabel.alpha = 0
            updateGraph()
        }
    }
    
    func viewExerciseBreakdown(exercise: String) {
        // this is where I deal with changing the page to the appropriate exercise
        // TO BE IMPLEMENTED
        print(exercise)
        UserDefaults.standard.set(exercise, forKey: "Selected Exercise")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "exerciseBreakdown")
        self.present(setupViewController, animated:true, completion:nil)
    }
    
    func addExercise() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "addExerciseVC")
        self.present(setupViewController, animated:true, completion:nil)
    }
    
    func getClosestGoal() {
        let goalList = dbManager.getGoalsList()
        var maxDiff = 3000
        var closestGoal = ["test", 1231231231.0] as [Any]
        for set in goalList {
            let exerciseName = set[0] as! String
            let best = dbManager.getRecord(exercise: exerciseName)
            let goalNum = Int(set[1] as! Double)
            let difference = goalNum - Int(best)
            if (difference > 0 && difference < maxDiff) {
                maxDiff = difference
                closestGoal = set
            }
        }
        if (closestGoal[1] as! Double == 1231231231.0) {
            self.closestGoalButton.alpha = 0
        } else {
            self.closestExercise = closestGoal[0] as! String
            print("ape")
            print(self.exerciseList)
            if (exerciseList.firstIndex(of: [self.closestExercise,"bodyweight"]) != nil) {
                let text = closestGoal[0] as! String + " " + String(Int(closestGoal[1] as! Double)) + " reps"
                self.closestGoalButton.setTitle(text, for: .normal)
            } else {
                var num = closestGoal[1] as! Double
                if (UserDefaults.standard.string(forKey: "Display Units") == "kgs") {
                    num /= 2.20462
                }
                num = round(num * 10) / 10.0
                let text = closestGoal[0] as! String + " " + String(num) + " " + UserDefaults.standard.string(forKey: "Display Units")!
                self.closestGoalButton.setTitle(text, for: .normal)
            }
        }
    }
    
    @IBAction func clickedClosestGoal(_ sender: Any) {
        if (self.closestGoalButton.title(for: .normal) == "Button") {
            return
        }
        self.viewExerciseBreakdown(exercise: self.closestExercise)
    }
    
    func updateGraph() {
        self.activity = dbManager.getRecentActivity(exercise: self.mostRecentExercise, timeFrame: "-6 days")
        print(self.activity)
        
        var myDataEntries: [ChartDataEntry] = []
        var dataDates: [String] = []
        var myGoalEntries: [ChartDataEntry] = []
        
        var standardsSets: [[ChartDataEntry]] = [[],[],[],[],[]]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "MM/dd/yyyy"
        
        let endTimeString = yearFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        var startTime = Calendar.current.date(byAdding: .day, value: -6, to: Date())
        
        var tiem = startTime!
        var numDates = 0
        while(yearFormatter.string(from: tiem) != endTimeString) {
//            print(formatter.string(from: tiem))
            tiem = Calendar.current.date(byAdding: .day, value: 1, to: tiem)!
            numDates += 1
        }
        
        
        var index = 0
        var entryIndex = 0
        var time = startTime!
//        print(endTimeString)
        while (yearFormatter.string(from: time) != endTimeString) {
            // add date
            if (!dataDates.contains(formatter.string(from: time))) {
                dataDates.append(formatter.string(from: time))
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
                    if (UserDefaults.standard.string(forKey: "Display Units") == "kgs") {
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

        self.recentGraph.xAxis.valueFormatter = DefaultAxisValueFormatter { (value, axis) -> String in return "l" }
        self.recentGraph.data = myData
        
        // styling for the graph
        self.recentGraph.rightAxis.drawAxisLineEnabled = false
        self.recentGraph.rightAxis.drawLabelsEnabled = false
        self.recentGraph.rightAxis.drawGridLinesEnabled = false
        self.recentGraph.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.recentGraph.leftAxis.axisMinimum = 0
        self.recentGraph.xAxis.spaceMin = 0.5
        self.recentGraph.xAxis.spaceMax = 0.5
        self.recentGraph.xAxis.granularityEnabled = true
        self.recentGraph.xAxis.granularity = 1
        self.recentGraph.doubleTapToZoomEnabled = false
        self.recentGraph.pinchZoomEnabled = false
        
        print(numDates)
        self.recentGraph.xAxis.labelCount = numDates
        self.recentGraph.xAxis.valueFormatter = DefaultAxisValueFormatter { (value, axis) -> String in return self.labelHandler(index: Int(value), dates: dataDates) }
    }
    
    func labelHandler(index: Int, dates: [String]) -> String {
        return dates[index]
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        self.viewExerciseBreakdown(exercise: self.recentExerciseLabel.text!)
    }
    
    func doStyling() {
        self.closestGoalButton.layer.cornerRadius = 15
        self.closestGoalButton.layer.borderWidth = 2
        self.closestGoalButton.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
    }
    

    /*
        COLLECTION VIEW METHODS
     */
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let numItems = userExerciseList.count + 1
        if (numItems % 3 == 0) {
            return numItems / 3
        } else {
            return numItems / 3 + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let index = section * 3
        if (userExerciseList.count + 1 - index > 3) {
            return 3
        } else {
            return userExerciseList.count + 1 - index
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellNumber = indexPath.row + (indexPath.section * 3)
        if (cellNumber == userExerciseList.count) {
            // get cell
            let cell: AddExerciseCollectionViewCell =  exerciseCollectionView.dequeueReusableCell(withReuseIdentifier: "addExerciseButton", for: indexPath) as! AddExerciseCollectionViewCell
            
            // modify styling
            cell.mainView.layer.borderColor = UIColor(red: (207/255.0), green: (41/255.0), blue: (29/255.0), alpha: 1).cgColor
            cell.mainView.layer.borderWidth = 2
            cell.mainView.layer.cornerRadius = 15
            
            // add onclick
            cell.onClick = addExercise
            return cell
        } else {
            // get cell
            let cell : ExerciseCollectionViewCell = exerciseCollectionView.dequeueReusableCell(withReuseIdentifier: "exerciseCell", for: indexPath) as! ExerciseCollectionViewCell
            
            // modify styling
            cell.cellView.layer.borderColor = UIColor(red: (207/255.0), green: (41/255.0), blue: (29/255.0), alpha: 1).cgColor
            cell.cellView.layer.borderWidth = 2
            cell.cellView.layer.cornerRadius = 15
            
            // edit attributes
            cell.cellName?.text = userExerciseList[cellNumber]
            cell.onClick = self.viewExerciseBreakdown
            let tempList = dbManager.getExercises()
            if (tempList.contains([userExerciseList[cellNumber], "bodyweight"]) || tempList.contains([userExerciseList[cellNumber], "weights"])) {
                cell.cellImage.image = UIImage(named: userExerciseList[cellNumber])
            } else {
                cell.cellImage.image = UIImage(named: "custom")
            }
            
            return cell
        }
    }

}
