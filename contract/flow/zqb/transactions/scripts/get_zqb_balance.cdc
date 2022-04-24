// This script returns the balance of an account's ZQB vault.
//
// Parameters:
// - address: The address of the account holding the ZQB vault.
//
// This script will fail if they account does not have an ZQB vault.
// To check if an account has a vault or initialize a new vault, 
// use check_zqb_vault_setup.cdc and setup_zqb_vault.cdc respectively.

import FungibleToken from 0x9a0766d93b6608b7
import ZQB from 0xc740c060b6aec1b9

pub fun main(address: Address): UFix64 {
    let account = getAccount(address)

    let vaultRef = account.getCapability(/public/zqbBalance)!
        .borrow<&ZQB.Vault{FungibleToken.Balance}>()
        ?? panic("Could not borrow Balance reference to the Vault")

    return vaultRef.balance
}
