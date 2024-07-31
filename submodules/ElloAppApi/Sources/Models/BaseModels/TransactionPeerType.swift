//
//  TransactionPeerType.swift
//  _idx_ElloAppApi_5257747F_ios_min14.0
//
//

import Foundation

public enum PeerType: Int, Codable {
    case channelsSubscription   //0 - channels subscription
    case courseSubscription     //1 - course channel
    case depositOrWithdrawal    //2 - payments
    /// One-time media purchase
    case mediaPurchase          //3 - media sale
    case aiSubscription         //4 - ai subscription
    case aiPacks                //5 - ai packs
    case transfer               //6 - transfer (peer_id is receiver user_id)
    case aiTextPacks            //7 - ai packs text
    case aiImagePacks           //8 - ai packs image
    case aiTextSubscription     //9 - ai packs subscription text
    case aiImageSubscription    //10 - ai packs subscription image
    case loyaltyComission       //11 - LOYALTY Partner comission
    case loyaltyBonus           //12 - LOYALTY Bonus
    case aiImageTextPack        //13 - AI Images and chat
}
