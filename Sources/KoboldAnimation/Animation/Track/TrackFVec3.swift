import simd

struct TrackFVec3 {
    let frames: [FrameFVec3]
    let interpolation: Interpolation

    init(
        interpolation: Interpolation,
        time: [Float],
        values: [SIMD3<Float>]
    ) {
        let isSamplerCubic = interpolation == .cubic

        self.interpolation = interpolation
        self.frames = time.enumerated().map { baseIndex, time in
            var value: SIMD3<Float> = .zero
            var input: SIMD3<Float> = .zero
            var output: SIMD3<Float> = .zero

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

            return FrameFVec3(
                value: value,
                input: input,
                output: output,
                time: time)
        }
    }

    private func customHermiteInterpolation(curve: CubicHermiteFVec3, t: Float) -> SIMD3<Float> {
        let tt = t * t
        let ttt = tt * t

        let h1 = 2 * ttt - 3 * tt + 1
        let h2 = -2 * ttt + 3 * tt
        let h3 = ttt - 2 * tt + t
        let h4 = ttt - tt

        return curve.p1 * h1 + curve.p2 * h2 + curve.s1 * h3 + curve.s2 * h4
    }

    func sample(t: Float, looping: Bool) -> SIMD3<Float> {
        switch interpolation {
        case .constant: return sampleConstant(t: t, looping: looping)
        case .linear: return sampleLinear(t: t, looping: looping)
        case .cubic: return sampleCubic(t: t, looping: looping)
        }
    }

    func sampleConstant(t: Float, looping: Bool) -> SIMD3<Float> {
        let frame = frameIndex(t: t, looping: looping)
        if frame < .zero || frame >= frames.count {
            return .zero
        }
        return frames[frame].value
    }

    func sampleLinear(t: Float, looping: Bool) -> SIMD3<Float> {
        let currentFrame = frameIndex(t: t, looping: looping)
        if currentFrame < .zero || currentFrame >= (frames.count - 1) {
            return .zero
        }

        let nextFrame = currentFrame + 1
        let trackTime = adjustTimeToFitTrack(t: t, looping: looping)
        let currentTime = frames[currentFrame].time
        let frameDelta = frames[nextFrame].time - currentTime

        if frameDelta <= .zero {
            return .zero
        }

        let t = (trackTime - currentTime) / frameDelta
        let start = frames[currentFrame].value
        let end = frames[nextFrame].value

        return SIMD3<Float>.lerp(start, end, t: t)
    }

    func sampleCubic(t: Float, looping: Bool) -> SIMD3<Float> {
        let currentFrame = frameIndex(t: t, looping: looping)
        if currentFrame < .zero || currentFrame >= (frames.count - 1) {
            return .zero
        }

        let nextFrame = currentFrame + 1
        let trackTime = adjustTimeToFitTrack(t: t, looping: looping)
        let currentTime = frames[currentFrame].time
        let frameDelta = frames[nextFrame].time - currentTime

        if frameDelta <= .zero {
            return .zero
        }

        let t = (trackTime - currentTime) / frameDelta

        let curve = CubicHermiteFVec3(
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

