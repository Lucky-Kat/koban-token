#[test_only]
module koban::test_koban {
    use koban::koban::{Self, KOBAN};
    use sui::balance;
    use sui::coin::{Self, Coin, CoinMetadata, TreasuryCap};
    use std::debug;
    use sui::test_scenario::{Self, Scenario, ctx};

    const OWNER: address = @0xCA6ED;
    const RECIPIENT: address = @0xB00B5;

    /**
     * Helper function that sets things up and calls init
     */
    fun test_setup(): Scenario {
        let mut scenario = test_scenario::begin(OWNER);
        koban::test_init(ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, OWNER);

        let metadata = test_scenario::take_immutable<CoinMetadata<KOBAN>>(&scenario);

        test_scenario::return_immutable(metadata);
        scenario
    }

    /**
     * Helper function that mints a single Koban coin with the specified value
     */
    public fun mint_koban(owner: address, recipient: address, amount: u64, scenario: &mut Scenario) {
        let found_treasury = test_scenario::has_most_recent_for_address<TreasuryCap<KOBAN>>(owner);
        assert!(found_treasury, 0);

        let mut treasury_cap = test_scenario::take_from_address<TreasuryCap<KOBAN>>(scenario, owner);
        let total_supply_before = coin::total_supply<KOBAN>(&treasury_cap);

        test_scenario::next_tx(scenario, owner);
        {
            let ctx = ctx(scenario);
            let koban = coin::mint<KOBAN>(&mut treasury_cap, amount, ctx);

            let balance = coin::balance<KOBAN>(&koban);
            let value = balance::value(balance);
            assert!(value == amount, 0);

            transfer::public_transfer(koban, recipient);
        };

        let total_supply_after = coin::total_supply<KOBAN>(&treasury_cap);
        assert!(total_supply_after == total_supply_before + amount, 0);

        test_scenario::return_to_address(owner, treasury_cap);
        test_scenario::next_tx(scenario, owner);
    }

    /**
     * Helper function that mints 3 Koban coins with varying values
     */
    fun mint_multiple_test_coins(owner: address, recipient: address, scenario: &mut Scenario) {
        let mint_1_amount = 10;
        let mint_2_amount = 81721009;
        let mint_3_amount = 1921000153;
        let total_amount = mint_1_amount + mint_2_amount + mint_3_amount;

        mint_koban(owner, recipient, mint_1_amount, scenario);
        mint_koban(owner, recipient, mint_2_amount, scenario);
        mint_koban(owner, recipient, mint_3_amount, scenario);

        // Check that the total KOBAN owned by recipient adds up
        test_scenario::next_tx(scenario, owner);
        {
            let koban_3 = test_scenario::take_from_address<Coin<KOBAN>>(scenario, recipient);
            let koban_2 = test_scenario::take_from_address<Coin<KOBAN>>(scenario, recipient);
            let koban_1 = test_scenario::take_from_address<Coin<KOBAN>>(scenario, recipient);

            let balance_3 = coin::balance<KOBAN>(&koban_3);
            let value_3 = balance::value(balance_3);
            debug::print(&value_3);

            let balance_2 = coin::balance<KOBAN>(&koban_2);
            let value_2 = balance::value(balance_2);
            debug::print(&value_2);

            let balance_1 = coin::balance<KOBAN>(&koban_1);
            let value_1 = balance::value(balance_1);
            debug::print(&value_1);

            assert!(value_3 + value_2 + value_1 == total_amount, 0);

            test_scenario::return_to_address(recipient, koban_3);
            test_scenario::return_to_address(recipient, koban_2);
            test_scenario::return_to_address(recipient, koban_1);
        };

        let treasury_cap = test_scenario::take_from_address<TreasuryCap<KOBAN>>(scenario, owner);
        let total_supply = coin::total_supply<KOBAN>(&treasury_cap);
        assert!(total_supply == total_amount, 0);
        test_scenario::return_to_address(owner, treasury_cap);

        test_scenario::next_tx(scenario, owner);
    }

    #[test]
    fun test_mint_koban_success() {
        let mut scenario = test_setup();
        mint_multiple_test_coins(OWNER, RECIPIENT, &mut scenario);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_burn_koban_success() {
        let mut scenario = test_setup();

        mint_multiple_test_coins(OWNER, RECIPIENT, &mut scenario);

        let found_treasury = test_scenario::has_most_recent_for_address<TreasuryCap<KOBAN>>(OWNER);
        assert!(found_treasury, 0);
        let mut treasury_cap = test_scenario::take_from_address<TreasuryCap<KOBAN>>(&scenario, OWNER);

        let mut total_supply = coin::total_supply<KOBAN>(&treasury_cap);
        assert!(total_supply > 0, 0);

        let coin_3 = test_scenario::take_from_address<Coin<KOBAN>>(&scenario, RECIPIENT);
        let coin_2 = test_scenario::take_from_address<Coin<KOBAN>>(&scenario, RECIPIENT);
        let coin_1 = test_scenario::take_from_address<Coin<KOBAN>>(&scenario, RECIPIENT);

        coin::burn<KOBAN>(&mut treasury_cap, coin_3);
        coin::burn<KOBAN>(&mut treasury_cap, coin_2);
        coin::burn<KOBAN>(&mut treasury_cap, coin_1);

        total_supply = coin::total_supply<KOBAN>(&treasury_cap);
        assert!(total_supply == 0, 0);

        test_scenario::return_to_address(OWNER, treasury_cap);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_join_and_split_koban_success() {
        let mut scenario = test_setup();

        mint_multiple_test_coins(OWNER, RECIPIENT, &mut scenario);

        // Join all coins into one
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut coin_3 = test_scenario::take_from_address<Coin<KOBAN>>(&scenario, RECIPIENT);
            let coin_2 = test_scenario::take_from_address<Coin<KOBAN>>(&scenario, RECIPIENT);
            let mut coin_1 = test_scenario::take_from_address<Coin<KOBAN>>(&scenario, RECIPIENT);

            let balance_3 = coin::balance<KOBAN>(&coin_3);
            let value_3 = balance::value(balance_3);

            let balance_2 = coin::balance<KOBAN>(&coin_2);
            let value_2 = balance::value(balance_2);

            let balance_1 = coin::balance<KOBAN>(&coin_1);
            let value_1 = balance::value(balance_1);

            coin::join<KOBAN>(&mut coin_1, coin_2);
            let balance = coin::balance<KOBAN>(&coin_1);
            let value = balance::value(balance);
            assert!(value == value_1 + value_2, 0);

            coin::join<KOBAN>(&mut coin_3, coin_1);
            let balance = coin::balance<KOBAN>(&coin_3);
            let value = balance::value(balance);
            assert!(value == value_1 + value_2 + value_3, 0);

            test_scenario::return_to_address(RECIPIENT, coin_3);
        };

        // Split coins
        test_scenario::next_tx(&mut scenario, OWNER);
        {
            let mut original_coin = test_scenario::take_from_address<Coin<KOBAN>>(&scenario, RECIPIENT);
            let original_balance = coin::balance<KOBAN>(&original_coin);
            let original_value = balance::value(original_balance);

            let split_coin_1 = coin::split<KOBAN>(&mut original_coin, 10, ctx(&mut scenario));
            let balance_1 = coin::balance<KOBAN>(&split_coin_1);
            let value_1 = balance::value(balance_1);
            assert!(value_1 == 10, 0);

            let updated_balance = coin::balance<KOBAN>(&original_coin);
            let updated_value = balance::value(updated_balance);
            assert!(updated_value == original_value - value_1, 0);

            let mut split_coin_2 = coin::split<KOBAN>(&mut original_coin, 489123, ctx(&mut scenario));
            let mut balance_2 = coin::balance<KOBAN>(&split_coin_2);
            let mut value_2 = balance::value(balance_2);
            assert!(value_2 == 489123, 0);

            let updated_balance = coin::balance<KOBAN>(&original_coin);
            let updated_value = balance::value(updated_balance);
            assert!(updated_value == original_value - value_1 - value_2, 0);

            let mut split_coin_3 = coin::split<KOBAN>(&mut split_coin_2, 89120, ctx(&mut scenario));
            let mut balance_3 = coin::balance<KOBAN>(&split_coin_3);
            let mut value_3 = balance::value(balance_3);
            assert!(value_3 == 89120, 0);

            balance_2 = coin::balance<KOBAN>(&split_coin_2);
            value_2 = balance::value(balance_2);
            assert!(original_value == updated_value + value_1 + value_2 + value_3, 0);

            coin::join<KOBAN>(&mut split_coin_3, original_coin);
            balance_3 = coin::balance<KOBAN>(&split_coin_3);
            value_3 = balance::value(balance_3);
            assert!(original_value == value_1 + value_2 + value_3, 0);

            transfer::public_transfer(split_coin_1, RECIPIENT);
            transfer::public_transfer(split_coin_2, RECIPIENT);
            transfer::public_transfer(split_coin_3, RECIPIENT);
        };

        test_scenario::end(scenario);
    }

    #[test, expected_failure]
    fun test_mint_koban_auth_fail() {
        let mut scenario = test_setup();
        mint_koban(RECIPIENT, RECIPIENT, 10, &mut scenario);
        test_scenario::end(scenario);
    }
}


