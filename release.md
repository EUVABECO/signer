# Release Notes

## Version 0.0.2

### Added
- Added `exp` (expiration time) and `iat` (issued at) fields to claims.

### Fixed
- Updated to use a root key (`-260`) for the HCERT.
- Ensured `protected` and `claims` are encoded in CBOR within the CWT, as specified in the RFC (the signature is also created using these fields encoded in CBOR).
