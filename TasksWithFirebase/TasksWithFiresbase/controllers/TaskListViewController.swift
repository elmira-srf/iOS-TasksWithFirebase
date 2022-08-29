import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class TaskListViewController: UITableViewController {

    
    let db = Firestore.firestore()
    
//    var taskList = ["Buy groceries", "Go to gym", "Do homework"]
    var taskList:[Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        taskList = []
        db.collection("tasks").getDocuments {
                    (queryResults, error) in
                
            if let err = error {
                print("Something went wrong when fetching data from firestore")
                print(err)
            }
            else {
                // error = nil, then your request succeeded
                if (queryResults!.documents.count == 0) {
                    print("The collection has no documents in it")
                }
                else {
                    for doc in queryResults!.documents {
                        do {
                                // doc.data(as:...) will return an optional
                                let taskFromFirestore = try doc.data(as: Task.self)
                                if let task = taskFromFirestore {
                                    // add it to the array of tasks
                                    self.taskList.append(task)
                                    print("Task added to list")
                                }
                                else {
                                    // skip it
                                    print("Task from Firestore was null")
                                }
                        } catch {
                            print("Error converting to a Task object")
                        }
                    }
                self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func addTaskPressed(_ sender: Any) {
        guard let addUpdateVC = storyboard?.instantiateViewController(identifier: "AddUpdateScreen") as? AddUpdateViewController else{
            return
        }
        
        show(addUpdateVC, sender: self)
    }

}

extension TaskListViewController {
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.taskList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)

        let task = self.taskList[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = "Priority goes here"
        if (task.isHighPriority == true) {
                    cell.detailTextLabel?.text = "High Priority"
                }
                else {
                    cell.detailTextLabel?.text = "Low Priority"
                }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // befor we delete the task, we need its id
            let taskToDelete = self.taskList[indexPath.row]
            let idToDelete = taskToDelete.id!
            // delete the task from the array of tasks
            self.taskList.remove(at: indexPath.row)
            // delete the corresponding row from the table view
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //delete from firestore
            db.collection("tasks").document(idToDelete).delete() {
                (err) in
                if let err = err {
                    print("Error removing task")
                    print(err)
                }
                else{
                    print("Document deleted from firestore")
                }
            }
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("row clicked")
        
        guard let addUpdateVC = storyboard?.instantiateViewController(identifier: "AddUpdateScreen") as? AddUpdateViewController else{
            return
        }
        
        addUpdateVC.taskToEdit = self.taskList[indexPath.row]
        show(addUpdateVC, sender: self)
    }


}

