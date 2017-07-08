# SpeechToText
SpeechToText using OpenEars Library

## Requirements
To use this sample code you have to
- Xcode 8+
- iOS 8+

## Usage Discription
This sample project is design for words recognization from specified list of words.

*Step to use it*
1) Download or clone this code
2) Open in Xcode
3) Coneect device(iPhone,iPad)
4) Press 'cmd + R' to run project
5) Allow Permission for mic to recognize words while you speak.
6) Add Words which you use for recognization.
7) Start Speech recognization button.
8) Say words that you alrady added.

### How to use this code

`OEEventsObserver`
This class continuosly observing while you speaking with its delegate methods
for delegate methods you have to implements `OEEventsObserverDelegate`

do not forgot to intialize and set delegate before use it
like
`` self.openEarsEventsObserver = OEEventsObserver()
`  self.openEarsEventsObserver.delegate = self`

`OELanguageModelGenerator`
This class is use to generate Language model and allow adds words for recognization.
```
        let name = "LanguageModelFileStarSaver"
        lmGenerator.generateLanguageModel(from: words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"))
        
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModel(withRequestedName: name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionary(withRequestedName: name)
```

`OEPocketsphinxController`
this controller use to start recognization and need to laguage model dictionary for recognize words with laguages here is a sample code.

```
        do{
            try OEPocketsphinxController.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModel(atPath: lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.path(toModel: "AcousticModelEnglish"), languageModelIsJSGF: false)
```

Delegate methods where you can get words while recognization is
```
func pocketsphinxDidReceiveHypothesis(_ hypothesis: String!, recognitionScore: String!, utteranceID: String!) { // Something was heard
        print("Local callback: The received hypothesis is \(hypothesis!) with a score of \(recognitionScore!) and an ID of \(utteranceID!)")
        self.txtRecognize.text = self.txtRecognize.text + " \(hypothesis!)\n"
}
```
 
 You can add static words list by adding words in 'addWords()' method
 ```
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
        words.append("PURCHASE")
 }
```

To stop recognization speech recognization
```
func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
}
```
