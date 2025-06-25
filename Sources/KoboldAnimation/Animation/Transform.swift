import simd

struct Transform: Equatable {
    var position: SIMD3<Float>
    var rotation: simd_quatf
    var scale: SIMD3<Float>
    
    func combine(_ other: Transform) -> Transform {
        return Transform(
            position: self.position + simd_act(self.rotation, (self.scale * other.position)),
            rotation: self.rotation * other.rotation,
            scale: self.scale * other.scale)
    }
    
    func inverse() -> Transform {
        let inverseRotation = simd_inverse(rotation)
        let inverseScale = SIMD3<Float>(
            x: fabsf(self.scale.x) < 1e-6 ? .zero : 1 / self.scale.x,
            y: fabsf(self.scale.y) < 1e-6 ? .zero : 1 / self.scale.y,
            z: fabsf(self.scale.z) < 1e-6 ? .zero : 1 / self.scale.z)
        let inversePosition = simd_act(inverseRotation, (inverseScale * -self.position))
        
        return Transform(
            position: inversePosition,
            rotation: inverseRotation,
            scale: inverseScale)
    }
    
    func lerp(_ other: Transform, t: Float) -> Transform {
        var otherRotation = other.rotation
        if simd_dot(self.rotation, otherRotation) < .zero {
            otherRotation = -otherRotation
        }
        
        return Transform(
            position: SIMD3<Float>.lerp(
                self.position, other.position, t: t),
            rotation: simd_quatf.nlerp(
                self.rotation, otherRotation, t: t),
            scale: SIMD3<Float>.lerp(
                self.scale, other.scale, t: t))
    }
    
    func toMat4() -> simd_float4x4 {
        let x = simd_act(rotation, .xPositive) * scale.x
        let y = simd_act(rotation, .yPositive) * scale.y
        let z = simd_act(rotation, .zPositive) * scale.z
        return simd_float4x4(
            SIMD4<Float>(x.x, x.y, x.z, 0),
            SIMD4<Float>(y.x, y.y, y.z, 0),
            SIMD4<Float>(z.x, z.y, z.z, 0),
            SIMD4<Float>(position, 1))
    }
    
    func transformPoint(_ p: SIMD3<Float>) -> SIMD3<Float> {
        return self.position + simd_act(self.rotation, (self.scale * p))
    }
    
    func transformVector(_ v: SIMD3<Float>) -> SIMD3<Float> {
        return simd_act(self.rotation, self.scale * v)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.position == rhs.position
        && lhs.rotation == rhs.rotation
        && lhs.scale == rhs.scale
    }
}

extension Transform {
    init() {
        self.position = .zero
        self.rotation = .identity
        self.scale = .one
    }
    
    init(fromMatrix m: simd_float4x4) {
        self.position = m[3].xyz
        //        self.rotation = simd_quatf(m.upperLeft)
        self.rotation = Transform.mat4ToQuat(m)
        let rotationScaleMatrix = m.toRotationScaleMatrix()
        //        let inverseRotationMatrix = float4x4(self.rotation.inverse)
        let inverseRotationMatrix = Transform.quatToMat4(self.rotation.inverse)
        let scaleSkewMatrix = rotationScaleMatrix * inverseRotationMatrix
        self.scale = scaleSkewMatrix.diagonal.xyz
    }
    
    static func mat4ToQuat(_ m: float4x4) -> simd_quatf {
        var up = normalize(m.columns.1.xyz)
        let forward = normalize(m.columns.2.xyz)
        let right = cross(up, forward)
        up = cross(forward, right)
        
        return Self.lookRotation(direction: forward, up: cross(forward, right))
    }
    
    static func lookRotation(direction: SIMD3<Float>, up: SIMD3<Float>) -> simd_quatf {
        let f = normalize(direction)
        var u = normalize(up)
        let r = cross(u, f)
        u = cross(f, r)
        let f2d = simd_quatf(from: SIMD3<Float>.zPositive, to: f)
        let objectUp = simd_act(f2d, SIMD3<Float>.yPositive)
        let u2u = simd_quatf(from: objectUp, to: u)
        
        let result = u2u * f2d
        
        return result.normalized
    }
    
    static func quatToMat4(_ q: simd_quatf) -> float4x4 {
        let r = simd_act(q, SIMD3<Float>.xPositive)
        let u = simd_act(q, SIMD3<Float>.yPositive)
        let f = simd_act(q, SIMD3<Float>.zPositive)
        
        return float4x4(
            r.toDir4(),
            u.toDir4(),
            f.toDir4(),
            SIMD4<Float>.wPositive)
    }
}
