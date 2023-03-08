import { expect } from 'chai';
import { ethers } from 'hardhat';

describe.only("Profile Registry", function () {

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
		it("Should get the tokenID count", async function () {
			
			const currentCount: string = await registry.getCount();
			expect(currentCount).to.equal(0);
		});
	})

    describe("Profile creation", function() {
		
        beforeEach(async function () {
            const handle = "mozambique"
            const metadataURI = "https://arweave.net/cc7848jjh277xn"
			const profle: string = await registry.registerProfile(handle, metadataURI);
        });

		it("Should update current count when registering a new profile", async function () {

			const currentCount: number = await registry.getCount();
			expect(currentCount).to.equal(1);
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

        /**
		// It should set the deployer as moderator
		it("Should set the deployer as moderator", async function () {
			
			const isModerator: boolean = await registry.getModerator(owner.address);
			expect(isModerator).to.be.true;
		});

		// It should set the deployer as member
		it("Should set the deployer as member", async function () {
			
			const isMember: boolean = await registry.getMember(owner.address);
			expect(isMember).to.be.true;
		});
         */
	})
});
