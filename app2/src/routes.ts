import { FastifyInstance, FastifyReply, FastifyRequest } from "fastify";
import axios from "axios";
import { env } from "../src/env";

export async function helloRoutes(app: FastifyInstance) {
  app.get("/", async (request: FastifyRequest, reply: FastifyReply) => {
    reply.send({ message: "Hello from App2" });
  });
}

export async function cpuIntensiveRoutes(app: FastifyInstance) {
  app.get(
    "/cpu-intensive",
    async (request: FastifyRequest, reply: FastifyReply) => {
      const startTime = Date.now();

      while (Date.now() - startTime < 5000) {
        for (let i = 0; i < 10000; i++) {
          Math.pow(i, 2);
        }
      }

      reply.send({ message: "CPU intensive task completed" });
    },
  );
}

export async function healthRoutes(instance: FastifyInstance) {
  instance.get(
    "/health",
    async (request: FastifyRequest, reply: FastifyReply) => {
      reply.send({ status: "healthy" });
    },
  );
}

export async function communicationRoutes(instance: FastifyInstance) {
  instance.get(
    "/call-app1",
    async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const response = await axios.get(env.APP1_URL);
        reply.send({ message: `App2 received: ${response.data.message}` });
      } catch (error) {
        const errorMessage =
          error instanceof Error ? error.message : "An unknown error occurred";
        reply.send({ error: `Failed to call App1: ${errorMessage}` });
      }
    },
  );
}
