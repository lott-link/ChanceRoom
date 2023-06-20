async function deployFee(contractName, ...arguments) {

  const Contract = await hre.ethers.getContractFactory(contractName);
  const deploymentData = Contract.getDeployTransaction(...arguments).data;

  const gasPrice = await hre.ethers.provider.getGasPrice();
  const gasEstimate = await hre.ethers.provider.estimateGas({
    data: deploymentData,
  });

  const gasFee = gasEstimate.mul(gasPrice);
  const gasFeeInEth = hre.ethers.utils.formatEther(gasFee);

  console.log("Estimated gas:", gasEstimate.toString());
  console.log("Gas price:", (gasPrice / 10 ** 9).toString());
  console.log("Gas fee (ETH):", gasFeeInEth.toString());
}

async function callFee(contract, functionName, ...arguments) {
const ethers = hre.ethers;

const functionSignature = contract.interface.getSighash(functionName);
const callData = contract.interface.encodeFunctionData(functionSignature, arguments);

const gasEstimate = await ethers.provider.estimateGas({
  data: callData,
});

const gasPrice = await ethers.provider.getGasPrice();

const gasFee = gasEstimate.mul(gasPrice);
const gasFeeInEth = ethers.utils.formatEther(gasFee);

console.log("Estimated gas:", gasEstimate.toString());
console.log("Gas price:", gasPrice.toString());
console.log("Gas fee (ETH):", gasFeeInEth.toString());
}

module.exports = {
deployFee,
callFee
}
