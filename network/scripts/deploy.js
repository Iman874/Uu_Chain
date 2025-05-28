async function main() {
  const UuChain = await ethers.getContractFactory("UuChain");
  const uuChain = await UuChain.deploy();

  await uuChain.deployed();

  console.log("UuChain deployed to:", uuChain.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
