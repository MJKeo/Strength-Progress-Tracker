//
//  SetupProfileInputViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/13/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class SetupProfileInputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var mainView: UIView!
    
    // input fields
    @IBOutlet weak var genderInput: UIButton!
    @IBOutlet weak var ageInput: UIButton!
    @IBOutlet weak var weightInput: UIButton!
    
    var selectedButton: UIButton!
    
    
    // picker stuff
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var dataPicker: UIPickerView!
    
    
    // variables
    let genderOptions = ["male","female"]
    let weightUnits = ["lbs","kgs"]
    var ageOptions: [String] = []
    var weightOptions: [String] = []
    var options: [String] = []
    var numComponents = 1
    var selectedUnit = "lbs"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start off invisible
        self.mainView?.alpha = 0.0
        
        doStyling()
        setupLists()
        
        dataPicker.delegate = self
        dataPicker.dataSource = self
        
        // this one is specifically so that you can tap anywhere to hide the picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipe)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hidePicker(weightInput as Any)
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // fade in on loading
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.mainView?.alpha = 1.0
        }, completion: nil)
    }
    
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
    
    // modify what's in the picker
    @IBAction func changePicker(_ sender: UIButton) {
        var selectAt = 0
        if (sender == self.genderInput) {
            options = genderOptions
            numComponents = 1
            if (self.genderInput.title(for: .normal) == nil) {
                genderInput.setTitle(options[0], for: .normal)
                selectAt = 0
            } else {
                let curVal = self.genderInput.title(for: .normal)
                selectAt = options.firstIndex(of: curVal!)!
            }
            selectedButton = genderInput
            
        } else if (sender == self.ageInput) {
            options = ageOptions
            numComponents = 1
            if (self.ageInput.title(for: .normal) == nil) {
                ageInput.setTitle(options[25], for: .normal)
                selectAt = 25
            } else {
                let curVal = self.ageInput.title(for: .normal)
                selectAt = options.firstIndex(of: curVal!)!
            }
            selectedButton = ageInput
            
        } else if (sender == self.weightInput) {
            options = weightOptions
            numComponents = 2
            if (self.weightInput.title(for: .normal) == nil) {
                weightInput.setTitle(options[150] + " " + selectedUnit, for: .normal)
                selectAt = 150
            } else {
                let curVal = String(self.weightInput.title(for: .normal)!.split(separator: " ")[0])
                selectAt = options.firstIndex(of: curVal)!
            }
            selectedButton = weightInput
            
        }
        
        dataPicker.reloadAllComponents()
        dataPicker.selectRow(selectAt, inComponent: 0, animated: false)
        showPicker()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (numComponents == 1) {
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
    
    
    // picker classes
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
    
    // action to be done once data has been submitted
    @IBAction func submitValues(_ sender: Any) {
        if (genderInput.title(for: .normal) == nil || ageInput.title(for: .normal) == nil || weightInput.title(for: .normal) == nil) {
            return
        }
        
        hidePicker(weightInput as Any)
        
        // save user values
        UserDefaults.standard.set(genderInput.title(for: .normal), forKey: "User Gender")
        UserDefaults.standard.set(ageInput.title(for: .normal), forKey: "User Age")
        UserDefaults.standard.set(weightInput.title(for: .normal), forKey: "User Weight")
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.mainView?.alpha = 0
        }, completion: {(finished: Bool) in
            self.changePages()
        })
    }
    
    func changePages() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "selectExerciseVC")
        self.present(setupViewController, animated:true, completion:nil)
    }
    
    func setupLists() {
        var i = 0
        while i < 1000 {
            if (i < 100) {
                ageOptions.append(String(i))
            }
            weightOptions.append(String(i))
            i += 1
        }
    }
    
    func doStyling() {
        // put bottom borders on weight buttons
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: genderInput.frame.height - 1, width: genderInput.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        genderInput.layer.addSublayer(bottomLine)
        let bottomLine2 = CALayer()
        bottomLine2.frame = CGRect(x: 0.0, y: ageInput.frame.height - 1, width: ageInput.frame.width, height: 1.0)
        bottomLine2.backgroundColor = UIColor.white.cgColor
        ageInput.layer.addSublayer(bottomLine2)
        let bottomLine3 = CALayer()
        bottomLine3.frame = CGRect(x: 0.0, y: weightInput.frame.height - 1, width: weightInput.frame.width, height: 1.0)
        bottomLine3.backgroundColor = UIColor.white.cgColor
        weightInput.layer.addSublayer(bottomLine3)
    }
}
