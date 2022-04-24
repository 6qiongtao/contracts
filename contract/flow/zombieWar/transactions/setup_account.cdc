import ZombieWar from 0xb778a4d137e24d8a
import NonFungibleToken from 0x631e88ae7f1d7c20
transaction{
    prepare(signer:AuthAccount){
        signer.save(<-ZombieWar.createEmptyCollection(), to: ZombieWar.collectionStoragePath)

        signer.link<&ZombieWar.Collection{NonFungibleToken.CollectionPublic, ZombieWar.ZombieWarCollectionPublic}>(
            ZombieWar.collectionPublicPath,
            target: ZombieWar.collectionStoragePath
        )
    }
}