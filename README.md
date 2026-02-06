# 🚀 Atelier API-Driven Infrastructure

## 💡 Le Concept en 30 secondes
Ce projet démontre comment orchestrer une infrastructure Cloud (AWS) sans jamais toucher à une console graphique. Une simple requête HTTP `POST` envoyée à une **API Gateway** déclenche une fonction **Lambda** qui va, à son tour, piloter (démarrer/arrêter) une instance **EC2**. 

Le tout est exécuté dans un environnement émulé grâce à **LocalStack** au sein de **GitHub Codespaces**.

---

## 🏗️ Architecture Cible

L'architecture suit un flux serverless moderne :
1. **Client** : Envoie une requête JSON (via `curl`).
2. **API Gateway** : Point d'entrée HTTP qui route la requête.
3. **Lambda (Python)** : Logique métier qui utilise le SDK `boto3` pour interagir avec EC2.
4. **EC2** : La ressource d'infrastructure ciblée par l'action.



---

## 🛠️ Installation et Déploiement

Le projet est entièrement automatisé pour garantir la reproductibilité.

### 1. Préparation de l'environnement
Dans votre terminal Codespace, installez les outils nécessaires :

# Activation de l'environnement virtuel et installation des outils
```
python3 -m venv venv
source venv/bin/activate
pip install localstack awscli-local boto3
```
Lancement de LocalStack

localstack start -d
# Attendez quelques secondes que les services soient prêts
```
localstack status services
```
Déploiement automatique
```
chmod +x deploy.sh
./deploy.sh
```
🚦 Guide d'utilisation (Test de l'API)

Une fois le déploiement terminé, récupérez l'URL publique du port 4566 dans l'onglet PORTS de votre Codespace.

Envoyer une commande d'arrêt (Stop)
Remplacez [VOTRE_ID_API] et [VOTRE_URL_CODESPACE] dans la commande suivante :

```
curl -X POST https://[VOTRE_URL_CODESPACE]/restapis/[VOTRE_ID_API]/prod/_user_request_/manage \
     -H "Content-Type: application/json" \
     -d '{"action": "stop", "instance_id": "i-1234567890abcdef0"}'
```
     
Vérifier le statut de l'infrastructure
Pour confirmer que l'API a bien piloté l'EC2, vérifiez l'état de l'instance :
```
awslocal ec2 describe-instances --query 'Reservations[0].Instances[0].State.Name'
```
