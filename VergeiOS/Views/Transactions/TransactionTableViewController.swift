//
//  TransactionTableViewController.swift
//  VergeiOS
//
//  Created by Swen van Zanten on 10-09-18.
//  Copyright © 2018 Verge Currency. All rights reserved.
//

import UIKit

class TransactionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var tableView: PlaceholderTableView!
    
    let addressBookManager = AddressBookManager()
    var scrollViewEdger: ScrollViewEdger!
    
    var transaction: Transaction?
    var items: [Transaction] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let transaction = transaction {
            setTransaction(transaction)
            loadTransactions(transaction)
        }
        
        scrollViewEdger = ScrollViewEdger(scrollView: tableView)
        scrollViewEdger.hideBottomShadow = true
        
        DispatchQueue.main.async {
            self.scrollViewEdger.createShadowViews()
            // Select the current transaction.
            self.selectCurrentTransaction()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTransaction(_ transaction: Transaction) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateTimeLabel.text = dateFormatter.string(from: transaction.time)
        
        if let name = addressBookManager.name(byAddress: transaction.address) {
            nameLabel.text = name
        } else {
            nameLabel.text = transaction.address.truncated(limit: 6, position: .tail, leader: "******")
        }
        
        var prefix = ""
        if transaction.category == .Send {
            amountLabel.textColor = UIColor.vergeRed()
            iconImageView.image = UIImage(named: "Payment")
            
            prefix = "-"
        } else {
            amountLabel.textColor = UIColor.vergeGreen()
            iconImageView.image = UIImage(named: "Receive")
            
            prefix = "+"
        }
        
        amountLabel.text = "\(prefix) \(transaction.amount.toCurrency(currency: "XVG", fractDigits: 2))"
    }
    
    func loadTransactions(_ transaction: Transaction) {
        let transactions = WalletManager.default
            .getTransactions(offset: 0, limit: 7).sorted { a, b in
                return a.blockindex > b.blockindex
            }
            .filter { item in
                return item.address == transaction.address
            }
        
        items = transactions
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Transaction Details"
        }
        
        return "Transaction History"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.secondaryDark()
        header.textLabel?.font = UIFont.avenir(size: 17).demiBold()
        header.textLabel?.frame = header.frame
        header.textLabel?.text = header.textLabel?.text?.capitalized
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "transactionDetailCell")!
            
            switch indexPath.row {
            case 0:
                cell.imageView?.image = UIImage(named: "Address")
                cell.textLabel?.text = "From Address"
                cell.detailTextLabel?.text = transaction?.address
                break
            case 1:
                cell.imageView?.image = UIImage(named: "Confirmations")
                cell.textLabel?.text = "Confirmations"
                cell.detailTextLabel?.text = "\(transaction?.confirmations ?? 0)"
                break
            case 2:
                cell.imageView?.image = UIImage(named: "Block")
                cell.textLabel?.text = "Blockhash"
                cell.detailTextLabel?.text = transaction?.blockhash
                break
            default:
                break
            }
            
            cell.imageView?.tintColor = UIColor.secondaryLight()
            
            return cell
        }
        
        
        let cell = Bundle.main.loadNibNamed("TransactionTableViewCell", owner: self, options: nil)?.first as! TransactionTableViewCell
        
        let item = items[indexPath.row]
        
        let recipient = Address()
        recipient.address = item.address
        recipient.name = nameLabel.text ?? item.address
        
        cell.setTransaction(item, address: recipient)
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewEdger.updateView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if items[indexPath.row].txid == transaction?.txid {
            return
        }
        
        transaction = items[indexPath.row]
        setTransaction(transaction!)
        tableView.reloadData()
        selectCurrentTransaction()
    }
    
    func selectCurrentTransaction() {
        for (index, item) in items.enumerated() {
            if (item.txid == self.transaction?.txid) {
                let indexPath = IndexPath(row: index, section: 1)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }
    
    @IBAction func closeViewController(_ sender: Any) {
        self.dismiss(animated: true)
    }

}