import { it, describe, expect, beforeAll, afterAll } from "vitest";
import request from "supertest";
import { app } from "../src/app";

describe("Test server routes", () => {
  beforeAll(async () => {
    await app.ready();
  });

  afterAll(async () => {
    await app.close();
  });

  it("should respond ok on health route", async () => {
    await request(app.server).get("/app2/health").expect(200);
  });
});
