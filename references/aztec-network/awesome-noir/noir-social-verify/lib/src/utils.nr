pub struct VerifiedOutputs {
    pub_key_hash: Field,
    email_nullifier: Field,
    to_address: BoundedVec<u8, 320>,
}

impl VerifiedOutputs {
    pub fn new(
        pub_key_hash: Field,
        email_nullifier: Field,
        to_address: BoundedVec<u8, 320>,
    ) -> Self {
        Self { pub_key_hash, email_nullifier, to_address }
    }

    pub fn pub_key_hash(self) -> Field {
        self.pub_key_hash
    }

    pub fn email_nullifier(self) -> Field {
        self.email_nullifier
    }

    pub fn to_address(self) -> BoundedVec<u8, 320> {
        self.to_address
    }
}
