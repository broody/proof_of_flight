use proof_of_flight::models::flight::Origin;

#[starknet::interface]
trait IFlightSystem<TContractState> {
    fn create(self: @TContractState, origin: Origin, rotation: u32);
    fn update(self: @TContractState, flight_id: u32, origin: Origin, rotation: u32);
    fn copy(self: @TContractState, flight_id: u32);
    fn seal(self: @TContractState, flight_id: u32);
}
