use proof_of_flight::models::spaxel::{Color, Coordinate};

#[starknet::interface]
trait ISpaxelSystem<TContractState> {
    fn add(
        self: @TContractState,
        flight_id: u32,
        coordinate: Coordinate,
        color: Color
    );
    fn update(
        self: @TContractState,
        flight_id: u32,
        coordinate_idx: u32,
        coordinate: Coordinate,
        color: Color
    );
    fn remove(self: @TContractState, flight_id: u32, coordinate_idx: u32);
}

