import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("heads-or-tails", function () {
    // We define a fixture to reuse the same setup in every test.
    // We use loadFixture to run this setup once, snapshot that state,
    async function deployFixture() {
        // Contracts are deployed using the first signer/account by default
        const [owner, player1, player2] = await ethers.getSigners();

        const HeadsOrTailsFact = await ethers.getContractFactory("HeadsOrTails", owner);
        const headsOrTails = await HeadsOrTailsFact.deploy();
    
        return { headsOrTails, player1, player2};
    }

    async function deployAndCreateFixture() {
            // Contracts are deployed using the first signer/account by default
        const [owner, player1, player2, otherPlayer] = await ethers.getSigners();

        const HeadsOrTailsFact = await ethers.getContractFactory("HeadsOrTails", owner);
        const headsOrTails = await HeadsOrTailsFact.deploy();

        return { headsOrTails, player1, player2, otherPlayer};
    }

    describe("CreateGame", function () {
        it("Should increase a numGames", async function () {
            const { headsOrTails, player1, player2 } = await loadFixture(deployFixture);

            const player1SecretBytes32 = ethers.utils.formatBytes32String("player1Secret");
            const deadline = (await time.latest()) + 3600;

            const initialNumGames = await headsOrTails.numGames();

            await headsOrTails.createGame(ethers.utils
                                                .solidityKeccak256(['uint', 'bytes32', 'address'], [1, player1SecretBytes32, player1.address]),
                                          true,
                                          deadline);
            

            expect(await headsOrTails.numGames()).to.equal(initialNumGames.toNumber() + 1);
        });
    });
});