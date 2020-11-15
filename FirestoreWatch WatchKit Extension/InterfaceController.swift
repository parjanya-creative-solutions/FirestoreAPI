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
    @UserDefault("userID", default: UUID().uuidString) var currentUserID: String
    
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
    
    @IBAction func startBtnClicked() {
        if let timer = self.timer {
            if timer.isValid {
                self.startButton.setTitle("Start Pushing")
                timer.invalidate()
            } else {
                self.startButton.setTitle("Stop Pushing")
                self.timer = Timer.scheduledTimer(withTimeInterval:  1 , repeats: true) { (timer) in
                    self.pushDataToFirebase()
                }
            }
        } else {
            self.startButton.setTitle("Stop Pushing")
            self.timer = Timer.scheduledTimer(withTimeInterval:  1 , repeats: true) { (timer) in
                self.pushDataToFirebase()
            }
        }
    }
    
    func pushDataToFirebase() {
        let dataToBePushed = userData(
            userID: repository.currentUserID,
            heartRate: Int.random(in: 60...128),
            calories: Int.random(in: 1...100),
            points: Int.random(in: 1...10),
            effort: Int.random(in: 1...10)
        )
        
        repository
            .patch(try! FirestoreEncoder().encode(dataToBePushed), at: "/users/\(repository.currentUserID)")
            .store(in: cancellables)
    }
}
