//
//  ConfirmSendView.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 24-08-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class ConfirmSendView: UIView {

    @IBOutlet weak var sendingAmountLabel: UILabel!
    @IBOutlet weak var transactionFeeAmountLabel: UILabel!
    @IBOutlet weak var totalXvgAmountLabel: UILabel!
    @IBOutlet weak var totalFiatAmountLabel: UILabel!
    @IBOutlet weak var recipientAddressLabel: UILabel!

    var transaction: SendTransaction!
    var margin: CGFloat {
        if #available(iOS 12.0, *) {
            return 8.0
        } else {
            return 10.0
        }
    }

    func makeActionSheet() -> UIAlertController {
        let viewHeight: CGFloat = subviews.first?.frame.height ?? 0
        let lineHeight: CGFloat = 18.33
        let times = (viewHeight / lineHeight).rounded()
        let enters: String = String(repeating: "\n", count: Int(times))

        let alertController = UIAlertController(title: enters, message: nil, preferredStyle: .actionSheet)

        frame = CGRect(
            x: 0,
            y: 0,
            width: alertController.view.bounds.size.width - margin * 2.0,
            height: viewHeight
        )

        let container = UIView(frame: frame)
        container.addSubview(self)

        alertController.view.addSubview(container)

        return alertController
    }

    func setTransaction(_ transaction: SendTransaction) {
        self.transaction = transaction

        updateTransactionValues()
    }

    func updateTransactionValues() {
        if let xvgInfo = PriceTicker.shared.xvgInfo {
            let totalXVG = transaction.amount.doubleValue + Config.fee
            let totalFiat = totalXVG * xvgInfo.price

            sendingAmountLabel.text = transaction.amount.toCurrency(currency: "XVG")
            transactionFeeAmountLabel.text = NSNumber(floatLiteral: Config.fee).toCurrency(currency: "XVG")

            totalXvgAmountLabel.text = NSNumber(floatLiteral: (transaction.amount.doubleValue + Config.fee)).toCurrency(
                currency: "XVG",
                fractDigits: 6
            )

            totalFiatAmountLabel.text = NSNumber(floatLiteral: totalFiat).toCurrency(
                currency: ApplicationManager.default.currency,
                fractDigits: 6
            )

            recipientAddressLabel.text = transaction.address
        }
    }
    
}
