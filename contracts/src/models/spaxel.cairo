const SCALING_FACTOR: u32 = 1000;

#[derive(Copy, Drop, Serde, Introspect)]
struct Coordinate {
    x: u16,
    y: u16,
    z: u16,
}

#[derive(Copy, Drop, Serde, Introspect)]
struct Color {
    r: u8,
    g: u8,
    b: u8,
}

#[derive(Model, Copy, Drop, Serde)]
struct Spaxel {
    #[key]
    spaxel_id: u32,
    #[key]
    flight_id: u32,
    #[key]
    coordinate_idx: u32,
    coordinate: Coordinate,
    color: Color,
        total_coordinates: u16,

}
