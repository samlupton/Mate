import FirebaseFirestore
import SwiftUI

class MyClass {
    var numFollowers: Int = 0
    
    func fetchNumFollowers() {
        let db = Firestore.firestore()
        let followingCollection = db.collection("Users").document(getOtherUsersUID()).collection("Followers")
        
        followingCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching followers: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                return
            }
            
            let count = snapshot.documents.count
            print("Number of followers: \(count)")
            
            // Update the state variable on the main queue
            DispatchQueue.main.async {
                self.numFollowers = count
            }
        }
    }
    
    private func getOtherUsersUID() -> String {
        // Implement your logic to get the UID of other users
        return ""
    }
}
