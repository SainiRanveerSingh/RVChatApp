//
//  Constants.swift
//  RVChatApp
//
//  Created by RV on 26/04/25.
//

import Foundation
import UIKit

struct Constants {
    static let userDefault = UserDefaults.standard
    //static let appDelegate = UIApplication.shared.delegate as! AppDelegate
}

struct ErrorMessages {
    static let emailRequired        = "Email address is required."
    static let validMail            = "Please enter a Valid email address."
    static let confirmMail          = "Emails do not match."
    static let passwordRequired     = "Password is required."
    static let passwordStrength     = "Password must be of 6 characters."
    static let passwordMatching     = "Passwords do not match."
    static let noNetwork            = "Please check your internet connection."
    static let responseErrorTryAgain        = "Something went wrong. Please try again"
    static let requiredError        = "Please enter all the details."
    static let alreadyRegistered    = "Username already exists."
    static let userUnavailable      = "User does not exists."
    static let wrongPassword        = "Invalid password."
    static let userDeleted          = "This account is deleted."
    static let userBlocked          = "This account is blocked."
    static let correctInformation   = "Please fill all fields correctly."
    
    //MARK:- Registration -
    static let checkAcceptTandC             = "Please check and accept the Terms and Condition."
    static let checkAndVerifyEmail          = "Please check and verify your email"
    static let accountCreatedVerifyYourAccount = "Please check your email we have sent a verification link on your Email Id. Please verify your email and then please Login to the application."
    static let verificationMailSent         = "We have sent a verification link on your Email Id. Please verify your email and Login to the application."
    static let verificationNotDoneSentAgain = "Email verification not done yet! Please check your email we have again sent the verification mail."
    
    //MARK:- Forgot Password -
    static let checkUserNameEmail           = "Username and Email Id does not match. Please check and try again"
    static let passwordUpdated              = "Password updated successfully."
    static let passwordResetLinkSent       = "Password reset link sent on the email"
    static let errorOnPasswordResetLink     = "Getting error in sending Password reset link sent on the email. Please try again."
    
    //MARK:- Change Password -
    static let passwordNotUpdated            = "Password not updated. Please try again."
    
    //MARK:- Address Information -
    static let invalidPhoneNo            = "Please enter a valid phone number"
}
