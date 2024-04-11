FROM crystallang/crystal:latest-alpine as build
WORKDIR /tmp
COPY . .
RUN apk update && apk add --no-cache opus opus-dev libsodium libsodium-dev
RUN shards install
RUN bin/ameba
RUN crystal tool format --check
RUN crystal build --progress --time --stats src/discord-music.cr

FROM crystallang/crystal:latest-alpine
WORKDIR /app
RUN apk update && apk add --no-cache ffmpeg yt-dlp
COPY --from=build /tmp/discord-music /app/discord-music
RUN chmod +x /app/discord-music
CMD [ "/app/discord-music" ]
