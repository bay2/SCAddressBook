//
//  AddressBookDataSource.swift
//  CavyLifeBand2
//
//  Created by xuemincai on 16/4/13.
//  Copyright © 2016年 xuemincai. All rights reserved.
//

import AddressBook
import Contacts

public typealias GetPhineInfoCallBack = (SCAddressBookContact -> Void)

public protocol SCAddressBookDataSource {
    
    func sc_GetAddresBookPhoneInfo(complete: GetPhineInfoCallBack?)
    
}

extension SCAddressBookDataSource {
    
    
    /**
     获取电话信息
     
     - parameter complete:
     */
    public func sc_GetAddresBookPhoneInfo(complete: GetPhineInfoCallBack?) {
        
        if #available(iOS 9.0, *) {
            
            let contact = CNContactStore()
            
            if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Denied {
                print("No permission address book")
                return
            }
            
            if CNContactStore.authorizationStatusForEntityType(.Contacts) == .NotDetermined {
                
                contact.requestAccessForEntityType(.Contacts) {(granted, error) in
                    
                    guard granted else {
                        return
                    }
                    
                    self.readAllPeopleInAddressBook(contact, complete: complete)
                    
                }
                
            }
            
            if CNContactStore.authorizationStatusForEntityType(.Contacts) == .Authorized {
                self.readAllPeopleInAddressBook(contact, complete: complete)
            }
            
            return

        }
        
        // ios 9以下版本的处理
        let contact = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
        
        if ABAddressBookGetAuthorizationStatus() == .Denied {
            print("No permission address book")
            return
        }
        
        if ABAddressBookGetAuthorizationStatus() == .NotDetermined {
            
            ABAddressBookRequestAccessWithCompletion(contact) {(granted, error) in
                
                guard granted else {
                    return
                }
                
                self.readAllPeopleInAddressBook(contact, complete: complete)
            }
        }
        
        if ABAddressBookGetAuthorizationStatus() == .Authorized {
            self.readAllPeopleInAddressBook(contact, complete: complete)
        }
            
    }
    
    @available(iOS 9.0, *)
    /**
     读取通信电话信息
     
     - parameter addressBook:
     - parameter complete:
     
     Available in iOS 9.0 and later.
     */
    private func readAllPeopleInAddressBook(addressBook: CNContactStore, complete: GetPhineInfoCallBack? = nil) {
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(CNContactFormatterStyle.FullName), CNContactPhoneNumbersKey]
        
        try! addressBook.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: keysToFetch)) {(contact, pointer) in
            
            let phone = contact.phoneNumbers.first
            guard let phoneNumber = phone?.value as? CNPhoneNumber else {
                return
            }
            
            let phoneString = phoneNumber.stringValue
            
            let contactInfo = SCAddressBookContact(name: contact.familyName + contact.givenName, phoneName: phoneString)
            
            complete?(contactInfo)
            
        }
        
    }
    
    /**
     读取通信电话信息 
     
     - parameter addressBook:
     - parameter complete:
     
     version Available in iOS 2.0 and later. Deprecated in iOS 9.0.
     */
    private func readAllPeopleInAddressBook(addressBook: ABAddressBook, complete: GetPhineInfoCallBack? = nil) {
        
        let peoples = ABAddressBookCopyArrayOfAllPeople(addressBook).takeRetainedValue() as NSArray
        
        for people: ABRecordRef in peoples {
            
            var firstName = ""
            var lastName = ""
            
            if let firstNameUnmanaged = ABRecordCopyValue(people, kABPersonLastNameProperty) {
                firstName = firstNameUnmanaged.takeRetainedValue() as? String ?? ""
            }
            
            if let lastNameUnmanaged = ABRecordCopyValue(people, kABPersonFirstNameProperty) {
                lastName = lastNameUnmanaged.takeRetainedValue() as? String ?? ""
            }
            
            let phoneNums: ABMultiValueRef = ABRecordCopyValue(people, kABPersonPhoneProperty).takeRetainedValue()
            
            guard let phoneNumUnmanaged = ABMultiValueCopyValueAtIndex(phoneNums, 0) else {
                continue
            }
            
            let phoneNum = phoneNumUnmanaged.takeRetainedValue() as? String ?? ""
            
            let contactInfo = SCAddressBookContact(name: firstName + lastName, phoneName: phoneNum)
            
            complete?(contactInfo)
            
        }
        
    }
    
}

