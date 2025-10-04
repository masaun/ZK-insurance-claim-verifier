import { useAppKitTheme } from "@reown/appkit/react";

const { themeMode, themeVariables, setThemeMode, setThemeVariables } =
  useAppKitTheme();

setThemeMode("dark");

setThemeVariables({
  "--apkt-color-mix": "#00BB7F",
  "--apkt-color-mix-strength": 40,
});