# Kubernetes Core Concepts & Architecture

As I prepare to transition into a cloud-native platform environment, I am building a strong foundational mental model of Kubernetes (K8s). Kubernetes is an open-source container orchestration platform designed to automate the deployment, scaling, and management of containerized applications. 

Here is a breakdown of the core building blocks I am learning:

---

### 1. Containers vs. Pods
* **What a Container is:** A lightweight, standalone package that includes everything needed to run an application (code, runtime, system tools, libraries). 
* **The Kubernetes Equivalent (The Pod):** In Kubernetes, you don't deploy containers directly. Instead, you deploy **Pods**. A Pod is the smallest deployable unit in Kubernetes and acts as a "wrapper" or sandbox for one or more tightly coupled containers. 
* **Key Takeaway for Support:** Pods share the same network IP and storage space. If an application is failing, investigating the specific logs of a container *inside* a Pod is usually the first step in Tier 1 triage.

---

### 2. Nodes (The Infrastructure Layer)
* **What a Node is:** A Node is a worker machine in Kubernetes. It can be a physical machine or, more commonly in cloud environments like AWS, a virtual machine (EC2 instance).
* **Control Plane vs. Worker Nodes:** 
  * The **Control Plane** acts as the brains of the cluster, deciding where applications run and monitoring system health.
  * **Worker Nodes** actually run the Pods and do the heavy lifting of processing user traffic.
* **Key Takeaway for Support:** If multiple applications or pipelines break simultaneously, the issue might not be the code—it could mean a underlying Node has run out of CPU/memory or lost its connection to the network.

---

### 3. Deployments (Scaling & Uptime)
* **What a Deployment is:** A declarative configuration file (usually written in YAML) that tells Kubernetes how many copies (replicas) of a Pod should be running at any given time.
* **Self-Healing Capabilities:** If a Pod crashes or a Node goes offline, the Deployment controller automatically notices the gap and spins up a brand-new Pod on a healthy node to take its place. 
* **Key Takeaway for Support:** This built-in redundancy is why cloud platforms achieve high uptime. Understanding Deployments helps when triaging broken development pipelines or identifying why a new application version failed to roll out.

---

### 4. Services & Ingress (Networking)
* **What a Service is:** Because Pods are constantly being created and destroyed (and their internal IP addresses change every time), you cannot rely on a single Pod's IP to access an application. A **Service** provides a single, permanent IP address and DNS name that routes traffic to the correct group of Pods.
* **What an Ingress is:** While a Service manages traffic *inside* the cluster, an **Ingress** acts as the smart front door, managing how external users on the internet safely access those internal services.
* **Key Takeaway for Support:** When end-users encounter "Application Access" or "Site Down" issues, checking the Service routing and Ingress rules is a crucial part of isolating network blocks from code bugs.
