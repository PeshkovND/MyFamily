import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore

class FirebaseClient {
    static let shared = FirebaseClient()
    
    private func configureFirebase() -> Firestore {
        var db: Firestore
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        return db
    }
    
    func getPost() {
        
    }
}
