//
//  ViewController.swift
//  System View Controllers
//
//  Created by Evgeniy Goncharov on 14.09.2021.
//

import MessageUI
import UIKit
import SafariServices

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - UIViewController Methods
    override func viewDidLoad() {
        updateUI(with: view.bounds.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateUI(with: size)
    }
    
    // MARK: - UI Methods
    func updateUI(with size: CGSize){
        let isVertical = size.width < size.height
        stackView.axis = isVertical ? .vertical : .horizontal
    }
    
    // MARK: - Methods
    // Get documentDirectoryPath
    func getDocumentsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // Save image and return Data image
    func saveJpg(_ image: UIImage) -> Data? {
        if let jpgData = image.jpegData(compressionQuality: 0.5),
           let path = getDocumentsDirectory()?.appendingPathComponent("attachement.jpg") {
            //print(#line, #function, path)
            try? jpgData.write(to: path)
            return try? Data(contentsOf: path)
        } else { return nil }
    
    }
    
    // Show Alert message
    func showAlert(title: String?, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - IBActions
    // Share Button
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender
        self.present(activityController, animated: true, completion: nil)
    }
    // Safari Button
    @IBAction func safariButtonPressed(_ sender: UIButton) {
        let url = URL(string: "http://apple.com")
        let safari = SFSafariViewController(url: url!)
        self.present(safari, animated: true, completion: nil)
    }
    // Camera Button
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Please Choose Image Source", message: nil, preferredStyle: .actionSheet)
        let imagePiker = UIImagePickerController()
        imagePiker.delegate = self
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                imagePiker.sourceType = .camera
                self.present(imagePiker, animated: true, completion: nil)
                
            }
            alert.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                imagePiker.sourceType = .photoLibrary
                self.present(imagePiker, animated: true)
                print(#line,#function, "Photo Library selected")
            }
            alert.addAction(photoLibraryAction)
        }
        
        alert.popoverPresentationController?.sourceView = sender
        self.present(alert, animated: true, completion: nil)
    }
    
    // Email Button
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        guard MFMailComposeViewController.canSendMail() else {
            showAlert(title: "Sorry Bro", message: "Mail services are not available")
            print("Mail services are not available")
            return
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.delegate = self
        
        // Configure the field of the interface
        mailComposer.setToRecipients(["tcook@apple.com"])
        mailComposer.setSubject("Hello from Russia")
        mailComposer.setMessageBody("Hello Tim, how are you?  \n Look my attachement file 👍", isHTML: false)
        
        // Get Image Data
        let imageData = saveJpg(imageView.image!)
        
        // Atachem file
        mailComposer.addAttachmentData(imageData!, mimeType: "image/jpeg", fileName: "attachement.jpg")
        // Present the view controller modally.
        self.present(mailComposer, animated: true, completion: nil)
        
    }
}

// MARK: - Extension
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        imageView.image = selectedImage
        dismiss(animated: true)
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
        
        // Check the result or perform other tasks.
        switch (result) {
        case .cancelled:
            showAlert(title: "Cancelled", message: "You cancelled sending this email.")
            print("You cancelled sending this email.")
            break
        case .saved:
            showAlert(title: "Saved", message: "You saved a draft of this email")
            print("You saved a draft of this email")
            break
        case .sent:
            showAlert(title: "Sent", message: "You sent the email.")
            print("You sent the email.")
            break
        case .failed:
            showAlert(title: "Failed", message: "Mail failed:  An error occurred when trying to compose this email")
            print("Mail failed:  An error occurred when trying to compose this email")
            break
        default:
            showAlert(title: "Error", message: "An error occurred when trying to compose this email")
            print("An error occurred when trying to compose this email")
            break
        }
        
    }
}

