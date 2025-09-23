import { config } from 'dotenv';

config({ path: '.env.example' });

export const skipPlonkProving = process.env.PROVE_PLONK
  ? process.env.PROVE_PLONK === 'false'
  : true;

export const skipHonkProving = process.env.PROVE_HONK
  ? process.env.PROVE_HONK === 'false'
  : true;
