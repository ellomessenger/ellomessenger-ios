import Foundation
import Postbox
import ElloAppApi


extension ElloAppMediaPollOption {
    init(apiOption: Api.PollAnswer) {
        switch apiOption {
            case let .pollAnswer(text, option):
                self.init(text: text, opaqueIdentifier: option.makeData())
        }
    }
    
    var apiOption: Api.PollAnswer {
        return .pollAnswer(text: self.text, option: Buffer(data: self.opaqueIdentifier))
    }
}

extension ElloAppMediaPollOptionVoters {
    init(apiVoters: Api.PollAnswerVoters) {
        switch apiVoters {
            case let .pollAnswerVoters(flags, option, voters):
                self.init(selected: (flags & (1 << 0)) != 0, opaqueIdentifier: option.makeData(), count: voters, isCorrect: (flags & (1 << 1)) != 0)
        }
    }
}

extension ElloAppMediaPollResults {
    init(apiResults: Api.PollResults) {
        switch apiResults {
            case let .pollResults(_, results, totalVoters, recentVoters, solution, solutionEntities):
                var parsedSolution: ElloAppMediaPollResults.Solution?
                if let solution = solution, let solutionEntities = solutionEntities, !solution.isEmpty {
                    parsedSolution = ElloAppMediaPollResults.Solution(text: solution, entities: messageTextEntitiesFromApiEntities(solutionEntities))
                }
                
                self.init(voters: results.flatMap({ $0.map(ElloAppMediaPollOptionVoters.init(apiVoters:)) }), totalVoters: totalVoters, recentVoters: recentVoters.flatMap { recentVoters in
                    return recentVoters.map { PeerId(namespace: Namespaces.Peer.CloudUser, id: PeerId.Id._internalFromInt64Value($0)) }
                    } ?? [], solution: parsedSolution)
        }
    }
}
