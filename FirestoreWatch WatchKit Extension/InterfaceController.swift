//
//  InterfaceController.swift
//  FirestoreWatch WatchKit Extension
//
//  Created by Krishnaprasad Jagadish on 10/11/20.
//

import Google
import WatchKit
import Foundation

final class GroupeeFirestoreRepository: FirestoreProjectRepository {
    @Resource(get: \.listDocumentsInCollection, from: "users") var documentList
    
    init() {
        super.init(projectID: "groupee-a17e7")
        
        documentList = nil
    }
    
    func data(forUserID userID: String) -> AnyPublisher<userData, Error> {
        self.getDocumentAtPath("users/\(userID)")
            .successPublisher
            .tryMap({ (document: FirestoreDocument) in
                try FirestoreDecoder().decode(userData.self, from: document)
            })
            .eraseToAnyPublisher()
    }
}

struct userData: Codable {
    var userID: String = ""
    var heartRate: Int = 0
    var calories: Int = 0
    var points: Int  = 0
    var effort: Int = 0
}

class InterfaceController: WKInterfaceController, CancellablesHolder {
    let repository = GroupeeFirestoreRepository()
    
    @IBOutlet weak var startButton: WKInterfaceButton!
    var timer: Timer?
    var userUUID: String = ""
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        
        if ( UserDefaults.standard.object(forKey: "userID") == nil) {
            let userID = UUID().uuidString
            UserDefaults.standard.setValue(userID, forKey: "userID")
        } else {
            userUUID = UserDefaults.standard.object(forKey: "userID") as! String
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    
    
    @IBAction func startBtnClicked() {
        if let timer = self.timer {
            if timer.isValid {
                self.startButton.setTitle("Start Pushing")
                timer.invalidate()
            } else {
                self.startButton.setTitle("Stop Pushing")
                self.timer = Timer.scheduledTimer(withTimeInterval:  5.0 , repeats: true) { (timer) in
                    self.pushDataToFirebase()
                }
            }
        } else {
            self.startButton.setTitle("Stop Pushing")
            self.timer = Timer.scheduledTimer(withTimeInterval:  5.0 , repeats: true) { (timer) in
                self.pushDataToFirebase()
            }
        }
    }
    
    
    func pushDataToFirebase() {
        let heartRate = Int.random(in: 60...128)
        let calories = Int.random(in: 1...100)
        let points = Int.random(in: 1...10)
        let effort = Int.random(in: 1...10)
        
        let dataToBePushed = userData(userID:userUUID, heartRate: heartRate, calories: calories, points: points, effort: effort)
        
        do {
            repository
                .patch(try FirestoreEncoder().encode(dataToBePushed), at: "/users/\(userUUID)")
                .store(in: cancellables)
        } catch {
            
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
}
