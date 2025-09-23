export type u8 = string;
export type u32 = string;
export type Field = string;

export type BoundedVec = {
  storage: u8[];
  len: u32;
};

export type RSAPubkey = {
  modulus: Field[];
  redc: Field[];
};

export type Sequence = {
  index: u32;
  length: u32;
};

export type VerifiedOutputs = {
  pub_key_hash: Field;
  email_nullifier: Field;
  to_address: BoundedVec;
};

export type VerifyGoogleEmailInputs = {
  header: BoundedVec;
  pubkey: RSAPubkey;
  signature: Field[];
  from_header_sequence: Sequence;
  from_address_sequence: Sequence;
  to_header_sequence: Sequence;
  to_address_sequence: Sequence;
};

export type VerifyGoogleEmailOutput = VerifiedOutputs;

export type VerifyXEmailInputs = {
  header: BoundedVec;
  pubkey: RSAPubkey;
  signature: Field[];
  from_header_sequence: Sequence;
  from_address_sequence: Sequence;
  to_header_sequence: Sequence;
  to_address_sequence: Sequence;
};

export type VerifyXEmailOutput = VerifiedOutputs;

export type CircuitInputMap = {
  google: VerifyGoogleEmailInputs;
  x: VerifyXEmailInputs;
};

export type CircuitOutputMap = {
  google: VerifyGoogleEmailOutput;
  x: VerifyXEmailOutput;
};

export type CircuitType = 'google' | 'x';
