//
//  ViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/12/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

var dbManager = DatabaseManager()

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dbManager.createDatabase()
//        dbManager.deleteDatabase()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        if (UserDefaults.standard.object(forKey: "User Exercise List") == nil) {
            // Profile needs to be set up
            let setupViewController = storyBoard.instantiateViewController(withIdentifier: "setupProfileView") as! SetupProfileViewController
            self.present(setupViewController, animated:true, completion:nil)
        } else {
            // Profile has been set up so just go to their profile screen
            let setupViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarController") 
            self.present(setupViewController, animated:true, completion:nil)
        }
        
//        dbManager.populateDatabase()
//        dbManager.readFromDatabase()
//        dbManager.test()
        dbManager.readFromUserDB()
//        dbManager.readFromCustomExercises()
    }

}

