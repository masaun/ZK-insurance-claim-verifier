import { beforeAll, describe, expect, it } from 'vitest';

import { readFileSync } from 'node:fs';
import os from 'node:os';
import path from 'node:path';

import { createProver, generateCircuitInputs } from '../src';

import type { Prover } from '@zkpersona/noir-helpers';

import circuit from '../target/x_example.json' assert { type: 'json' };

import type { CompiledCircuit } from '@noir-lang/noir_js';
import { skipHonkProving, skipPlonkProving } from './constants';

describe('X (Twitter) Email Verification', () => {
  let prover: Prover;

  beforeAll(() => {
    const threads = os.cpus().length;
    prover = createProver(circuit as CompiledCircuit, {
      type: 'all',
    });
  });

  it.skipIf(skipHonkProving)(
    'should verify a valid x email using honk backend',
    async () => {
      const emailContent = readFileSync(
        path.join(__dirname, '../data/x-valid.eml')
      );
      const inputs = await generateCircuitInputs(emailContent, 'x');

      const proof = await prover.fullProve(inputs, { type: 'honk' });
      const isVerified = await prover.verify(proof, { type: 'honk' });

      expect(isVerified).toBe(true);
    }
  );

  it.skipIf(skipPlonkProving)(
    'should verify a valid x email using plonk backend',
    async () => {
      const emailContent = readFileSync(
        path.join(__dirname, '../data/x-valid.eml')
      );
      const inputs = await generateCircuitInputs(emailContent, 'x');

      const proof = await prover.fullProve(inputs, { type: 'plonk' });
      const isVerified = await prover.verify(proof, { type: 'plonk' });

      expect(isVerified).toBe(true);
    }
  );
});
