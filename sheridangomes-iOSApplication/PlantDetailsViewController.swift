//
//  PlantDetailsViewController.swift
//  sheridangomes-iOSApplication
//
//  Created by Sheridan's Lair on 17/09/20.
//  Copyright © 2020 monash. All rights reserved.
//

import UIKit

class PlantDetailsViewController: UIViewController, DatabaseListener {
    
    
    
    @IBOutlet weak var plantName: UILabel!
    @IBOutlet weak var plantScientificName: UILabel!
    @IBOutlet weak var plantYear: UILabel!
    @IBOutlet weak var plantFamily: UILabel!
    @IBOutlet weak var plantImageView: UIImageView!
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sciNameTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var familyTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var name: String = ""
    var scientificName: String = ""
    var family: String = ""
    var year: String = ""
    var imageUrl: String = ""
    
    var listenerType: ListenerType = .all
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        plantName.text = "Name:"
        plantScientificName.text =  "Scientific Name:"
        plantYear.text = "Year Discovered:"
        plantFamily.text = "Family:"
        plantImageView.downloadedFrom1(from: imageUrl )
        
        //placeholder color
        nameTextField.attributedPlaceholder = NSAttributedString(string: name,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        sciNameTextField.attributedPlaceholder = NSAttributedString(string: scientificName,
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        
        yearTextField.attributedPlaceholder = NSAttributedString(string: year,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        
        familyTextField.attributedPlaceholder = NSAttributedString(string: family,
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        
    }
    @IBAction func editPlantBtn(_ sender: Any) {
        nameTextField.isEnabled = true
        nameTextField.isUserInteractionEnabled = true
        
        sciNameTextField.isEnabled = true
        sciNameTextField.isUserInteractionEnabled = true
        
        yearTextField.isEnabled = true
        yearTextField.isUserInteractionEnabled = true
        
        familyTextField.isEnabled = true
        familyTextField.isUserInteractionEnabled = true
        
        plantName.text = "Name (Edit Textbox):"
        plantScientificName.text = "Scientific Name (Edit Textbox):"
        plantYear.text = "Year Discovered (Edit Textbox):"
        plantFamily.text = "Family (Edit Textbox):"
        
        saveButton.isHidden = false
    }
    
    @IBAction func savePlantBtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        return
    }
    
    // MARK: - Database Listener Functions
    func onExhibitionChange(change: DatabaseChange, exhibitions: [Exhibition]) {
        //           allExhibitions = exhibitions
        //
        //           for ex in exhibitions {
        //               if ex.name == name{
        //                   print("lol")
        //                   print(ex.exhibitionPlants?.allObjects as Any)
        //               }
        //           }
    }
    
    func onPlantListChange(change: DatabaseChange, exhibitionPlants: [Plant]) {
        //           allPlants = exhibitionPlants
        //           print("plant count")
        //           print(allPlants.count)
        //           plantExCollectionView.reloadData()
    }
    
}

extension UIImageView {
    func downloadedFrom1(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                var image = UIImage(data: data)
                else { return }
            image = resizeImage(image: image, newWidth: CGFloat())!
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
                
            }
        }.resume()
    }
    func downloadedFrom1(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

func resizeImage1(image: UIImage, newWidth: CGFloat) -> UIImage? {
    
    let scale = newWidth / image.size.width
    let newHeight = image.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
    image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
}
