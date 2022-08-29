import Foundation
import FirebaseFirestoreSwift

struct Task:Codable {
    // add properties of a task here
    
    @DocumentID var id:String?
    var name:String = ""
    var isHighPriority = false
}
