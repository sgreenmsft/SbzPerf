FROM microsoft/aspnetcore:2.0 as base
EXPOSE 80
WORKDIR /app

FROM microsoft/aspnetcore-build:2.0 as build
COPY . .
WORKDIR RunForever
RUN dotnet publish -o /app

FROM base as final
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "RunForever.dll"]