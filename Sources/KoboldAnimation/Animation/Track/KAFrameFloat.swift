import simd

public struct KAFrameFloat: Equatable {
    public let value: Float
    public let input: Float
    public let output: Float
    public let time: Float

    public init(
        value: Float,
        input: Float,
        output: Float,
        time: Float
    ) {
        self.value = value
        self.input = input
        self.output = output
        self.time = time
    }

    public static func == (lhs: KAFrameFloat, rhs: KAFrameFloat) -> Bool {
        return lhs.value == rhs.value
        && lhs.input == rhs.input
        && lhs.output == rhs.output
        && lhs.time == rhs.time
    }
}

