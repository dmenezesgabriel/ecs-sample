from locust import HttpUser, LoadTestShape, between, task


class User(HttpUser):
    wait_time = between(1, 3)

    @task(2)
    def test_app1(self):
        self.client.get("/app1")

    @task(1)
    def test_app2(self):
        self.client.get("/app2")

    @task(1)
    def test_app1_call_app2(self):
        self.client.get("/app1/call-app2")

    @task(1)
    def test_app2_call_app1(self):
        self.client.get("/app2/call-app1")

    @task(2)
    def test_cpu_intensive_app1(self):
        self.client.get("/app1/cpu-intensive")

    @task(2)
    def test_cpu_intensive_app2(self):
        self.client.get("/app2/cpu-intensive")


class StagesShape(LoadTestShape):
    stages = [
        {"duration": 60, "users": 1000, "spawn_rate": 1},
        {"duration": 120, "users": 5000, "spawn_rate": 5},
        {"duration": 180, "users": 10000, "spawn_rate": 10},
        {"duration": 240, "users": 3000, "spawn_rate": 5},
        {"duration": 300, "users": 1000, "spawn_rate": 1},
    ]

    def tick(self):
        run_time = self.get_run_time()

        for stage in self.stages:
            if run_time < stage["duration"]:
                tick_data = (stage["users"], stage["spawn_rate"])
                return tick_data

        return None
