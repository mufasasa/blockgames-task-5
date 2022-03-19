


const main = async () => {
    const [deployer] = await hre.ethers.getSigners();
    const acountBalance = await deployer.getBalance();

    console.log('Deploying contract with account: ', deployer.address);
    console.log('Deployer balance: ', acountBalance.toString());

    const stakingTokenContractFactory = await hre.ethers.getContractFactory("StakingToken");
    const stakingContract = await stakingTokenContractFactory.deploy(1000);
    await stakingContract.deployed();
    console.log('Contract deployed to: ', stakingContract.address);
    await stakingContract.modifyTokenBuyPrice(1);
    console.log('token buy price modified');
}

const runMain = async () => {
    try {
        await main();
        process.exit(0); // exit Node process without error
    } catch (error) {
        console.log(error);
        process.exit(1); // exit Node process while indicating 'Uncaught Fatal Exception' error
    }
}

runMain();