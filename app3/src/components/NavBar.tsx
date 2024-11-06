import { AppBar, Toolbar, Avatar, Typography, Box } from "@mui/material";

interface Props {
  title: string;
}

function NavBar({ title }: Props) {
  return (
    <AppBar position="static">
      <Toolbar>
        <Box sx={{ flexGrow: 1 }}>
          <Typography variant="h6">{title}</Typography>
        </Box>
        <Box sx={{ flexGrow: 0 }}>
          <Avatar>U</Avatar>
        </Box>
      </Toolbar>
    </AppBar>
  );
}

export default NavBar;
