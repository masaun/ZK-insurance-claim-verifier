const { getInclusionProof } = require("./merkleTree.js");
const { resolve } = require("path");

const { stringify: tomlStringify } = require("@iarna/toml");
const { writeFile } = require("fs");

const { buildPoseidon } = require("circomlibjs");

const TEST_EMAIL_ADDRESSES = [
    "dry.914@yandex.com", // "swoons.00rubbing@icloud.com",
    "aa@oxor.io",
    "ab@oxor.io",
    "ac@oxor.io",
    "ad@oxor.io"
]
const TEST_SECRETS = [
    BigInt("2000000000000000000000000000000"),
    2,
    3,
    4,
    5
]
const TREE_HIGHT = 8;
const MAX_EMAIL_ADDRESS_LENGTH = 124;

function prepareForSerialization(obj) {
    if (obj instanceof Uint8Array) obj = Array.from(obj);

    const typeOfObj = typeof obj;

    if (typeOfObj === "bigint" || typeOfObj === "number") {
        return obj.toString();
    }

    if (Array.isArray(obj)) {
        return obj.map((element) => prepareForSerialization(element));
    }

    if (typeOfObj === "object" && obj !== null) {
        const result = {};
        for (const [key, value] of Object.entries(obj)) {
            result[key] = prepareForSerialization(value);
        }
        return result;
    }

    return obj;
}

function writeProverTOML(inputs, writeTo) {
    inputs = prepareForSerialization(inputs);
    const tomlString = tomlStringify(inputs);

    writeFile(writeTo, tomlString, (err) => {
        if (err) throw err;
        console.log("The Prover file has been saved!");
    });
}

(async function () {
    const poseidon = await buildPoseidon();
    
    function poseidonHash(values) {
        if (!Array.isArray(values)) {
            throw new Error("Values must be an array type");
        }
    
        const res = poseidon(values);
        return poseidon.F.toObject(res);
    }

    // convert email address to BigInt
    let members = TEST_EMAIL_ADDRESSES.map((val) => Array.from(Buffer.from(val, 'utf8')));
    // console.log(members)

    // 124 - len of email address
    members = members.map(val => val.concat(Array(MAX_EMAIL_ADDRESS_LENGTH-val.length).fill(0)))
    // console.log(members)

    // 4 slots for email address + 1 slot secret (31 bytes each slot)
    let leafs = []
    let chunks
    let chunk
    for (let i = 0; i < TEST_EMAIL_ADDRESSES.length; i++) {
        chunks = [0, 0, 0, 0, TEST_SECRETS[i]]
        for (let j = 0; j <4; j++) {
            chunk = members[i].slice(31*j,31*j+31)
            chunks[j] = BigInt('0x' + chunk.reduce((acc, byte) => acc + byte.toString(16).padStart(2, '0'), ''))
        }
        // console.log(chunks)
        leafs.push(poseidonHash(chunks))
    }
    // console.log(leafs)

    const { proof, tree } = await getInclusionProof(leafs[0], leafs, TREE_HIGHT);

    let data = {
        root: tree.root.toString(),
        path_elements: proof.pathElements,
        path_indices: proof.pathIndices,
        leaf: leafs[0],
    };
    const pathToWrite = resolve("./Prover_tree.toml");
    writeProverTOML(data, pathToWrite);
})();
