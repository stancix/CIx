# Bashx.CIx
A few continuous integration scripts.

---

## Release

`0.0.1`
| [GitHub](https://github.com/stanbashx/Bashx.CIx/releases/tag/0.0.1)
| [Key](https://stanbashx.github.io/release-public.pem)

### Build and Install

```
$ ./assemble.sh \
 && ./src/test/bash/unit_test.sh \
 && unzip -d /opt/Bashx.CIx-0.0.1 ./build/zip/Bashx.CIx-0.0.1.zip
```

### Download and Install

```
$ TMP_PATH="$(mktemp)"; \
 curl -L 'https://github.com/stanbashx/Bashx.CIx/releases/download/0.0.1/Bashx.CIx-0.0.1.zip' \
  -o "${TMP_PATH}" && unzip -d /opt/Bashx.CIx-0.0.1 "${TMP_PATH}" && rm "${TMP_PATH}"
```

---
