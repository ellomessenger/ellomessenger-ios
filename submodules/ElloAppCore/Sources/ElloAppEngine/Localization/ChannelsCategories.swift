//
//  ChannelsCategories.swift
//  _idx_ElloAppCore_C5FFD640_ios_min14.0
//
//

import Foundation
import Postbox
import SwiftSignalKit
import ElloAppApi
import MtProtoKit

func _internal_channelCategoriesList(network: Network) -> Signal<[String], NoError> {
    return network.request(Api.functions.help.channelCategories())
    |> retryRequest
    |> map { $0.categories }
    |> mapToSignal { .single($0) }
}
