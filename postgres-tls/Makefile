# PostgreSQL TLS Docker Container Makefile
#
# Usage:
#   make ssl                  - Generate all certificates (CA, server, client)
#   make ca-ssl               - Generate CA certificate
#   make server-ssl           - Generate server certificate (requires CA)
#   make client-ssl           - Generate client certificate (requires CA)
#   make build                - Build Docker image
#   make run                  - Run PostgreSQL container in background
#   make test                 - Test connection to PostgreSQL server
#   make check                - Alias for test
#   make psql                 - Run psql in interactive mode
#   make logs                 - Show container logs
#   make stop                 - Stop the running container
#   make clean                - Remove certificates and stop container
#
# Variables (can be overridden):
#   CERT_DIR     - Certificate directory (default: ~/.postgres-tls)
#   IMAGE_TAG    - Docker image tag (default: miarec/postgres-tls)
#   PORT         - Host port to expose (default: 5433)
#   CLIENT_NAME  - Client certificate name (default: client)
#   SSL_MODE     - SSL mode: prefer, require, verify-ca, verify-full (default: prefer)

.PHONY: ssl ca-ssl server-ssl client-ssl build run test check psql logs stop clean help

# Configuration variables
CERT_DIR ?= $(HOME)/.postgres-tls
IMAGE_TAG ?= miarec/postgres-tls
PORT ?= 5433
CLIENT_NAME ?= client
CONTAINER_NAME := postgres-tls
SSL_MODE ?= verify-ca
POSTGRES_PASSWORD ?= postgres

# Certificate files
CA_KEY := $(CERT_DIR)/ca.key
CA_CERT := $(CERT_DIR)/ca.crt
CA_SERIAL := $(CERT_DIR)/ca.srl
SERVER_KEY := $(CERT_DIR)/server.key
SERVER_CERT := $(CERT_DIR)/server.crt
CLIENT_KEY := $(CERT_DIR)/$(CLIENT_NAME).key
CLIENT_CERT := $(CERT_DIR)/$(CLIENT_NAME).crt

# Default target
help:
	@echo "PostgreSQL TLS Docker Container"
	@echo ""
	@echo "Targets:"
	@echo "  make ssl          - Generate all certificates (CA, server, client)"
	@echo "  make ca-ssl       - Generate CA certificate"
	@echo "  make server-ssl   - Generate server certificate"
	@echo "  make client-ssl   - Generate client certificate"
	@echo "  make build        - Build Docker image"
	@echo "  make run          - Run PostgreSQL container (port $(PORT))"
	@echo "  make test/check   - Test connection to PostgreSQL"
	@echo "  make psql         - Interactive psql session"
	@echo "  make logs         - Show container logs"
	@echo "  make stop         - Stop the container"
	@echo "  make clean        - Remove certificates and stop container"
	@echo ""
	@echo "Configuration (override with make VAR=value):"
	@echo "  CERT_DIR=$(CERT_DIR)"
	@echo "  IMAGE_TAG=$(IMAGE_TAG)"
	@echo "  PORT=$(PORT)"
	@echo "  CLIENT_NAME=$(CLIENT_NAME)"
	@echo "  SSL_MODE=$(SSL_MODE)"
	@echo ""
	@echo "SSL Modes:"
	@echo "  prefer      - SSL optional, client certs optional (default)"
	@echo "  require     - SSL required, client certs optional"
	@echo "  verify-ca   - SSL required, client certs required"
	@echo "  verify-full - SSL required, client certs + CN match required"

# Generate all certificates
ssl: ca-ssl server-ssl client-ssl

# Generate CA certificate
ca-ssl: $(CA_CERT)

$(CERT_DIR):
	mkdir -p $(CERT_DIR)

$(CA_KEY): | $(CERT_DIR)
	@if [ -f $(CA_KEY) ]; then \
		echo "CA key already exists: $(CA_KEY)"; \
	else \
		openssl genrsa -out $(CA_KEY) 4096; \
		chmod 600 $(CA_KEY); \
	fi

$(CA_CERT): | $(CA_KEY)
	@if [ -f $(CA_CERT) ]; then \
		echo "CA certificate already exists: $(CA_CERT)"; \
	else \
		openssl req -x509 -new -nodes -key $(CA_KEY) -sha256 -days 3650 \
			-out $(CA_CERT) -subj "/CN=PostgreSQL Test CA"; \
		echo "Generated CA certificate: $(CA_CERT)"; \
	fi

# Generate server certificate
server-ssl: $(SERVER_CERT)

$(SERVER_KEY): | $(CERT_DIR)
	@if [ -f $(SERVER_KEY) ]; then \
		echo "Server key already exists: $(SERVER_KEY)"; \
	else \
		openssl genrsa -out $(SERVER_KEY) 2048; \
		chmod 600 $(SERVER_KEY); \
	fi

$(SERVER_CERT): | $(SERVER_KEY) $(CA_CERT) $(CA_KEY)
	@if [ -f $(SERVER_CERT) ]; then \
		echo "Server certificate already exists: $(SERVER_CERT)"; \
	else \
		openssl req -new -key $(SERVER_KEY) -out $(CERT_DIR)/server.csr -subj "/CN=postgres-server"; \
		echo "subjectAltName=DNS:localhost,DNS:postgres-tls,IP:127.0.0.1" > $(CERT_DIR)/server.ext; \
		echo "extendedKeyUsage=serverAuth" >> $(CERT_DIR)/server.ext; \
		openssl x509 -req -in $(CERT_DIR)/server.csr \
			-CA $(CA_CERT) -CAkey $(CA_KEY) \
			-CAcreateserial -CAserial $(CA_SERIAL) \
			-out $(SERVER_CERT) -days 3650 -sha256 \
			-extfile $(CERT_DIR)/server.ext; \
		rm -f $(CERT_DIR)/server.csr $(CERT_DIR)/server.ext; \
		echo "Generated server certificate: $(SERVER_CERT)"; \
	fi

# Generate client certificate
client-ssl: $(CLIENT_CERT)

$(CLIENT_KEY): | $(CERT_DIR)
	@if [ -f $(CLIENT_KEY) ]; then \
		echo "Client key already exists: $(CLIENT_KEY)"; \
	else \
		openssl genrsa -out $(CLIENT_KEY) 2048; \
		chmod 600 $(CLIENT_KEY); \
	fi

$(CLIENT_CERT): | $(CLIENT_KEY) $(CA_CERT) $(CA_KEY)
	@if [ -f $(CLIENT_CERT) ]; then \
		echo "Client certificate already exists: $(CLIENT_CERT)"; \
	else \
		openssl req -new -key $(CLIENT_KEY) -out $(CERT_DIR)/$(CLIENT_NAME).csr -subj "/CN=$(CLIENT_NAME)"; \
		echo "subjectAltName=DNS:$(CLIENT_NAME),DNS:localhost,IP:127.0.0.1" > $(CERT_DIR)/$(CLIENT_NAME).ext; \
		echo "extendedKeyUsage=clientAuth" >> $(CERT_DIR)/$(CLIENT_NAME).ext; \
		openssl x509 -req -in $(CERT_DIR)/$(CLIENT_NAME).csr \
			-CA $(CA_CERT) -CAkey $(CA_KEY) \
			-CAcreateserial -CAserial $(CA_SERIAL) \
			-out $(CLIENT_CERT) -days 3650 -sha256 \
			-extfile $(CERT_DIR)/$(CLIENT_NAME).ext; \
		rm -f $(CERT_DIR)/$(CLIENT_NAME).csr $(CERT_DIR)/$(CLIENT_NAME).ext; \
		echo "Generated client certificate: $(CLIENT_CERT)"; \
	fi

# Build Docker image
build:
	docker build -t $(IMAGE_TAG) .
	@echo "Built Docker image: $(IMAGE_TAG)"

# Run PostgreSQL container in background
run: build ca-ssl server-ssl
	@if docker ps -q -f name=^$(CONTAINER_NAME)$$ | grep -q .; then \
		echo "Container $(CONTAINER_NAME) is already running"; \
	else \
		if docker ps -aq -f name=^$(CONTAINER_NAME)$$ | grep -q .; then \
			docker rm $(CONTAINER_NAME) > /dev/null; \
		fi; \
		docker run -d --name $(CONTAINER_NAME) \
			-p $(PORT):5432 \
			-v $(CERT_DIR):/tls \
			-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
			-e SSL_MODE=$(SSL_MODE) \
			$(IMAGE_TAG); \
		echo "Started PostgreSQL TLS container on port $(PORT)"; \
		echo "Certificates mounted from $(CERT_DIR)"; \
		echo "SSL_MODE=$(SSL_MODE)"; \
	fi

# Test connection using psql from the container
# Retries up to 15 times waiting for PostgreSQL to be ready
test: run client-ssl
	@echo "Waiting for PostgreSQL to accept connections..."
	@ATTEMPTS=0; \
	MAX_ATTEMPTS=15; \
	while [ $$ATTEMPTS -lt $$MAX_ATTEMPTS ]; do \
		ATTEMPTS=$$((ATTEMPTS + 1)); \
		RESPONSE=$$(docker exec $(CONTAINER_NAME) psql -U postgres -h localhost \
			"sslmode=require sslcert=/tls/$(CLIENT_NAME).crt sslkey=/tls/$(CLIENT_NAME).key sslrootcert=/tls/ca.crt" \
			-c "SELECT 'CONNECTION_OK' as status;" -t 2>&1) && \
		if echo "$$RESPONSE" | grep -q "CONNECTION_OK"; then \
			echo "PostgreSQL connection test passed (attempt $$ATTEMPTS/$$MAX_ATTEMPTS)"; \
			echo "Verifying SSL is enabled..."; \
			docker exec $(CONTAINER_NAME) psql -U postgres -h localhost \
				"sslmode=require sslcert=/tls/$(CLIENT_NAME).crt sslkey=/tls/$(CLIENT_NAME).key sslrootcert=/tls/ca.crt" \
				-c "SELECT ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();" 2>&1; \
			exit 0; \
		fi; \
		echo "Attempt $$ATTEMPTS/$$MAX_ATTEMPTS: waiting for PostgreSQL..."; \
		sleep 2; \
	done; \
	echo "PostgreSQL connection test failed after $$MAX_ATTEMPTS attempts"; \
	docker logs $(CONTAINER_NAME); \
	exit 1

# Alias for test
check: test

# Run psql in interactive mode (SSL connection)
psql: run client-ssl
	@docker exec -it $(CONTAINER_NAME) psql -U postgres -h localhost \
		"sslmode=require sslcert=/tls/$(CLIENT_NAME).crt sslkey=/tls/$(CLIENT_NAME).key sslrootcert=/tls/ca.crt"

# Run psql without client certificate (SSL connection, server verification only)
psql-no-cert: run
	@docker exec -it $(CONTAINER_NAME) psql -U postgres -h localhost "sslmode=require"

# Run psql without SSL (only works if SSL_MODE=prefer)
psql-no-ssl: run
	@docker exec -it $(CONTAINER_NAME) psql -U postgres -h localhost "sslmode=disable"

# Show container logs
logs:
	@docker logs $(CONTAINER_NAME)

# Stop the container
stop:
	@if docker ps -q -f name=^$(CONTAINER_NAME)$$ | grep -q .; then \
		docker stop $(CONTAINER_NAME) > /dev/null; \
		echo "Stopped container $(CONTAINER_NAME)"; \
	else \
		echo "Container $(CONTAINER_NAME) is not running"; \
	fi
	@if docker ps -aq -f name=^$(CONTAINER_NAME)$$ | grep -q .; then \
		docker rm $(CONTAINER_NAME) > /dev/null; \
	fi

# Clean up certificates and stop container
clean: stop
	rm -rf $(CERT_DIR)
	@echo "Removed certificates from $(CERT_DIR)"
