# Offline Password Storage
## 🎯 Project Scope

This application is an offline-first password manager using End-to-End Encryption, with no cloud or remote backup involved.

All credentials are stored locally on the user’s mobile device.
If the device is lost, the data cannot be recovered.

The mobile device acts as the single source of truth.

## 🔑 Master Key

On first launch, the application generates a Master Key, stored securely on the device.

The Master Key is currently prepared for future extended encryption layers, but passwords are not yet re-encrypted using it.

## 🏠 Architecture

The mobile device acts as a local authority / server.

A browser extension communicates with the mobile device:

only over a local network

without involving any remote backend

ensuring full offline operation

Connection & Authentication

On first connection, the browser extension generates a cryptographic key pair.

Communication is allowed only if:

device UUID

public key

client metadata (user agent)

match the records stored on the mobile device.

If validation fails, the mobile device rejects the connection.

Active Session Behavior

The extension fetches metadata for stored websites

Data is kept in memory only (session-based)

__All data is cleared when the browser is closed__

## 🔁 Login Flow

The user navigates to a website with stored credentials

The extension detects username/email and password fields

On login attempt, a request is sent to the mobile device

The device responds with the encrypted password

Decryption is only possible using the established key pair

## 🔒 Stored Data (Mobile Side)
Connection Metadata

* uuid – device identifier

* publicKey – public key generated during pairing

* agent – browser metadata

## 📐 Credential Entry

* id – randomly generated UUID

* title – website name

* username – email or username

* password – encrypted password (secure storage)

* createdAt

* updatedAt