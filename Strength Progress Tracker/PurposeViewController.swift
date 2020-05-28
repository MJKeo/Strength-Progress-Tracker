//
//  PurposeViewController.swift
//  Strength Progress Tracker
//
//  Created by Michael Keohane on 5/27/20.
//  Copyright © 2020 Michael Keohne. All rights reserved.
//

import UIKit

class PurposeViewController: UIViewController {
    // visual items in order of appearance
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstPanel: UIView!
    @IBOutlet weak var secondPanel: UIView!
    @IBOutlet weak var thirdPanel: UIView!
    @IBOutlet weak var gotItBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.alpha = 0
        self.firstPanel.alpha = 0
        self.secondPanel.alpha = 0
        self.thirdPanel.alpha = 0
        self.gotItBtn.alpha = 0
        
        self.gotItBtn.isEnabled = false

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // animate everything in
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.8, delay: 0.75, options: .curveEaseOut, animations: {
            self.firstPanel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.8, delay: 1.5, options: .curveEaseOut, animations: {
            self.secondPanel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.8, delay: 2.25, options: .curveEaseOut, animations: {
            self.thirdPanel.alpha = 1
        }, completion: nil)
        UIView.animate(withDuration: 0.8, delay: 3, options: .curveEaseOut, animations: {
            self.gotItBtn.alpha = 1
        }, completion: {(finished: Bool) in
            self.gotItBtn.isEnabled = true
        })
    }
    
    @IBAction func goToNextPage(_ sender: Any) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.titleLabel.alpha = 0
            self.firstPanel.alpha = 0
            self.secondPanel.alpha = 0
            self.thirdPanel.alpha = 0
            self.gotItBtn.alpha = 0
        }, completion: {(finished: Bool) in
            // change to the input view
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let setupViewController = storyBoard.instantiateViewController(withIdentifier: "test")
            self.present(setupViewController, animated:true, completion:nil)
        })
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
