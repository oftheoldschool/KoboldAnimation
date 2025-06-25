import simd

extension float4x4 {
    var diagonal: SIMD4<Float> {
        return SIMD4<Float>(
            x: self[0][0],
            y: self[1][1],
            z: self[2][2],
            w: self[3][3])
    }

    func toRotationScaleMatrix() -> Self {
        return Self(
            SIMD4<Float>(self[0].xyz, 0),
            SIMD4<Float>(self[1].xyz, 0),
            SIMD4<Float>(self[2].xyz, 0),
            SIMD4<Float>.wPositive)
    }
}
