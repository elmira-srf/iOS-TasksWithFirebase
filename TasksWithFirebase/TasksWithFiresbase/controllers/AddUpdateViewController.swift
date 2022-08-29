import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class AddUpdateViewController: UIViewController {

    @IBOutlet weak var txtTaskName: UITextField!
    @IBOutlet weak var segmentPriority: UISegmentedControl!
    @IBOutlet weak var labelScreenTitle: UILabel!
    
    var isEditingTask = false
    var taskToEdit:Task?
    // database
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if we are adding or updating a task
        if let task = taskToEdit {
            isEditingTask = true
            labelScreenTitle.text = "Edit Task"
            
            //populate the text boxes with the information in the task
            txtTaskName.text = task.name
            
            if (task.isHighPriority == true) {
                segmentPriority.selectedSegmentIndex = 0
            }
            else if (task.isHighPriority == false) {
                segmentPriority.selectedSegmentIndex = 1
            }

        }
       
    }
    

    @IBAction func savePressed(_ sender: Any) {
        // validation
        if (txtTaskName.text!.isEmpty) {
            print("You must enter a task name")
            return
        }
        
        if(isEditingTask == true){
            updateTask()
        }else{
            addTask()
        }
    }
    private func updateTask() {
            
            guard var taskToEdit = taskToEdit else {
                print("The task is null, so we cannot proceed")
                return
            }
            
            // 1. Create a task object containing the data you want to update
            taskToEdit.name = txtTaskName.text!
            if (segmentPriority.selectedSegmentIndex  == 1) {
                taskToEdit.isHighPriority = false
            }
            else if (segmentPriority.selectedSegmentIndex == 0) {
                taskToEdit.isHighPriority = true
            }
            
            
            // 2. Id of the document to update
            // 3. Do the update
            do {
                try db.collection("tasks").document(taskToEdit.id!).setData(from: taskToEdit)
                print("Document updated")
            } catch {
                print("Error updating document")
            }
            
            
        }

    private func addTask() {
    // 1. get the task name from the text box
    // 2. get the priority from the segement control
         
        let taskNameFromUI:String = txtTaskName.text!
        var taskPriorityFromUI:Bool = false
        if (segmentPriority.selectedSegmentIndex  == 1) {
            taskPriorityFromUI = false
        }
        else if (segmentPriority.selectedSegmentIndex == 0) {
            taskPriorityFromUI = true
        }
            
        // 3. create a task object using the data from the user interface
        let taskToAdd:Task = Task(name: taskNameFromUI, isHighPriority: taskPriorityFromUI)
            
        // 4. insert the document into firestore
        do {
            try db.collection("tasks").addDocument(from: taskToAdd)
            print("Document saved!")
        } catch {
            print("Error when adding document")
        }
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
