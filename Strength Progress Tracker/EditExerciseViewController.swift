//
//  EditExerciseViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/19/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class EditExerciseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var exerciseName: UILabel!
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var unitsButton: UIButton!
    
    // picker stuff
    @IBOutlet weak var dataPicker: UIPickerView!
    @IBOutlet weak var pickerView: UIView!
    
    
    // variables
    var name: String!
    var typeOptions: [String] = ["Bodyweight", "Weightlifting"]
    var unitsOptions: [String] = ["lbs", "kgs"]
    
    var options: [String] = []
    var selectedButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.name = UserDefaults.standard.string(forKey: "Selected Exercise")
        self.nameInput.text = name
        
        // setup picker
        self.dataPicker.delegate = self
        self.dataPicker.dataSource = self
        
        // establish defaults
//        print(UserDefaults.standard.string(forKey: "Exercise Category"))
//        print(UserDefaults.standard.string(forKey: "Exercise Type"))
        if (UserDefaults.standard.string(forKey: "Exercise Type") == "bodyweight") {
            self.typeButton.setTitle("Bodyweight", for: .normal)
        } else {
            self.typeButton.setTitle("Weightlifting", for: .normal)
        }
        self.unitsButton.setTitle(UserDefaults.standard.string(forKey: "Display Units")!, for: .normal)
        if (UserDefaults.standard.string(forKey: "Exercise Category") != "custom") {
            self.typeButton.isEnabled = false
            self.typeButton.setTitleColor(UIColor.gray, for: .normal)
            self.nameInput.isEnabled = false
            self.nameInput.textColor = UIColor.gray
            
            self.exerciseName.textColor = UIColor.gray
            self.typeLabel.textColor = UIColor.gray
        }
        
        // this one is specifically so that you can tap anywhere to hide the picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipe)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        hidePicker(self)
        self.view.endEditing(true)
    }

    @IBAction func deleteExercise(_ sender: Any) {
        let alertController = UIAlertController(title: "Are you sure you want to delete this exercise?", message: "(all data for this exercise will be removed too)", preferredStyle: .alert)
        
        //the confirm action taking the inputs
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { (_) in
            dbManager.deleteExercise(exercise: self.name)
            
            var list = UserDefaults.standard.object(forKey: "User Exercise List") as! [String]
            var index = 0
            while (index < list.count) {
                if (list[index] == self.name) {
                    list.remove(at: index)
                }
                index += 1
            }
            UserDefaults.standard.set(list, forKey: "User Exercise List")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let setupViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
            self.present(setupViewController, animated:true, completion:nil)
        }
        
        //the cancel action doing nothing
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { (_) in }
        
        //adding the action to dialogbox
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        //finally presenting the dialog box
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveValues(_ sender: Any) {
        UserDefaults.standard.set(unitsButton.title(for: .normal), forKey: "Display Units")
        if (self.typeButton.title(for: .normal) == "Bodyweight") {
            UserDefaults.standard.set("reps", forKey: "Suffix")
        } else {
            UserDefaults.standard.set(self.unitsButton.title(for: .normal), forKey: "Suffix")
        }
        
        if (self.typeButton.isEnabled) {
            print("SAVING")
            UserDefaults.standard.set(self.nameInput.text!, forKey: "Selected Exercise")
            dbManager.updateExerciseType(exercise: self.name, newType: self.typeButton.title(for: .normal)!.lowercased())
            dbManager.updateExerciseName(oldName: self.name, newName: self.nameInput.text!)
            var list = UserDefaults.standard.object(forKey: "User Exercise List") as! [String]
            var index = 0
            while (index < list.count) {
                if (list[index] == self.name) {
                    list[index] = self.nameInput.text!
                }
                index += 1
            }
            UserDefaults.standard.set(list, forKey: "User Exercise List")
        }
    }
    
    
    @IBAction func goBack(_ sender: Any) {
        self.saveValues(self)
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
        PICKER METHODS
     */
    @IBAction func preparePicker(_ sender: UIButton) {
        self.selectedButton = sender
        if (sender == self.typeButton) {
            self.options = self.typeOptions
        } else {
            self.options = self.unitsOptions
        }
        
        let cur = sender.title(for: .normal)!
        let index = self.options.firstIndex(of: cur)!
        self.dataPicker.reloadAllComponents()
        self.dataPicker.selectRow(index, inComponent: 0, animated: false)
        showPicker()
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
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.options.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedButton.setTitle(self.options[row], for: .normal)
    }
}
