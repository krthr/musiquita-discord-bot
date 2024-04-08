FROM ghcr.io/crystal-ameba/ameba as ameba
WORKDIR /tmp
COPY . .
# RUN ameba

FROM crystallang/crystal:latest-alpine as build
WORKDIR /tmp
COPY --from=ameba /tmp /tmp
RUN shards install
RUN crystal tool format --check
RUN crystal build --progress --time --stats src/discord-music.cr

FROM crystallang/crystal:latest-alpine
WORKDIR /app
RUN apk update && apk add --no-cache ffmpeg yt-dlp
COPY --from=build /tmp/discord-music /app/discord-music
RUN chmod +x /app/discord-music
CMD [ "/app/discord-music" ]
