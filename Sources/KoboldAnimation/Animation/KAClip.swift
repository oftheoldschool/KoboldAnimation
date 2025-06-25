import Foundation

public class KAClip {
    public let name: String
    var startTime: Float
    var endTime: Float
    let looping: Bool
    let tracks: [TransformTrack]
    
    init(
        name: String,
        looping: Bool,
        tracks: [TransformTrack]
    ) {
        self.name = name
        self.startTime = 0
        self.endTime = 0
        self.looping = looping
        self.tracks = tracks
        
        recalculateDuration()
    }

    public func sample(pose: KAPose, inTime: Float) -> Float {
        let duration = endTime - startTime
        if duration == .zero {
            return .zero
        }

        let outTime = adjustTimeToFitRange(inTime: inTime)
        for track in tracks {
            let animated = track.sample(
                referenceTransform: pose.joints[track.joint].transform,
                t: outTime,
                looping: looping)
            pose.joints[track.joint].transform = animated
        }
        return outTime
    }

    private func recalculateDuration() {
        startTime = 0
        endTime = 0
        
        var startSet = false
        var endSet = false
        
        tracks.forEach { track in
            if track.isValid() {
                let trackStartTime = track.getStartTime()
                let trackEndTime = track.getEndTime()
                if startTime < trackStartTime || !startSet {
                    startSet = true
                    startTime = trackStartTime
                }
                if trackEndTime > endTime || !endSet {
                    endSet = true
                    endTime = trackEndTime
                }
            }
        }
    }
    
    private func adjustTimeToFitRange(inTime: Float) -> Float {
        var outTime: Float = inTime
        if looping {
            let duration = endTime - startTime
            if duration <= 0 { 
                outTime = 0
            }
            
            outTime = fmodf(outTime - startTime, endTime - startTime)
            if outTime < 0 {
                outTime += endTime - startTime
            }
            outTime = outTime + startTime
        } else {
            if outTime < startTime {
                outTime = startTime
            }
            if outTime > endTime {
                outTime = endTime
            }
        }
        return outTime
    }
}
