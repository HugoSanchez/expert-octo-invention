import type { NextApiRequest, NextApiResponse } from 'next';
import Bundlr from '@bundlr-network/client';

type Data = {

    balance: string | any,
    transaction: string | any,
    txID: string

}
/** 
export default async function handler(

    req: NextApiRequest,
    res: NextApiResponse<Data>

) {

    // const BUNDLER_NODE_URL = "X"
	const {BUNDLER_NODE_URL, BUNDLER_CURRENCY, BUNDLER} = process.env
    const bundlr = new Bundlr(BUNDLER_NODE_URL, BUNDLER_CURRENCY, BUNDLER);
    const data = JSON.stringify({isThisWorking: "yes"})
    const tags = [{name: "Content-Type", value: "application/json"}];


    const transaction = bundlr.createTransaction(data, { tags });  
    await transaction.sign();
    await transaction.upload();

    let balance = await bundlr.getLoadedBalance()

    res.status(200).json({ 
		balance: balance,
		transaction: transaction,
		txID: transaction.id
    })
}

*/