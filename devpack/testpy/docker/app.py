from flask import Flask, render_template, request, redirect, url_for, flash
from kubernetes import client, config
import base64

app = Flask(__name__)
app.secret_key = 'your_secret_key'

# Chemin vers le kubeconfig dans l'application Docker
kubeconfig_path = '/app/kubeconfig'

@app.route('/')
def index():
    return render_template('index.html', title='Post Config')

@app.route('/edit', methods=['GET', 'POST'])
def edit():
    if request.method == 'POST':
        new_data = {}
        for key, value in request.form.items():
            new_data[key] = value
        
        # Charger la configuration kubeconfig
        config.load_kube_config(config_file=kubeconfig_path)
        
        # Accéder aux secrets Kubernetes
        v1 = client.CoreV1Api()
        
        try:
            # Lire le secret existant
            secret = v1.read_namespaced_secret('ntt-data', 'default')
            
            # Mettre à jour les valeurs du secret avec les nouvelles données
            for key, value in new_data.items():
                secret.data[key] = base64.b64encode(value.encode('utf-8')).decode('utf-8')
            
            # Appliquer les modifications au secret
            v1.replace_namespaced_secret('ntt-data', 'default', secret)
            
            flash('Les modifications ont été appliquées avec succès.', 'success')
        except Exception as e:
            flash(f'Erreur lors de la mise à jour du secret : {str(e)}', 'danger')
        
        return redirect(url_for('index'))  # Redirection vers la page principale après modification
    
    # Charger la configuration kubeconfig
    config.load_kube_config(config_file=kubeconfig_path)
    
    # Accéder aux secrets Kubernetes
    v1 = client.CoreV1Api()
    secret = v1.read_namespaced_secret('ntt-data', 'default')
    
    # Décoder les données du secret
    secret_data = {}
    for k, v in secret.data.items():
        secret_data[k] = base64.b64decode(v).decode('utf-8')
    
    return render_template('edit.html', secret_data=secret_data)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
