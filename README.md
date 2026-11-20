# CIx
A few continuous integration scripts.

---

## Release

`0.2.2`
| [GitHub](https://github.com/stancix/CIx/releases/tag/0.2.2)
| [Key](https://stanprojects.github.io/stanprojects_release.pub)

### Build and Install

```
./assemble.sh --build_variant 'release' \
 && ./src/test/bash/checks.sh --build_variant 'release' \
 && mkdir '/opt/CIx-0.2.2/' \
 && tar -xf './build/tar/CIx-0.2.2.tar.gz' -C '/opt/CIx-0.2.2/'
```

### Download and Install

```
TMP_PATH="$(mktemp)" \
 && curl -m 32 -f -L 'https://github.com/stancix/CIx/releases/download/0.2.2/CIx-0.2.2.tar.gz' -o "${TMP_PATH}" \
 && mkdir '/opt/CIx-0.2.2/' \
 && tar -xf "${TMP_PATH}" -C '/opt/CIx-0.2.2/' && rm "${TMP_PATH}"
```

---

## Unstable

`0.2.2-UNSTABLE`
| [GitHub](https://github.com/stancix/CIx/releases/tag/0.2.2-UNSTABLE)
| [Key](https://stanprojects.github.io/stanprojects_debug.pub)

### Build and Install

```
./assemble.sh --build_variant 'unstable' \
 && ./src/test/bash/checks.sh --build_variant 'unstable' \
 && mkdir '/opt/CIx-0.2.2-UNSTABLE/' \
 && tar -xf './build/tar/CIx-0.2.2-UNSTABLE.tar.gz' -C '/opt/CIx-0.2.2-UNSTABLE/'
```

### Download and Install

```
TMP_PATH="$(mktemp)" \
 && curl -m 32 -f -L 'https://github.com/stancix/CIx/releases/download/0.2.2-UNSTABLE/CIx-0.2.2-UNSTABLE.tar.gz' -o "${TMP_PATH}" \
 && mkdir '/opt/CIx-0.2.2-UNSTABLE/' \
 && tar -xf "${TMP_PATH}" -C '/opt/CIx-0.2.2-UNSTABLE/' && rm "${TMP_PATH}"
```

---
