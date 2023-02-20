const CID = require('cids')

task(
    "cid-to-bytes",
    "Converts CID to EVM compatible hex bytes."
  )
    .addParam("cid", "The piece CID of the data you want to put up a bounty for")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const cid = taskArgs.cid

        //convert piece CID string to hex bytes
        const cidHexRaw = new CID(cid).toString('base16').substring(1)
        const cidHex = "0x00" + cidHexRaw
        console.log("Hex bytes are:", cidHex)
        console.log("Complete!")
    })