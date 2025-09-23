const { MerkleTree } = require("fixed-merkle-tree");
const { buildPoseidon } = require("circomlibjs");

async function generateTree(levels, leaves) {
    const poseidon = await buildPoseidon();

    function poseidonHash(values) {
        if (!Array.isArray(values)) {
            throw new Error("Values must be an array type");
        }

        const res = poseidon(values);
        return poseidon.F.toObject(res);
    }

    const tree = new MerkleTree(levels, leaves, {
        hashFunction: (l, r) => poseidonHash([l, r]),
    });

    return { tree, treeHashFn: poseidonHash };
}

async function getInclusionProof(userAddress, participantAddresses, treeHeight) {
    if (!participantAddresses.includes(userAddress)) {
        throw new Error("Account with provided private key is not participant of Trie");
    }

    const { tree, _ } = await generateTree(treeHeight, participantAddresses);

    return { proof: tree.proof(userAddress), tree };
}

module.exports = { generateTree, getInclusionProof };
