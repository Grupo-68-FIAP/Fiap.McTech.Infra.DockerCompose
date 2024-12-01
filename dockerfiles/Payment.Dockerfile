FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER app
WORKDIR /app
EXPOSE 8081
EXPOSE 443
ARG ALLOW_SWAGGER_UI=false
ARG ALLOW_ORIGINS=*

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Fiap.McTech.Payments/src/Fiap.McTech.Payments.Presentation.API", "Fiap.McTech.Payments.Presentation.API"]
COPY ["Fiap.McTech.Payments/src/Fiap.McTech.Payments.Application", "Fiap.McTech.Payments.Application"]
COPY ["Fiap.McTech.Payments/src/Fiap.McTech.Payments.Domain", "Fiap.McTech.Payments.Domain"]
COPY ["Fiap.McTech.Payments/src/Fiap.McTech.Payments.Infra", "Fiap.McTech.Payments.Infra"]
COPY ["Fiap.McTech.Payments/src/Fiap.McTech.Payments.CrossCutting", "Fiap.McTech.Payments.CrossCutting"]
COPY ["Fiap.McTech.Payments/src/Fiap.McTech.Payments.CrossCutting.IoC", "Fiap.McTech.Payments.CrossCutting.IoC"]
COPY ["Fiap.McTech.Payments/src/Fiap.McTech.Payments.ExternalService.WebAPI", "Fiap.McTech.Payments.ExternalService.WebAPI"]
RUN dotnet restore "./Fiap.McTech.Payments.Presentation.API/Fiap.McTech.Payments.Presentation.API.csproj"
WORKDIR "/src/Fiap.McTech.Payments.Presentation.API"
RUN dotnet build "./Fiap.McTech.Payments.Presentation.API.csproj" \
	-c "$BUILD_CONFIGURATION" \
	-o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Fiap.McTech.Payments.Presentation.API.csproj" \
	-c "$BUILD_CONFIGURATION" \
	-o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Fiap.McTech.Payments.Presentation.API.dll"]