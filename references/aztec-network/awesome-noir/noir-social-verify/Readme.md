# Noir Social Verify

Noir Social Verify is a library that provides a simple way to verify ownership of social accounts by proving Emails from `no-reply@<company>.<tld>`.  This library is built using the [zkemail.nr](https://github.com/zkemail/zkemail.nr). Currently the library provides verification for the following social accounts:

- [x] Google: Any Email from `no-reply@accounts.google.com`
- [x] X (Twitter): Any Email from `info@x.com`

## Installation

In your `Nargo.toml` file, add the version of this library you would like to install under dependency:

```toml
[dependencies]
noir_social_verify = { tag = "v0.0.4", git = "https://github.com/zkpersona/noir-social-verify", directory = "lib" }
```

## Usage

To generate inputs for the verification functions, `@zkpersona/noir-social-verify` npm package. Install it by using the following command:

```bash
npm install @zkpersona/noir-social-verify
# or
yarn add @zkpersona/noir-social-verify
# or
pnpm add @zkpersona/noir-social-verify
# or
bun add @zkpersona/noir-social-verify
```

Generating Inputs:

```ts
import { generateCircuitInputs } from '@zkpersona/noir-social-verify';

const inputs = await generateCircuitInputs(emailContent, 'google');
```

Testing emails can be found in [data/](./data/) directory, along with unit tests in [tests/](./tests/) directory.

---

## Google Verification

```noir
use noir_social_verify::{
    constants::MAX_EMAIL_HEADER_LENGTH, google::verify_google_email, utils::VerifiedOutputs,
};
use zkemail::{dkim::RSAPubkey, KEY_LIMBS_2048, Sequence};

fn main(
    header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH>,
    pubkey: RSAPubkey<KEY_LIMBS_2048>,
    signature: [Field; KEY_LIMBS_2048],
    from_header_sequence: Sequence,
    from_address_sequence: Sequence,
    to_header_sequence: Sequence,
    to_address_sequence: Sequence,
) -> pub VerifiedOutputs {
    let verified_outputs: VerifiedOutputs = verify_google_email(
        header,
        pubkey,
        signature,
        from_header_sequence,
        from_address_sequence,
        to_header_sequence,
        to_address_sequence,
    );

    verified_outputs
}
```

---

## X Verification

```noir
use noir_social_verify::{
    constants::MAX_EMAIL_HEADER_LENGTH, utils::VerifiedOutputs, x::verify_x_email,
};
use zkemail::{dkim::RSAPubkey, KEY_LIMBS_2048, Sequence};

fn main(
    header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH>,
    pubkey: RSAPubkey<KEY_LIMBS_2048>,
    signature: [Field; KEY_LIMBS_2048],
    from_header_sequence: Sequence,
    from_address_sequence: Sequence,
    to_header_sequence: Sequence,
    to_address_sequence: Sequence,
) -> pub VerifiedOutputs {
    let verified_outputs: VerifiedOutputs = verify_x_email(
        header,
        pubkey,
        signature,
        from_header_sequence,
        from_address_sequence,
        to_header_sequence,
        to_address_sequence,
    );

    verified_outputs
}
```

---

## Getting Started

To get started with the project, clone the repository and install the dependencies:

```bash
git clone https://github.com/zkpersona/noir_social_verify.git
```

Install the dependencies by running the following command:

```bash
pnpm install
```

Compile all the circuits by running the following command:

```bash
pnpm compile
```

To run the tests, use the following command:

```bash
pnpm test
```

---
