import os
import time
from kubernetes import client, config, watch

# Récupération des variables d'environnement
NAMESPACE = os.getenv("NAMESPACE", "default")
ANNOTATION_REFLECTOR_NAMESPACE = "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces"
ANNOTATION_NO_CHANGES = "reflector.v1.k8s.emberstack.com/nochanges"

# Initialisation de la configuration Kubernetes
config.load_incluster_config()
v1 = client.CoreV1Api()

def get_secret_data(secret_name, namespace):
    try:
        secret = v1.read_namespaced_secret(secret_name, namespace)
        return secret.data
    except client.exceptions.ApiException as e:
        print(f"Exception when reading secret {secret_name} in namespace {namespace}: {e}")
        return None

def sync_secret_if_needed(secret_name, namespace, target_namespace):
    source_data = get_secret_data(secret_name, namespace)
    target_data = get_secret_data(secret_name, target_namespace)

    if source_data and target_data:
        if source_data != target_data:
            target_secret = v1.read_namespaced_secret(secret_name, target_namespace)
            target_secret.data = source_data
            v1.replace_namespaced_secret(secret_name, target_namespace, target_secret)
            print(f"Secret {secret_name} in namespace {target_namespace} synced with source")

def main():
    while True:
        secrets = v1.list_namespaced_secret(NAMESPACE).items
        for secret in secrets:
            annotations = secret.metadata.annotations
            if annotations and ANNOTATION_REFLECTOR_NAMESPACE in annotations:
                target_namespace = annotations[ANNOTATION_REFLECTOR_NAMESPACE]
                if annotations.get(ANNOTATION_NO_CHANGES) == "true":
                    sync_secret_if_needed(secret.metadata.name, NAMESPACE, target_namespace)

        time.sleep(60)

if __name__ == '__main__':
    main()
