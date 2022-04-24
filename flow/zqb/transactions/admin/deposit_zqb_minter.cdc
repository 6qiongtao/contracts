// This transaction creates a new ZQB minter and deposits
// it into an existing minter proxy resource on the specified account.
//
// Parameters:
// - minterAddress: The minter account address.
//
// This transaction will fail if the authorizer does not have the ZQB.Administrator
// resource.
//
// This transaction will fail if the minter account does not have
// an ZQB.MinterProxy resource. Use the setup_zqb_minter.cdc transaction to
// create a minter proxy in the minter account.

import ZQB from 0xc740c060b6aec1b9

transaction(minterAddress: Address) {

    let resourceStoragePath: StoragePath
    let capabilityPrivatePath: CapabilityPath
    let minterCapability: Capability<&ZQB.Minter>

    prepare(adminAccount: AuthAccount) {

        // These paths must be unique within the ZQB contract account's storage
        self.resourceStoragePath = /storage/minter_zqb_01
        self.capabilityPrivatePath = /private/minter_zqb_01

        // Create a reference to the admin resource in storage.
        let tokenAdmin = adminAccount.borrow<&ZQB.Administrator>(from: ZQB.AdminStoragePath)
            ?? panic("Could not borrow a reference to the admin resource")

        // Create a new minter resource and a private link to a capability for it in the admin's storage.
        let minter <- tokenAdmin.createNewMinter()
        adminAccount.save(<- minter, to: self.resourceStoragePath)
        self.minterCapability = adminAccount.link<&ZQB.Minter>(
            self.capabilityPrivatePath,
            target: self.resourceStoragePath
        ) ?? panic("Could not link minter")

    }

    execute {
        // This is the account that the capability will be given to
        let minterAccount = getAccount(minterAddress)

        let capabilityReceiver = minterAccount.getCapability
            <&ZQB.MinterProxy{ZQB.MinterProxyPublic}>
            (ZQB.MinterProxyPublicPath)!
            .borrow() ?? panic("Could not borrow capability receiver reference")

        capabilityReceiver.setMinterCapability(cap: self.minterCapability)
    }

}
