use proof_of_flight::models::waypoint::{Color, Coordinate, Waypoint};
use proof_of_flight::models::flight::Flight;

#[starknet::interface]
trait IWaypointSystem<TContractState> {
    fn append(
        self: @TContractState,
        flight_id: u32,
        coordinates: Array<Coordinate>,
        colors: Array<Color>,
    );
    fn update(
        self: @TContractState,
        flight_id: u32,
        coordinate_idx: u16,
        coordinate: Option<Coordinate>,
        color: Option<Color>,
    );
    fn get(
        self: @TContractState,
        flight_id: u32,
    ) -> Array<(Coordinate, Color)>;
}

#[dojo::contract]
mod waypoint_system {
    use starknet::Zeroable;
    use core::array::ArrayTrait;
    use super::{IWaypointSystem, Coordinate, Color, Waypoint};

    use core::traits::{Into, TryInto};
    use starknet::{ContractAddress, get_caller_address};
    use proof_of_flight::models::flight::{Flight, Status};
    use proof_of_flight::errors;

    #[abi(embed_v0)]
    impl WaypointSystemImpl of IWaypointSystem<ContractState> {
        fn append(
            self: @ContractState,
            flight_id: u32,
            coordinates: Array<Coordinate>,
            colors: Array<Color>,
        ) {
            let world = self.world_dispatcher.read();
            let pilot = get_caller_address();
            let mut flight = get!(world, flight_id, (Flight));

            assert(flight.pilot == pilot, errors::UNAUTHORIZED_PILOT);
            assert(flight.status != Status::Completed, errors::CANNOT_UPDATE);
            assert(coordinates.len() == colors.len(), errors::INVALID_INPUT);

            let mut idx = 0;
            loop {
                set!(world, Waypoint {
                    flight_id,
                    coordinate_idx: flight.total_waypoints + idx,
                    coordinate: *coordinates.at(idx.into()),
                    color: *colors.at(idx.into()),
                });

                idx += 1;
                if idx.into() == coordinates.len() {
                    break;
                }
            };
            
            flight.total_waypoints += idx;
            set!(world, (flight));
        }

        fn update(
            self: @ContractState,
            flight_id: u32,
            coordinate_idx: u16,
            coordinate: Option<Coordinate>,
            color: Option<Color>,
        ) {
            let world = self.world_dispatcher.read();
            let pilot = get_caller_address();
            let mut flight = get!(world, flight_id, (Flight));

            assert(flight.pilot == pilot, errors::UNAUTHORIZED_PILOT);
            assert(flight.status != Status::Completed, errors::CANNOT_UPDATE);

            let mut waypoint = get!(world, (flight_id, coordinate_idx), (Waypoint));

            if coordinate.is_some() {
                waypoint.coordinate = coordinate.unwrap();
            }

            if color.is_some() {
                waypoint.color = color.unwrap();
            }

            set!(world, (flight, waypoint));
        }      

        fn get(
            self: @ContractState,
            flight_id: u32,
        ) -> Array<(Coordinate, Color)> {
            let world = self.world_dispatcher.read();
            let mut waypoints = ArrayTrait::<(Coordinate, Color)>::new();
            let mut idx = 0;
            loop {
                let waypoint = get!(world, (flight_id, idx), (Waypoint));
                if waypoint.coordinate.is_zero() {
                    break;
                }

                waypoints.append((waypoint.coordinate, waypoint.color));
                idx += 1;
            };

            waypoints
        }  
    }
}