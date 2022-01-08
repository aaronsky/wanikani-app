import ComposableArchitecture
import WaniKani

extension ModelCollection where Element == Subject {
    public var grouped: SubjectGroups {
        .init(self)
    }
}

public struct SubjectGroups: Sequence {
    public var radicals: [Radical] = []
    public var kanji: [Kanji] = []
    public var vocabulary: [Vocabulary] = []

    public var ids: [Subject.ID] {
        radicals.map(\.id) + kanji.map(\.id) + vocabulary.map(\.id)
    }

    public var count: Int {
        radicals.count + kanji.count + vocabulary.count
    }

    public init<S>(
        _ subjects: S
    ) where S: Sequence, S.Element == Subject {
        for subject in subjects {
            switch subject {
            case .radical(let r):
                radicals.append(r)
            case .kanji(let k):
                kanji.append(k)
            case .vocabulary(let v):
                vocabulary.append(v)
            }
        }
    }

    public func makeIterator() -> AnyIterator<Subject>.Iterator {
        var current: Subject.Kind = .radical
        var index = 0

        return AnyIterator {
            defer { index += 1 }

            if current == .radical {
                if radicals.indices.contains(index) {
                    return .radical(radicals[index])
                } else {
                    current = .kanji
                    index = 0
                }
            }

            if current == .kanji {
                if kanji.indices.contains(index) {
                    return .kanji(kanji[index])
                } else {
                    current = .vocabulary
                    index = 0
                }
            }

            if current == .vocabulary && vocabulary.indices.contains(index) {
                return .vocabulary(vocabulary[index])
            }

            return nil
        }
    }
}
