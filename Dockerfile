#################################
# BUILD FOR LOCAL DEVELOPMENT
#################################

FROM node:18-alpine As development

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./


RUN npm ci

# Bundle app source
COPY --chown=node:node . .

# Use the node user from the image (instead of the root user)
USER node

##################################
# BUILD FOR PRODUCTION
##################################

FROM node:18-alpine As build

WORKDIR /usr/src/app

COPY --chown=node:node --from=development /usr/src/app/package*.json ./

# In order to run `npm run build` we need access to the Nest CLI which is a dev dependency. In the previous development stage we ran `npm ci` which installed all dependencies, so we can copy over the node_modules directory from the development image.
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

RUN npm install -g @nestjs/cli

RUN npm install --only=production

COPY --chown=node:node . .

RUN npm run build

# Running `npm ci` removes the existing node_modules directory and passing in --only=production ensures that only the production dependencies are installed. This ensures that the node_modules directory is as optimized as possible
RUN npm ci --only=production && npm cache clean --force

USER node

##############################
# PRODUCTION
##############################

FROM node:18-alpine As production

# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules

# Start the server using the production build
CMD ["node", "dist/main.js" ]
