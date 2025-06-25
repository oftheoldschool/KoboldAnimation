import simd

struct FrameFloat {
    let value: Float
    let input: Float
    let output: Float
    let time: Float

    static func == (lhs: FrameFloat, rhs: FrameFloat) -> Bool {
        return lhs.value == rhs.value
        && lhs.input == rhs.input
        && lhs.output == rhs.output
        && lhs.time == rhs.time
    }
}

struct FrameFVec3: Equatable {
    let value: SIMD3<Float>
    let input: SIMD3<Float>
    let output: SIMD3<Float>
    let time: Float

    static func == (lhs: FrameFVec3, rhs: FrameFVec3) -> Bool {
        return lhs.value == rhs.value
        && lhs.input == rhs.input
        && lhs.output == rhs.output
        && lhs.time == rhs.time
    }
}

struct FrameFQuat {
    let value: simd_quatf
    let input: simd_quatf
    let output: simd_quatf
    let time: Float

    static func == (lhs: FrameFQuat, rhs: FrameFQuat) -> Bool {
        return lhs.value == rhs.value
        && lhs.input == rhs.input
        && lhs.output == rhs.output
        && lhs.time == rhs.time
    }
}
