import Fastify, { FastifyInstance } from "fastify";
import {
  helloRoutes,
  healthRoutes,
  cpuIntensiveRoutes,
  communicationRoutes,
} from "../src/routes";

export const app: FastifyInstance = Fastify({ logger: true });

app.register(
  async (app) => {
    app.register(helloRoutes, { prefix: "hello" });
    app.register(healthRoutes);
    app.register(cpuIntensiveRoutes);
    app.register(communicationRoutes);
  },
  { prefix: "app2" },
);
