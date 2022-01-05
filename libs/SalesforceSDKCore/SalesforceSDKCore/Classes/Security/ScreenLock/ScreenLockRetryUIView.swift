//
//  ScreenLockRetryUIView.swift
//  SalesforceSDKCore
//
//  Created by on 20/12/21.
//  Copyright (c) 2021-present, _.com, inc. All rights reserved.
// 
//  Redistribution and use of this software in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//  * Redistributions of source code must retain the above copyright notice, this list of conditions
//  and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or other materials provided
//  with the distribution.
//  * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific prior written
//  permission of salesforce.com, inc.
// 
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
//  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import SwiftUI
import LocalAuthentication

public struct ScreenLockViewConfiguration {
    public enum Background {
        case color(UIColor)
        case image(UIImage)
    }

    let textColor: UIColor
    let buttonBackgroundColor: UIColor
    let buttonTitleColor: UIColor
    let background: Background
    let appIconImage: UIImage

    public init(textColor: UIColor = .salesforceDefaultText,
                buttonTitleColor: UIColor = .white,
                buttonBackgroundColor: UIColor = .salesforceBlue,
                appIconImage: UIImage = SFSDKResourceUtils.imageNamed("salesforce-logo"),
                background: Background = Background.color(.salesforceSystemBackground)) {
        self.textColor = textColor
        self.buttonTitleColor = buttonTitleColor
        self.buttonBackgroundColor = buttonBackgroundColor
        self.appIconImage = appIconImage
        self.background = background
    }
}

struct ScreenLockRetryUIView: View {
    @Environment(\.presentationMode) var presentationMode
    let configuration: ScreenLockViewConfiguration
    @State var hasError = false
    @State var canEvaluatePolicy = false
    @State var errorText = ""
    private let canLogout = true

    var body: some View {
        ZStack {
            switch configuration.background {
            case .color(let color):
                Color(color)
            case .image(let image):
                Image(uiImage: image)
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
            }
            VStack(alignment: .center, content: {
                HStack {
                    Spacer()
                }
                Spacer()

                Image(uiImage: configuration.appIconImage)
                    .resizable()
                    .frame(width: 125, height: 125, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .offset(y: getImageOffset())
                    .padding()

                if hasError {
                    VStack {
                        Text(errorText)
                            .foregroundColor(Color(configuration.textColor))
                            .padding()

                        if canEvaluatePolicy {
                            Button(action: retryUnlock) {
                                Text(SFSDKResourceUtils.localizedString("retryButtonTitle"))
                                    .foregroundColor(Color(configuration.buttonTitleColor))
                            }
                            .padding()
                            .background(Color(configuration.buttonBackgroundColor).cornerRadius(5))
                        }
                        if canLogout {
                            Button(action: { logout() },
                                   label: {
                                Text(SFSDKResourceUtils.localizedString("logoutButtonTitle"))
                                    .foregroundColor(Color(configuration.textColor))
                            }).padding()
                        }
                    }
                    .offset(y: -50)
                }
            })
        }.onAppear(perform: {
            showBiometric()
        })
    }

    func retryUnlock() {
        showBiometric()
    }

    func showBiometric() {
        let context = LAContext()
        var error: NSError?
        
        hasError = false
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            canEvaluatePolicy = true
            let reason = SFSDKResourceUtils.localizedString("biometricReason")
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, error in
                if success {
                    DispatchQueue.main.async {
                        ScreenLockManager.shared.unlock()
                    }
                } else {
                    errorText = error?.localizedDescription ?? SFSDKResourceUtils.localizedString("fallbackErrorMessage")
                    hasError = true
                }
            }
        } else {
            errorText = String(format: SFSDKResourceUtils.localizedString("setUpPasscodeMessage"), SalesforceManager.shared.appDisplayName)
            hasError = true
            canEvaluatePolicy = false
        }
    }
    
    private func getImageOffset() -> CGFloat {
        return hasError ?
            (canLogout ?
                (canEvaluatePolicy ? -290 : -350) :
                (canEvaluatePolicy ? -350 : -410)
            ) : -470
    }
}

private func logout() {
    ScreenLockManager.shared.logoutScreenLockUsers();

    if(UIAccessibility.isVoiceOverRunning) {
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: SFSDKResourceUtils.localizedString("accessibilityLoggedOutAnnouncement"))
    }
}

struct ScreenLockRetryUIView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenLockRetryUIView(configuration: ScreenLockViewConfiguration())
    }
}
