import CoreML
import Foundation
import Vision

struct rHit: Identifiable {
    var id: String { latin }
    let latin: String
    let score: Float
}

final class FishClassifier {
    static let modelName = "INatVision_Small_2_fact256_8bit"
    private let visionModel: VNCoreMLModel
    private let fishClasses: [Int: String]

    init(modelURL: URL, classesURL: URL) throws {
        let configuration = MLModelConfiguration()
        configuration.computeUnits = .cpuOnly
        visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL, configuration: configuration))
        fishClasses = try JSONDecoder().decode([Int: String].self, from: Data(contentsOf: classesURL))
        guard fishClasses.count == 17, fishClasses.keys.allSatisfy((0..<507).contains) else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }

    func suggestions(for image: CGImage, orientation: CGImagePropertyOrientation = .up) throws -> [rHit] {
        let cropped = try probabilities(for: image, orientation: orientation, crop: .centerCrop)
        let candidates = Self.suggestions(from: cropped, fishClasses: fishClasses)
        guard candidates.isEmpty,
              let winner = cropped.indices.max(by: { cropped[$0] < cropped[$1] }),
              let taxon = fishClasses[winner], (0.10..<0.20).contains(cropped[winner]),
              fishClasses.keys.reduce(0.0, { $0 + cropped[$1] }) >= 0.50 else { return candidates }

        // A long fish can lose its head or tail in a square crop. Accept the whole-frame
        // view only when it independently clears the same thresholds for the same species.
        let wholeFrame = try probabilities(for: image, orientation: orientation, crop: .scaleFit)
        let fullFrameCandidates = Self.suggestions(from: wholeFrame, fishClasses: fishClasses)
        return fullFrameCandidates.first?.latin == taxon ? fullFrameCandidates : []
    }

    private func probabilities(for image: CGImage, orientation: CGImagePropertyOrientation,
                               crop: VNImageCropAndScaleOption) throws -> [Float] {
        let request = VNCoreMLRequest(model: visionModel)
        request.imageCropAndScaleOption = crop
        try VNImageRequestHandler(cgImage: image, orientation: orientation).perform([request])
        let observations = request.results as? [VNCoreMLFeatureValueObservation]
        guard let scores = observations?.first(where: { $0.featureName == "Identity" })?.featureValue.multiArrayValue,
              scores.count == 507 else {
            throw CocoaError(.fileReadCorruptFile)
        }
        return (0..<scores.count).map { scores[$0].floatValue }
    }

    static func suggestions(from probabilities: [Float], fishClasses: [Int: String]) -> [rHit] {
        guard probabilities.count == 507,
              probabilities.allSatisfy({ $0.isFinite && (0...1).contains($0) }),
              let winner = probabilities.indices.max(by: { probabilities[$0] < probabilities[$1] }),
              fishClasses[winner] != nil, probabilities[winner] >= 0.20 else { return [] }

        let candidates = fishClasses.map { rHit(latin: $0.value, score: probabilities[$0.key]) }
        // Keep the probability assigned to the original 507-way output.
        // Small residual fish scores on unrelated subjects must not become confident matches.
        guard candidates.reduce(0.0, { $0 + $1.score }) >= 0.50 else { return [] }
        return Array(candidates.filter { $0.score >= 0.04 }.sorted { $0.score > $1.score }.prefix(3))
    }
}
