import { generateToml } from '@zkpersona/noir-helpers';
import type { CircuitInputMap, CircuitType } from '../src/types';

export const exportCircuitInputs = <T extends CircuitType>(
  circuitType: T,
  inputs: CircuitInputMap[T]
) => {
  if (circuitType === 'google' || circuitType === 'x') {
    const json = {
      header: inputs.header,
      pubkey: inputs.pubkey,
      signature: inputs.signature,
      from_header_sequence: inputs.from_header_sequence,
      from_address_sequence: inputs.from_address_sequence,
      to_header_sequence: inputs.to_header_sequence,
      to_address_sequence: inputs.to_address_sequence,
    };

    generateToml(json, `../examples/${circuitType}_example/Prover.toml`, {
      indent: 0,
      newlineAfterSection: true,
    });
  }
};
