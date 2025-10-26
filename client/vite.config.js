
// client/vite.config.js
export default {
    base: '/silktongue/',
    server: {
      proxy: {
        '/api': 'http://localhost:3000',
      },
    },
  };
  