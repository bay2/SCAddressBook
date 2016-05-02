//
//  AddressBookPicker.swift
//  CavyLifeBand2
//
//  Created by xuemincai on 16/5/1.
//  Copyright © 2016年 xuemincai. All rights reserved.
//

import UIKit
import AddressBookUI
import ContactsUI

public struct SCAddressBookContact {
    
    public var name: String
    public var phoneName: String
    
}

public protocol SCAddressBookPickerDelegate {
    
    func sc_ContactPicker(didSelectContact contact: SCAddressBookContact)
    
}

public class SCAddressBookPicker: NSObject {
    
    public var pickerDelegate: SCAddressBookPickerDelegate?
    
    public func sc_ShowAddressBoolPicker(viewController: UIViewController) {
        
        if #available(iOS 9.0, *) {
            
            let picker = CNContactPickerViewController()
            picker.delegate = self
            picker.displayedPropertyKeys = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactPhoneNumbersKey]
            
            viewController.navigationController?.presentViewController(picker, animated: true, completion: nil)
            
            
        } else {
            
            let picker = ABPeoplePickerNavigationController()
            picker.displayedProperties = [NSNumber(int: kABPersonFirstNameProperty), NSNumber(int: kABPersonLastNameProperty), NSNumber(int: kABPersonPhoneProperty)]
            picker.peoplePickerDelegate = self
            
            viewController.navigationController?.presentViewController(picker, animated: true, completion: nil)
            
        }
        
    }
    
    
}

@available(iOS 9.0, *)
extension SCAddressBookPicker: CNContactPickerDelegate {
    
    /**
     通讯录联系人选择回调
     
     - parameter picker:  选择器
     - parameter contact: 联系人信息
     */
    public func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        
        let phone = contact.phoneNumbers.first
        guard let phoneNumber = phone?.value as? CNPhoneNumber else {
            return
        }
        
        let contactInfo = SCAddressBookContact(name: contact.familyName + contact.givenName, phoneName: phoneNumber.stringValue)
        
        pickerDelegate?.sc_ContactPicker(didSelectContact: contactInfo)
        
        
    }
    
}

@available(iOS 8.0, *)
extension SCAddressBookPicker: ABPeoplePickerNavigationControllerDelegate {
    
    public func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController, didSelectPerson person: ABRecord) {
        
        var firstName = ""
        var lastName = ""
        
        if let firstNameUnmanaged = ABRecordCopyValue(person, kABPersonLastNameProperty) {
            firstName = firstNameUnmanaged.takeRetainedValue() as? String ?? ""
        }
        
        if let lastNameUnmanaged = ABRecordCopyValue(person, kABPersonFirstNameProperty) {
            lastName = lastNameUnmanaged.takeRetainedValue() as? String ?? ""
        }
        
        var phoneNum = ""
        
        let phoneNums: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()
        
        guard let phoneNumUnmanaged = ABMultiValueCopyValueAtIndex(phoneNums, 0) else {
            
            let contactInfo = SCAddressBookContact(name: lastName + firstName, phoneName: phoneNum)
            pickerDelegate?.sc_ContactPicker(didSelectContact: contactInfo)
            return
        }
        
        phoneNum = phoneNumUnmanaged.takeRetainedValue() as? String ?? ""
        
        let contactInfo = SCAddressBookContact(name: lastName + firstName, phoneName: phoneNum)
        pickerDelegate?.sc_ContactPicker(didSelectContact: contactInfo)
        
    }
    
    
}
