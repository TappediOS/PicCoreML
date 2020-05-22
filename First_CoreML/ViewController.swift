//
//  ViewController.swift
//  First_CoreML
//
//  Created by jun on 2018/03/14.
//  Copyright © 2018年 jun. All rights reserved.
//

import UIKit
import CoreML
import Vision
import GoogleMobileAds
import FirebaseAnalytics
import Firebase
import SnapKit
import NVActivityIndicatorView

class ViewController: UIViewController, GADBannerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
   let imageView = UIImageView()
   let resultLabel = UILabel()

   
   //ad
   var bannreView: GADBannerView = GADBannerView()
   var interstitial: GADInterstitial!
   let request:GADRequest = GADRequest()
   let BANNER_VIEW_TEST_ID: String = "ca-app-pub-3940256099942544/2934735716"
   var BANNER_VIEW_HIGHT: CGFloat = 50
   
   let ChoseAndSelectButtonHight: CGFloat = 60
   
   let ChosePhotoButton = UIButton()
   let TakePhotoButton = UIButton()
   
   var LoadActivityView: NVActivityIndicatorView?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.viewSetting()
      self.InitImageView()
      self.InitResultLabel()
      self.InitChosePhotoButton()
      self.InitTakePhotoButton()
      self.InitButtonCommonProcessing(button: ChosePhotoButton)
      self.InitButtonCommonProcessing(button: TakePhotoButton)
      self.InitAdBannerView()
      self.InitLoadActivityView()
   }
   
   //safeArea取得するために必要。
   override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      self.SNPChosePhotoButton()
      self.SNPTakePhotoButton()
      self.SNPAdBannerView()
      self.SNPImageView()
      self.SNPResultLabel()
   }
   
   private func SNPChosePhotoButton() {
      let safeAreaIns_Buttom = self.view.safeAreaInsets.bottom
      self.ChosePhotoButton.snp.makeConstraints{ make in
         make.height.equalTo(ChoseAndSelectButtonHight)
         make.width.equalTo(self.view.frame.width / 23 * 10)
         make.leading.equalTo(self.view.snp.leading).offset(self.view.frame.width / 23 * 1)
         if #available(iOS 11, *) {
            make.bottom.equalTo(self.view.snp.bottom).offset(-(safeAreaIns_Buttom + 15))
         } else {
            make.bottom.equalTo(self.view.snp.bottom).offset(0)
         }
      }
   }
   
   private func SNPTakePhotoButton() {
      let safeAreaIns_Buttom = self.view.safeAreaInsets.bottom
      self.TakePhotoButton.snp.makeConstraints{ make in
         make.height.equalTo(ChoseAndSelectButtonHight)
         make.width.equalTo(self.view.frame.width / 23 * 10)
         make.leading.equalTo(self.ChosePhotoButton.snp.trailing).offset(self.view.frame.width / 23 * 1)
         if #available(iOS 11, *) {
            make.bottom.equalTo(self.view.snp.bottom).offset(-(safeAreaIns_Buttom + 15))
         } else {
            make.bottom.equalTo(self.view.snp.bottom).offset(0)
         }
      }
   }
   
   private func SNPAdBannerView() {
      self.bannreView.snp.makeConstraints{ make in
         make.height.equalTo(BANNER_VIEW_HIGHT)
         make.width.equalTo(self.view.frame.width)
         make.leading.equalTo(self.view.snp.leading).offset(0)
         if #available(iOS 11, *) {
            make.top.equalTo(self.view.snp.top).offset(self.view.safeAreaInsets.top)
         } else{
            make.top.equalTo(self.view.snp.top).offset(0)
         }
      }
   }
   private func SNPImageView() {
      self.imageView.snp.makeConstraints{ make in
         make.top.equalTo(self.bannreView.snp.bottom).offset(16)
         make.width.equalTo(self.view.frame.width / 23 * 21)
         make.leading.equalTo(self.view.snp.leading).offset(self.view.frame.width / 23 * 1)
         make.bottom.equalTo(self.resultLabel.snp.top).offset(-10)
      }
   }
   private func SNPResultLabel() {
      self.resultLabel.snp.makeConstraints{ make in
         make.bottom.equalTo(self.ChosePhotoButton.snp.top).offset(-15)
         make.width.equalTo(self.view.frame.width / 23 * 21)
         make.leading.equalTo(self.view.snp.leading).offset(self.view.frame.width / 23 * 1)
         make.height.equalTo(230)
      }
   }
   
   private func viewSetting() {
      if #available(iOS 13.0, *) {
         view.backgroundColor = .systemBackground
      } else {
         // Fallback on earlier versions
      }
   }
   
   private func InitImageView() {
      imageView.accessibilityIgnoresInvertColors = true
      imageView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.2)
      imageView.layer.cornerRadius = 10
      imageView.clipsToBounds = true
      imageView.contentMode = .scaleAspectFill
      view.addSubview(imageView)
   }
   
   private func InitResultLabel() {
      resultLabel.numberOfLines = 0
      resultLabel.font = UIFont(name: "Helvetica", size: 18)
      resultLabel.adjustsFontSizeToFitWidth = true
      resultLabel.layer.cornerRadius = 10
      resultLabel.clipsToBounds = true
      resultLabel.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
      view.addSubview(resultLabel)
   }
   
   private func InitChosePhotoButton() {
      ChosePhotoButton.addTarget(self, action: #selector(self.tapSelectBtn), for: .touchUpInside)
      ChosePhotoButton.setTitle(NSLocalizedString("Select", comment: ""), for: .normal)
      ChosePhotoButton.setTitleColor(.white, for: .normal)
      ChosePhotoButton.backgroundColor = .systemTeal
      view.addSubview(ChosePhotoButton)
   }
   
   private func InitTakePhotoButton() {
      TakePhotoButton.addTarget(self, action: #selector(self.startCamera), for: .touchUpInside)
      TakePhotoButton.setTitle(NSLocalizedString("TakePhoto", comment: ""), for: .normal)
      TakePhotoButton.setTitleColor(.white, for: .normal)
      TakePhotoButton.backgroundColor = .systemGreen
      view.addSubview(TakePhotoButton)
   }
   
   private func InitLoadActivityView() {
      let spalete: CGFloat = 5
      let Viewsize = self.view.frame.width / spalete
      let StartX = self.view.frame.width / 2 - (Viewsize / 2)
      let StartY = self.view.frame.height / 2 - (Viewsize / 2)
      let Rect = CGRect(x: StartX, y: StartY, width: Viewsize, height: Viewsize)
      LoadActivityView = NVActivityIndicatorView(frame: Rect, type: .ballPulseSync, color: UIColor.systemPink, padding: 0)
      self.view.addSubview(LoadActivityView!)
   }
   
   func StartLoadingAnimation() { self.LoadActivityView?.startAnimating() }
   
   public func StopLoadingAnimation() {
      if self.LoadActivityView?.isAnimating == true {
         self.LoadActivityView?.stopAnimating()
      }
   }
   
   private func InitButtonCommonProcessing(button: UIButton) {
      button.layer.cornerRadius = 10
   }
   
   private func InitAdBannerView() {
      //ad
      print("\n--------INFO ADMOB--------------\n")
      print("Google Mobile ads SDK Versioin -> " + GADRequest.sdkVersion())
      
      
      #if DEBUG
      bannreView.adUnitID = BANNER_VIEW_TEST_ID
      #else
      bannreView.adUnitID = "ca-app-pub-1460017825820383/2681477233"
      #endif
      
      bannreView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: BANNER_VIEW_HIGHT)
      view.addSubview(bannreView)
      view.bringSubview(toFront: bannreView)
      
//      let frame = { () -> CGRect in
//         return view.frame.inset( by: view.safeAreaInsets)
//      }()
      let viewWidth = self.view.frame.width
      let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
      BANNER_VIEW_HIGHT = adSize.size.height
      bannreView.adSize = adSize
      
      bannreView.delegate = self
      bannreView.rootViewController = self
      bannreView.load(request)
   }
   
   @objc func tapSelectBtn() {
      Analytics.logEvent("SelectImage", parameters: nil)
      let SelectedPhone = UIImagePickerController()
      SelectedPhone.delegate = self
      present(SelectedPhone, animated: true)
   }
   
   // Start Take Photo
   @IBAction func startCamera(_ sender : AnyObject) {
      
      Analytics.logEvent("TakeImage", parameters: nil)
      
      let sourceType:UIImagePickerControllerSourceType =
         UIImagePickerControllerSourceType.camera
      
      // Can you use your camera
      if UIImagePickerController.isSourceTypeAvailable(
         UIImagePickerControllerSourceType.camera){
         
         // create instanse
         let CameraPickerer = UIImagePickerController()
         CameraPickerer.sourceType = sourceType
         CameraPickerer.delegate = self
         self.present(CameraPickerer, animated: true, completion: nil)
      }else{
         print("errer 1")
      }
   }
   
   func getLanguage() -> TranslateLanguage {
      let language = NSLocale.preferredLanguages[0].components(separatedBy: "-")[0]
      print(language)
      print(NSLocale.preferredLanguages)
      switch language {
      case "ja":
         return .ja
      case "ko":
         return .ko
      case "de":
         return .de
      case "nl":
         return .nl
      case "es":
         return .es
      case "zh":
         return .zh
      default:
         return .en
      }
   }
   
   func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
      
      if let image = info[UIImagePickerControllerOriginalImage] as? UIImage, let model = try? VNCoreMLModel(for: MobileNet().model) {
         imageView.image = image
         //imageView.backgroundColor = .none
         imagePicker.dismiss(animated: true, completion: nil)
         self.StartLoadingAnimation()
         
         let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else { return }
   
            let options = TranslatorOptions(sourceLanguage: .en, targetLanguage: self.getLanguage())
            let englishGermanTranslator = NaturalLanguage.naturalLanguage().translator(options: options)
            
   
      
            let conditions = ModelDownloadConditions(allowsCellularAccess: false, allowsBackgroundDownloading: true)
            
            var ResutlStr: [String] = Array()
            
            
            var count = 0
            for result in results[0...4] {
               
               englishGermanTranslator.downloadModelIfNeeded(with: conditions) { error in
                  guard error == nil else { return }
                  englishGermanTranslator.translate(result.identifier) { translatedText, error in
                     guard error == nil, let translatedText = translatedText else { return }
                                       
                     print(translatedText + ": " + String(NSString(format: "%.2f", result.confidence).doubleValue * 100) + "%")
                     ResutlStr.append(translatedText + ": " + String(NSString(format: "%.2f", result.confidence).doubleValue * 100) + "%")
                     
                     count += 1
                     if count == 5 {
                        self.resultLabel.text = NSLocalizedString("result", comment: "") + "\n" + ResutlStr.joined(separator: "\n")
                        self.StopLoadingAnimation()
                     }
                  }
               }
               
            }
      
         }
                  
         request.imageCropAndScaleOption = .centerCrop
         let handler = VNImageRequestHandler(cgImage: image.cgImage!)
         try! handler.perform([request])
      }
   }
   
   
   // 撮影中断
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      picker.dismiss(animated: true, completion: nil)
   }
   
   
   // save photo
   @IBAction func savePicture(_ sender : AnyObject) {
      let image:UIImage! = imageView.image
      
      if image != nil {
         UIImageWriteToSavedPhotosAlbum(image, self,
                                        #selector(ViewController.image(_:didFinishSavingWithError:contextInfo:)),
                                        nil)
      }
      else{
         print("Faild")
      }
   }
   
   @objc func image(_ image: UIImage,
                    didFinishSavingWithError error: NSError!,
                    contextInfo: UnsafeMutableRawPointer) {
      
      if error != nil {
         print(error.code)
      }
      else{
         print("save success")
      }
   }
   
   
   //MARK:- ADMOB
   /// Tells the delegate an ad request loaded an ad.
   func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("広告(banner)のロードが完了しました。")
      self.bannreView.alpha = 0
      UIView.animate(withDuration: 1, animations: {
         self.bannreView.alpha = 1
      })
   }
   
   /// Tells the delegate an ad request failed.
   func adView(_ bannerView: GADBannerView,
               didFailToReceiveAdWithError error: GADRequestError) {
      print("広告(banner)のロードに失敗しました。: \(error.localizedDescription)")
   }
   
   /// Tells the delegate that a full-screen view will be presented in response
   /// to the user clicking on an ad.
   func adViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
   }
   
   /// Tells the delegate that the full-screen view will be dismissed.
   func adViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
   }
   
   /// Tells the delegate that the full-screen view has been dismissed.
   func adViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
   }
   
   /// Tells the delegate that a user click will open another app (such as
   /// the App Store), backgrounding the current app.
   func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
   }
}

