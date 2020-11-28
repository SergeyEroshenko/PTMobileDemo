 //
//  ViewController.swift
//  PTMobileDemo
//
//  Created by Сергей Ерошенко on 22.11.2020.
//

import UIKit

 class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    var inputImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let image = UIImage(named: "kitten.jpg") else {
            fatalError("no starting image")
        }
        
        imageView.image = image
        
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
   
    @IBAction func openFile(_ sender: Any) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .savedPhotosAlbum
        present(pickerController, animated: true)
    }
    /*
    private func imagePickerController(_ picker: UIImagePickerController,
                                       didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        textView.text = "Analyzing Image…"
        imageView.image = nil
        
    }
    */
    @IBAction func takePicture(_ sender: Any) {
        /*
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        present(picker, animated: true)
         */
    }

        
}
