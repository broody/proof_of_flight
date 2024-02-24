use starknet::ContractAddress;
use proof_of_flight::models::spaxel::Coordinate;

#[derive(Copy, Drop, Serde, Introspect)]
struct Origin {
    longitude: u32,
    latitude: u32,
}

#[derive(Copy, Drop, Serde, Introspect)]
enum Status {
    Planning,
    Completed,
}

#[derive(Model, Copy, Drop, Serde)]
struct Flight {
    #[key]
    flight_id: u32,
    #[key]
    pilot: ContractAddress,
    source_flight_id: u32,
    status: Status,
    origin: Origin,
    offset: Coordinate,
    rotation: u16,
    scale: u16,
    total_spaxels: u16,
}
