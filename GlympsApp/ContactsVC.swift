//
//  ContactsVC.swift
//  GlympsApp
//
//  Created by James B Morris on 11/17/19.
//  Copyright © 2019 James B Morris. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class ContactsVC: UIViewController {
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var contactStore = CNContactStore()
    
    var contacts = [Contact]()
    
    var shareableLink: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        contactStore.requestAccess(for: .contacts) { (success, error) in
            if success {
                print("Authorization Successful.")
            } else {
                print("Authorization Denied.")
            }
        }
        
        fetchContacts()
        
    }
    
    func fetchContacts() {
        
        let key = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: key)
        
        do {
            
            try contactStore.enumerateContacts(with: request) { (contact, stoppingPointer) in
                
                let name = contact.givenName
                let family = contact.familyName
                let number = contact.phoneNumbers.first?.value.stringValue
                
                let contactToAppend = Contact(name: name, family: family, number: number!)
                
                self.contacts.append(contactToAppend)
            }
            
            tableView.reloadData()
            
        } catch let err {
            print("Sorry, please check contacts permissions in settings and try again later. Error: \(err)")
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ContactsVC: UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let contactToDisplay = contacts[indexPath.row]
        cell.textLabel?.font = UIFont(name: "Avenir-Next", size: 18)
        cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)
        cell.textLabel?.text = contactToDisplay.name + " " + contactToDisplay.family
        cell.detailTextLabel?.font = UIFont(name: "Avenir-Next", size: 15)
        cell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0.7123068571, blue: 1, alpha: 1)
        cell.detailTextLabel?.text = contactToDisplay.number
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let messageVC = MFMessageComposeViewController()
        let contact = contacts[indexPath.row].name + " " + contacts[indexPath.row].family
        messageVC.body = self.shareableLink!
        messageVC.recipients = [contact]
        messageVC.messageComposeDelegate = self
            
        self.present(messageVC, animated: true, completion: nil)
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch (result) {
            case .cancelled:
                print("Message was cancelled")
                dismiss(animated: true, completion: nil)
            case .failed:
                print("Message failed")
                dismiss(animated: true, completion: nil)
            case .sent:
                print("Message was sent")
                dismiss(animated: true, completion: nil)
            default:
            break
        }
        
    }
}
