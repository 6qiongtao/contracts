import ZombieWar from 0xb778a4d137e24d8a
import NonFungibleToken from 0x631e88ae7f1d7c20

transaction(recipient:Address){
    let minter:&ZombieWar.NFTMinter
    // let receiver: &{NonFungibleToken.CollectionPublic}
    prepare(signer:AuthAccount){
        self.minter = signer.borrow<&ZombieWar.NFTMinter>(from:ZombieWar.minterStoragePath)
            ?? panic("Could not borrow a reference to the NFT minter")

    }

    execute{
        let receiver = getAccount(recipient)
                        .getCapability(ZombieWar.collectionPublicPath)
                        .borrow<&{NonFungibleToken.CollectionPublic}>()
                        ?? panic("Could not get receiver reference to the NFT Collection")
        
        let metadata:ZombieWar.ZombieWarMetadata = ZombieWar.ZombieWarMetadata(
            name:"test1",
            rarity:"",
            level:1,
            fighting_power:200,
            camp:"fda",
            hero_type :"fadff",
            attack_power:100,
            fire_rate:1.0,
            critical_hits:"5%",
            ch_damage:"%200",
            description:"this is a test",
            url:"https://baidu.com"
        )
        
        self.minter.mintNFT(
            recipient:receiver,
            meta:metadata
        )
    }
}