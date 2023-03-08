import { expect } from 'chai';
import { ethers } from 'hardhat';

describe("Collections", function () {

	let Collection: any;
	let collection: any;
	let owner: any;
	let addr1: any;
	let addr2: any;
	let addrs: any;

	// `beforeEach` will run before each test, re-deploying the contract every
	// time. It receives a callback, which can be async.
	beforeEach(async function () {
		Collection = await ethers.getContractFactory("Collections");
		[owner, addr1, addr2, ...addrs] = await ethers.getSigners();
		collection = await Collection.deploy("Rebirth of Detroit", "RDT");
	});

	describe("Deployment", function() {
		// It should set the deployer as contract owner 
		it("Should set the deployer as contract owner", async function () {
			
			const contractOwner: string = await collection.getOwner();
			expect(owner.address).to.equal(contractOwner);
		});

		// It should set the deployer as moderator
		it("Should set the deployer as moderator", async function () {
			
			const isModerator: boolean = await collection.getModerator(owner.address);
			expect(isModerator).to.be.true;
		});

		// It should set the deployer as member
		it("Should set the deployer as member", async function () {
			
			const isMember: boolean = await collection.getMember(owner.address);
			expect(isMember).to.be.true;
		});
	})

	describe("Member management", function() {
		// ADD MODERATOR 
		it("ADD MODERATOR - Should allow owner to add new moderator", async function () {
			
			await collection.addModerator(addr1.address);
			let isModerator : boolean = await collection.getModerator(addr1.address)
			expect(isModerator).to.be.true;
		});
		// ADD MODERATOR
		it("ADD MODERATOR - Should NOT allow non-owner to add new moderator", async function () {
			
			await expect(collection.connect(addr1).addModerator(addr2.address))
				.to.be.revertedWith("Only contract owner is allowed'")
		});

		// ADD MODERATOR
		it("ADD MODERATOR - Should also add Moderator as Member", async function () {
			
			await collection.addModerator(addr1.address);
			let isMember : boolean = await collection.getMember(addr1.address)
			expect(isMember).to.be.true;
		});

		// DELETE MODERATOR
		it("DELETE MODERATOR - Should allow owner to delete a moderator", async function () {
			
			await collection.addModerator(addr1.address);
			await collection.deleteModerator(addr1.address)
			let isModerator : boolean = await collection.getModerator(addr1.address)
			expect(isModerator).to.be.false;
		});

		// DELETE MODERATOR
		it("DELETE MODERATOR - Should ONLY allow owner to delete a moderator", async function () {
			
			await collection.addModerator(addr1.address);
			await expect(collection.connect(addr1).deleteModerator(owner.address))
				.to.be.revertedWith("Only contract owner is allowed")
		});
		// DELETE MODERATOR
		it("DELETE MODERATOR - Should also delete Moderator as Member", async function () {
			
			await collection.addModerator(addr1.address);
			await collection.deleteModerator(addr1.address)
			let isModerator : boolean = await collection.getMember(addr1.address)
			expect(isModerator).to.be.false;
		});


		// ADD MEMBER 
		it("ADD MEMBER - Should allow moderators to add new member", async function () {
			
			await collection.addModerator(addr1.address);
			await collection.connect(addr1).addMember(addr2.address)
			let isMember : boolean = await collection.getMember(addr2.address)
			expect(isMember).to.be.true;
		});

		it("ADD MEMBER - Should NOT allow non-moderator to add new moderator", async function () {
			
			await expect(collection.connect(addr2).addMember(addr2.address))
				.to.be.revertedWith("Only moderators allowed")
		});

		// DELETE MEMBER 
		it("DELETE MEMBER - Should allow moderators to delete a member", async function () {
			
			await collection.addModerator(addr1.address);
			await collection.connect(addr1).addMember(addr2.address)
			
			await collection.connect(addr1).deleteMember(addr2.address)
			let isMemberAgain : boolean = await collection.getMember(addr2.address)
			expect(isMemberAgain).to.be.false;
		});
		// DELETE MEMBER
		it("DELETE MEMBER - Should NOT allow non-moderator to delete a member", async function () {
			
			await expect(collection.connect(addr2).addMember(addr2.address))
				.to.be.revertedWith("Only moderators allowed")
		});
	})


	describe("Minting", function() {
		// It should mint a new memory 
		it("Should MINT a new memory item!", async function () {
			await collection.mintMemory("Title", "Description", "www.mockurl.xyz");
			let memory = await collection.tokenMetadataAndURI(1)
			expect(memory.name).to.equal("Title");
		});

		// It should delete a memory item 
		it("Should delete a new memory item!", async function () {
			await collection.mintMemory("Title", "Description", "www.mockurl.xyz");
			await collection.deleteMemory(1)

			await expect(collection.tokenMetadataAndURI(1))
				.to.be.revertedWith("ERC721URIStorage: URI query for nonexistent token")
		});
	})
});
