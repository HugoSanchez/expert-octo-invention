const main = async () => {
    const [owner, randomPerson] = await hre.ethers.getSigners();
    const ContractFactory = await hre.ethers.getContractFactory('ContractMain');
    const mainContract = await ContractFactory.deploy("verso");
    await mainContract.deployed();
    console.log("Contract deployed to:", mainContract.address);
    console.log("Contract deployed by:", owner.address);

}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};
  
runMain();