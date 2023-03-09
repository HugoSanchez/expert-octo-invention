import { expect } from 'chai';
import { ethers } from 'hardhat';

describe("Profile Registry", function () {

	let ProfileRegistry: any;
	let registry: any;
	let owner: any;
	let addr1: any;
	let addr2: any;
	let addrs: any;

	// `beforeEach` will run before each test, re-deploying the contract every
	// time. It receives a callback, which can be async.
	beforeEach(async function () {
		ProfileRegistry = await ethers.getContractFactory("ProfileRegistry");
		[owner, addr1, addr2, ...addrs] = await ethers.getSigners();
		registry = await ProfileRegistry.deploy();
	});

	describe("Deployment", function() {
		// It should set the deployer as contract owner 
		it("Should deploy contract and set initial count to 1", async function () {
			
			const currentCount: string = await registry.getCount();
			expect(currentCount).to.equal(1);
		});
	})

    describe("Profile creation", function() {
		
        beforeEach(async function () {
            const handle = "mozambique"
            const metadataURI = "https://arweave.net/cc7848jjh277xn"
			const profle: string = await registry.registerProfile(handle, metadataURI);
        });

        it("Should mint a new profile", async function () {
			
			const currentCount: string = await registry.getCount();
			expect(currentCount).to.equal(2);
		});

        it("Should NOT allow to mint the same profile twice", async function () {
			
			const handle = "mozambique"
            const metadataURI = "https://arweave.net/cc7848jjh277xn"
			await expect(registry.registerProfile(handle, metadataURI))
                .to.be.revertedWith("This address already has a profile.");
		});

        it("Should NOT allow to mint a profile which handle is already taken", async function () {
			
			const handle = "mozambique"
            const metadataURI = "https://arweave.net/cc7848jjh277xn"
            const [owner, addr1] = await ethers.getSigners();
			await expect(registry.connect(addr1).registerProfile(handle, metadataURI))
                .to.be.revertedWith("Handle already taken");
		});


        it("Should return profile ID by address", async function () {
			
			const profileID: number = await registry.getIdFromAddress(owner.address);
            const parsed = profileID.toString()
			expect(parsed).to.equal("1");
		});

        it("Should return profile details by ID", async function () {
			
			const profileDetails: any = await registry.getProfileByID(1);
			expect(profileDetails.handle).to.equal("mozambique");
		});

        it("Should allow owner to update metadata", async function () {
			
            const newMetadata = "https://arweave.net/cc77xn"
			const newData: number = await registry.updateProfileMetadata(1, newMetadata);
            const profileDetails: any = await registry.getProfileByID(1);
			expect(profileDetails.metadataURI).to.equal(newMetadata);
		});

        it("Should NOT allow to update someone else's metadata", async function () {
			
            const newMetadata = "https://arweave.net/cc77xn"
            const [owner, addr1] = await ethers.getSigners();
			await expect(registry.connect(addr1).updateProfileMetadata(1, newMetadata))
                .to.be.revertedWith("Can't change someone else's metadata");
            
		});

        it("Should allow owner to ADD a new collection", async function () {
			
            const collectionAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
			await registry.addCollection(1, collectionAddress);
            const profileDetails: any = await registry.getProfileByID(1);
			expect(profileDetails.collections[0]).to.equal(collectionAddress);
		});

        it("Should NOT allow to UPDATE someone else's collections", async function () {
			
            const collectionAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
            const [owner, addr1] = await ethers.getSigners();
			await expect(registry.connect(addr1).addCollection(1, collectionAddress))
                .to.be.revertedWith("Can't change someone else's collections");
            
		});

        it("Should allow owner to REMOVE a collection", async function () {
			
            const collectionAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
			await registry.addCollection(1, collectionAddress);
			await registry.removeCollection(1, 0);
            const profileDetails: any = await registry.getProfileByID(1);
			expect(profileDetails.collections[0]).to.equal(undefined);
		});

        it("Should NOT allow someone else to REMOVE a collection", async function () {
			
            const collectionAddress = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
			await registry.addCollection(1, collectionAddress);
            const [owner, addr1] = await ethers.getSigners();
			await expect(registry.connect(addr1).removeCollection(1, 0))
                .to.be.revertedWith("Can't remove someone else's collections");
		});
	})
});
