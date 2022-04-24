import ZombieWar from 0xb778a4d137e24d8a
import NonFungibleToken from 0x631e88ae7f1d7c20

pub fun main(acc:Address):[UInt64]{
    let ref = getAccount(acc).getCapability(ZombieWar.collectionPublicPath)
    .borrow<&{NonFungibleToken.CollectionPublic}>()
    ?? panic("could not borrow this acc ref")
    return ref.getIDs()
}