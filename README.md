# CIx
A few continuous integration scripts.

---

## Release

`0.0.1`
| [GitHub](https://github.com/stancix/CIx/releases/tag/0.0.1)
| [Key](https://stancix.github.io/release-public.pem)

### Build and Install

```
$ ./assemble.sh \
 && ./src/test/bash/unit_test.sh \
 && unzip -d /opt/CIx-0.0.1 ./build/zip/CIx-0.0.1.zip
```

### Download and Install

```
$ TMP_PATH="$(mktemp)"; \
 curl -L 'https://github.com/stancix/CIx/releases/download/0.0.1/CIx-0.0.1.zip' \
  -o "${TMP_PATH}" && unzip -d /opt/CIx-0.0.1 "${TMP_PATH}" && rm "${TMP_PATH}"
```

---

## Unstable

`0.1.2-UNSTABLE`
| [GitHub](https://github.com/stancix/CIx/releases/tag/0.1.2-UNSTABLE)
| [Key](https://stancix.github.io/debug-public.pem)

### Build and Install

```
$ ./assemble.sh 'unstable' \
 && ./src/test/bash/checks.sh 'unstable' \
 && unzip -d /opt/CIx-0.1.2-UNSTABLE ./build/zip/CIx-0.1.2-UNSTABLE.zip
```

### Download and Install

```
$ TMP_PATH="$(mktemp)"; \
 curl -L 'https://github.com/stancix/CIx/releases/download/0.1.2-UNSTABLE/CIx-0.1.2-UNSTABLE.zip' \
  -o "${TMP_PATH}" && unzip -d /opt/CIx-0.1.2-UNSTABLE "${TMP_PATH}" && rm "${TMP_PATH}"
```

---
