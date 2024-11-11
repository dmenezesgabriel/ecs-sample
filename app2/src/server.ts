import { app } from "../src/app";
import { env } from "../src/env";

app.listen({ host: env.ADDRESS, port: env.PORT }).catch((err) => {
  app.log.error(err);
  process.exit(1);
});

process.on("SIGINT", () => {
  console.log("SIGINT received: closing server");
  app.close().then(() => {
    console.log("Server closed gracefully");
    process.exit(0);
  });
});
