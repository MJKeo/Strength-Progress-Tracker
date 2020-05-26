//
//  RecordActivityViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/18/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class RecordActivityViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var exerciseView: UIView!
    @IBOutlet weak var exerciseButton: UIButton!
    
    
    // picker
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var dataPicker: UIPickerView!
    
    
    // Input Buttons
    @IBOutlet weak var repsButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    
    // popup screen
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var popupORM: UILabel!
    @IBOutlet weak var popupButton: UIButton!
    @IBOutlet weak var popupPB: UILabel!
    @IBOutlet weak var viewFinesseStuff: UIView!
    @IBOutlet weak var popupTopConstraint: NSLayoutConstraint!
    
    // miscellaneous screen items
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var centeringView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var darkBackground: UIView!
    
    
    
    // variables
    let weightUnits = ["lbs","kgs"]
    var repsOptions: [String] = []
    var weightOptions: [String] = []
    var exerciseList: [[String]] = []
    var exerciseNames: [String] = []
    var options: [String] = []
    var numComponents = 1
    var selectedUnit = "lbs"
    var timer: Timer = Timer()
    var skipIteration = true
    var userExercises: [String] = []
    
    var selectedButton: UIButton!
    
    /*
        SETUP FUNCTIONS
     */
    override func viewDidLoad() {
        super.viewDidLoad()

        // Make this file the picker source
        dataPicker.delegate = self
        dataPicker.dataSource = self
        
        // handle styling (only needs to be done once)
        exerciseView.layer.cornerRadius = 15
        exerciseView.layer.borderWidth = 1
        exerciseView.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
        
        popupButton.layer.cornerRadius = 15
        popupButton.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
        popupButton.layer.borderWidth = 1
        
        popupView.layer.cornerRadius = 10
        popupView.layer.borderColor = UIColor.gray.cgColor
        popupView.layer.borderWidth = 1
        
        // lets the user tap anywhere to dismiss the picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipe)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hidePicker(exerciseButton as Any)
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
         // starting animation so it fades in
        self.titleLabel.alpha = 0
        self.centeringView.alpha = 0
        self.submitBtn.alpha = 0
        self.popupPB.alpha = 1
        
        self.popupView.frame.origin.y = self.view.frame.height
        self.popupView.frame.origin.x = (self.view.frame.width / 2) - (self.popupView.frame.width / 2)
        self.darkBackground.frame.origin.y = self.view.frame.height
        
        self.skipIteration = true
        
        self.userExercises = UserDefaults.standard.object(forKey: "User Exercise List") as! [String]
        
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
            self.centeringView.alpha = 1
            self.submitBtn.alpha = 1
        }, completion: nil)
        
        // set up lists (I have it here because the list may be modified in between uses)
        createLists()
        
        // set my titles to their default values
        setDefaults()
    }
    
    func createLists() {
        // reset lists first
        self.repsOptions = []
        self.weightOptions = []
        self.exerciseList = []
        self.exerciseNames = []
        
        var index = 0
        while (index < 1000) {
            if (index < 100) {
                repsOptions.append(String(index))
            }
            weightOptions.append(String(index))
            index += 1
        }
        exerciseList = dbManager.getExercises()
        let userExercises = dbManager.getUserExercises()
        for item in userExercises {
            exerciseList.append(item)
        }
        print(exerciseList)
        exerciseList.sort(by: {$0[0] < $1[0]})
        index = 0
        while (index < exerciseList.count) {
            if (self.userExercises.contains(exerciseList[index][0])) {
                exerciseNames.append(exerciseList[index][0])
            }
            index += 1
        }
    }
    
    func setDefaults() {
        self.repsButton.setTitle("5", for: .normal)
        self.weightButton.setTitle("200 lbs", for: .normal)
        self.weightButton.isEnabled = true
        self.weightButton.setTitleColor(UIColor.black, for: .normal)
        self.exerciseButton.setTitle("Select Exercise", for: .normal)
    }
    
    /*
        PICKER FUNCTIONS
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (numComponents == 1) {
            selectedButton.setTitle(options[row], for: .normal)
            // make button gray if we're using bodyweight
            if (selectedButton == exerciseButton) {
                if (exerciseList.firstIndex(of: [options[row],"bodyweight"]) == nil) {
                    self.weightButton.isEnabled = true
                    self.weightButton.setTitleColor(UIColor.black, for: .normal)
                } else {
                    let userWeight = UserDefaults.standard.object(forKey: "User Weight")
                    self.weightButton.setTitle(userWeight as? String, for: .normal)
                    self.weightButton.setTitleColor(UIColor.gray, for: .normal)
                    self.weightButton.isEnabled = false
                }
            }
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return options.count
        }
        return 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return numComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return options[row]
        }
        return weightUnits[row]
    }
    
    @IBAction func changePickerData(_ sender: UIButton) {
        var curVal = ""
        if (sender == exerciseButton) {
            options = exerciseNames
            numComponents = 1
            selectedButton = exerciseButton
            curVal = self.exerciseButton.title(for: .normal)!
            if (curVal == "Select Exercise") {
                curVal = exerciseNames[0]
                exerciseButton.setTitle(exerciseNames[0], for: .normal)
            }
            dataPicker.reloadAllComponents()
            
        } else if (sender == repsButton) {
            options = repsOptions
            numComponents = 1
            selectedButton = repsButton
            curVal = self.repsButton.title(for: .normal)!
            dataPicker.reloadAllComponents()
            
        } else {
            options = weightOptions
            numComponents = 2
            selectedButton = weightButton
            curVal = String(self.weightButton.title(for: .normal)!.split(separator: " ")[0])
            dataPicker.reloadAllComponents()
            dataPicker.selectRow(weightUnits.firstIndex(of: selectedUnit)!, inComponent: 1, animated: false)
            
        }
        dataPicker.selectRow(options.firstIndex(of: curVal)!, inComponent: 0, animated: false)
        showPicker()
    }
    
    @IBAction func hidePicker(_ sender: Any) {
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: 140 + ((self.tabBarController?.tabBar.frame.height)!))
        }, completion: nil)
    }
    
    func showPicker() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: -140 - ((self.tabBarController?.tabBar.frame.height)!))
        }, completion: nil)
    }
    
    /*
        Extra functionality
     */
    @IBAction func submitActivity(_ sender: Any) {
        if (exerciseButton.title(for: .normal) == "Select Exercise") {
            return
        }
        let orm = calculateOrm()
        var ormNumber = Double(orm.split(separator: " ")[0])!
        // store all numbers as lbs so we can accurately compare
        if (orm.split(separator: " ").count > 1 && orm.split(separator: " ")[1] == "kgs") {
            ormNumber *= 2.20462
        }
        
        self.popupORM.text = "ORM: " + orm
        
        let currentBest = dbManager.getRecord(exercise: exerciseButton.title(for: .normal)!)
        self.popupTopConstraint.constant = 0
        if (currentBest == -1.0) {
            dbManager.insertRecord(exercise: exerciseButton.title(for: .normal)!, value: ormNumber)
        } else if (ormNumber > currentBest) {
            dbManager.setRecord(exercise: exerciseButton.title(for: .normal)!, value: ormNumber)
        } else {
            self.popupPB.alpha = 0
            self.popupTopConstraint.constant = (self.viewFinesseStuff.frame.height / 2) - (self.popupORM.frame.height / 2)
        }
        
        // causes delay to let the animation run
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.animatePopup), userInfo: nil, repeats: true)
        
        // send data to be stored in database
        let exercise = exerciseButton.title(for: .normal)!
        let reps = Int(repsButton.title(for: .normal)!)!
        let weightText = weightButton.title(for: .normal)!
        dbManager.addUserActivity(exercise: exercise, reps: reps, weight: weightText, orm: ormNumber)
    }
    
    @objc func animatePopup() {
        if (skipIteration == false) {
            // prepare for animation
            self.darkBackground.frame.origin.x = self.view.frame.origin.x
            self.darkBackground.frame.origin.y = self.view.frame.origin.y
            self.darkBackground.alpha = 0
            
            // animate popup
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.darkBackground.alpha = 0.4
                self.popupView.frame.origin.y = (self.view.frame.height / 2) - (self.popupView.frame.height / 2)
            }, completion: nil)
            timer.invalidate()
        } else {
            skipIteration = false
        }
    }
    
    @IBAction func test(_ sender: Any) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.darkBackground.alpha = 0
            self.popupView.frame.origin.y = self.view.frame.height
        }, completion: {(finished: Bool) in
            self.changeView()
        })
    }
    
    func changeView() {
        self.tabBarController?.selectedIndex = 0
    }
    
    func calculateOrm() -> String {
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
        print(ORM)

        return String(ORM) + " " + units
    }

}
