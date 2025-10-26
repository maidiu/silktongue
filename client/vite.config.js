
// client/vite.config.js
export default {
    // Use / for development, /silktongue/ for production
    base: process.env.NODE_ENV === 'production' ? '/silktongue/' : '/',
    server: {
      proxy: {
        '/api': 'http://localhost:3000',
        '/silktongue/api': 'http://localhost:3000',
      },
    },
  };
  