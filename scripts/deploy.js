const { ethers } = require("hardhat");

const deploy = async() => {
    const [deployer] = await ethers.getSigners();

    console.log('Deploying contract w account :', deployer.address);

    const PlatziPunks = await ethers.getContractFactory("PlatziPunks");

    const deployed = await PlatziPunks.deploy(10000);

    console.log("PPKS deployed at:", deployed.address);
};

deploy().then(() => process.exit(0)).catch(error => {
    console.log(error)
    process.exit(1)
})