async function deployFee(contractName) {

    const Contract = await hre.ethers.getContractFactory(contractName);
    const deploymentData = Contract.getDeployTransaction("0x0000000000000000000000000000000000000000").data;
  
    const gasPrice = await hre.ethers.provider.getGasPrice();
    const gasEstimate = await hre.ethers.provider.estimateGas({
      data: deploymentData,
    });
  
    const gasFee = gasEstimate.mul(gasPrice);
    const gasFeeInEth = hre.ethers.utils.formatEther(gasFee);
  
    console.log("Estimated gas:", gasEstimate.toString());
    console.log("Gas price:", gasPrice.toString());
    console.log("Gas fee (ETH):", gasFeeInEth.toString());
  }
 

module.exports = {
  deployFee,
}
  