// This transaction configures the signer's account with an empty ZQB vault.
//
// It also links the following capabilities:
//
// - FungibleToken.Receiver: this capability allows this account to accept ZQB deposits.
// - FungibleToken.Balance: this capability allows anybody to inspect the ZQB balance of this account.

import FungibleToken from 0x9a0766d93b6608b7
import ZQB from 0xc740c060b6aec1b9

transaction {

    prepare(signer: AuthAccount) {

        // It's OK if the account already has a Vault, but we don't want to replace it
        if(signer.borrow<&ZQB.Vault>(from: /storage/zqbVault) != nil) {
            return
        }

        // Create a new ZQB Vault and put it in storage
        signer.save(<-ZQB.createEmptyVault(), to: /storage/zqbVault)

        // Create a public capability to the Vault that only exposes
        // the deposit function through the Receiver interface
        signer.link<&ZQB.Vault{FungibleToken.Receiver}>(
            /public/zqbReceiver,
            target: /storage/zqbVault
        )

        // Create a public capability to the Vault that only exposes
        // the balance field through the Balance interface
        signer.link<&ZQB.Vault{FungibleToken.Balance}>(
            /public/zqbBalance,
            target: /storage/zqbVault
        )
    }

}
