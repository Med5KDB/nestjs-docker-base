# NestJS Docker Base Image

This repository provides a reusable Docker image for NestJS projects. It includes:

- Node.js 18
- Global installation of the NestJS CLI

## Usage

To use this image in your project, reference it in your `Dockerfile`:

```dockerfile
FROM med5/nestjs-base:latest

# Add your project-specific configuration for example: 
WORKDIR /app
COPY . .
RUN npm install

CMD ["npm", "run", "start:dev"]
