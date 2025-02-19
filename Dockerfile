// Use Node.js 14 as base image
FROM node:14

// Create app directory
WORKDIR /app

// Copy Packages and Install Dependencies
COPY package*.json ./
RUN npm install

// Copy app source code
COPY . .

// Expose port and start application
EXPOSE 3000

CMD ["npm", "start"]