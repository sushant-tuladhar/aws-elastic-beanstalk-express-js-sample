# Use Node 16 Alpine as the lightweight base image
FROM node:16-alpine

# Set working directory inside the container
WORKDIR /app

# Copy dependency manifests
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy application source code
COPY . .

# Expose the application port
EXPOSE 3000

# Command to start the Express application
CMD ["npm", "start"]