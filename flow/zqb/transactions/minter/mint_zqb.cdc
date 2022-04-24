// This transaction mints new ZQB and increases the total supply.
// The minted ZQB is deposited into the recipient account.
//
// Parameters:
// - amount: The amount of ZQB to transfer (e.g. 10.0)
// - to: The recipient account address.
//
// This transaction will fail if the authorizer does not have and ZQB.MinterProxy
// resource. Use the setup_ZQB_minter.cdc and deposit_zqb_minter.cdc transactions
// to configure the minter proxy.
//
// This transaction will fail if the recipient does not have
// an ZQB vault stored in their account. To check if an account has a vault
// or initialize a new vault, use check_zqb_vault_setup.cdc and setup_zqb_vault.cdc
// respectively.

import FungibleToken from 0x9a0766d93b6608b7
import ZQB from 0xc740c060b6aec1b9

transaction(to: Address, amount: UFix64) {

    let tokenMinter: &ZQB.MinterProxy
    let tokenReceiver: &{FungibleToken.Receiver}

    prepare(minterAccount: AuthAccount) {
        self.tokenMinter = minterAccount
            .borrow<&ZQB.MinterProxy>(from: ZQB.MinterProxyStoragePath)
            ?? panic("No minter available")

        self.tokenReceiver = getAccount(to)
            .getCapability(/public/zqbReceiver)!
            .borrow<&{FungibleToken.Receiver}>()
            ?? panic("Unable to borrow receiver reference")
    }

    execute {
        let mintedVault <- self.tokenMinter.mintTokens(amount: amount)

        self.tokenReceiver.deposit(from: <-mintedVault)
    }
}
