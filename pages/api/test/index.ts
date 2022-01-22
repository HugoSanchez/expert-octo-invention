import type { NextApiRequest, NextApiResponse } from 'next';
import Bundlr from '@bundlr-network/client';

type Data = {

    balance: string | any,
    transaction: string | any,
    txID: string
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<Data>
) {
    const bundlr = new Bundlr("https://node1.bundlr.network/", "matic", process.env.BUNDLER);
    
    const data = JSON.stringify({isThisWorking: "yes"})
    const tags = [{name: "Content-Type", value: "application/json"}];


    const transaction = bundlr.createTransaction(data, { tags });  
    await transaction.sign();
    await transaction.upload();

    console.log(1)
    let balance = await bundlr.getLoadedBalance()
    console.log(2)

    res.status(200).json({ 
      balance: balance,
      transaction: transaction,
      txID: transaction.id
     })
}

