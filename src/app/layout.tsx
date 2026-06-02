import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "sembl",
  description: "Graph-driven semantic software engineering workspace"
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
