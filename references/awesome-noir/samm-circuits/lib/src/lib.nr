mod merkle_tree;
mod utils;

use merkle_tree::compute_merkle_root;
use dep::std::field::bytes32_to_field;
use dep::zkemail::Sequence;

global LEVELS: u32 = 8; // Depth of the tree
global MAX_EMAIL_HEADER_LENGTH: u32 = 1024;
global MAX_EMAIL_ADDRESS_LENGTH: u32 = 124; // the max length of email address (4 slots 31 bytes each)
global MAX_EMAIL_DOMAIN_LENGTH: u32 = 24;
global MAX_EMAIL_FIELD_LENGTH: u32 = 256;
global MSG_HASH_LENGTH: u32 = 44; // base64 hash
global MIN_SECRET: Field = 2.pow_32(100);

pub fn verify_samm_logic(
    header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH>,
    root: Field,
    path_indices: [Field; LEVELS],
    path_elements: [Field; LEVELS],
    secret: Field,
    padded_member: [u8; MAX_EMAIL_ADDRESS_LENGTH],
    domain: BoundedVec<u8, MAX_EMAIL_DOMAIN_LENGTH>,
    from_seq: Sequence,
    member_seq: Sequence,
    relayer: BoundedVec<u8, MAX_EMAIL_ADDRESS_LENGTH>,
    relayer_address: Field,
    to_seq: Sequence,
    relayer_seq: Sequence,
    msg_hash: [u8; MSG_HASH_LENGTH]
) -> Field {
    assert(from_seq.length <= MAX_EMAIL_FIELD_LENGTH);
    assert(member_seq.length <= MAX_EMAIL_ADDRESS_LENGTH);
    assert(to_seq.length <= MAX_EMAIL_FIELD_LENGTH);
    assert(relayer.len == relayer_seq.length);
    assert(MIN_SECRET.lt(secret));

    // check domain
    for i in 0..MAX_EMAIL_DOMAIN_LENGTH {
        assert(padded_member[member_seq.length - domain.len + i] == domain.storage[i]);
    }

    // check relayer address - some mock computation for constraint creation
    assert(relayer_address.pow_32(2) == relayer_address.pow_32(2));

    // sender must be member email address
    utils::check_from_field(header, padded_member, from_seq, member_seq);

    // convert padded_member to Field type
    let leaf = member_to_leaf(padded_member, secret);

    // check merkle inclusion proof of sender email
    let _root = compute_merkle_root(leaf, path_indices, path_elements);
    assert(_root == root);

    // recipient must be relayer email address
    utils::check_to_field(header, relayer.storage, to_seq, relayer_seq);

    // check that subject field of header is msgHash
    let (found, _) = utils::find_subject_in_header(header, msg_hash);
    assert(found);

    // Return commitment
    compute_commitment(leaf, msg_hash)
}

fn member_to_leaf(padded_member: [u8; MAX_EMAIL_ADDRESS_LENGTH], secret: Field) -> Field {
    let mut chunks = [0; 5];
    let mut chunk = [0; 32];
    for i in 0..4 {
        for j in 0..31 {
            chunk[j+1] = padded_member[31*i + j];
        }
        chunks[i] = bytes32_to_field(chunk);
    }
    chunks[4] = secret;

    std::hash::poseidon::bn254::hash_5(chunks)
}

fn compute_commitment(leaf: Field, msg_hash: [u8; MSG_HASH_LENGTH]) -> Field {
    // convert msg_hash to Field type
    let mut chunks = [0; 3];
    let mut chunk = [0; 32];
    for i in 0..2 {
        for j in 0..22 {
            chunk[j+10] = msg_hash[22*i + j];
        }
        chunks[i] = bytes32_to_field(chunk);
    }
    chunks[2] = leaf;

    std::hash::poseidon::bn254::hash_3(chunks)
}

#[test]
fn test_samm() {
    let header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH> = BoundedVec {
        storage: [116, 111, 58, 97, 100, 64, 111, 120, 111, 114, 46, 105, 111, 13, 10, 102, 114, 111, 109, 58, 115, 119, 111, 111, 110, 115, 46, 48, 48, 114, 117, 98, 98, 105, 110, 103, 64, 105, 99, 108, 111, 117, 100, 46, 99, 111, 109, 13, 10, 115, 117, 98, 106, 101, 99, 116, 58, 119, 70, 50, 115, 90, 68, 120, 52, 109, 99, 75, 54, 65, 115, 74, 88, 84, 74, 77, 82, 103, 83, 111, 99, 115, 67, 112, 50, 50, 87, 87, 102, 90, 119, 120, 120, 119, 82, 72, 106, 103, 112, 48, 61, 13, 10, 100, 97, 116, 101, 58, 87, 101, 100, 44, 32, 57, 32, 79, 99, 116, 32, 50, 48, 50, 52, 32, 49, 50, 58, 51, 51, 58, 51, 48, 32, 43, 48, 48, 48, 48, 32, 40, 85, 84, 67, 41, 13, 10, 109, 101, 115, 115, 97, 103, 101, 45, 105, 100, 58, 60, 70, 57, 53, 50, 67, 70, 49, 65, 45, 54, 48, 51, 51, 45, 52, 53, 53, 66, 45, 65, 50, 56, 67, 45, 69, 53, 51, 53, 65, 70, 70, 65, 68, 48, 48, 68, 64, 105, 99, 108, 111, 117, 100, 46, 99, 111, 109, 62, 13, 10, 99, 111, 110, 116, 101, 110, 116, 45, 116, 121, 112, 101, 58, 109, 117, 108, 116, 105, 112, 97, 114, 116, 47, 97, 108, 116, 101, 114, 110, 97, 116, 105, 118, 101, 59, 32, 98, 111, 117, 110, 100, 97, 114, 121, 61, 65, 112, 112, 108, 101, 45, 87, 101, 98, 109, 97, 105, 108, 45, 52, 50, 45, 45, 98, 97, 56, 56, 54, 100, 51, 51, 45, 50, 98, 99, 56, 45, 52, 97, 102, 52, 45, 57, 99, 51, 49, 45, 54, 99, 52, 56, 101, 49, 51, 54, 101, 99, 50, 102, 13, 10, 109, 105, 109, 101, 45, 118, 101, 114, 115, 105, 111, 110, 58, 49, 46, 48, 13, 10, 100, 107, 105, 109, 45, 115, 105, 103, 110, 97, 116, 117, 114, 101, 58, 118, 61, 49, 59, 32, 97, 61, 114, 115, 97, 45, 115, 104, 97, 50, 53, 54, 59, 32, 99, 61, 114, 101, 108, 97, 120, 101, 100, 47, 114, 101, 108, 97, 120, 101, 100, 59, 32, 100, 61, 105, 99, 108, 111, 117, 100, 46, 99, 111, 109, 59, 32, 115, 61, 49, 97, 49, 104, 97, 105, 59, 32, 116, 61, 49, 55, 50, 56, 52, 55, 55, 50, 49, 51, 59, 32, 98, 104, 61, 105, 116, 84, 86, 66, 71, 57, 67, 49, 52, 90, 85, 47, 43, 97, 51, 72, 68, 69, 77, 90, 114, 71, 79, 52, 118, 73, 79, 48, 80, 99, 87, 110, 81, 72, 106, 77, 101, 100, 107, 108, 67, 69, 61, 59, 32, 104, 61, 84, 111, 58, 70, 114, 111, 109, 58, 83, 117, 98, 106, 101, 99, 116, 58, 68, 97, 116, 101, 58, 77, 101, 115, 115, 97, 103, 101, 45, 73, 100, 58, 67, 111, 110, 116, 101, 110, 116, 45, 84, 121, 112, 101, 58, 77, 73, 77, 69, 45, 86, 101, 114, 115, 105, 111, 110, 59, 32, 98, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        len: 530
    };
    let from_seq = Sequence {
        index: 15,
        length: 32
    };
    let member_seq = Sequence {
        index: 20,
        length: 27
    };
    let to_seq = Sequence {
        index: 0,
        length: 13
    };
    let relayer_seq = Sequence {
        index: 3,
        length: 10
    };

    // tree part 
    let path_indices = [0,0,0,0,0,0,0,0];
    let path_elements = [12181380747766530663019567607642183183842923227107503250029079799455572184768,14752333704901535729870671529802743390978931851983497868673528090961169705309,16538135409515176547194568220928820916682786764828918280336228751737583509415,11286972368698509976183087595462810875513684078608517520839298933882497716792,3607627140608796879659380071776844901612302623152076817094415224584923813162,19712377064642672829441595136074946683621277828620209496774504837737984048981,20775607673010627194014556968476266066927294572720319469184847051418138353016,3396914609616007258851405644437304192397291162432396347162513310381425243293];
    let root = 20511819156590425064232637729680364151906840836244771318276577108131705348606;
    let secret = 2000000000000000000000000000000;

    // member
    let member = "swoons.00rubbing@icloud.com".as_bytes();
    let mut padded_member: [u8; MAX_EMAIL_ADDRESS_LENGTH] = [0; MAX_EMAIL_ADDRESS_LENGTH];
    for i in 0..member.len() {
        padded_member[i] = member[i];
    }
    for i in member.len()..MAX_EMAIL_ADDRESS_LENGTH {
        padded_member[i] = 0;
    }

    // domain
    let domain_bytes = "icloud.com".as_bytes();
    let mut padded_domain: [u8; MAX_EMAIL_DOMAIN_LENGTH] = [0; MAX_EMAIL_DOMAIN_LENGTH];
    for i in 0..domain_bytes.len() {
        padded_domain[i] = domain_bytes[i];
    }
    for i in domain_bytes.len()..MAX_EMAIL_DOMAIN_LENGTH {
        padded_domain[i] = 0;
    }
    let domain: BoundedVec<u8, MAX_EMAIL_DOMAIN_LENGTH> = BoundedVec {
        storage: padded_domain,
        len: domain_bytes.len()
    };

    println("MEMBER ---");
    println(padded_member);
    println(member.len());

    // relayer
    let relayer_bytes = "ad@oxor.io".as_bytes();
    let mut padded_relayer: [u8; MAX_EMAIL_ADDRESS_LENGTH] = [0; MAX_EMAIL_ADDRESS_LENGTH];
    for i in 0..relayer_bytes.len() {
        padded_relayer[i] = relayer_bytes[i];
    }
    for i in relayer_bytes.len()..MAX_EMAIL_ADDRESS_LENGTH {
        padded_relayer[i] = 0;
    }
    let relayer: BoundedVec<u8, MAX_EMAIL_ADDRESS_LENGTH> = BoundedVec {
        storage: padded_relayer,
        len: relayer_bytes.len()
    };

    println("RELAYER ---");
    println(relayer.storage);
    println(relayer.len);

    let relayer_address = 728815563385977040452943777879061427756277306518; // 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496

    // msg_hash
    let subject = "wF2sZDx4mcK6AsJXTJMRgSocsCp22WWfZwxxwRHjgp0=".as_bytes();
    let mut msg_hash: [u8; MSG_HASH_LENGTH] = [0; MSG_HASH_LENGTH];
    for i in 0..subject.len() {
        msg_hash[i] = subject[i];
    }

    println("MSG_HASH ---");
    println(msg_hash);

    let _ = verify_samm_logic(
        header,
        root,
        path_indices,
        path_elements,
        secret,
        padded_member,
        domain,
        from_seq,
        member_seq,
        relayer,
        relayer_address,
        to_seq,
        relayer_seq,
        msg_hash
    );
}
