use proof_of_flight::models::flight::Origin;
use proof_of_flight::models::spaxel::Coordinate;

#[starknet::interface]
trait IFlightSystem<TContractState> {
    fn create(self: @TContractState, origin: Origin, source_flight_id: Option<u32>);
    fn update(
        self: @TContractState,
        flight_id: u32,
        origin: Option<Origin>,
        offset: Option<Coordinate>,
        rotation: Option<u16>,
        scale: Option<u16>,
    );
    fn complete(self: @TContractState, flight_id: u32);
}


#[dojo::contract]
mod flight {
    use super::{IFlightSystem, Origin, Coordinate};

    use core::zeroable::Zeroable;
    use starknet::{ContractAddress, get_caller_address};
    use proof_of_flight::models::flight::{Flight, Status};

    mod Errors {
        const INVALID_SOURCE_FLIGHT: felt252 = 'Invalid source flight';
        const UNAUTHORIZED_PILOT: felt252 = 'Unauthorized pilot';
        const FLIGHT_COMPLETED: felt252 = 'Flight completed';
    }


    #[abi(embed_v0)]
    impl FlightSystemsImpl of IFlightSystem<ContractState> {
        fn create(self: @ContractState, origin: Origin, source_flight_id: Option<u32>) {
            let world = self.world_dispatcher.read();
            
            set! (
                world,
                (
                    Flight {
                        flight_id: world.uuid(),
                        source_flight_id: source_flight_id.unwrap_or(0),
                        pilot: get_caller_address(),
                        status: Status::Planning,
                        origin,
                        offset: Coordinate { x: 0, y: 0, z: 0 },
                        rotation: 0,
                        scale: 0,
                        total_spaxels: 0,
                    }
                )
            )
        }
        
        fn update(
            self: @ContractState,
            flight_id: u32,
            origin: Option<Origin>,
            offset: Option<Coordinate>,
            rotation: Option<u16>,
            scale: Option<u16>,
        ) {

            let world = self.world_dispatcher.read();
            let pilot = get_caller_address();
            let mut flight = get!(world, flight_id, (Flight));

            assert(flight.pilot == pilot, Errors::UNAUTHORIZED_PILOT);
            assert(flight.status != Status::Completed, Errors::FLIGHT_COMPLETED);

            if origin.is_some() {
                flight.origin = origin.unwrap();
            }

            if offset.is_some() {
                flight.offset = offset.unwrap();
            }

            if rotation.is_some() {
                flight.rotation = rotation.unwrap();
            }

            if scale.is_some() {
                flight.scale = scale.unwrap();
            }

            set!( world, (flight));
        }

        fn complete(self: @ContractState, flight_id: u32) {
            let world = self.world_dispatcher.read();
            let pilot = get_caller_address();
            let mut flight = get!(world, flight_id, (Flight));

            assert(flight.pilot == pilot, Errors::UNAUTHORIZED_PILOT);

            // GENERATE PROOF OF FLIGHT NFT

            flight.status = Status::Completed;
            set!( world, (flight));
        }
    }
}