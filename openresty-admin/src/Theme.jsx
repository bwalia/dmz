import React from "react";
import { defaultTheme } from "react-admin";
import { red, indigo } from '@mui/material/colors';

const secondaryColor = import.meta.env.VITE_THEME_SECONDARY_COLOR
const primaryColor = import.meta.env.VITE_THEME_PRIMARY_COLOR


const Theme = {
  ...defaultTheme,
  palette: {
    background: {
      main: indigo[500]
    },
    primary: {
      main: `#${primaryColor}`,
    },
    secondary: {
      main: `#${secondaryColor}`
    },
    error: red,
    contrastThreshold: 3,
    tonalOffset: 0.2,
  },
  typography: {
    fontFamily: ["Bitter", "Inter", "system-ui", "Avenir", "Helvetica", "Arial", "sans-serif"].join(",")
  },
  components: {
    ...defaultTheme.components,
    RaDatagrid: {
      styleOverrides: {
        root: {
          backgroundColor: "#f3f3f3",
          "& .RaDatagrid-headerCell": {
            backgroundColor: "#d7d6d6",
            fontWeight: "bold",
            lineHeight: '2.5em'
          },
        }
      }
    },
    RaSidebar: {
      styleOverrides: {
        root: {
          backgroundColor: "#f1eeee",
          marginTop: "16px"
        }
      }
    }
  }

};

export default Theme;
