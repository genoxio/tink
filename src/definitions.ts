export interface TinkPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
