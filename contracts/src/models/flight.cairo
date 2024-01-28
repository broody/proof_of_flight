use starknet::ContractAddress;

#[derive(Copy, Drop, Serde, Introspect)]
struct Origin {
    longitude: u32,
    latitude: u32,
}

#[derive(Model, Copy, Drop, Serde)]
struct Flight {
    #[key]
    pilot: ContractAddress,
    #[key]
    flight_id: u32,
    origin: Origin,
    rotation: u32,
    is_sealed: bool,
    total_spaxels: u16,
}
