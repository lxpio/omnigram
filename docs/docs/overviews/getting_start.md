---
title: "Quick Start"
sidebar_position: 1
---

## Dependencies

Please refer to [environment requirements](../install/requirements) for details.

## Docker Startup

By default, after docker starts up it will create a default admin account `admin` with the default password `123456`.

- The default password is `123456`. You can change it after logging in later, or by setting the `OMNI_PASSWORD` environment variable.
- `my_local_docs_path` should be modified to your actual directory path that stores Epubs and PDFs. After logging in, you can configure scanning strategies to build file indices.
- If you need persistent running, please refer to [Best Practices for Deployment](../install/best_practice).

```bash
# Replace my_local_docs_path below with your actual documents directory
docker run -v <my_local_docs_path>:/docs -p 8080:80 lxpio/omnigram-server:v0.1.2-alpine
```

## Try Mobile UI

### Download App

The mobile app can be downloaded from:

- [ ] Google Play
- [ ] App Store
- [x] [Github (apk)](https://github.com/nexptr/omnigram)

### Login App

//TODO add login page

<!-- [] -->

### Scan local files

//TODO add scan page

### Starting reading

//TODO add reading page

## What next？

The above documentation is only intended for quick start deployments and trials. If you expect full service capabilities and user experiences from Omnigram, please refer to [Best Practices for Deployment](../install/best_practice).
