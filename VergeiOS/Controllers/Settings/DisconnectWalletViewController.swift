//
//  DisconnectWalletViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 23-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class DisconnectWalletViewController: UIViewController {

    var applicationRepository: ApplicationRepository!
    var transactionManager: TransactionManager!
    var walletTicker: WalletTicker!
    var fiatRateTicker: FiatRateTicker!
    var torClient: TorClient!

    @IBAction func disconnectWallet(_ sender: Any) {
        let alert = UIAlertController(
            title: "Disconnect Wallet",
            message: "Your about to disconnect this device from your current wallet. " +
                "Please make absolutely sure you have written down your paperkey. " +
                "Remember that your paperkey is the only way to restore your current wallet.",
            preferredStyle: .alert
        )

        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let confirm = UIAlertAction(title: "Disconnect", style: .destructive) { action in
            // Show unlock view.
            let pinUnlockView = PinUnlockViewController.createFromStoryBoard()
            pinUnlockView.cancelable = true
            pinUnlockView.completion = { authenticated in
                if authenticated {
                    pinUnlockView.dismiss(animated: true) {
                        self.performSegue(withIdentifier: "disconnectWallet", sender: self)
                    }
                    
                    // Reset wallet manager.
                    // @TODO: Move to event.
                    self.transactionManager.removeAll()
                    self.applicationRepository.reset()
                    self.fiatRateTicker.stop()
                    self.walletTicker.stop()
                    self.torClient.resign()
                } else {
                    pinUnlockView.dismiss(animated: true)
                }
            }
            
            self.present(pinUnlockView, animated: true)
         }

        alert.addAction(cancel)
        alert.addAction(confirm)

        present(alert, animated: true)
    }

}
