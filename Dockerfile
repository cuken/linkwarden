FROM node:20-alpine AS dependencies

WORKDIR /opt/linkwarden
COPY package.json yarn.lock ./
RUN yarn

FROM node:20-alpine AS build

WORKDIR /opt/linkwarden
COPY --from=dependencies /opt/linkwarden/node_modules ./node_modules
COPY . .

RUN yarn
RUN npx playwright@1.36.2 install-deps
RUN yarn build

ENV DATABASE_URL=postgres://linkwarden:Linkwarden123!@linkwarden-db:5432/linkwarden?sslmode=disable&max_conns=20&max_idle_conns=4
ENV NEXTAUTH_SECRET=${NEXTAUTH_SECRET:-DR5o8dX6SR5#g*@7z!k2%8#sf5S@RR6F}
ENV NEXTAUTH_URL=${NEXTAUTH_URL:-http://localhost:3000}
ENV PAGINATION_TAKE_COUNT=
ENV STORAGE_FOLDE=
ENV SPACES_KEY =
ENV SPACES_SECRET =
ENV SPACES_ENDPOINT =
ENV SPACES_REGION =
ENV NEXT_PUBLIC_EMAIL_PROVIDER =
ENV EMAIL_FROM =
ENV EMAIL_SERVER =

RUN prisma migrate deploy

FROM node:20-alpine AS deploy

WORKDIR /opt/linkwarden

COPY --from=build /opt/linkwarden /opt/linkwarden

EXPOSE 3000

ENV PORT 3000