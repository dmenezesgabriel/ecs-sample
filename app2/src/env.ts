import { config } from "dotenv";
import { z } from "zod";

if (process.env.NODE_ENV === "test") {
  config({ path: ".env.test", override: true });
} else {
  config();
}

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("production"),
  APP1_URL: z.string().default(""),
  ADDRESS: z.string().default("localhost"),
  PORT: z.coerce.number().default(3000),
});

export const env = envSchema.parse(process.env);
