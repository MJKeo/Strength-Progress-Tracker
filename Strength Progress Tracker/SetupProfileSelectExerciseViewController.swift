//
//  SetupProfileSelectExerciseViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/17/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class SetupProfileSelectExerciseViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    

    @IBOutlet weak var promptLabel: UILabel!
    // collection view
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    
    var exerciseList: [[String]] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseCollectionView.delegate = self
        exerciseCollectionView.dataSource = self
        exerciseCollectionView.alpha = 0
        self.promptLabel.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.promptLabel.alpha = 1
            self.exerciseCollectionView.alpha = 1
        }, completion: nil)
        
        let itemSize = UIScreen.main.bounds.width / 3.4
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 1, bottom: 5, right: 1)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        exerciseCollectionView.collectionViewLayout = layout
        
        getExerciseList()

        // Do any additional setup after loading the view.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var index = section * 3
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
    
    func getExerciseList() {
        exerciseList = dbManager.getExercises()
    }
    
    func chooseExercise(name: String) {
        var list = [name]
        UserDefaults.standard.set([name], forKey: "User Exercise List")
        if (self.exerciseList.firstIndex(of: [name, "bodyweight"]) != nil) {
            dbManager.addToGoals(exercise: name, value: 5)
        } else {
            dbManager.addToGoals(exercise: name, value: 315)
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.exerciseCollectionView.alpha = 0
            self.promptLabel.alpha = 0
        }, completion: {(finished: Bool) in
            self.changePages()
        })
    }
    
    func changePages() {
        UserDefaults.standard.set("lbs", forKey: "Display Units")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController")
        self.present(setupViewController, animated:true, completion:nil)
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
