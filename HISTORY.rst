4.3-1 (2022-08-06)
==================
- Add support for disabling core volume.
- Fix image pull secret.
- Update Mayan EDMS to 4.3.
- Convert to a single app helm chart that deploys only mayan EDMS.
  Removed managed settings.
- Fix restart policy of the initial setup and perform upgrade jobs.
- Add resource limits to all pods.
- Lower default replica count of all pods to 1.

4.2-3 (2022-07-02)
==================
- Update dependencies.

4.2-2 (2022-04-21)
==================
- Add RabbitMQ `forceBoot` to ensure the stateful set
  does not remain in a degraded state after an upgrade.

4.2 (2022-03-29)
================
- Update for Mayan EDMS 4.2.
- Add support for quoted arguments for workers.
- Add an ElasticSearch service.
- Support configuring service type of the frontend.

4.0-1 (2021-XX-XX)
==================
- Support launching general purpose containers.

4.0 (2021-05-27)
================
- Initial public release.
