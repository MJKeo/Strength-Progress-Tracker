//
//  AddExerciseViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/24/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class AddExerciseViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // collection view
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    
    // create exercise variables
    @IBOutlet weak var exerciseTypeButton: UIButton!
    @IBOutlet weak var exerciseNameInput: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // picker
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var dataPicker: UIPickerView!
    
    
    
    // other variables
    var exerciseList: [[String]] = []
    var exerciseTypes = ["Bodyweight","Weightlifting"]
    var userExercises: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.exerciseCollectionView.dataSource = self
        self.exerciseCollectionView.delegate = self
        
        self.dataPicker.dataSource = self
        self.dataPicker.delegate = self

        // handle styling
        doStyling()
        
        // set layout for "my lifts" collection view
        let itemSize = exerciseCollectionView.frame.width / 3.4
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 1, bottom: 5, right: 1)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        exerciseCollectionView.collectionViewLayout = layout
        
        exerciseList = dbManager.getExercises()
        removeDuplicates()
        
        // this one is specifically so that you can tap anywhere to hide the picker
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        swipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(swipe)
    }
    
    /*
        Helper Methods
     */
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
            hidePicker(exerciseNameInput as Any)
            self.view.endEditing(true)
        }
    
    func doStyling() {
        submitButton.layer.cornerRadius = 15
    }
    
    func removeDuplicates() {
        // don't let the user select an exercise they already have
        var index = 0
        userExercises = UserDefaults.standard.object(forKey: "User Exercise List") as! [String]
        while (index < exerciseList.count) {
            let name = exerciseList[index][0]
            if (userExercises.contains(name)) {
                exerciseList.remove(at: index)
            } else {
                index += 1
            }
        }
    }
    
    /*
        EXTRA FUNCTIONALITY
     */
    @IBAction func submitValues(_ sender: Any) {
        if (exerciseNameInput.text == "" || exerciseTypeButton.title(for: .normal) == "Exercise Type") {
            return
        }
        let exercise = exerciseNameInput.text!
        let category = exerciseTypeButton.title(for: .normal)!
        dbManager.addToCustomExerciseList(exercise: exercise, category: category.lowercased())
        userExercises.append(exercise)
        userExercises.sort(by: {$0.lowercased() < $1.lowercased()})
        UserDefaults.standard.set(userExercises, forKey: "User Exercise List")
        changePage()
    }
    
    func chooseExercise(exercise: String) {
        print(exercise)
        userExercises.append(exercise)
        userExercises.sort(by: {$0.lowercased() < $1.lowercased()})
        UserDefaults.standard.set(userExercises, forKey: "User Exercise List")
        changePage()
    }
    
    func changePage() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        self.present(setupViewController, animated:true, completion:nil)
    }
    
    /*
        COLLECTION VIEW METHODS
     */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let index = section * 3
        if (exerciseList.count - index > 3) {
            return 3
        } else {
            return exerciseList.count - index
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if (exerciseList.count % 3 == 0) {
            return exerciseList.count / 3
        } else {
            return exerciseList.count / 3 + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print(exerciseCollectionView.numberOfSections)
        print(exerciseCollectionView.numberOfItems(inSection: 0))
        print("accessed")
        let cell : ExerciseCollectionViewCell = exerciseCollectionView.dequeueReusableCell(withReuseIdentifier: "exerciseCell", for: indexPath) as! ExerciseCollectionViewCell
        cell.cellName?.text = exerciseList[indexPath.row + (indexPath.section * 3)][0]
        cell.cellView.layer.borderColor = UIColor(red: (162/255.0), green: (0/255.0), blue: (34/255.0), alpha: 1).cgColor
        cell.cellView.layer.borderWidth = 3
        cell.cellView.layer.cornerRadius = 15
        cell.onClick = self.chooseExercise
        cell.cellImage.image = UIImage(named: exerciseList[indexPath.row + (indexPath.section * 3)][0])
        return cell
    }
    
    /*
        PICKER VIEW METHODS
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.exerciseTypes[row]
    }
    
    @IBAction func hidePicker(_ sender: Any) {
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: 185)
        }, completion: nil)
    }
    
    @IBAction func showPicker() {
        if (exerciseTypeButton.title(for: .normal) == "Exercise Type") {
            exerciseTypeButton.setTitle(exerciseTypes[0], for: .normal)
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.pickerView.transform = CGAffineTransform(translationX: 0, y: -185)
        }, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        exerciseTypeButton.setTitle(exerciseTypes[row], for: .normal)
    }

}
