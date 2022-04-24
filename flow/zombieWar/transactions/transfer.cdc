import ZombieWar from 0xb778a4d137e24d8a
import NonFungibleToken from 0x631e88ae7f1d7c20

transaction(recipient: Address,tokenID:UInt64){
    let collectionRef :&ZombieWar.Collection
    
    
    prepare(signer:AuthAccount){
        self.collectionRef = signer.borrow<&ZombieWar.Collection>(from:ZombieWar.collectionStoragePath)
                        ?? panic("Could not borrow collection Ref")
        
        
    }
    execute{
        let receiver = getAccount(recipient)
        let receiverRef =  receiver.getCapability(ZombieWar.collectionPublicPath)
                .borrow<&{ZombieWar.ZombieWarCollectionPublic}>()
                ?? panic("Could not borrow receiver collection ref")
        let nft <- self.collectionRef.withdraw(withdrawID:tokenID)
        receiverRef.deposit(token:<-nft)
    }
}