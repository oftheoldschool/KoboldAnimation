import simd

extension SIMD3 where Scalar == Float {
    static func lerp(_ start: Self, _ end: Self, t: Scalar) -> Self {
        return Self(
            start.x + (end.x - start.x) * t,
            start.y + (end.y - start.y) * t,
            start.z + (end.z - start.z) * t)
    }
}

extension SIMD3 where Scalar: SignedNumeric {
    static var xPositive: Self {
        Self(x: 1, y: 0, z: 0)
    }

    static var yPositive: Self {
        Self(x: 0, y: 1, z: 0)
    }

    static var zPositive: Self {
        Self(x: 0, y: 0, z: 1)
    }

    func toDir4() -> SIMD4<Scalar> {
        return SIMD4<Scalar>(self, 0)
    }
}
