export interface TinkOpenOptions {
  clientId: string;
  market: string;
  locale?: string;
  redirectUri: string;
  appUri: string;
  autoRedirectMobile?: boolean;
  state?: string;
  scope?: string;
  additionalParameters?: Record<string, string>;
}

export interface TinkOpenResult {
  success: boolean;
  code?: string;
  error?: string;
  userCancelled?: boolean;
  url?: string;
}

export interface TinkPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  openTink(options: TinkOpenOptions): Promise<TinkOpenResult>;
  handleOpenUrl(options: { url: string }): Promise<TinkOpenResult>;
  dismissTink(): Promise<{ success: boolean }>;
}
