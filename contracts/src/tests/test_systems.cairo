#[cfg(test)]
mod tests {
    // import world dispatcher
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // import test utils
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    use proof_of_flight::models::{flight::{flight, Flight, Origin}, waypoint::{waypoint, Coordinate, Color, TransitionMode}};
    use proof_of_flight::systems::{
        flight::{flight_system, IFlightSystemDispatcher, IFlightSystemDispatcherTrait}, 
        waypoint::{waypoint_system, IWaypointSystemDispatcher, IWaypointSystemDispatcherTrait}
    };

    #[test]
    #[available_gas(30000000)]
    fn test_create_and_update_flight() {
        let caller = starknet::contract_address_const::<0x0>();
        let mut models = array![flight::TEST_CLASS_HASH, waypoint::TEST_CLASS_HASH];
        let world = spawn_test_world(models);

        let contract_address = world.deploy_contract('salt', flight_system::TEST_CLASS_HASH.try_into().unwrap());
        let flight_system = IFlightSystemDispatcher { contract_address };
        let flight_id = 0_u32;

        flight_system.create(Origin { longitude: 420, latitude: 69}, Option::None);
        let flight = get!(world, flight_id, Flight);

        assert(flight.pilot == caller, 'pilot should be the caller');
        assert(flight.origin.longitude == 420, 'longitude should be 420');
        assert(flight.origin.latitude == 69, 'latitude should be 69');
    }

    #[test]
    #[available_gas(30000000)]
    fn test_update_flight() {
        let mut models = array![flight::TEST_CLASS_HASH, waypoint::TEST_CLASS_HASH];
        let world = spawn_test_world(models);

        let contract_address = world.deploy_contract('salt', flight_system::TEST_CLASS_HASH.try_into().unwrap());
        let flight_system = IFlightSystemDispatcher { contract_address };
        let flight_id = 0_u32;

        flight_system.create(Origin { longitude: 420, latitude: 69}, Option::None);
        flight_system.update(
            flight_id, 
            Option::Some(Origin { longitude: 69, latitude: 420}),
            Option::Some(Coordinate { x: 1, y: 2, z: 3}),
            Option::Some(69),
            Option::Some(420)
        );

        let flight = get!(world, flight_id, Flight);

        assert(flight.origin.longitude == 69, 'longitude should be 69');
        assert(flight.origin.latitude == 420, 'latitude should be 420');
        assert(flight.offset == Coordinate { x: 1, y: 2, z: 3}, 'offset should be (1, 2, 3)');
        assert(flight.rotation == 69, 'rotation should be 69');
        assert(flight.scale == 420, 'scale should be 420');
    }

    #[test]
    #[available_gas(60000000)]
    fn test_append_waypoint() {
        let mut models = array![flight::TEST_CLASS_HASH, waypoint::TEST_CLASS_HASH];
        let world = spawn_test_world(models);

        let contract_address = world.deploy_contract('salt', flight_system::TEST_CLASS_HASH.try_into().unwrap());
        let flight_system = IFlightSystemDispatcher { contract_address };
        let flight_id = 0_u32;

        flight_system.create(Origin { longitude: 420, latitude: 69}, Option::None);

        let contract_address = world.deploy_contract('salt', waypoint_system::TEST_CLASS_HASH.try_into().unwrap());
        let waypoint_system = IWaypointSystemDispatcher { contract_address };

        waypoint_system.append(flight_id, 
            array![
                Coordinate { x: 1, y: 2, z: 3},
                Coordinate { x: 4, y: 5, z: 6}
            ], 
            array![
                Color { r: 1, g: 2, b: 3, a: 4, mode: TransitionMode::Immediate},
                Color { r: 1, g: 2, b: 3, a: 4, mode: TransitionMode::Gradual}
            ]
        );
        
        let flight = get!(world, flight_id, (Flight));
        let waypoints = waypoint_system.get(flight_id);

        assert(flight.total_waypoints == 2, 'total_waypoints is not length 2');
        assert(waypoints.len() == 2, 'waypoints len is not length 2');
    }
}