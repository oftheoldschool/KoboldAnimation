public struct KATransformTrack {
    let joint: Int
    var position: KATrackFVec3?
    let rotation: KATrackFQuat?
    let scale: KATrackFVec3?

    public init(
        joint: Int,
        position: KATrackFVec3? = nil,
        rotation: KATrackFQuat?,
        scale: KATrackFVec3?
    ) {
        self.joint = joint
        self.position = position
        self.rotation = rotation
        self.scale = scale
    }

    func isValid() -> Bool {
        return !(position?.frames.isEmpty ?? true
                 && rotation?.frames.isEmpty ?? true
                 && scale?.frames.isEmpty ?? true)
    }

    func sample(
        referenceTransform: KATransform,
        t: Float,
        looping: Bool
    ) -> KATransform {
        var result = referenceTransform
        if let p = position, p.frames.count > 1 {
            result.position = p.sample(t: t, looping: looping)
        }
        if let r = rotation, r.frames.count > 1 {
            result.rotation = r.sample(t: t, looping: looping)
        }
        if let s = scale, s.frames.count > 1 {
            result.scale = s.sample(t: t, looping: looping)
        }
        return result
    }

    func getStartTime() -> Float {
        var result: Float? = nil
        if let p = position, p.frames.count > 1 {
            result = p.getStartTime()
        }
        if let r = rotation, r.frames.count > 1 {
            let rotationStart = r.getStartTime()
            if result == nil || rotationStart < result! {
                result = rotationStart
            }
        }
        if let s = scale, s.frames.count > 1 {
            let scaleStart = s.getStartTime()
            if result == nil || scaleStart < result! {
                result = scaleStart
            }
        }
        return result ?? .zero
    }

    func getEndTime() -> Float {
        var result: Float? = nil
        if let p = position, p.frames.count > 1 {
            result = p.getEndTime()
        }
        if let r = rotation, r.frames.count > 1 {
            let rotationEnd = r.getEndTime()
            if result == nil || rotationEnd > result! {
                result = rotationEnd
            }
        }
        if let s = scale, s.frames.count > 1 {
            let scaleEnd = s.getEndTime()
            if result == nil || scaleEnd > result! {
                result = scaleEnd
            }
        }
        return result ?? 0
    }
}
