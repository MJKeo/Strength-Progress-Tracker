//
//  SetupProfileViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 4/12/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class SetupProfileViewController: UIViewController {
    @IBOutlet weak var welcomeLabel: UILabel! // text that says "welcome"
    @IBOutlet weak var firstScreen: UIView! // view that holds my label and button

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        // Fade out current views then transition views
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.firstScreen?.alpha = 0.0
            self.welcomeLabel?.alpha = 0.0
        }, completion: {(finished: Bool) in
            self.changeView()
        })
    }
    
    func changeView() {
        // change to the purpose view
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let setupViewController = storyBoard.instantiateViewController(withIdentifier: "purposeVC")
        self.present(setupViewController, animated:true, completion:nil)
    }
    

}
