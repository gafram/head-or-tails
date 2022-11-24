import { ethers } from "hardhat";


async function main() {
    const [signer] = await ethers.getSigners();

    const HeadsOrTailsFact = await ethers.getContractFactory("HeadsOrTails", signer);
    const headsOrTails = await HeadsOrTailsFact.deploy();

    await headsOrTails.deployed();

    console.log(headsOrTails.address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});