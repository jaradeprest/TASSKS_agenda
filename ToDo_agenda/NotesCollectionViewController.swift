//
//  NotesCollectionViewController.swift
//  ToDo_agenda
//
//  Created by Jara De Prest on 26/03/2019.
//  Copyright © 2019 iam.deprest. All rights reserved.
//
import CoreData
import UIKit

private let reuseIdentifier = "Cell"

class NotesCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cv_tassks: UICollectionView!
    var tassks = [Tassks]()
    var managedObjectContext: NSManagedObjectContext!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        LoadData()
    }

    func LoadData() {
        let tasskRequest:NSFetchRequest<Tassks> = Tassks.fetchRequest()
        do{
            tassks = try managedObjectContext.fetch(tasskRequest)
            self.collectionView.reloadData()
        } catch {
            print ("ERROR")
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tassks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NoteCollectionViewCell
    
        let tasskItem = tassks[indexPath.row]
        
        if let tasskIcon = UIImage(data: tasskItem.icon!){
            cell.TaskIcon_iv.image = tasskIcon
        }
        cell.TaskTitle_Label.text = tasskItem.title
        
        //format date to string
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yy HH:mm"
        let tasskDateHour = formatter.string(from: tasskItem.date_hour!)
        
        //set date to cell
        cell.TaskTime_Label.text = tasskDateHour
        
        return cell
    }

    @IBAction func btn_addTassk(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary //TODO Create own library with icons for tassks
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let icon = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            self.createTasskItem(with: icon)
        }
    }
    
    func createTasskItem (with icon:UIImage){
        let tasskItem = Tassks(context: managedObjectContext)
        let imageData = icon.jpegData(compressionQuality: 3.0)
        tasskItem.icon = imageData

        let alert = UIAlertController(title: "New Tassk", message: "Enter your Tassk", preferredStyle: .alert)
        alert.addTextField{
            (textfield:UITextField) in textfield.placeholder="Title"
        }
        alert.addTextField{
            (textfield:UITextField) in textfield.placeholder="Date/Hour"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action:UIAlertAction) in
            let nameField = alert.textFields?.first
            let timeField = alert.textFields?.last
            
            if nameField?.text != "" && timeField?.text != ""{
                tasskItem.title = nameField?.text
                
                //string to date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT + 0:00")
                let dataDate = dateFormatter.date(from: timeField!.text!)!
                
                tasskItem.date_hour = dataDate
                
                do{
                    try self.managedObjectContext.save()
                }catch{
                    print("ERROR")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
