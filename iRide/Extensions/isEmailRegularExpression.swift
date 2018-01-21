//
//  isEmailRegularExpression.swift
//  iRide
//
//  Created by Nishant Hooda on 2018-01-13.
//  Copyright © 2018 Nishant Hooda. All rights reserved.
//

import UIKit

class isEmailRegularExpression: UIViewController {

}


extension String {
    func isValidEmail() -> Bool {

        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: characters.count)) != nil
    }
}

