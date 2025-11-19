# Stage 1: Build
FROM node:20-alpine AS build

# Install pnpm globally
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy package.json and pnpm-lock.yaml
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy the rest of the project
COPY . .

# Build the project
RUN pnpm run build

# Stage 2: Production
FROM node:20-alpine

# Install pnpm in production stage
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy built files and package files
COPY --from=build /app/dist ./dist
COPY --from=build /app/package.json ./
COPY --from=build /app/pnpm-lock.yaml ./

# Install production dependencies only
RUN pnpm install --prod --frozen-lockfile

# Expose the default NestJS port
EXPOSE 3000

# Start the app
CMD ["node", "dist/main.js"]
