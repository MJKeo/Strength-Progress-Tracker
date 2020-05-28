//
//  ORMViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/16/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class ORMViewController: UIViewController {

    // main views
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    // personal info buttons
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    
    // reps and weight button
    @IBOutlet weak var liftRepsButton: UIButton!
    @IBOutlet weak var liftWeightButton: UIButton!
    @IBOutlet weak var exerciseButton: UIButton!
    @IBOutlet weak var calculateButton: UIButton!
    
    
    // Strength standards views + texts
    @IBOutlet var strengthStandardsViews: [UIView]!
    @IBOutlet var strengthStandardsTexts: [UILabel]!
    @IBOutlet weak var mainStandardsView: UIStackView!
    
    // strength category label
    @IBOutlet weak var strengthCategoryLabel: UILabel!
    @IBOutlet weak var strengthCategoryView: UIView!
    
    // ORM Label
    @IBOutlet weak var ORMLabel: UILabel!
    @IBOutlet weak var repsView: UIButton!
    
    // how did we get this button
    @IBOutlet weak var questionButton: UIButton!
    @IBOutlet weak var optionsPicker: UIPickerView!
    @IBOutlet weak var optionsView: UIView!
    
    // extra vriables
    @IBOutlet weak var titleLabel: UILabel!
    
    // picker variables
    var gtvc: GenericPickerViewController?
    var ageList: [String] = []
    var weightList: [String] = []
    var genderList: [String] = []
    var exerciseList: [[String]] = []
    var exerciseNames: [String] = []
    var selectedButton: UIButton!
    
    // how did we get this?
    @IBOutlet weak var howDidWeGetThisView: UIView!
    @IBOutlet weak var hdwgtBottom: NSLayoutConstraint!
    @IBOutlet weak var darkBackground: UIView!
    @IBOutlet weak var darkBGHeight: NSLayoutConstraint!
    @IBOutlet weak var darkBGWidth: NSLayoutConstraint!
    
    /*
        SETUP FUNCTIONS
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // using a class GenericPickerViewController to deal with the many pickers
        gtvc = GenericPickerViewController(controller: self)
        optionsPicker.delegate = gtvc
        optionsPicker.dataSource = gtvc
        
        // visual styling (only needs to be done once)
        doStyling()
        
        // lets the user tap anywhere to dismiss the picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipe)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hidePicker(ageButton as Any)
        hideHowDidWe()
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // hide everything so it can animate back in later
        self.topView.alpha = 0
        self.bottomView.alpha = 0
        self.ORMLabel.alpha = 0
        self.strengthCategoryView.alpha = 0
        self.mainStandardsView.alpha = 0
        self.titleLabel.alpha = 0
        self.hdwgtBottom.constant = -632
        
        // populate user info into appropriate buttons
        self.weightButton.setTitle(UserDefaults.standard.object(forKey: "User Weight") as? String, for: .normal)
        self.ageButton.setTitle(UserDefaults.standard.object(forKey: "User Age") as? String, for: .normal)
        self.genderButton.setTitle(UserDefaults.standard.object(forKey: "User Gender") as? String, for: .normal)
        
        // repopulate my lists (must be done on viewdidappear)
        setupPickerLists()
        
        // animate everything into view
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut, animations: {
            self.topView.alpha = 1
            self.titleLabel.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
            self.bottomView.alpha = 1
        }, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.exerciseButton.setTitle("Select Exercise", for: .normal)
        self.liftRepsButton.setTitle("5", for: .normal)
        self.liftWeightButton.setTitle("200 lbs", for: .normal)
        hideHowDidWe()
    }
    
    func doStyling() {
        // HDWGT View
        self.howDidWeGetThisView.layer.borderColor = UIColor.black.cgColor
        self.howDidWeGetThisView.layer.borderWidth = 1
        self.howDidWeGetThisView.layer.cornerRadius = 10
        
        // calculate button
        self.calculateButton.layer.borderWidth = 1
        self.calculateButton.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
        self.calculateButton.backgroundColor = UIColor(red: (207/255.0), green: (41/255.0), blue: (29/255.0), alpha: 1)
        
        // put borders on personal info buttons
        self.weightButton.layer.borderWidth = 1
        self.weightButton.layer.borderColor = UIColor.darkGray.cgColor
        self.weightButton.layer.cornerRadius = 5
        
        self.ageButton.layer.borderWidth = 1
        self.ageButton.layer.borderColor = UIColor.darkGray.cgColor
        self.ageButton.layer.cornerRadius = 5
        
        self.genderButton.layer.borderWidth = 1
        self.genderButton.layer.borderColor = UIColor.darkGray.cgColor
        self.genderButton.layer.cornerRadius = 5
        
        self.exerciseButton.layer.borderWidth = 1
        self.exerciseButton.layer.borderColor = UIColor.darkGray.cgColor
        self.exerciseButton.layer.cornerRadius = 5
        
        // standards borders
        for item in strengthStandardsViews {
            item.layer.borderWidth = 1
            item.layer.borderColor = UIColor.black.cgColor
        }
        
        // question button borders
        self.questionButton.layer.borderWidth = 1
        self.questionButton.layer.borderColor = UIColor.darkGray.cgColor
        self.questionButton.layer.cornerRadius = 15
        
        self.strengthCategoryView.layer.borderWidth = 1
        self.strengthCategoryView.layer.borderColor = UIColor(red: (169.0/255.0), green: (118.0/255.0), blue: (3.0/255.0), alpha: 1).cgColor
        self.strengthCategoryView.layer.cornerRadius = 15
        
        // borders around my main views
        topView.layer.cornerRadius = 10
        topView.layer.borderWidth = 1
        topView.layer.borderColor = UIColor.lightGray.cgColor
        
        bottomView.layer.cornerRadius = 10
        bottomView.layer.borderWidth = 1
        bottomView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setupPickerLists() {
        // clear previous data in it
        self.ageList = []
        self.weightList = []
        self.exerciseNames = []
        
        var index = 0
        while index < 100 {
            ageList.append(String(index))
            index += 1
        }
        index = 0
        while (index < 1000) {
            weightList.append(String(index))
            index += 1
        }
        genderList = ["male","female"]
        
        exerciseList = dbManager.getExercises()
        for exercise in exerciseList {
            exerciseNames.append(exercise[0])
        }
    }
    
    /*
        CALCULATIONS AND UPDATE METHODS
     */
    @IBAction func calculateORM(_ sender: Any) {
        self.hidePicker(self)
        var mustConvertBack = false //  in case they used KG
        let exercise = self.exerciseButton.title(for: .normal)!
        if (exercise == "Select Exercise") {
            return
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.5, options: .curveEaseOut, animations: {
            self.ORMLabel.alpha = 0
            self.strengthCategoryView.alpha = 0
            for standard in self.strengthStandardsTexts {
                standard.alpha = 0
            }
        }, completion: nil)
        
        let reps = Double(self.liftRepsButton.title(for: .normal)!)!
        var weight = Double(self.liftWeightButton.title(for: .normal)!.split(separator: " ")[0])!
        if (self.liftWeightButton.title(for: .normal)!.split(separator: " ")[1] == "kgs") {
            weight *= 2.20462
            mustConvertBack = true
        }
        var userWeight = Double(self.weightButton.title(for: .normal)!.split(separator: " ")[0])!
        if (self.weightButton.title(for: .normal)!.split(separator: " ")[1] == "kgs") {
            userWeight *= 2.20462
        }
        
//         Formula for ORM: (100 x weight) / (48.8 + (53.8 x e^(-0.075 x reps)))
        var ORM = (100.0 * weight)
        let secondHalf = (48.8 + (53.8 * pow(M_E,-0.075 * reps)))
        ORM /= secondHalf
        ORM = round(ORM * 10) / 10.0
        print(ORM)
        if (self.liftWeightButton.isEnabled == false) {
            ORM = reps
        }
        let strengthStandards = dbManager.getStrengthStandards(exercise: exercise, weight: Int(userWeight), gender: self.genderButton.title(for: .normal)!, age: Int(self.ageButton.title(for: .normal)!)!)
        var index = 0
        while (index < strengthStandards.count) {
            print(ORM)
            print(strengthStandards[index])
            if (ORM < strengthStandards[index]) {
                changeStrengthCategoryView(level: index - 1)
                break
            } else if (index == strengthStandards.count - 1) {
                changeStrengthCategoryView(level: index)
            }
            index += 1
        }
        
        // update my labels
        var unit = " lbs"
        if (mustConvertBack) {
            ORM /= 2.20462
            unit = " kgs"
            ORM = round(ORM * 10) / 10.0
            
        }
        if (self.liftWeightButton.isEnabled == false) {
            ORM = reps
            unit = " reps"
            ORMLabel.text = String(Int(ORM)) + unit
        } else {
            ORMLabel.text = String(ORM) + unit
        }
        
        
        //update strength standards
        index = 0
        while (index < strengthStandardsTexts.count) {
            var amount = 0.0
            if (mustConvertBack && unit == " kgs") {
                amount = strengthStandards[index] / 2.20462
            } else {
                amount = strengthStandards[index]
            }
            strengthStandardsTexts[index].text = String(Int(amount)) + unit
            index += 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.ORMLabel.alpha = 1
            self.strengthCategoryView.alpha = 1
            self.mainStandardsView.alpha = 1
            for standard in self.strengthStandardsTexts {
                standard.alpha = 1
            }
        }, completion: nil)
    }
    
    func updateMyButtons(value: String) {
        if (selectedButton == self.exerciseButton) {
            if(exerciseList.firstIndex(of: [value,"weights"]) == nil) {
                self.liftWeightButton.isEnabled = false
                self.liftWeightButton.setTitleColor(UIColor.gray, for: .normal)
                self.liftWeightButton.setTitle(self.weightButton.title(for: .normal), for: .normal)
            } else {
                self.liftWeightButton.isEnabled = true
                self.liftWeightButton.setTitleColor(UIColor.black, for: .normal)
            }
        } else if (selectedButton == self.weightButton && (self.liftWeightButton.isEnabled == false)) {
            self.liftWeightButton.setTitle(value, for: .normal)
        }
        self.selectedButton?.setTitle(value, for: .normal)
    }
    
    @IBAction func showHowDidWe(_ sender: Any) {
        self.darkBackground.frame.origin.x = self.view.frame.origin.x
        self.darkBackground.frame.origin.y = self.view.frame.origin.y
        self.darkBGHeight.constant = self.view.frame.height
        self.darkBGWidth.constant = self.view.frame.width
        self.darkBackground.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.howDidWeGetThisView.frame.origin.y = self.view.frame.height / 2 - (self.howDidWeGetThisView.frame.height / 2)
            self.darkBackground.alpha = 0.35
        }, completion: nil)
        self.hdwgtBottom.constant = (self.view.frame.height - self.howDidWeGetThisView.frame.height) / 2
    }
    
    func hideHowDidWe() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.howDidWeGetThisView.frame.origin.y = self.view.frame.height + 10
            self.darkBackground.alpha = 0
        }, completion: {(finished: Bool) in
            self.darkBGHeight.constant = 1
        })
        self.hdwgtBottom.constant = -632
    }
    
    
    func changeStrengthCategoryView(level: Int) {
        if (level == 0) {
            self.strengthCategoryView.layer.backgroundColor = UIColor(red: (135/255.0), green: (32/255.0), blue: (239/255.0), alpha: 1).cgColor
            self.strengthCategoryView.layer.borderColor = UIColor(red: (85/255.0), green: (14/255.0), blue: (157/255.0), alpha: 1).cgColor
            self.strengthCategoryLabel?.text = "Beginner"
            
        } else if (level == 1) {
            self.strengthCategoryView.layer.backgroundColor = UIColor(red: (74/255.0), green: (127/255.0), blue: (245/255.0), alpha: 1).cgColor
            self.strengthCategoryView.layer.borderColor = UIColor(red: (41/255.0), green: (81/255.0), blue: (172/255.0), alpha: 1).cgColor
            self.strengthCategoryLabel?.text = "Novice"
            
        } else if (level == 2) {
            self.strengthCategoryView.layer.backgroundColor = UIColor(red: (23/255.0), green: (172/255.0), blue: (3/255.0), alpha: 1).cgColor
            self.strengthCategoryView.layer.borderColor = UIColor(red: (15/255.0), green: (114/255.0), blue: (2.0/255.0), alpha: 1).cgColor
            self.strengthCategoryLabel?.text = "Intermediate"
            
        } else if (level == 3) {
            self.strengthCategoryView.layer.backgroundColor = UIColor(red: (240.0/255.0), green: (166/255.0), blue: (0/255.0), alpha: 1).cgColor
            self.strengthCategoryView.layer.borderColor = UIColor(red: (169.0/255.0), green: (118.0/255.0), blue: (3.0/255.0), alpha: 1).cgColor
            self.strengthCategoryLabel?.text = "Advanced"
            
        } else if (level == 4) {
            self.strengthCategoryView.layer.backgroundColor = UIColor(red: (237/255.0), green: (17/255.0), blue: (51/255.0), alpha: 1).cgColor
            self.strengthCategoryView.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
            self.strengthCategoryLabel?.text = "Elite"
        } else {
            self.strengthCategoryView.layer.backgroundColor = UIColor.gray.cgColor
            self.strengthCategoryView.layer.borderColor = UIColor.darkGray.cgColor
            self.strengthCategoryLabel?.text = "Untrained"
        }
    }
    
    /*
        PICKER FUNCTIONS
     */
    @IBAction func hidePicker(_ sender: Any) {
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.optionsView.transform = CGAffineTransform(translationX: 0, y: 140 + ((self.tabBarController?.tabBar.frame.height)!))
        }, completion: nil)
    }
    
    func showPicker() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.optionsView.transform = CGAffineTransform(translationX: 0, y: -140 - ((self.tabBarController?.tabBar.frame.height)!))
        }, completion: nil)
    }
    
    @IBAction func changePicker(_ sender: UIButton) {
        var curVal: String = ""
        if (sender == self.weightButton) {
            gtvc!.myList = weightList
            gtvc!.numSections = 2
            gtvc!.selectedFirstList = String(self.weightButton.title(for: .normal)!.split(separator: " ")[0])
            gtvc!.selectedSecondList = String(self.weightButton.title(for: .normal)!.split(separator: " ")[1])
            curVal = String(self.weightButton.title(for: .normal)!.split(separator: " ")[0])
            selectedButton = self.weightButton
            optionsPicker.reloadAllComponents()
            optionsPicker.selectRow(gtvc!.secondList.firstIndex(of: gtvc!.selectedSecondList)!, inComponent: 1, animated: false)
            
        } else if (sender == self.ageButton) {
            gtvc!.myList = ageList
            gtvc!.numSections = 1
            curVal = self.ageButton.title(for: .normal)!
            selectedButton = self.ageButton
            
        } else if (sender == self.genderButton) {
            gtvc!.myList = genderList
            gtvc!.numSections = 1
            curVal = self.genderButton.title(for: .normal)!
            selectedButton = self.genderButton
            
        } else if (sender == self.exerciseButton) {
            gtvc!.myList = exerciseNames
            gtvc!.numSections = 1
            curVal = self.exerciseButton.title(for: .normal)!
            if (curVal == "Select Exercise") {
                curVal = exerciseNames[0]
                exerciseButton.setTitle(exerciseNames[0], for: .normal)
            }
            selectedButton = self.exerciseButton
            
        } else if (sender == self.liftRepsButton) {
            gtvc!.myList = Array(ageList[1...])
            gtvc!.numSections = 1
            curVal = self.liftRepsButton.title(for: .normal)!
            selectedButton = self.liftRepsButton
            
        } else if (sender == self.liftWeightButton) {
            gtvc!.myList = weightList
            gtvc!.numSections = 2
            gtvc!.selectedFirstList = String(self.liftWeightButton.title(for: .normal)!.split(separator: " ")[0])
            gtvc!.selectedSecondList = String(self.liftWeightButton.title(for: .normal)!.split(separator: " ")[1])
            curVal = String(self.liftWeightButton.title(for: .normal)!.split(separator: " ")[0])
            selectedButton = self.liftWeightButton
            optionsPicker.reloadAllComponents()
            optionsPicker.selectRow(gtvc!.secondList.firstIndex(of: gtvc!.selectedSecondList)!, inComponent: 1, animated: false)
        }
        
        optionsPicker.reloadAllComponents()
        optionsPicker.selectRow(gtvc!.myList.firstIndex(of: curVal)!, inComponent: 0, animated: false)
        showPicker()
    }

}
