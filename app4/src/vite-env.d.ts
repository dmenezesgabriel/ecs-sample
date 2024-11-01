/// <reference types="vite/client" />
/// <reference types="vite/types/importMeta.d.ts" />
interface ImportMetaEnv {
  readonly VITE_ENVIRONMENT: string;
  readonly VITE_ALB_DNS_NAME: string;
}
