import simd

public struct KAFrameFQuat: Equatable {
    public let value: simd_quatf
    public let input: simd_quatf
    public let output: simd_quatf
    public let time: Float

    public init(
        value: simd_quatf,
        input: simd_quatf,
        output: simd_quatf,
        time: Float
    ) {
        self.value = value
        self.input = input
        self.output = output
        self.time = time
    }

    public static func == (lhs: KAFrameFQuat, rhs: KAFrameFQuat) -> Bool {
        return lhs.value == rhs.value
        && lhs.input == rhs.input
        && lhs.output == rhs.output
        && lhs.time == rhs.time
    }
}
