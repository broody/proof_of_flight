import { extendTheme, ThemeConfig } from "@chakra-ui/react";

const config: ThemeConfig  = {
  initialColorMode: "dark",
  useSystemColorMode: false,
}

const theme = extendTheme({ 
  config,
  styles: {
    global: {
      body: {
        background: "black",
        color: "white"
      }
    }
  } 
});

export default theme;