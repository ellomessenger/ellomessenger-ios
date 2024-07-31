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

func _internal_channelGenresList(network: Network) -> Signal<[String], NoError> {
    return network.request(Api.functions.help.channelGenres())
    |> retryRequest
    |> map { $0.genres }
    |> mapToSignal { .single($0.compactMap { $0.genre } ) }
}
