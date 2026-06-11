httpie is completely broken for https since requests 2.32.3 — in a fresh venv every
https request fails with:

```
https: error: SSLError: HTTPSConnectionPool(host='raw.githubusercontent.com', port=443):
Max retries exceeded ... (Caused by SSLError(SSLCertVerificationError(1, '[SSL:
CERTIFICATE_VERIFY_FAILED] certificate verify failed: unable to get local issuer
certificate (_ssl.c:1000)')))
```

repro: `pip install httpie` then `https https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/h/httpie.rb`

worked fine on older requests. apparently requests changed something about ssl contexts
in 2.32.3. please fix this so plain https requests verify against the system certs again.
