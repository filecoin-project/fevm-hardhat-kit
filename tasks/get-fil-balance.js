task("get-fil-balance", "Get the amount of FIL at address.")
  .addParam("address", "The address of the account")
  .setAction(async (taskArgs) => {
  const balance = await provider.getBalance(
    taskArgs.address,
    "latest"
  );
  console.log(balance);
})