 //
//  ViewController.swift
//  PTMobileDemo
//
//  Created by Сергей Ерошенко on 22.11.2020.
//

import UIKit

 
 class ViewController: UIViewController,
                       UIImagePickerControllerDelegate,
                       UINavigationControllerDelegate {

    //Camera Capture requiered properties
    var imagePickers:UIImagePickerController?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var inputImage: CIImage!
    
    override func viewDidLoad() {
        addCameraInView()
        super.viewDidLoad()
    }
    
    func addCameraInView(){

        imagePickers = UIImagePickerController()
        if UIImagePickerController.isCameraDeviceAvailable( UIImagePickerController.CameraDevice.rear) {
            imagePickers?.delegate = self
            imagePickers?.sourceType = UIImagePickerController.SourceType.camera

            //add as a childviewcontroller
            addChild(imagePickers!)

            // Add the child's View as a subview
            self.imageView.addSubview((imagePickers?.view)!)
            imagePickers?.view.frame = imageView.bounds
            imagePickers?.allowsEditing = false
            imagePickers?.showsCameraControls = false
            imagePickers?.view.autoresizingMask = [.flexibleWidth,  .flexibleHeight]
            }
        }
    
    private lazy var module: TorchModule = {
        if let filePath = Bundle.main.path(forResource: "model", ofType: "pt"),
           let module = TorchModule(fileAtPath: filePath) {
            return module
        } else {
            fatalError("Can't find the module file!")
        }
    }()
    
    private lazy var labels: [String] = {
        if let filePath = Bundle.main.path(forResource: "words", ofType: "txt"),
            let labels = try? String(contentsOfFile: filePath) {
            return labels.components(separatedBy: .newlines)
        } else {
            fatalError("Can't find the text file!")
        }
    } ()
    
    @IBAction func openFile(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .savedPhotosAlbum
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        textView.text = "Press Infer, please."
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
            else { fatalError("no image from image picker") }
        
        imageView.image = selectedImage
    }
    
    @IBAction func inferNow(_ sender: Any) {

        let resizedImage = imageView.image!.resized(to: CGSize(width: 224, height: 224))

        guard var pixelBuffer = resizedImage.normalized() else {
            return
        }

        guard var outputs = module.predict(image: UnsafeMutableRawPointer(&pixelBuffer)) else {
            return
        }
        let zippedResults = zip(labels.indices, outputs)
        let sortedResults = zippedResults.sorted { $0.1.floatValue > $1.1.floatValue }.prefix(3)
        var text = ""
        for result in sortedResults {
            text += "\u{2022} \(labels[result.0]) \n\n"
        }
        textView.text = text

    }
    
}
