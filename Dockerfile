FROM node:8.10

# Deps
RUN apt-get -qq update && apt-get -qq install -y ca-certificates git-core ssh python-pip python-dev build-essential default-jdk jq

# Install google chrome for tests
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -qq update
RUN apt-get -qq install -y google-chrome-stable
RUN export CHROME_BIN=/usr/bin/google-chrome

# Install aws-cli
RUN pip -q install awscli --upgrade

RUN npm i -g npm
RUN npm install -g serverless


# Create app directory for our source code
RUN mkdir /app
WORKDIR /app

# Copy over only files needed to install dependencies
# This will allow Docker to reuse a cached image if no dependencies have changed
# effectively speeding up image build times on local machines
ADD ./package.json /app
ADD ./package-lock.json /app

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

# Set values of environment variables to be the args from previous ARG steps
# Makes the args available to the Node app via process.env.*
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}}

RUN npm ci -q --no-progress

# Copy over all source
ADD . /app
