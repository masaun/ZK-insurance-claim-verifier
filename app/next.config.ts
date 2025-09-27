import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      // Proxy font requests to avoid CORS issues
      {
        source: '/fonts/:path*',
        destination: 'https://fonts.reown.com/:path*'
      },
      // Proxy Coinbase API requests to avoid COEP issues
      {
        source: '/api/coinbase/:path*',
        destination: 'https://cca-lite.coinbase.com/:path*'
      }
    ];
  },
  async headers() {
    return [
      // Allow font loading with proper CORS headers
      {
        source: "/fonts/:path*",
        headers: [
          { key: "Access-Control-Allow-Origin", value: "*" },
          { key: "Access-Control-Allow-Methods", value: "GET" },
          { key: "Access-Control-Allow-Headers", value: "Content-Type" },
          { key: "Cache-Control", value: "public, max-age=86400, immutable" },
        ],
      },
      // Generic patterns without capturing groups (one per extension)
      {
        source: "/:path*.png",
        headers: [
          { key: "Cache-Control", value: "public, max-age=86400, immutable" },
        ],
      },
      {
        source: "/:path*.jpg",
        headers: [
          { key: "Cache-Control", value: "public, max-age=86400, immutable" },
        ],
      },
      {
        source: "/:path*.jpeg",
        headers: [
          { key: "Cache-Control", value: "public, max-age=86400, immutable" },
        ],
      },
      {
        source: "/:path*.gif",
        headers: [
          { key: "Cache-Control", value: "public, max-age=86400, immutable" },
        ],
      },
      {
        source: "/:path*.webp",
        headers: [
          { key: "Cache-Control", value: "public, max-age=86400, immutable" },
        ],
      },
      // @dev - COEP headers commented out to allow Coinbase API calls
      // Uncomment only if you encounter bb.js WASM issues
      // {
      //   source: '/:path*',
      //   headers: [
      //     { key: 'Cross-Origin-Embedder-Policy', value: 'require-corp' },
      //     { key: 'Cross-Origin-Opener-Policy', value: 'same-origin' },
      //   ],
      // }
    ];
  },
  webpack: (config) => {
    config.externals.push('pino-pretty', 'lokijs', 'encoding'),
    config.resolve.fallback = {
      buffer: require.resolve("buffer/"), // @dev - This is for preventing from the "buf.writeBigUInt64BE is not function" error, which is caused by the bb.js v0.87.0
    };
    return config;
  }
};

export default nextConfig;