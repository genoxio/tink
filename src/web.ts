import { WebPlugin } from '@capacitor/core';

import type { TinkOpenResult, TinkOpenOptions, TinkPlugin } from './definitions';

export class TinkWeb extends WebPlugin implements TinkPlugin {

  async openTink(_options: TinkOpenOptions): Promise<TinkOpenResult> {
    throw new Error(
      'Tink openTink is only available on iOS. This plugin has no web implementation.',
    );
  }

  async handleOpenUrl(options: { url: string }): Promise<TinkOpenResult> {
    const { url } = options;
    const parsed = new URL(url);
    const code = parsed.searchParams.get('code');
    const error = parsed.searchParams.get('error');

    if (code) {
      return { success: true, code };
    }

    return {
      success: false,
      error: error ?? 'UNKNOWN_ERROR',
      userCancelled: error === 'USER_CANCELLED',
      url,
    };
  }

  async dismissTink(): Promise<{ success: boolean }> {
    return { success: true };
  }
}
