import { registerPlugin } from '@capacitor/core';

import type { TinkPlugin } from './definitions';

const Tink = registerPlugin<TinkPlugin>('Tink', {
  web: () => import('./web').then((m) => new m.TinkWeb()),
});

export * from './definitions';
export { Tink };
