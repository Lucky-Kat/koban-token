#[test_only]
module koban::test_koban {
    use koban::koban::{Self, KOBAN};
    use sui::test_utils::assert_eq;
    use sui::coin::{Self, CoinMetadata, TreasuryCap};
    use sui::test_scenario::{Self, next_tx, ctx};
    use std::debug;

    const OWNER: address = @0xCA6ED;
    
    #[test]
    fun test_koban_init() {
        // Set up the test scenario
        let mut scenario = test_scenario::begin(OWNER);
        {
            // Call the test_init function from the koban module
            koban::test_init(ctx(&mut scenario));
        };
        
        // Move to the next transaction
        next_tx(&mut scenario, OWNER);
        {
            // Get references to the created objects
            let metadata = test_scenario::take_immutable<CoinMetadata<KOBAN>>(&scenario);
            let treasury_cap = test_scenario::take_immutable<TreasuryCap<KOBAN>>(&scenario);
            
            // Verify the total supply
            let total_supply = coin::total_supply<KOBAN>(&treasury_cap);
            // 2,500,000,000 KOBAN with 9 decimals
            assert_eq(total_supply, 2500000000000000000);

            debug::print(&total_supply);
            
            // Return the objects
            test_scenario::return_immutable(metadata);
            test_scenario::return_immutable(treasury_cap);
        };
        
        // End the test scenario
        test_scenario::end(scenario);
    }
}


