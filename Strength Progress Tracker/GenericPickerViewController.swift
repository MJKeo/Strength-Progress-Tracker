//
//  GenericPickerViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/16/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class GenericPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var myList: [String] = []
    var reference: ORMViewController
    var numSections = 1
    var secondList = ["lbs","kgs"]
    var userWeight = (UserDefaults.standard.object(forKey: "User Weight") as? String)!.split(separator: " ")
    var selectedFirstList = String((UserDefaults.standard.object(forKey: "User Weight") as? String)!.split(separator: " ")[0])
    var selectedSecondList = String((UserDefaults.standard.object(forKey: "User Weight") as? String)!.split(separator: " ")[1])
    
    init(controller: ORMViewController) {
        self.reference = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func printlist() {
        for item in myList {
            print(item)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (numSections == 1) {
            reference.updateMyButtons(value: myList[row])
        } else {
            if (component == 0) {
                selectedFirstList = myList[row]
            } else {
                selectedSecondList = secondList[row]
            }
            reference.updateMyButtons(value: selectedFirstList + " " + selectedSecondList)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return myList[row]
        } else {
            return secondList[row]
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numSections
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return myList.count
        } else {
            return 2
        }
    }

}
