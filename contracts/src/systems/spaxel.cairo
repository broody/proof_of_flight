#[starknet::interface]
trait ISpaxelSystem<TContractState> {
    fn add(
        self: @TContractState,
        flight_id: u32,
        coordinate: proof_of_flight::models::Coordinate,
        color: proof_of_flight::models::Color
    );
    fn update(
        self: @TContractState,
        flight_id: u32,
        coordinate_idx: u32,
        coordinate: proof_of_flight::models::Coordinate,
        color: proof_of_flight::models::Color
    );
    fn remove(self: @TContractState, flight_id: u32, coordinate_idx: u32);
}

