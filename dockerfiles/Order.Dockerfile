FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
USER app
WORKDIR /app
EXPOSE 8081
EXPOSE 443
ARG ALLOW_SWAGGER_UI=false
ARG ALLOW_ORIGINS=*

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Fiap.McTech.Orders/src/WebApi", "WebApi"]
COPY ["Fiap.McTech.Orders/src/Application", "Application"]
COPY ["Fiap.McTech.Orders/src/CrossCutting.Ioc", "CrossCutting.Ioc"]
COPY ["Fiap.McTech.Orders/src/ExternalServices", "ExternalServices"]
COPY ["Fiap.McTech.Orders/src/Infra", "Infra"]
COPY ["Fiap.McTech.Orders/src/Domain", "Domain"]
RUN dotnet restore "./WebApi/WebApi.csproj"
WORKDIR "/src/WebApi"
RUN dotnet build "./WebApi.csproj" \
	-c "$BUILD_CONFIGURATION" \
	-o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./WebApi.csproj" \
	-c "$BUILD_CONFIGURATION" \
	-o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebApi.dll"]