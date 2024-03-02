use starknet::Zeroable;
const SCALING_FACTOR: u32 = 1000;

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
struct Coordinate {
    x: u16,
    y: u16,
    z: u16,
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
struct Color {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
    mode: TransitionMode,
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum TransitionMode {
    Immediate,
    Gradual,
}

#[derive(Model, Copy, Drop, Serde)]
struct Waypoint {
    #[key]
    flight_id: u32,
    #[key]
    coordinate_idx: u16,
    coordinate: Coordinate,
    color: Color,
}

impl CoordinateZeroable of Zeroable<Coordinate> {
    fn zero() -> Coordinate {
        Coordinate {
            x: 0,
            y: 0,
            z: 0,
        }
    }

    fn is_zero(self: Coordinate) -> bool {
        self.x == 0 && self.y == 0 && self.z == 0
    }

    fn is_non_zero(self: Coordinate) -> bool {
        self.x != 0 || self.y != 0 || self.z != 0
    }
}

impl ColorZeroable of Zeroable<Color> {
    fn zero() -> Color {
        Color {
            r: 0,
            g: 0,
            b: 0,
            a: 0,
            mode: TransitionMode::Immediate,
        }
    }

    fn is_zero(self: Color) -> bool {
        self.r == 0 && self.g == 0 && self.b == 0 && self.a == 0 && self.mode == TransitionMode::Immediate
    }

    fn is_non_zero(self: Color) -> bool {
        self.r != 0 || self.g != 0 || self.b != 0 || self.a != 0 || self.mode != TransitionMode::Immediate
    }
}
