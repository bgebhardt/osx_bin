module.exports = {
  apps: [{
    name: 'note-companion',
    cwd: '/Users/bryan/code/personal/note-companion/packages/web',
    script: 'pnpm',
    args: 'start',
    env: {
      NODE_ENV: 'production'
    },
    watch: false,
    autorestart: true,
    max_restarts: 10,
    exec_mode: 'fork'
  }]
};