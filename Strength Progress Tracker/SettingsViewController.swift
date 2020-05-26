//
//  SettingsViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/18/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    // each setting
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var displayButton: UIButton!
    
    // picker stuff
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var dataPicker: UIPickerView!
    
    // other visuals
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var stacky: UIStackView!
    
    
    // variables
    let genderOptions = ["male","female"]
    let displayOptions = ["lbs", "kgs"]
    var ageOptions: [String] = []
    var weightOptions: [String] = []
    
    var options: [String] = []
    var numComponents = 1
    var selectedButton: UIButton!
    var selectedUnits = "lbs"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingsLabel.alpha = 0
        self.descriptionLabel.alpha = 0
        self.stacky.alpha = 0
        
        // set delegates n stuff
        self.dataPicker.delegate = self
        self.dataPicker.dataSource = self
        
        // hide everything
        self.settingsLabel.alpha = 1
        self.descriptionLabel.alpha = 1
        self.stacky.alpha = 1
        
        // deal with pre-existing user standards
        let userGender = UserDefaults.standard.string(forKey: "User Gender")!
        let userAge = UserDefaults.standard.string(forKey: "User Age")!
        let userWeight = UserDefaults.standard.string(forKey: "User Weight")!
        let displayUnits = UserDefaults.standard.string(forKey: "Display Units")!
        self.genderButton.setTitle(userGender, for: .normal)
        self.ageButton.setTitle(userAge, for: .normal)
        self.weightButton.setTitle(userWeight, for: .normal)
        self.displayButton.setTitle(displayUnits, for: .normal)
        self.selectedUnits = String(userWeight.split(separator: " ")[1])

        // this one is specifically so that you can tap anywhere to hide the picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipe)
        
        // set up my lists
        setupLists()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
        
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hidePicker(self)
        self.view.endEditing(true)
    }
    
    @IBAction func TransitionBack(_ sender: Any) {
        self.saveValues(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupLists() {
        var index = 1
        while (index < 1000) {
            if (index < 100) {
                self.ageOptions.append(String(index))
            }
            self.weightOptions.append(String(index))
            index += 1
        }
    }
    
    @IBAction func buttonClick(_ sender: UIButton) {
        self.selectedButton = sender
        if (sender == self.genderButton) {
            self.numComponents = 1
            self.options = self.genderOptions
            let selected = self.genderButton.title(for: .normal)!
            let index = self.genderOptions.firstIndex(of: selected)!
            self.dataPicker.reloadAllComponents()
            self.dataPicker.selectRow(index, inComponent: 0, animated: false)
            
        } else if (sender == self.ageButton) {
            self.numComponents = 1
            self.options = self.ageOptions
            let selected = self.ageButton.title(for: .normal)!
            let index = self.ageOptions.firstIndex(of: selected)!
            self.dataPicker.reloadAllComponents()
            self.dataPicker.selectRow(index, inComponent: 0, animated: false)
            
        } else if (sender == self.weightButton) {
            self.numComponents = 2
            self.options = self.weightOptions
            let title = self.weightButton.title(for: .normal)!
            let weight = title.split(separator: " ")[0]
            let units = title.split(separator: " ")[1]
            let firstIndex = self.weightOptions.firstIndex(of: String(weight))!
            let secondIndex = self.displayOptions.firstIndex(of: String(units))!
            self.dataPicker.reloadAllComponents()
            self.dataPicker.selectRow(firstIndex, inComponent: 0, animated: false)
            self.dataPicker.selectRow(secondIndex, inComponent: 1, animated: false)
            
        } else {
            self.numComponents = 1
            self.options = self.displayOptions
            let selected = self.displayButton.title(for: .normal)!
            let index = self.displayOptions.firstIndex(of: selected)!
            self.dataPicker.reloadAllComponents()
            self.dataPicker.selectRow(index, inComponent: 0, animated: false)
            
        }
        showPicker()
    }
    
    @IBAction func saveValues(_ sender: Any) {
        UserDefaults.standard.set(genderButton.title(for: .normal), forKey: "User Gender")
        UserDefaults.standard.set(ageButton.title(for: .normal), forKey: "User Age")
        UserDefaults.standard.set(weightButton.title(for: .normal), forKey: "User Weight")
        UserDefaults.standard.set(displayButton.title(for: .normal), forKey: "Display Units")
    }
    
    
    /*
        PICKER METHODS
     */
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (numComponents == 1) {
            selectedButton.setTitle(self.options[row], for: .normal)
        } else {
            if (component == 0) {
                selectedButton.setTitle(self.options[row] + " " + self.selectedUnits, for: .normal)
            } else {
                selectedUnits = self.displayOptions[row]
                let newTitle = String(self.selectedButton.title(for: .normal)!.split(separator: " ")[0]) + " " + selectedUnits
                selectedButton.setTitle(newTitle, for: .normal)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return self.options.count
        } else {
            return 2
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return self.numComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return self.options[row]
        } else {
            return self.displayOptions[row]
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
