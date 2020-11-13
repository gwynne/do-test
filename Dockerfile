FROM swift:5.3-focal as build
WORKDIR /build
COPY . .
RUN swift build --enable-test-discovery -c release -Xswiftc -use-ld=lld
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
