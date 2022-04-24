// This transaction withdraws ZQB from the signer's account and deposits it into a recipient account.
// This transaction will fail if the recipient does not have an ZQB receiver.
// No funds are transferred or lost if the transaction fails.
//
// Parameters:
// - amount: The amount of ZQB to transfer (e.g. 10.0)
// - to: The recipient account address.
//
// This transaction will fail if either the sender or recipient does not have
// an ZQB vault stored in their account. To check if an account has a vault
// or initialize a new vault, use check_zqb_vault_setup.cdc and setup_zqb_vault.cdc
// respectively.

import FungibleToken from 0x9a0766d93b6608b7
import ZQB from 0xc740c060b6aec1b9

transaction(to: Address, amount: UFix64) {

    // The Vault resource that holds the tokens that are being transferred
    let sentVault: @FungibleToken.Vault

    prepare(signer: AuthAccount) {
        // Get a reference to the signer's stored vault
        let vaultRef = signer.borrow<&ZQB.Vault>(from: /storage/zqbVault)
            ?? panic("Could not borrow reference to the owner's Vault!")

        // Withdraw tokens from the signer's stored vault
        self.sentVault <- vaultRef.withdraw(amount: amount)
    }

    execute {
        // Get the recipient's public account object
        let recipient = getAccount(to)

        // Get a reference to the recipient's Receiver
        let receiverRef = recipient.getCapability(/public/zqbReceiver)!.borrow<&{FungibleToken.Receiver}>()
            ?? panic("Could not borrow receiver reference to the recipient's Vault")

        // Deposit the withdrawn tokens in the recipient's receiver
        receiverRef.deposit(from: <-self.sentVault)
    }
}
