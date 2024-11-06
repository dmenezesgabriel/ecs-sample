import {
  Container,
  Typography,
  Button,
  Card,
  CardActions,
  CardContent,
  CssBaseline,
  Grid2,
} from "@mui/material";
import NavBar from "../components/NavBar";

const servicesList = [
  { name: "Planning", description: "", icon: "" },
  { name: "Indicators", description: "", icon: "" },
  { name: "Forecast", description: "", icon: "" },
  { name: "Management", description: "", icon: "" },
  { name: "Reports", description: "", icon: "" },
  { name: "Resources", description: "", icon: "" },
];

export default function Home() {
  return (
    <>
      <CssBaseline />
      <NavBar title="Application Name" />
      <Container>
        <Typography
          variant="h2"
          sx={{ textAlign: "center", color: "primary.main" }}
        >
          Services
        </Typography>

        <Grid2 container spacing={4}>
          {servicesList.map((service) => (
            <Grid2 key={service.name}>
              <Card sx={{ width: { xs: 1, md: 320 } }}>
                <CardContent sx={{ m: 3 }}>
                  <Typography variant="h5">{service.name}</Typography>
                  <Typography sx={{ mt: 2 }}>
                    Lorem ipsum dolor sit amet, consectetur adipisicing elit.
                    Esse, enim? Aperiam, iusto! Modi nihil voluptates eos ab
                    incidunt iusto voluptatum sapiente expedita at, impedit
                    nesciunt libero corporis aspernatur laboriosam ea suscipit
                    quo unde qui soluta nemo sunt! Harum at, dolor voluptatem
                    maxime eaque alias debitis voluptatibus voluptates. Ea,
                    mollitia non!
                  </Typography>
                </CardContent>
                <CardActions>
                  <Button variant="contained" sx={{ mt: 2 }}>
                    Learn More
                  </Button>
                </CardActions>
              </Card>
            </Grid2>
          ))}
        </Grid2>
      </Container>
    </>
  );
}
