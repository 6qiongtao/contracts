
import ZombieWar from 0xb778a4d137e24d8a
import NonFungibleToken from 0x631e88ae7f1d7c20
import MetadataViews from 0x631e88ae7f1d7c20
pub fun main(from:Address,tokenID:UInt64):ZombieWar.ZombieWarMetadata{
    let nftRef = getAccount(from)
    .getCapability(ZombieWar.collectionPublicPath)
    .borrow<&{ZombieWar.ZombieWarCollectionPublic}>()
    ?? panic("could not borrow ref")
    let zqNFTRef = nftRef.borrowZombieWar(id:tokenID)?? panic("could not borrow zq nft ref")
    let view =  zqNFTRef.resolveView(Type<ZombieWar.ZombieWarMetadata>())!
    let meta = view as! ZombieWar.ZombieWarMetadata
    return meta
}