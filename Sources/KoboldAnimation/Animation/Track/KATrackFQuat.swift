import simd

public struct KATrackFQuat {
    let frames: [FrameFQuat]
    let interpolation: KAInterpolation

    public init(
        interpolation: KAInterpolation,
        time: [Float],
        values: [simd_quatf]
    ) {
        let isSamplerCubic = interpolation == .cubic

        self.interpolation = interpolation
        self.frames = time.enumerated().map { baseIndex, time in
            var value: simd_quatf = .identity
            var input: simd_quatf = .identity
            var output: simd_quatf = .identity

            var offset = 0
            if isSamplerCubic {
                input = values[baseIndex]
                offset += 1
            }

            value = values[baseIndex + offset]
            offset += 1

            if isSamplerCubic {
                output = values[baseIndex + offset]
            }

            return FrameFQuat(
                value: value,
                input: input,
                output: output,
                time: time)
        }
    }

    private func neighbourhood(_ a: simd_quatf, _ b: simd_quatf) -> simd_quatf {
        if dot(a, b) < .zero {
            return -b
        }
        return b
    }

    func adjustHermiteResult(_ q: simd_quatf) -> simd_quatf {
        return simd_normalize(q)
    }

    private func customHermiteInterpolation(curve: CubicHermiteFQuat, t: Float) -> simd_quatf {
        let tt = t * t
        let ttt = tt * t

        let h1 = 2 * ttt - 3 * tt + 1
        let h2 = -2 * ttt + 3 * tt
        let h3 = ttt - 2 * tt + t
        let h4 = ttt - tt

        let p2 = neighbourhood(curve.p1, curve.p2)
        let result = curve.p1 * h1 + p2 * h2 + curve.s1 * h3 + curve.s2 * h4
        return simd_normalize(result)
    }

    func sample(t: Float, looping: Bool) -> simd_quatf {
        switch interpolation {
        case .constant: return sampleConstant(t: t, looping: looping)
        case .linear: return sampleLinear(t: t, looping: looping)
        case .cubic: return sampleCubic(t: t, looping: looping)
        }
    }

    func sampleConstant(t: Float, looping: Bool) -> simd_quatf {
        let frame = frameIndex(t: t, looping: looping)
        if frame < .zero || frame >= frames.count {
            return .identity
        }
        return frames[frame].value
    }

    func sampleLinear(t: Float, looping: Bool) -> simd_quatf {
        let currentFrame = frameIndex(t: t, looping: looping)
        if currentFrame < .zero || currentFrame >= (frames.count - 1) {
            return .identity
        }

        let nextFrame = currentFrame + 1
        let trackTime = adjustTimeToFitTrack(t: t, looping: looping)
        let currentTime = frames[currentFrame].time
        let frameDelta = frames[nextFrame].time - currentTime

        if frameDelta <= .zero {
            return .identity
        }

        let t = (trackTime - currentTime) / frameDelta
        let start = frames[currentFrame].value
        let end = frames[nextFrame].value

        var result = simd_quatf.lerp(start, end, t: t)
        if dot(start, end) < .zero {
            result = simd_quatf.lerp(start, -end, t: t)
        }
        return simd_normalize(result)
    }

    func sampleCubic(t: Float, looping: Bool) -> simd_quatf {
        let currentFrame = frameIndex(t: t, looping: looping)
        if currentFrame < .zero || currentFrame >= (frames.count - 1) {
            return .identity
        }

        let nextFrame = currentFrame + 1
        let trackTime = adjustTimeToFitTrack(t: t, looping: looping)
        let currentTime = frames[currentFrame].time
        let frameDelta = frames[nextFrame].time - currentTime

        if frameDelta <= .zero {
            return .identity
        }

        let t = (trackTime - currentTime) / frameDelta

        let curve = CubicHermiteFQuat(
            p1: frames[currentFrame].value,
            s1: frames[currentFrame].output * frameDelta,
            p2: frames[nextFrame].value,
            s2: frames[nextFrame].input * frameDelta)

        return customHermiteInterpolation(curve: curve, t: t)
    }

    func frameIndex(t: Float, looping: Bool) -> Int {
        if frames.count <= 1 {
            return -1
        }

        let startTime = frames[0].time

        var evaluatedTime = t

        if looping {
            let endTime = frames[frames.count - 1].time
            let duration = endTime - startTime
            evaluatedTime = fmodf(evaluatedTime - startTime, duration)
            if evaluatedTime < .zero {
                evaluatedTime += duration
            }
            evaluatedTime = evaluatedTime + startTime
        } else {
            if evaluatedTime <= startTime {
                return .zero
            }
            if evaluatedTime >= frames[frames.count - 2].time {
                return frames.count - 2
            }
        }

        for i in stride(from: frames.count - 1, through: 0, by: -1) {
            if evaluatedTime >= frames[i].time {
                return i
            }
        }

        return -1
    }

    func adjustTimeToFitTrack(t: Float, looping: Bool) -> Float {
        if frames.count <= 1 {
            return .zero
        }

        let startTime = frames[0].time
        let endTime = frames[frames.count - 1].time
        let duration = endTime - startTime
        if duration <= .zero {
            return .zero
        }

        var evaluatedTime = t

        if looping {
            evaluatedTime = fmodf(evaluatedTime - startTime, duration)
            if evaluatedTime < .zero {
                evaluatedTime += duration
            }
            evaluatedTime = evaluatedTime + startTime
        } else {
            if evaluatedTime <= startTime {
                evaluatedTime = startTime
            }
            if evaluatedTime >= frames[frames.count - 1].time {
                evaluatedTime = endTime
            }
        }

        return evaluatedTime
    }

    func getStartTime() -> Float {
        return frames[0].time
    }

    func getEndTime() -> Float {
        return frames[frames.count - 1].time
    }
}

