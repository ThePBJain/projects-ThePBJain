//
//  ViewController.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/14/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var buildingImageView: UIImageView!
    @IBOutlet weak var buildingNameLabel: UILabel!
    @IBOutlet weak var buildingYearLabel: UILabel!
    @IBOutlet weak var buildingTextView: UITextView!
    
    let walkModel = WalkModel.sharedInstance
    let imagePicker = UIImagePickerController()
    let bufferHeight : CGFloat = 20.0
    var indexPath : IndexPath?
    weak var delegate : BuildingTableViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure main image.
        if walkModel.buildingImage(at: self.indexPath!) != nil {
            buildingImageView.image = walkModel.buildingImage(at: self.indexPath!)
        }else if !walkModel.buildingPhoto(at: self.indexPath!)!.isEmpty {
            buildingImageView.image = UIImage(named: walkModel.buildingPhoto(at: indexPath!)!)
        }
        
      
        imagePicker.delegate = self
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //setup rest of labels and views
        if let ip = self.indexPath {
            buildingNameLabel.text = walkModel.buildingName(at: ip)
            let year = walkModel.buildingYear(at: ip)
            if year != nil && year! > 0 {
                buildingYearLabel.text = "\(walkModel.buildingYear(at: ip)!)"
            }else{
                buildingYearLabel.text = ""
            }
            buildingTextView.text = walkModel.buildingText(at: ip) ?? "Insert Notes Here."
        }
        
        //Keyboard Manager
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    override func viewDidLayoutSubviews()
    {
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        buildingTextView.isEditable = editing
        var height : CGFloat = 0.0
        for subview in infoView.subviews {
            let subviewDepth = subview.frame.origin.y + subview.frame.size.height
            if subviewDepth > height {
                height = subviewDepth
            }
        }
        print(height)
        height += self.bufferHeight
        scrollView.contentSize.height = height
        //save here
        if walkModel.editBuildingText(at: self.indexPath!, with: buildingTextView.text)  {
            buildingTextView.isEditable = editing
        }else{
            assert(true, "Failed to save properly")
        }
    }
    
    func configureView(with indexPath: IndexPath){
        self.indexPath = indexPath
        
    }
    
    
    @IBAction func closeInfoView(_ sender: Any) {
        delegate?.dismissMe()
    }
    
    //MARK: - Manage Keyboard layout
    
    
    @objc func keyboardWillBeShown(_ notification: Notification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height + self.bufferHeight, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.scrollView.contentOffset.y = self.scrollView.contentOffset.y + keyboardSize!.height
        /*var aRect : CGRect = self.view.frame
         aRect.size.height -= keyboardSize!.height
         if let activeField = self.activeField {
         if (!aRect.contains(activeField.frame.origin)){
         self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
         }
         }*/
    }
    
    @objc func keyboardWillBeHidden(_ notification: Notification){
        //Once keyboard disappears, restore original positions
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
    }
    
    //MARK: - Image Picker Handlers
    
    //worked with Jacky and Hedgie on this.
    
    @IBAction func changePhoto(_ sender: Any) {
        actionSheet()
    }
    
    func actionSheet(){
        let actionSheet = UIAlertController(title: "Get Image from...", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
            self.takePhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default, handler: { (alert: UIAlertAction!) in
            self.galleryPhoto()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func takePhoto(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            
            imagePicker.allowsEditing = false
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker,animated: true,completion: nil)
        }
        else {
            let alert = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera. Please upload a picture from the gallery.", preferredStyle: .alert)
            let dismiss = UIAlertAction(title: "Dismiss", style:.default, handler: nil)
            alert.addAction(dismiss)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func galleryPhoto(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.modalPresentationStyle = .popover
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        buildingImageView.contentMode = .scaleAspectFit
        buildingImageView.image = image
        if walkModel.editBuildingImage(at: self.indexPath!, with: image) {
            buildingImageView.setNeedsDisplay()
        }
        dismiss(animated:true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

