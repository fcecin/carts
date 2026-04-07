# Minimal keyfile excerpt for testing isNil normalization

import std/json

proc decodeCrypto(n: JsonNode): Result[Crypto, string] =
  var crypto = n.getOrDefault("crypto")
  if isNil(crypto):
    return err("malformed")

  var kdf = crypto.getOrDefault("kdf")
  if isNil(kdf):
    return err("malformed")

  var cipherparams = crypto.getOrDefault("cipherparams")
  if isNil(cipherparams):
    return err("malformed")

  if c.kdfParams.isNil:
    return err("malformed")

  return ok(c)
