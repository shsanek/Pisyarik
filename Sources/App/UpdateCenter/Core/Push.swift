//
//  File.swift
//  
//
//  Created by Alex Shipin on 03.04.2022.
//

import APNSwift

struct Push: APNSwiftNotification {
    let aps: APNSwiftPayload
    let chatId: IdentifierType
}
