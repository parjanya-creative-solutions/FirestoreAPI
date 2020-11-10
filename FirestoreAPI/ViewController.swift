//
//  ViewController.swift
//  FirestoreAPI
//
//  Created by Krishnaprasad Jagadish on 10/11/20.
//

import UIKit


struct userData: Encodable {
    var userID: String = ""
    var heartRate: Int = 0
    var calories: Int = 0
    var points: Int  = 0
    var effort: Int = 0
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

