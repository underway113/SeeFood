//
//  ViewController.swift
//  SeeFood
//
//  Created by Jeremy Adam on 20/05/19.
//  Copyright © 2019 Underway. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ImageView: UIImageView!
    
    //Collection Variable Display    
    
    @IBOutlet var txtObjectCollection: [UILabel]!
    @IBOutlet var txtConfCollection: [UILabel]!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            ImageView.image = userPickedimage
            
            guard let ciImage = CIImage(image: userPickedimage) else {
                fatalError("Could not conver to CIIMAGE")
            }
            detect(ciImage)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    func detect(_ image:CIImage) {
        
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (req, err) in
            guard let results = req.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to process image")
            }
            
//            print(results)
            
            for (index, item) in self.txtObjectCollection.enumerated() {
                item.text = results[index].identifier.capitalized.components(separatedBy: ",")[0]
                self.txtConfCollection[index].text = String(format: "%.2f%%",  results[index].confidence*100)
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }


}

