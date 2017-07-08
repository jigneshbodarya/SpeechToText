//
//  RecognizerVC.swift
//  SpeechToText
//
//  Created by Malik on 7/4/17.
//  Copyright © 2017 Jignesh. All rights reserved.
//

import UIKit

class RecognizerVC: UIViewController, OEEventsObserverDelegate, UITextFieldDelegate {
    
    @IBOutlet var btnRecord:UIButton!
    @IBOutlet var txtStatus:UITextView!
    @IBOutlet var txtRecognize:UITextView!
    @IBOutlet var txtAddWords:UITextField!
    //Creating object of FliteController, Slt and OEEventsObserver
    var fliteController = OEFliteController()
    var slt = Slt()
    var openEarsEventsObserver = OEEventsObserver()
    
    var words: Array<String> = []
    var lmPath: String!
    var dicPath: String!
    var buttonFlashing = false
    
    //MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.openEarsEventsObserver = OEEventsObserver()
        self.openEarsEventsObserver.delegate = self
        self.settingUpOpenEars()
        
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 5))
        self.txtAddWords.leftView = v;
        self.txtAddWords.leftViewMode = .always
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*======================================================
     * Method Name: btnAddTap
     * Parameter: sener:UIButton
     * Return Type: nil
     * Purpose: To add new words in dictionary
     *======================================================*/
    @IBAction func btnAddTap(sener:UIButton) {
        if self.txtAddWords.text != "" {
            self.words.append(self.txtAddWords.text!)
            self.txtAddWords.text = ""
            self.stopListening()
            self.settingUpOpenEars()
            self.startListening()
        }
        self.txtAddWords.resignFirstResponder()
    }
    
    //MARK: - Other Methods
    /*======================================================
     * Method Name: settingUpOpenEars()
     * Parameter: nil
     * Return Type: nil
     * Purpose: To set EventsObserver and specifying model to recognize text from speech
     *======================================================*/
    func settingUpOpenEars() {
        let lmGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
        
        addWords()
        let name = "LanguageModelFileStarSaver"
        lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name)
        
    }
    
    /*======================================================
     * Method Name: addWords()
     * Parameter: nil
     * Return Type: nil
     * Purpose: To creating word to recognize from speech
     *======================================================*/
    func addWords() {
        //add any thing here that you want to be recognized. Must be in capital letters
        words.append("WorkOrder")
        words.append("CREATEWorkOrder")
        words.append("CHECKIN")
        words.append("CHECKOUT")
        words.append("SEARCH")
        words.append("REPORT")
        words.append("HELP")
        words.append("START")
        words.append("STOP")
        words.append("FIND")
        words.append("PURCHASE")
       /* words.append("FRIDAY")
        words.append("SATURDAY")
        words.append("MEN")
        words.append("WOMEN")
        words.append("HI")
        words.append("HELLO")
        words.append("HOW")
        words.append("ARE")
        words.append("YOU")
        words.append("THANKS")
        words.append("JANUARY")
        words.append("FEBRUARY")
        words.append("MARCH")
        words.append("APRIL")
        words.append("MAY")
        words.append("JUNE")
        words.append("JULY")
        words.append("AUGUST")
        words.append("SEPTEMBER")
        words.append("OCTOBER")
        words.append("NOVEMBER")
        words.append("DECEMBER")*/
    }
    
    /*======================================================
     * Method Name: startListening
     * Parameter: nil
     * Return Type: nil
     * Purpose: To start lisning of speech
     *======================================================*/
    func startListening() {
        do{
            try OEPocketsphinxController.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    /*======================================================
     * Method Name: stopListening
     * Parameter: nil
     * Return Type: nil
     * Purpose: To stop recognization
     *======================================================*/
    func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
    }
    
    /*======================================================
     * Method Name: startFlashingbutton
     * Parameter: nil
     * Return Type: nil
     * Purpose: To start animation of flashing button while recognizing
     *======================================================*/
    func startFlashingbutton() {
        buttonFlashing = true
        btnRecord.alpha = 1
        UIView.animate(withDuration: 0.5 , delay: 0.0, options: [UIViewAnimationOptions.curveEaseInOut , UIViewAnimationOptions.repeat , UIViewAnimationOptions.autoreverse , UIViewAnimationOptions.allowUserInteraction], animations: {
            self.btnRecord.alpha = 0.1
        }, completion: {Bool in
        })
    }
    
    /*======================================================
     * Method Name: stopFlashingbutton
     * Parameter: nil
     * Return Type: nil
     * Purpose: To stop animation of flashing button
     *======================================================*/
    func stopFlashingbutton() {
        
        buttonFlashing = false
        //        Stop animation of speech recognization
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [UIViewAnimationOptions.curveEaseInOut , UIViewAnimationOptions.beginFromCurrentState], animations: {
            self.btnRecord.alpha = 1
        }, completion: {Bool in
        })
    }
    /*======================================================
     * Method Name: btnStartRecignizeTap
     * Parameter: sender: UIButton
     * Return Type: nil
     * Purpose: To start/stop recognize of text
     *======================================================*/
    @IBAction func btnStartRecignizeTap(sender: UIButton) {
        if !buttonFlashing {
            startFlashingbutton()
            startListening()
        } else {
            stopFlashingbutton()
            stopListening()
        }
    }
    
    //MARK: - OEEventsObserverDelegate delegate methods
    
    func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        self.txtRecognize.text = self.txtRecognize.text + " \(hypothesis!)\n"
    }
    
    // An optional delegate method of OEEventsObserver which informs that the Pocketsphinx recognition loop has entered its actual loop.
    // This might be useful in debugging a conflict between another sound class and Pocketsphinx.
    func pocketsphinxRecognitionLoopDidStart() {
        print("Local callback: Pocketsphinx started.")
        self.txtStatus.text = "Pocketsphinx started."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is now listening for speech.
    func pocketsphinxDidStartListening() {
        print("Local callback: Pocketsphinx is now listening.") // Log it.
        self.txtStatus.text = "Pocketsphinx is now listening."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected speech and is starting to process it.
    func pocketsphinxDidDetectSpeech() {
        print("Local callback: Pocketsphinx has detected speech.")
        self.txtStatus.text = " Pocketsphinx has detected speech."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx detected a second of silence, indicating the end of an utterance.
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Local callback: Pocketsphinx has detected a second of silence, concluding an utterance.")
        self.txtStatus.text = "Pocketsphinx has detected a second of silence, concluding an utterance."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx has exited its recognition loop, most
    // likely in response to the OEPocketsphinxController being told to stop listening via the stopListening method.
    func pocketsphinxDidStopListening() {
        print("Local callback: Pocketsphinx has stopped listening.")
        self.txtStatus.text = "Pocketsphinx has stopped listening."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop but it is not
    // Going to react to speech until listening is resumed. This can happen as a result of Flite speech being
    // in progress on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to suspend recognition via the suspendRecognition method.
    func pocketsphinxDidSuspendRecognition() {
        print("Local callback: Pocketsphinx has suspended recognition.")
        self.txtStatus.text = "Local callback: Pocketsphinx has suspended recognition."
    }
    
    // An optional delegate method of OEEventsObserver which informs that Pocketsphinx is still in its listening loop and after recognition
    // having been suspended it is now resuming. This can happen as a result of Flite speech completing
    // on an audio route that doesn't support simultaneous Flite speech and Pocketsphinx recognition,
    // or as a result of the OEPocketsphinxController being told to resume recognition via the resumeRecognition method.
    func pocketsphinxDidResumeRecognition() {
        print("Local callback: Pocketsphinx has resumed recognition.")
        self.txtStatus.text = "Local callback: Pocketsphinx has resumed recognition."
    }
    
    // An optional delegate method which informs that Pocketsphinx switched over to a new language model at the given URL in the course of
    // recognition. This does not imply that it is a valid file or that recognition will be successful using the file.
    func pocketsphinxDidChangeLanguageModel(toFile newLanguageModelPathAsString: String!, andDictionary newDictionaryPathAsString: String!) {
        print("Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)")
        self.txtStatus.text = "Local callback: Pocketsphinx is now using the following language model: \n\(newLanguageModelPathAsString!) and the following dictionary: \(newDictionaryPathAsString!)"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is speaking, most likely to be useful if debugging a
    // complex interaction between sound classes. You don't have to do anything yourself in order to prevent Pocketsphinx from listening to Flite talk and trying to recognize the speech.
    func fliteDidStartSpeaking() {
        print("Local callback: Flite has started speaking") // Log it.
        self.txtStatus.text = "Local callback: Flite has started speaking"
    }
    
    // An optional delegate method of OEEventsObserver which informs that Flite is finished speaking, most likely to be useful if debugging a
    // complex interaction between sound classes.
    func fliteDidFinishSpeaking() {
        print("Local callback: Flite has finished speaking") // Log it.
        self.txtStatus.text = "Local callback: Flite has finished speaking"
    }
    
    func pocketSphinxContinuousSetupDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on [OELogging startOpenEarsLogging] to learn why.
        print("Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more.") // Log it.
        self.txtStatus.text = "Local callback: Setting up the continuous recognition loop has failed for the reason \(reasonForFailure), please turn on OELogging.startOpenEarsLogging() to learn more."
    }
    
    func pocketSphinxContinuousTeardownDidFail(withReason reasonForFailure: String!) { // This can let you know that something went wrong with the recognition loop startup. Turn on OELogging.startOpenEarsLogging() to learn why.
        print("Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)") // Log it.
        self.txtStatus.text = "Local callback: Tearing down the continuous recognition loop has failed for the reason \(reasonForFailure)"
    }
    
    /** Pocketsphinx couldn't start because it has no mic permissions (will only be returned on iOS7 or later).*/
    func pocketsphinxFailedNoMicPermissions() {
        self.txtStatus.text = "Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start."
    }
    
    /** The user prompt to get mic permissions, or a check of the mic permissions, has completed with a true or a false result (will only be returned on iOS7 or later).*/
    func micPermissionCheckCompleted(withResult: Bool) {
        print("Local callback: mic check completed.")
        self.txtStatus.text = "Local callback: mic check completed."
    }
    
    //MARK: - TextField Delegate methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtAddWords.resignFirstResponder()
        return true
    }
}
