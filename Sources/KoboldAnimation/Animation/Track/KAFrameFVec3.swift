public struct KAFrameFVec3: Equatable {
    public let value: SIMD3<Float>
    public let input: SIMD3<Float>
    public let output: SIMD3<Float>
    public let time: Float

    public init(
        value: SIMD3<Float>,
        input: SIMD3<Float>,
        output: SIMD3<Float>,
        time: Float
    ) {
        self.value = value
        self.input = input
        self.output = output
        self.time = time
    }

    public static func == (lhs: KAFrameFVec3, rhs: KAFrameFVec3) -> Bool {
        return lhs.value == rhs.value
        && lhs.input == rhs.input
        && lhs.output == rhs.output
        && lhs.time == rhs.time
    }
}
