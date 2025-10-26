
// client/vite.config.js
export default {
    base: '/',
    server: {
      proxy: {
        '/api': 'http://localhost:3000',
      },
    },
  };
  