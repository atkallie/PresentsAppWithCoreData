//
//  GiftsTableViewController.swift
//  PresentsAppWithCoreData
//
//  Created by Ahmed T Khalil on 1/28/17.
//  Copyright © 2017 kalikans. All rights reserved.
//

import UIKit
import CoreData

class GiftsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    //want to replace hard-coded dictionary with the ability to load pictures from photo library
    /*OLD Hard-Coded Dictionary
     var myGifts = [["name":"Best Friend","image":"1","item":"Camera"],["name":"Mom","image":"2","item":"Flowers"],["name":"Dad","image":"3","item":"Some kind of tech"],["name":"Sister","image":"4","item":"Sweets"]]
     */
    
    //to do this we need to adopt the protocols: UIImagePickerControllerDelegate and UINavigationControllerDelegate (both are needed to let this class be the delegate for the UIImagePickerController)
    
    //create an array to store Present objects
    var myGifts = [Present]()
    
    var context:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display a white Edit button in the navigation bar for this view controller.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
        //self.editButtonItem.tintColor = UIColor.white
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "Shape"))
        
        //Managed Object Context sits at the top of the Core Data stack and provides an interface between the requests sent to the database, the actual database, and the answer sent back from the database as an array called the 'Managed Object' (see 'Core Data Fetch Flow' in Core Data folder)
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        //retrieve data from Core Data and update table 
        //(loadData is a function created by the user to help make code more clear)
        self.loadData()
    }
    
    func loadData(){
        //create a fetch request to retrieve data from Core Data
        let fetchRequest:NSFetchRequest<Present> = Present.fetchRequest()
        
        //can add predicates to filter request results:
        //fetchRequest.predicate = NSPredicate(format: "name = %@","[Name]")
        
        do{
            //populate presents array with data from Core Data
            myGifts = try context.fetch(fetchRequest)
            //reload the table view to reflect the data in the database
            self.tableView.reloadData()
            
        }catch{
            print("Error \(error.localizedDescription)")
        }
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myGifts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GiftsEachPersonTableViewCell
        
        // Configure the cell...
        
        let giftObject = myGifts[indexPath.row]
        
        if let name = giftObject.name{
            cell.name.text  = name
        }
        if let gift = giftObject.gift{
            cell.gift.text = gift
        }
        if let image = UIImage(data: giftObject.image as! Data){
            cell.personImage.image = image
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    @IBAction func addPresent(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        
        //you can also have a source type of '.camera'
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        //present a view controller modally (image picker controller in this case)
        self.present(imagePicker, animated: true, completion: nil)
        
        //must also add 'NSPhotoLibraryUsageDescription' key to info.plist file or the app will crash (similar to user location usage)
        
    }
    
    //important image picker controller methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //if they cancel, just dismiss the image picker controller
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //get the image that the user has selected
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //we want to prompt an alert view to enter name and description of gift, but we are still in the image picker controller
            //so first dismiss the image picker controller and once it is completed (i.e. code in completion handler) ...
            picker.dismiss(animated: true, completion: {
                //this function handles Core Data stuff (see below)
                self.createPresentEntry(with: image)
            })
        }
    }
    
    func createPresentEntry(with image: UIImage){
        //return an instance of the class Present (automaically for the entity 'Present') to create a Present object
        let presentEntry = Present(context: context)
        
        //then set the image for the object
        presentEntry.image = NSData(data: UIImageJPEGRepresentation(
            image, 0.3)!)
        
        //to obtain the name and the item description, we can use an alert view controller and present it modally on the screen
        //see descriptions of UIAlertController for some hints on how to use if you forget
    
        let alert = UIAlertController(title: "New Gift", message: "Enter a name and a gift", preferredStyle: UIAlertControllerStyle.alert)
        
        //then customize it...
        //you need two text fields
        alert.addTextField { (textfield) in
            //optional text field configuration
            textfield.placeholder = "Enter Name/Relationship"
        }
        alert.addTextField { (textfield) in
            //optional text field configuration
            textfield.placeholder = "Enter Gift Description"
        }
        
        //then add two actions, one to save and one to cancel
        //save button
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (save) in
            //what do you want this to do...
            
            //capture what the textfields say
            let person = alert.textFields?[0]
            let gift = alert.textFields?[1]
            
            
            
            if person?.text?.replacingOccurrences(of: " ", with: "") != "" && gift?.text?.replacingOccurrences(of: " ", with: "") != ""{
                
                //check if strings are
                presentEntry.name = person?.text!
                presentEntry.gift = gift?.text!
                
                do{
                    try self.context.save()
                    //then reload the table data
                    self.loadData()
                }catch{
                    print("Error \(error.localizedDescription)")
                }
            }
        }))
        
        //cancel button
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
        }))
        
        //and finally display it modally
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
