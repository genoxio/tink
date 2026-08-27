import { WebPlugin } from '@capacitor/core';

import type { TinkPlugin } from './definitions';

export class TinkWeb extends WebPlugin implements TinkPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async openTink(): Promise<void> {
    // no web implementation
  }
}
