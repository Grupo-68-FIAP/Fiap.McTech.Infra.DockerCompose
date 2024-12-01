FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
RUN groupadd -r mctech && useradd -r -g mctech mctech
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Fiap.McTech.Cart/src/Fiap.McTech.Cart.Api", "Fiap.McTech.Cart.Api"]
RUN dotnet restore "./Fiap.McTech.Cart.Api/Fiap.McTech.Cart.Api.csproj"
WORKDIR "/src/Fiap.McTech.Cart.Api"
RUN dotnet build "./Fiap.McTech.Cart.Api.csproj" -c "$BUILD_CONFIGURATION" -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./Fiap.McTech.Cart.Api.csproj" -c "$BUILD_CONFIGURATION" -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
USER mctech
ENTRYPOINT ["dotnet", "Fiap.McTech.Cart.Api.dll"]
