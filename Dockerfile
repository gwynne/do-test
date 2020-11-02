FROM swift:5.3-focal as build
WORKDIR /build
COPY . .
RUN swift build --enable-test-discovery -c debug -j 1 -v -Xcc -v -Xcxx -v -Xlinker -v -Xswiftc -v | \
    egrep -v -- '-o /build/\.build/x86_64-unknown-linux-gnu/debug/CNIOBoring|clang version 10|Thread model|GCC installation|multilib'
WORKDIR /staging
RUN cp "$(swift build --package-path /build -c release --show-bin-path)/Run" ./

FROM swift:5.3-focal-slim
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor
WORKDIR /app
COPY --from=build --chown=vapor:vapor /staging /app
USER vapor:vapor
EXPOSE 8080
ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
