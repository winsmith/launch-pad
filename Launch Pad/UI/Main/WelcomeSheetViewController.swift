//
//  WelcomeSheetViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 17.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class WelcomeSheetViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.isHidden = true
        openLaunchPadButton.isHidden = true
    }
    // var ckanClient: CKANClient?
    var delegate: WelcomeSheetViewControllerDelegate?

    @IBOutlet weak var kspDirLabel: NSTextField!
    @IBOutlet weak var resultLabel: NSTextField!
    @IBOutlet weak var openLaunchPadButton: NSButton!

    func updateUI(isCorrectKSPDirSelected: Bool?) {
        if isCorrectKSPDirSelected == true {
            resultLabel.stringValue = "This looks good. Hit the Launch button to continue."
            resultLabel.isHidden = false
            openLaunchPadButton.isHidden = false
        } else if isCorrectKSPDirSelected == false {
            resultLabel.stringValue = "We couldn't find a KSP installation in this folder. Please try again, and make sure you select the topmost Kerbal Space Program folder."
            resultLabel.isHidden = false
            openLaunchPadButton.isHidden = true
        } else {
            resultLabel.stringValue = "Something went wrong during initialization. Please file a bug report."
            resultLabel.isHidden = false
            openLaunchPadButton.isHidden = true
        }
    }
    
    @IBAction func selectKSPDir(_ sender: NSButton) {
        let dialog = NSOpenPanel();
        dialog.showsHiddenFiles = false;
        dialog.canChooseDirectories = true;
        dialog.canCreateDirectories = false;
        dialog.allowsMultipleSelection = false;
        dialog.canChooseFiles = false

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let pathURL = dialog.url

            if let pathURL = pathURL {
                let path = pathURL.path
                kspDirLabel.stringValue = path

                DispatchQueue.global().async {
                    // let returnValue = self.ckanClient?.addKSPDir(url: pathURL)

                    DispatchQueue.main.async {
                        NSAnimationContext.runAnimationGroup({context in
                            //configure the animation context
                            context.duration = 0.25
                            context.allowsImplicitAnimation = true

                            // self.updateUI(isCorrectKSPDirSelected: returnValue)
                            self.view.layoutSubtreeIfNeeded()

                        }, completionHandler: nil)
                    }
                }
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func openLaunchPad(_ sender: NSButton) {
        delegate?.didFinishSelectingKSPDir(sender: self)
    }
}

protocol WelcomeSheetViewControllerDelegate: class {
    func didFinishSelectingKSPDir(sender: WelcomeSheetViewController)
}
