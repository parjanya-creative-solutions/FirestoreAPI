//
//  ViewController.swift
//  FirestoreAPI
//
//  Created by Krishnaprasad Jagadish on 10/11/20.
//
import UIKit
import Google
struct userData: Encodable, Decodable {
    var userID: String = ""
    var heartRate: Int = 0
    var calories: Int = 0
    var points: Int  = 0
    var effort: Int = 0
}
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

class ViewController: UIViewController, CancellablesHolder {
    let repository = GroupeeFirestoreRepository()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Forces the API to fetch from the server the current snapshot
        repository.$documentList.fetch()
        
        
        
        Timer.scheduledTimer(withTimeInterval: 5.0 , repeats: true) { (timer) in
            self.getData()
        }
        
        
    }
    
    func getData() {
        repository.$documentList.fetch()
        repository.$documentList.publisher.map { documentList in
            (documentList.leftValue?.documents ?? []).map({ try! FirestoreDecoder().decode(userData.self, from: $0) })
        }
        .sinkResult { result  in
            //print(result)
            do {
                try self.processResult(result: result.get())
            } catch {
                print("Error \(error)")
            }
        }
        .store(in: cancellables)
    }
    
    func processResult(result: Array<userData>) {
        if (  result.count > 0) {
            print("result \(result[1])")
        }
    }
}
