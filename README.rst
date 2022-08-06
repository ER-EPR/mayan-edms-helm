.. image:: https://assets.gitlab-static.net/mayan-edms/helm-chart/raw/master/_static/mayan_labs_logo.png
   :alt: Mayan Labs logo

This repository is part of the Mayan Labs projects.

These are projects that are not yet complete or were created for a specific
use. These are early releases.

Experience with Mayan EDMS and programming concepts are required to use
Mayan Labs projects.

Mayan Labs projects are not General Availability and are only
supported via the commercial support offerings (https://www.mayan-edms.com/support/).

============
Installation
============

#. Install an initial release:

   .. code-block:: console

       helm install <release name> mayan-edms --timeout 15m

#. Deploy the chart using a different values file (optional):

   .. code-block:: console

      helm install <release name> mayan-edms --timeout 15m --values values-custom.yaml


Upgrade
=======

.. note::

    Use the same release name that was used for the installation.

.. code-block:: console

    helm upgrade <release name> mayan-edms --timeout 15m


Install or upgrade
==================

#. Performs an installation or an upgrade

.. code-block:: console

    helm upgrade --install --values freenas-nfs.yaml --timeout 15m <release name> mayan-edms


Uninstall
=========

This destroys the stack leaving only the persistent volume behind.

.. note::

    Use the same release name that was used for the installation.

.. code-block:: console

    helm uninstall <release name>


============
Chart layout
============

Default values:

- 1 front end pods, port 8000, host: mayan.minikube
- 1 A class workers pods
- 1 B class workers pods
- 1 C class workers pods
- 1 D class workers pods
- 1 scheduled task beat generator pods


==========
Parameters
==========

Global
======

- ``global.image.repository``

  Global Docker image registry.

  Default: ``mayanedms/mayanedms``

- ``global.image.pullPolicy``

  Global Dock erimage pull policy.

  Default: ``IfNotPresent``

- ``global.image.tag``

  Global Docker image tag.

  Default: latest image version (ie: ``s4.0``)

- ``global.storageClass``

  Global ``storageClass`` for all pods.

  Default: ``nil``


General
=======

- ``imagePullSecrets``

  Specify docker-registry secret names as an array.

  Default: ``[]``

- ``nameOverride``

  String to partially override ``mayan.fullname`` template with a string (will prefix the release name).

  Default: ``nil``

- ``fullnameOverride``

  String to fully override ``mayan.fullname`` template with a string.

  Default: ``nil``


Configuration
=============

- ``configuration``

  Key and value entries to populate the config map. Use Mayan EDMS environment variables.

  Default: ``{}``


Secrets
=======

- ``secrets``

  Key and value entries to populate the secrets. Use Mayan EDMS environment variables.

  Default: ``{}``


Persistence
===========

The persistent configuration is divided into several main components. The
first is the ``core`` component that controls how the storage for the
``media`` folder is configure.

The other components control how specific storages are configured. These
can be set to the following options:

- ``default``: Use the same storage as the ``core`` component.
- ``objectLocal``: Use a locally deployed Minio service for storage.
- ``objectExternal``: Use a remote object storage.
- ``custom``: Enable specifying a custom backend class using the ``backend``
  and passing arguments using either the ``argument`` key for YAML strings
  or the ``argumentMap`` for key and values pairs.

Since the ``media`` folder is shared among all pods, the ``accessMode`` is
set to ``ReadWrite`` and cannot be changed. The ``storageClass`` must support
this mode for this chart to be usable.


Core
^^^^

- ``persistence.core.annotations``

  Persistent Volume annotations.

  Default: ``{}``

- ``persistence.core.enabled``

  Use a PVC to persist data .

  Default: ``true``

- ``persistence.core.existingClaim``

  Name of an existing PVC to use (only in "standalone" mode)                                                                                                | `nil`

  Default: ``nil``

- ``persistence.core.size``

  Size of data volume.

  Default: ``nil``

- ``persistence.core.storageClass``

  Storage class of backing PVC. This value will be overridden by
  ``global.storageClass``.

  Default: ``nil``

- ``persistence.core.volume.create``

  Create a persistent volume resource. This is used for storage
  implementations that do not support automatic provisioning.


Frontend
========

- ``frontend.ingres.annotations``

  Ingress annotations.

  Default: ``[]``

- ``frontend.ingres.enabled``

  Enable/disable ingress.

  Default: ``nil``

- ``frontend.ingres.hosts[0].host``

  Hostname to Mayan EDMS stack.

  Default: ``nil``

- ``frontend.ingres.hosts[0].paths``

  Path within the URL structure

  Default: ``/``

- ``frontend.ingres.tls.0.secretName``

  Name of the TLS Secret (certificates)

- ``frontend.ingres.tls.0.hosts.0``

  Array of TLS hosts for ingress record (defaults to `ingress.hosts[0].name` if `nil`)

- ``frontend.replicaCount``

  Default: ``nil``

- ``frontend.resources.limits``

  Kunbernets resource control for the containers

  Default: ``{}``

- ``frontend.securityContext``

  Kubernets security context setup for the containers.

  Default: ``{}``

- ``frontend.service.type``

  Service type used when exposing the frontend.

  Default: ``ClusterIP``


===
SSL
===

SSL certificates are generated using cert-manager
(https://cert-manager.io/docs/installation/kubernetes/) and Let's Encrypt.

Installation of cert-manager
============================

.. code-block:: console

    kubectl create namespace cert-manager

.. code-block:: console

    helm repo add jetstack https://charts.jetstack.io

.. code-block:: console

    helm repo update

.. code-block:: console

    helm install cert-manager jetstack/cert-manager --namespace \
    cert-manager --version v0.16.0 --set installCRDs=true

.. code-block:: console

    kubectl get pods --namespace cert-manager

In the values file, set ``letscrypt.enabled`` to ``true`` and the ``domain``
key to the domain name for the certificate.

.. code-block:: yaml

    letsencrypt:
      domain: example.com
      email: username@example.com
      enabled: true
      production: false

Verify that a test certificate is issued. If a test certificate is issued,
change the ``production`` to ``true`` and upgrade the release.



===============
Troubleshooting
===============


``error while running "VolumeBinding" filter plugin for pod "...": pod has unbound immediate PersistentVolumeClaims``
=====================================================================================================================

- Permission issue: https://github.com/helm/charts/issues/17250
- Enable volume permissions: ``volumePermissions.enabled`` to ``true``
- There are no persistent volumes matching the claim. Provision a volume or
  wait is there is an automatic provisioner:
  https://stackoverflow.com/questions/60774220/kubernetes-pod-has-unbound-immediate-persistentvolumeclaims


Slow IO
=======

- Switch to block storage
- Switch to local storage for non persistent storage
- NFS locking needed or other mount option
- File storage with GID support and enable GID support in deployment
- https://cloud.ibm.com/docs/FileStorage?topic=FileStorage-about#provisioning-with-endurance-tiers
- "Another type of application that should not be run across NFS file
  systems is an application that does hundreds of lockf() or flock() calls
  per second. On an NFS file system, all the lockf() or flock() calls
  (and other file locking calls) must go through the rpc.lockd daemon.
  This can severely degrade system performance because the lock daemon may
  not be able to handle thousands of lock requests per second."
- https://www.ibm.com/support/knowledgecenter/ssw_aix_71/performance/misuses_nfs_perf.html
- https://github.com/helm/charts/issues/10427
- mountOptions (hard, nfsvers=4.1): https://kubernetes.io/docs/concepts/storage/persistent-volumes/
- "NFS does not support fsync kernel vfs call which is required transaction
  logs for ensuring the writing out the redo logs on the disk. So you should
  use block storage when you need to use RDBMS, such as PostgreSQL and
  MySQL. You might lose the data consistency althogh you can run the one on the NFS."
- https://stackoverflow.com/questions/51725559/how-to-deploy-postgresql-on-kubernetes-with-nfs-volume
- IO permissions:
  - https://cloud.ibm.com/docs/containers?topic=containers-cs_troubleshoot_storage#nonroot
  - https://github.com/kubernetes/kubernetes/issues/2630
  - https://gitmemory.com/issue/helm/charts/14127/496120841
- https://github.com/helm/charts/issues/17250
- Switch to a higher tier storage class.


Reboot cycling
==============

- Disable liveness and readiness probes to persist pod and examine logs.


Upload size limit
=================

- https://github.com/nginxinc/kubernetes-ingress/tree/release-1.7/deployments/helm-chart
- https://cloud.ibm.com/docs/containers?topic=containers-ingress_annotation


Credits
=======
Beaker icon by https://www.flaticon.com/authors/bqlqn
