# Springboot BankApp

A multi-tier banking web application built with Spring Boot, Spring Security, and MySQL. Users can register an account, log in, and manage their balance through deposits, withdrawals, and transfers to other accounts, with a full transaction history.

> **Status:** Work in progress. Core banking features and Docker setup are in place; still testing and refining end-to-end.

## Features

- **User registration & login** — Spring Security-backed authentication, with each bank account doubling as the login identity (`Account` implements `UserDetails`)
- **Dashboard** — view current balance after logging in
- **Deposit & withdraw** — update balance with validation (e.g. rejecting overdraws)
- **Transfer funds** — move money from one account to another by username
- **Transaction history** — every deposit, withdrawal, and transfer is logged with amount, type, and timestamp
- **Server-rendered UI** — Thymeleaf templates for login, registration, dashboard, and transaction history

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Java 17 |
| Framework | Spring Boot 3.3.3 |
| Security | Spring Security |
| Persistence | Spring Data JPA + MySQL |
| Templating | Thymeleaf |
| Build | Maven |
| Containerization | Docker (multi-stage build), Docker Compose |

## Architecture

The app is a two-tier system:

- **`mainapp`** — the Spring Boot application (port `8080`), built via a multi-stage Docker image (Maven build stage → lightweight `eclipse-temurin` JRE runtime stage)
- **`mysql`** — MySQL 8.4 database (port `3306`) with a persistent Docker volume

Both services run on a shared Docker bridge network defined in `docker-compose.yml`, with the app container waiting on a MySQL healthcheck before starting.

## Project Structure

```
src/main/java/com/example/bankapp/
├── controller/       # BankController — handles login, register, dashboard, deposit, withdraw, transfer
├── service/          # AccountService — business logic for balances & transactions
├── repository/       # AccountRepository, TransactionRepository (Spring Data JPA)
├── model/            # Account, Transaction entities
└── config/           # SecurityConfig — Spring Security setup

src/main/resources/
├── templates/        # login.html, register.html, dashboard.html, transactions.html
└── application.properties
```

## Running Locally

### Prerequisites
- Java 17
- Maven (or use the included `mvnw` wrapper)
- Docker & Docker Compose

### Option 1: Docker Compose (recommended)

```bash
docker compose up --build
```

This spins up MySQL and the Spring Boot app together, with the app available at `http://localhost:8080`.

You'll need a `.env` file (or exported environment variables) with:
```
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=bankdb
MYSQL_USER=bankuser
MYSQL_PASSWORD=bankpass
SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/bankdb?useSSL=false&serverTimezone=UTC
SPRING_DATASOURCE_USERNAME=bankuser
SPRING_DATASOURCE_PASSWORD=bankpass
```

### Option 2: Run the app directly

```bash
./mvnw clean package -DskipTests
java -jar target/bankapp-0.0.1-SNAPSHOT.jar
```

(Requires a MySQL instance reachable per the settings in `src/main/resources/application.properties`.)

## Roadmap

- [ ] Finish end-to-end testing of deposit/withdraw/transfer flows
- [ ] Add input validation & error handling improvements
- [ ] Set up a CI/CD pipeline for automated build and deployment


