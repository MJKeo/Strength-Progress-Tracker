//
//  GoalsViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/30/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit
import Charts

class GoalsViewController: UIViewController {

    @IBOutlet weak var lineChart: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var myData: [ChartDataEntry] = []
        var extra: [ChartDataEntry] = []
        
        var index = 0
        while (index < 5) {
            index += 1
            let entry = ChartDataEntry(x: Double(index), y: Double(index))
            let entry2 = ChartDataEntry(x: Double(index), y: 15)
            myData.append(entry)
            extra.append(entry2)
        }
        
        let myDataSet = LineChartDataSet(entries: myData, label: "One Rep Maxes")
        let myDataSet2 = LineChartDataSet(entries: extra, label: "Goal")
        myDataSet2.colors = [UIColor(red: (10/255.0), green: (225/255.0), blue: (51/255.0), alpha: 1)]
        myDataSet2.circleColors = [UIColor(red: (237/255.0), green: (17/255.0), blue: (51/255.0), alpha: 0)]
        myDataSet2.drawValuesEnabled = false
        myDataSet2.drawCirclesEnabled = false
        myDataSet.colors = [UIColor(red: (237/255.0), green: (17/255.0), blue: (51/255.0), alpha: 1)]
        myDataSet.circleColors = [UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1)]
        let myDat = LineChartData(dataSet: myDataSet)
        myDat.addDataSet(myDataSet2)
        
        self.lineChart.data = myDat
//        self.lineChart.invert
        self.lineChart.rightAxis.drawAxisLineEnabled = false
        self.lineChart.rightAxis.drawLabelsEnabled = false
        self.lineChart.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.lineChart.xAxis.drawGridLinesEnabled = false
        self.lineChart.leftAxis.drawGridLinesEnabled = false
        self.lineChart.xAxis.drawAxisLineEnabled = false
        
//        self.lineChart.xAxis.labelCount = chartXVals.count
//        self.lineChart.xAxis.valueFormatter = DefaultAxisValueFormatter { (value, axis) -> String in return chartXVals[Int(value)] }

        
        print(dbManager.getRecentActivity(exercise: "Bench Press"))
    }
    

    
}
