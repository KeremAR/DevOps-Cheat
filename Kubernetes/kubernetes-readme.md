# Kubernetes Learning Notes

## What is Kubernetes and Why is it Needed?

Kubernetes is an open-source container orchestration tool used to manage and scale containers efficiently. As microservices became more common, managing containers became increasingly complex. Kubernetes solves this problem by automatically scaling applications based on load and ensuring service continuity.

## Container Orchestration

Kubernetes provides the following container orchestration capabilities:

- **Provisioning and deployment** (IT altyapısının hazırlanmı ve dağıtımı)
- **Configuration and scheduling** (Konfigürasyon ve Zamanlama)
- **Resource allocation** (Kaynak tahsisi)
- **Container availability** (Konteyner kullanılabilirliği)
- **Scaling or removing containers** based on balancing workloads across your infrastructure (Altyapınızdaki iş yüklerini dengelemeye dayalı olarak workload birimlerini ölçeklendirme veya kaldırma)
- **Load balancing and traffic routing** (Yük dengeleme ve trafik yönlendirme)
- **Monitoring container health** (Konteynerların çalışma durumlarını izleme)
- **Keeping interactions between containers secure** (Konteynerlar arası etkileşimleri güvende tutmak)

## Key Features

### Resilience

Kubernetes ensures system reliability by restarting failed applications or relocating them to healthy servers. For example, if a server crashes, Kubernetes automatically redistributes the containers to other available servers, keeping the system running.

### Deployment

Kubernetes supports different deployment strategies:

* **Disruptive Deployment:** The old version is completely shut down before the new version is launched (risk of downtime).
* **Seamless Deployment:** The old version is gradually phased out while the new version is brought online (more reliable).
* **Rollback:** If an issue occurs in the new version, Kubernetes can automatically revert to the previous version.

### Provisioning (Resource Management)

Kubernetes optimizes hardware resource usage by:

* **Automatic Scaling:** Adding new containers when traffic increases and shutting down unnecessary ones when demand is low.
* **Load Balancing:** Distributing incoming requests across available containers efficiently.

## Kubernetes and CI/CD

**CD tools handle the deployment process**, but Kubernetes **ensures that deployed applications run continuously, scalably, and securely**. Without Kubernetes, CI/CD tools can still perform deployments, but features like load balancing, self-healing, and scaling would be missing. This is why **CI/CD and Kubernetes are typically used together**.

## Conclusion

Kubernetes automates container management, making systems more resilient, scalable, and efficient. While Docker is used to build and package containers, Kubernetes is responsible for managing and orchestrating them.
