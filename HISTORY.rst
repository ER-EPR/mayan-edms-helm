4.2-5 (2022-XX-XX)
==================
- Update minikube targets to use a separate namespace called `minikube`.
  The Helm installation name is also now set to `minikube`.
- Fix the Redis password entry.
- Add separate values file for the minikube target.

4.2-4 (2022-08-06)
==================
- Sort deployment YAML keys.
- Fix jobs image pull secrets.
- Lower default replica counts to 1.
- Add resource limits to pods.
- Update path to the Redis password for versions
  => 6.0.

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
