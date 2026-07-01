#!/usr/bin/sh

echo "Installing \`backend\`..."
helm upgrade --install backend ./backend
echo

echo "Installing \`frontend\`..."
helm upgrade --install frontend ./frontend
echo

echo "Installing \`db\`..."
helm upgrade --install db ./db
echo

