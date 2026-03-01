extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        return SIMD3<Scalar>(x, y, z)
    }
}

extension SIMD4 where Scalar: SignedNumeric {
    static var wPositive: Self {
        Self(x: 0, y: 0, z: 0, w: 1)
    }
}
