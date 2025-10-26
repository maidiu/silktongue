module.exports = {
  apps: [{
    name: 'maxvocab',
    script: './server/src/index.js',
    cwd: '/var/www/maxvocab',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'development',
      PORT: 3000
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: 3001,
      DATABASE_URL: process.env.DATABASE_URL,
      JWT_SECRET: process.env.JWT_SECRET
    },
    error_file: '/var/log/pm2/maxvocab-error.log',
    out_file: '/var/log/pm2/maxvocab-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
};

