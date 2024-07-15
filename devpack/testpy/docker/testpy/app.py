from flask import Flask, render_template, request, redirect, url_for, session
from kubernetes import client, config
import base64
import yaml
import os
from kubernetes.client.exceptions import ApiException

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Remplacez par votre propre clé secrète

# Chemin vers le kubeconfig dans l'application Docker
kubeconfig_path = '/app/kubeconfig'

with open(kubeconfig_path, 'r') as f:
    kubeconfig = yaml.safe_load(f)

current_context = kubeconfig.get('current-context')

for context in kubeconfig.get('contexts', []):
    if context.get('name') == current_context:
        namespace = context.get('context', {}).get('namespace')
        break
else:
    namespace = 'default'

# Charger la variable d'environnement pour le namespace atlas
namespace_atlas = os.getenv('nsatlas', 'default')

@app.route('/')
def index():
    # Charger la configuration kubeconfig
    config.load_kube_config(config_file=kubeconfig_path)
    
    # Accéder aux secrets Kubernetes
    v1 = client.CoreV1Api()
    secrets = v1.list_namespaced_secret(namespace)
    
    # Récupérer les noms des secrets
    secret_names = [secret.metadata.name for secret in secrets.items]

    # Accéder aux ConfigMaps Kubernetes
    configmaps = v1.list_namespaced_config_map(namespace)
    
    # Récupérer les noms des ConfigMaps
    configmap_names = [configmap.metadata.name for configmap in configmaps.items]
    
    return render_template('index.html', title='Post Config', secret_names=secret_names, configmap_names=configmap_names)

# Routes pour les secrets (inchangées)
@app.route('/edit_secret', methods=['POST'])
def edit_secret():
    secret_name = request.form.get('secret_name')

    if not secret_name:
        return "Erreur : Nom de secret manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au secret Kubernetes
        v1 = client.CoreV1Api()
        secret = v1.read_namespaced_secret(secret_name, namespace)

        # Vérifier si le secret contient des données
        if secret.data:
            # Décoder les données du secret
            secret_data = {k: base64.b64decode(v).decode('utf-8') for k, v in secret.data.items()}
        else:
            secret_data = {}

        # Stocker le nom du secret dans la session pour une utilisation ultérieure
        session['current_secret'] = secret_name

        return render_template('edit_secret.html', secret_data=secret_data)
    
    except ApiException as e:
        return f"Erreur lors de la récupération du secret : {e.reason}"

    except ApiValueError as e:
        return f"Erreur : {e}"

@app.route('/apply_changes', methods=['POST'])
def apply_changes():
    # Récupérer le nom du secret depuis la session
    secret_name = session.get('current_secret')

    if not secret_name:
        return "Erreur : Nom de secret manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au secret Kubernetes
        v1 = client.CoreV1Api()
        secret = v1.read_namespaced_secret(secret_name, namespace)

        # Vérifier et initialiser secret.data si nécessaire
        if not secret.data:
            secret.data = {}

        # Mettre à jour les données du secret avec celles soumises dans le formulaire
        form_keys = request.form.getlist('keys[]')
        form_values = request.form.getlist('values[]')

        updated_data = {}
        for i, key in enumerate(form_keys):
            if key:
                value = form_values[i]
                updated_data[key] = base64.b64encode(value.encode('utf-8')).decode('utf-8')

        # Traiter les nouvelles clés/valeurs ajoutées
        new_keys = request.form.getlist('new_keys[]')
        new_values = request.form.getlist('new_values[]')
        for i in range(len(new_keys)):
            new_key = new_keys[i].strip()
            new_value = new_values[i].strip()
            if new_key and new_value:
                updated_data[new_key] = base64.b64encode(new_value.encode('utf-8')).decode('utf-8')

        # Supprimer les clés marquées pour suppression
        deleted_keys = request.form.getlist('deleted_keys[]')
        for key in deleted_keys:
            if key in secret.data:
                del secret.data[key]

        # Mettre à jour secret.data avec les données mises à jour
        secret.data.update(updated_data)

        # Appliquer les modifications au secret
        v1.replace_namespaced_secret(secret_name, namespace, secret)
        
        return redirect(url_for('index'))
    
    except ApiException as e:
        return f"Erreur lors de la mise à jour du secret : {e.reason}"

    except ApiValueError as e:
        return f"Erreur : {e}"

@app.route('/create_secret', methods=['POST'])
def create_secret():
    new_secret_name = request.form.get('new_secret_name')

    if not new_secret_name:
        return "Erreur : Nom du nouveau secret manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au client CoreV1Api
        v1 = client.CoreV1Api()

        # Créer un nouveau secret vide avec le nom spécifié et les annotations
        new_secret = client.V1Secret(
            api_version='v1',
            kind='Secret',
            metadata=client.V1ObjectMeta(
                name=new_secret_name,
                namespace=namespace,
                annotations={
                    'reflector.v1.k8s.emberstack.com/reflection-allowed': 'true',
                    'reflector.v1.k8s.emberstack.com/reflection-auto-enabled': 'true',
                    f'reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces': namespace_atlas,
                    'reflector.v1.k8s.emberstack.com/nochanges': 'true'
                }
            ),
            data={}
        )
        
        # Créer le secret dans Kubernetes
        v1.create_namespaced_secret(namespace, new_secret)

        return redirect(url_for('index'))
    
    except ApiException as e:
        return f"Erreur lors de la création du secret : {e.reason}"

@app.route('/delete_secret', methods=['POST'])
def delete_secret():
    secret_name = request.form.get('secret_name')

    if not secret_name:
        return "Erreur : Nom de secret manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au client CoreV1Api
        v1 = client.CoreV1Api()

        # Supprimer le secret dans Kubernetes
        v1.delete_namespaced_secret(secret_name, namespace)

        return redirect(url_for('index'))
    
    except ApiException as e:
        return f"Erreur lors de la suppression du secret : {e.reason}"

# Routes pour les ConfigMaps
@app.route('/edit_configmap', methods=['POST'])
def edit_configmap():
    configmap_name = request.form.get('configmap_name')

    if not configmap_name:
        return "Erreur : Nom de ConfigMap manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au ConfigMap Kubernetes
        v1 = client.CoreV1Api()
        configmap = v1.read_namespaced_config_map(configmap_name, namespace)

        # Vérifier si le ConfigMap contient des données
        configmap_data = configmap.data if configmap.data else {}

        # Stocker le nom du ConfigMap dans la session pour une utilisation ultérieure
        session['current_configmap'] = configmap_name

        return render_template('edit_configmap.html', configmap_data=configmap_data)
    
    except ApiException as e:
        return f"Erreur lors de la récupération du ConfigMap : {e.reason}"

    except ApiValueError as e:
        return f"Erreur : {e}"

@app.route('/apply_configmap_changes', methods=['POST'])
def apply_configmap_changes():
    # Récupérer le nom du ConfigMap depuis la session
    configmap_name = session.get('current_configmap')

    if not configmap_name:
        return "Erreur : Nom de ConfigMap manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au ConfigMap Kubernetes
        v1 = client.CoreV1Api()
        configmap = v1.read_namespaced_config_map(configmap_name, namespace)

        # Vérifier et initialiser configmap.data si nécessaire
        if not configmap.data:
            configmap.data = {}

        # Mettre à jour les données du ConfigMap avec celles soumises dans le formulaire
        form_keys = request.form.getlist('keys[]')
        form_values = request.form.getlist('values[]')

        updated_data = {}
        for i, key in enumerate(form_keys):
            if key:
                value = form_values[i]
                updated_data[key] = value

        # Traiter les nouvelles clés/valeurs ajoutées
        new_keys = request.form.getlist('new_keys[]')
        new_values = request.form.getlist('new_values[]')
        for i in range(len(new_keys)):
            new_key = new_keys[i].strip()
            new_value = new_values[i].strip()
            if new_key and new_value:
                updated_data[new_key] = new_value

        # Supprimer les clés marquées pour suppression
        deleted_keys = request.form.getlist('deleted_keys[]')
        for key in deleted_keys:
            if key in configmap.data:
                del configmap.data[key]

        # Mettre à jour configmap.data avec les données mises à jour
        configmap.data.update(updated_data)

        # Appliquer les modifications au ConfigMap
        v1.replace_namespaced_config_map(configmap_name, namespace, configmap)
        
        return redirect(url_for('index'))
    
    except ApiException as e:
        return f"Erreur lors de la mise à jour du ConfigMap : {e.reason}"

    except ApiValueError as e:
        return f"Erreur : {e}"

@app.route('/create_configmap', methods=['POST'])
def create_configmap():
    new_configmap_name = request.form.get('new_configmap_name')

    if not new_configmap_name:
        return "Erreur : Nom du nouveau configmap manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au client CoreV1Api
        v1 = client.CoreV1Api()

        # Créer un nouveau configmap vide avec le nom spécifié et les annotations
        new_configmap = client.V1ConfigMap(
            api_version='v1',
            kind='ConfigMap',
            metadata=client.V1ObjectMeta(
                name=new_configmap_name,
                namespace=namespace,
                annotations={
                    'reflector.v1.k8s.emberstack.com/reflection-allowed': 'true',
                    'reflector.v1.k8s.emberstack.com/reflection-auto-enabled': 'true',
                    f'reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces': namespace_atlas,
                    'reflector.v1.k8s.emberstack.com/nochanges': 'true'
                }
            ),
            data={}
        )
        
        # Créer le configmap dans Kubernetes
        v1.create_namespaced_config_map(namespace, new_configmap)

        return redirect(url_for('index'))
    
    except ApiException as e:
        return f"Erreur lors de la création du configmap : {e.reason}"

@app.route('/delete_configmap', methods=['POST'])
def delete_configmap():
    configmap_name = request.form.get('configmap_name')

    if not configmap_name:
        return "Erreur : Nom de ConfigMap manquant"

    try:
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder au client CoreV1Api
        v1 = client.CoreV1Api()

        # Supprimer le ConfigMap dans Kubernetes
        v1.delete_namespaced_config_map(configmap_name, namespace)

        return redirect(url_for('index'))
    
    except ApiException as e:
        return f"Erreur lors de la suppression du ConfigMap : {e.reason}"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
