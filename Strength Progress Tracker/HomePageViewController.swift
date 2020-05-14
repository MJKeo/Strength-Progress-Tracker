//
//  HomePageViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/12/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // Collection View
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    @IBOutlet weak var exerciseCVHeight: NSLayoutConstraint!
    
    // constraint for my finesse
    
    
    // variables
    var userExerciseList: [String] = ["ONE", "TWO", "THREE"]
//    var exerciseList: [[String]] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseCollectionView.delegate = self
        exerciseCollectionView.dataSource = self

        userExerciseList = UserDefaults.standard.object(forKey: "User Exercise List") as! [String]
//        exerciseList = dbManager.getExercises()
        
        let itemSize = exerciseCollectionView.frame.width / 3.4
        // update height of my view to account for the items
        var numRows = 0
        if ((userExerciseList.count + 1) % 3 == 0) {
            numRows = (userExerciseList.count + 1) / 3
        } else {
            print("yeah")
            numRows = (userExerciseList.count + 1) / 3 + 1
        }
        print(numRows)
        exerciseCVHeight.constant = (itemSize + 15) * CGFloat(numRows)
        
        // set layout for "my lifts" collection view
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 1, bottom: 5, right: 1)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        exerciseCollectionView.collectionViewLayout = layout
        
        print(userExerciseList)
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
            cell.cellImage.image = UIImage(named: "snatch")
            return cell
        }
    }

}
