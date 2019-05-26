//
//  ViewController.swift
//  SeeFood
//
//  Created by Jeremy Adam on 20/05/19.
//  Copyright © 2019 Underway. All rights reserved.
//

import UIKit
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //UI Element
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var pickerViewModel: UIPickerView!
    
    //Collection Variable Results Display
    @IBOutlet var txtObjectCollection: [UILabel]!
    @IBOutlet var txtConfCollection: [UILabel]!
    
    let imagePicker = UIImagePickerController()
    
    var modelSelected:MLModel = MLModel()
    let modelCollection:[String:MLModel] =
    [
        "Age - (AgeNet)" : AgeNet().model,
        "Food - (Food101)" : Food101().model,
        "Gender - (GenderNet)" : GenderNet().model,
        "NSFW - (Nudity)" : Nudity().model,
        "Object - (Inceptionv3 Acc:94,4)" : Inceptionv3().model,
        "Object - (MobileNet Acc:89,9)" : MobileNet().model,
        "Object - (Resnet50 Acc:92,2)" : Resnet50().model,
        "Object - (VGG16 Acc:92,6)" : VGG16().model,
        "Pet - (CatDog Acc:98,9)" : cat_dog_20iter_98_95eval_1().model,
        "Scene - (GoogLeNetPlaces Acc:85,4)" : GoogLeNetPlaces().model
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //For Picker View Model
        pickerViewModel.delegate = self
        pickerViewModel.dataSource = self
    
        //For ImagePicker as Camera
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        
        //Default Value of ML Model
        modelSelected = [MLModel](modelCollection.values)[0]
        
    }
    
    //Camera Button Pressed
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    //UI Image Picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            ImageView.image = userPickedimage
            
        
            detect(ImageView.image!)
            
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    //
    
    
    //UI Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return modelCollection.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return [String](modelCollection.keys)[row]
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        modelSelected = [MLModel](modelCollection.values)[row]
        if let image = ImageView.image {
            detect(image)
        }
    }
    
    //
    
    //Detect Picture
    func detect(_ image:UIImage) {
        guard let ciImage = CIImage(image: image) else {
            fatalError("Could not convert to CIIMAGE")
        }
        
        //Using CreateML Model Cat vs Dog
        guard let model = try? VNCoreMLModel(for: modelSelected) else {
            fatalError("Loading CoreML Model Failed")
        }

        let request = VNCoreMLRequest(model: model) { (req, err) in
            guard let results = req.results as? [VNClassificationObservation] else {
                fatalError("Model Failed to process image")
            }
            
            //Print Results
            print(results)
            
            for (index, item) in self.txtObjectCollection.enumerated() {
                item.text = results[index].identifier.capitalized.components(separatedBy: ",")[0]
                self.txtConfCollection[index].text = String(format: "%.2f%%",  results[index].confidence*100)
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    //


}
