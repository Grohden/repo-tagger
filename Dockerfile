FROM vergissberlin/debian-development as frontend-build

RUN mkdir -p /home/root/frontend
WORKDIR /home/root/frontend

# Based on cirrusci/flutter:beta but without android sdk.
ENV FLUTTER_ROOT="/opt/flutter"
ENV PATH ${PATH}:${FLUTTER_ROOT}/bin:${FLUTTER_ROOT}/bin/cache/dart-sdk/bin

RUN git clone --branch "beta" --depth 1 https://github.com/flutter/flutter.git ${FLUTTER_ROOT}

# Copy current frontend
COPY --chown=root:root ./frontend .

# Cached layer for flutter deps
RUN flutter config --enable-web && flutter packages get

# Generate and build the frontend app
RUN dart tools/env_generator.dart && \
    flutter packages pub run build_runner build --delete-conflicting-outputs && \
    flutter build web

# Backend build
FROM openjdk:8-jdk-alpine as backend-build

RUN mkdir -p /home/root/backend
WORKDIR /home/root/backend

COPY --chown=root:root ./backend .
COPY --from=frontend-build /home/root/frontend/build/web ./resources/web

# Actually build backend
RUN ./gradlew --no-daemon shadowJar

# Backend serve
FROM openjdk:8-jre-alpine

RUN adduser -D -g '' server && \
    mkdir /app && \
    chown -R server /app

USER server

COPY --from=backend-build /home/root/backend/build/libs/repotagger-all.jar /app/repotagger-all.jar
WORKDIR /app

CMD ["java",  "-server",  "-XX:+UnlockExperimentalVMOptions",  "-XX:+UseCGroupMemoryLimitForHeap",  "-XX:InitialRAMFraction=2",  "-XX:MinRAMFraction=2",  "-XX:MaxRAMFraction=2",  "-XX:+UseG1GC",  "-XX:MaxGCPauseMillis=100",  "-XX:+UseStringDeduplication",  "-jar", "repotagger-all.jar"]