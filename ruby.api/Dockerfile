FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ruby.api/ruby.api.csproj ruby.api/
COPY ruby.application/ruby.application.csproj ruby.application/
COPY ruby.domain/ruby.domain.csproj ruby.domain/
COPY ruby.infrastructure/ruby.infrastructure.csproj ruby.infrastructure/
COPY ruby.tests/ruby.tests.csproj ruby.tests/

RUN dotnet restore ruby.api/ruby.api.csproj

COPY ruby.api/ ./ruby.api/
COPY ruby.application/ ./ruby.application/
COPY ruby.domain/ ./ruby.domain/
COPY ruby.infrastructure/ ./ruby.infrastructure/
COPY ruby.tests/ ./ruby.tests/

WORKDIR /src/ruby.api
RUN dotnet publish -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends libgssapi-krb5-2 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/publish .
EXPOSE 8000
ENV ASPNETCORE_URLS=http://+:8000
ENTRYPOINT ["dotnet", "ruby.api.dll"]
