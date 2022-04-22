import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

pub contract ZombieWar:NonFungibleToken{
    pub var totalSupply:UInt64
    pub let minterStoragePath:StoragePath
    pub let collectionStoragePath:StoragePath
    pub let collectionPublicPath:PublicPath

    pub event ContractInitialized()

    pub event Withdraw(id:UInt64,from:Address?)
    pub event Deposit(id:UInt64,to:Address?)
    pub event Minted(id:UInt64,to:Address?)
    pub event Burned(id:UInt64,from:Address?)

    pub struct ZombieWarMetadata {
        // hero name 
        pub let name:String
        // R or SR
        pub let rarity: String
        pub let level:UInt64
        pub let fighting_power:UInt64

        pub let camp: String
        pub let hero_type: String
        pub let attack_power:UInt64
        pub let fire_rate:UFix64
        pub let critical_hits:String
        // critical hits danage
        pub let ch_damage:String

        pub let description: String
        pub let url : String

        init(
            name:String,
            rarity:String,
            level:UInt64,
            fighting_power:UInt64,
            camp:String,
            hero_type:String,
            attack_power:UInt64,
            fire_rate:UFix64,
            critical_hits:String,
            ch_damage:String,
            description:String,
            url:String
        ){
            self.name = name
            self.rarity = rarity
            self.level = level
            self.fighting_power = fighting_power
            self.camp  = camp
            self.hero_type = hero_type
            self.attack_power = attack_power
            self.fire_rate = fire_rate
            self.critical_hits = critical_hits
            self.ch_damage = ch_damage
            self.description = description
            self.url = url
        }
    }

    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
        pub let id: UInt64
        pub var metadata:ZombieWarMetadata?

        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<ZombieWar.ZombieWarMetadata>()
            ]
        }

        pub fun resolveView(_ view: Type): AnyStruct? {
            switch view {
                case Type<MetadataViews.Display>():
                   if let meta = self.metadata{
                        let name = meta.name
                        let description = meta.description
                        return MetadataViews.Display(
                        name:name,
                        description:description,
                        thumbnail: MetadataViews.HTTPFile(
                            url: meta.url
                          )
                        )
                    }
                    return nil
                       
                case Type<ZombieWar.ZombieWarMetadata>():
                    if let meta = self.metadata{
                        return ZombieWar.ZombieWarMetadata(
                           name                :meta.name,
                            rarity              :meta.rarity,
                            level               :meta.level,
                            fighting_power      :meta.fighting_power,
                            camp                :meta.camp,
                            hero_type           :meta.hero_type,
                            attack_power        :meta.attack_power,
                            fire_rate           :meta.fire_rate,
                            critical_hits       :meta.critical_hits,
                            ch_damage           :meta.ch_damage,
                            description         :meta.description,
                            url                 :meta.url
                        )
                    }
                    return nil
                    
            }
            return nil
        }

        init(initID: UInt64, metadata: ZombieWar.ZombieWarMetadata) {
            self.id = initID
            self.metadata = metadata
        }

    }

    pub resource interface ZombieWarCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowZombieWar(id: UInt64): &ZombieWar.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow ZombieWar reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: ZombieWarCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

        init () {
            self.ownedNFTs <- {}
        }

        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("withdraw - missing NFT")

            emit Withdraw(id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @ZombieWar.NFT
            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token

            emit Deposit(id: id, to: self.owner?.address)
            destroy oldToken
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

        pub fun borrowZombieWar(id: UInt64): &ZombieWar.NFT? {
            if self.ownedNFTs[id] != nil {
                let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
                return ref as! &ZombieWar.NFT
            }

            return nil
        }

        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
            let ZombieWar = nft as! &ZombieWar.NFT
            return ZombieWar as &AnyResource{MetadataViews.Resolver}
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    pub resource NFTMinter {
        pub fun mintNFT(recipient: &{NonFungibleToken.CollectionPublic}, meta: ZombieWar.ZombieWarMetadata) {
          
            var newNFT <- create NFT(initID: ZombieWar.totalSupply, metadata: meta)
            recipient.deposit(token: <-newNFT)
            ZombieWar.totalSupply = ZombieWar.totalSupply + 1
        }
    }

     init() {
        self.totalSupply = 0

        self.minterStoragePath = /storage/zombieWarMinter
        self.collectionStoragePath = /storage/zombieWarCollection
        self.collectionPublicPath  = /public/zombieWarCollection

        let collection <- create Collection()
        self.account.save(<-collection, to: self.collectionStoragePath)

        self.account.link<&ZombieWar.Collection{NonFungibleToken.CollectionPublic, ZombieWar.ZombieWarCollectionPublic}>(
            self.collectionPublicPath,
            target: self.collectionStoragePath
        )

        let minter <- create NFTMinter()
        self.account.save(<-minter, to: self.minterStoragePath)

        emit ContractInitialized()
    }
}