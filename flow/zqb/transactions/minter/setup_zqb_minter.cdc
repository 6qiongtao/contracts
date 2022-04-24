// This transaction creates a new minter proxy resource and
// stores it in the signer's account.
//
// After running this transaction, the ZQB administrator
// must run deposit_zqb_minter.cdc to deposit a minter resource
// inside the minter proxy.

import ZQB from 0xc740c060b6aec1b9

transaction {

    prepare(minter: AuthAccount) {

        let minterProxy <- ZQB.createMinterProxy()

        minter.save(
            <- minterProxy, 
            to: ZQB.MinterProxyStoragePath,
        )
            
        minter.link<&ZQB.MinterProxy{ZQB.MinterProxyPublic}>(
            ZQB.MinterProxyPublicPath,
            target: ZQB.MinterProxyStoragePath
        )
    }
}
