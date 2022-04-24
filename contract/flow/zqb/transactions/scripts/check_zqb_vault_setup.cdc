// This script returns true if the account specified has been properly set up to use ZQB,
// and false otherwise.
//
// If this script returns false, 
// the most likely cause is that the account has not been set up with an ZQB vault.
// To fix this, the user should execute transactions/setup_account.cdc.
//
// Parameters:
// - address: The address of the account to check.

import FungibleToken from 0x9a0766d93b6608b7
import ZQB from 0xc740c060b6aec1b9

pub fun main(address: Address): Bool {
    let account = getAccount(address)

    let receiverRef = account.getCapability(/public/zqbReceiver)!
        .borrow<&ZQB.Vault{FungibleToken.Receiver}>()
        ?? nil

    let balanceRef = account.getCapability(/public/zqbBalance)!
        .borrow<&ZQB.Vault{FungibleToken.Balance}>()
        ?? nil

    return (receiverRef != nil) && (balanceRef != nil)
}
