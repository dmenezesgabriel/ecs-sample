import express, { Request, Response, Router } from "express";
import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const APP1_URL = process.env.APP1_URL || "";
const PORT = process.env.PORT || 3000;

class RootExpressAdapter {
  public router: Router;

  constructor() {
    this.router = Router();
    this.registerRoutes();
  }

  private registerRoutes() {
    this.router.get("/", this.readRoot);
  }

  private readRoot(req: Request, res: Response) {
    res.json({ message: "Hello from App2" });
  }
}

class PerformanceExpressAdapter {
  public router: Router;

  constructor() {
    this.router = Router();
    this.registerRoutes();
  }

  private registerRoutes() {
    this.router.get("/cpu-intensive", this.cpuIntensiveTask);
  }

  private cpuIntensiveTask(req: Request, res: Response) {
    const startTime = Date.now();

    while (Date.now() - startTime < 5000) {
      for (let i = 0; i < 10000; i++) {
        Math.pow(i, 2);
      }
    }

    res.json({ message: "CPU intensive task completed" });
  }
}

class HealthExpressAdapter {
  public router: Router;

  constructor() {
    this.router = Router();
    this.registerRoutes();
  }

  private registerRoutes() {
    this.router.get("/health", this.healthCheck);
  }

  private healthCheck(req: Request, res: Response) {
    res.json({ status: "healthy" });
  }
}

class CommunicationExpressAdapter {
  public router: Router;

  constructor() {
    this.router = Router();
    this.registerRoutes();
  }

  private registerRoutes() {
    this.router.get("/call-app1", this.callApp1);
  }

  private async callApp1(req: Request, res: Response) {
    try {
      const response = await axios.get(`${APP1_URL}/`);
      res.json({ message: `App2 received: ${response.data.message}` });
    } catch (error) {
      const errorMessage =
        error instanceof Error ? error.message : "An unknown error occurred";
      res.json({ error: `Failed to call App1: ${errorMessage}` });
    }
  }
}

const app = express();

app.use("/app2", new RootExpressAdapter().router);
app.use("/app2", new PerformanceExpressAdapter().router);
app.use("/app2", new HealthExpressAdapter().router);
app.use("/app2", new CommunicationExpressAdapter().router);

const server = app.listen(PORT, () => {
  console.log(`App2 is running on http://localhost:${PORT}/app2`);
});

process.on("SIGINT", () => {
  console.log("SIGINT signal received: closing HTTP server");
  server.close(() => {
    console.log("HTTP server closed");
  });
});
