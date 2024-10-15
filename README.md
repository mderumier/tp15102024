# Mathilde Derumier - 5A AVM #

# TP STREAMING ABS DASH et HLS

Dans ce TP nous allons compiler et configurer un service de streaming ABS DASH et HLS à partir des projets open-source Nginx et Nginx-vod-module.

[Nginx](https://www.nginx.com/) est une solution open source de serveur web et de reverse proxy développé en C.

[Nginx-vod-module](https://github.com/kaltura/nginx-vod-module/blob/master/README.md) est un module Nginx permettant de packager à la volée des video MP4 en DASH ou HLS.

La documentation de nginx-vod-module contient toutes les informations de configuration. Cet environnement codespace contient ffmpeg et ffprobe installés.

Le serveur de streaming sera compilé et executé dans un container Docker et configurer avec [Docker-Compose](https://docs.docker.com/compose/gettingstarted/).

## Service de streaming

1/ Listez les codecs audio et vidéo utilisables par Nginx-vod-module pour faire du DASH

Les codecs audios et vidéos utilisables par Nginx-vod-module pour faire du DASH sont les suivants :  H264, H265, AV1, VP8, VP9 (pour la vidéo) et AAC, AC-3, E-AC-3, VORBIS, OPUS (pour l'audio).

2/ Listez les codecs audio et vidéo utilisables par Nginx-vod-module pour faire du HLS

Les codecs audios et vidéos utilisables par Nginx-vod-module pour faire du HLS sont les suivants : H264, H265, AV1 (pour la vidéo) et AAC, MP3, AC-3, E-AC-3, FLAC, DTS (pour l'audio).

## Preparation et conternerisation du serveur de streaming

Le fichier [`Dockerfile`](https://docs.docker.com/reference/dockerfile/) contient les étapes de compilation du service.

3/ Decrivez les grandes étapes du fichier `Dockerfile`.

4/ Quelles sont les options fournies à la compilation de Nginx avec Nginx-vod-module ?

Créez le fichier `docker-compose.yml` contenant les informations suivantes :

```yml
services:
   streamer:
      build:
         context: .
         args:
            NGINX_VERSION: 1.25.3
            VOD_MODULE_VERSION: 1.33
      restart: always
      volumes:
         - ./MP4:/opt/mp4/
         - ./conf:/usr/local/nginx/conf/
      ports:
         - "3030:3030"
```

5/ Que fait le fichier  `docker-compose.yml` ?

Lancez le service de streaming dans le container

      docker compose up

6/ Detaillez ce qui s'affiche dans la console lors du lancement du container.

7/ Dans un autre terminal executez les commandes `docker images` et `docker ps`. Que remontent ces commandes ? 

Pour exposer publiquement le container hors de github codespace, lancez cette commande :

      gh codespace ports visibility 3030:public -c $CODESPACE_NAME

8/ Testez la connexion au serveur NGINX en local; Que retourne `curl http://localhost:3030`. 

Que retourne la commande curl ? 

Quelle est l'url publique permettant d'accèder au serveur NGINX ?

Le fichier de test que nous allons utilser est `MP4/content.mp4`.

8/ Executez la commande `ffprobe MP4/content.mp4` et reportez les caratéristiques techniques des 'essences/stream' video et audio de ce fichier.

## Configuration Nginx

_/!\ A chaque modification du fichier de configuration `conf/nginx.conf`, il faut redémarrer le serveur._

### Configuration DASH

9/ Dans le fichier `conf/nginx.conf` dans le bloc http>server ajoutez la configuration DASH permettant de streamer les fichiers du dossier /opt/mp4/ (CF la documentation de nginx-vod).

```yml
   location: /dash/ {
      vod: dash;
      alias: /opt/mp4/;
   }
```

_/!\ Redemarrez le serveur_

10/ Créez les requêtes localhost et publique pour streamer le fichier `content.mp4` en DASH (CF la documentation de nginx-vod).

   http://localhost:3030/...

   https//XXXXX.app.github.dev/...

Ouvrez la page https://timeline.fishtank.cloud, selectionnez DASH, entrez l'url publique du manifest pour streamer le fichier `content.mp4`.

11/ Descrivez le contenu du Manifest.

12/ Ouvrez la console du navigateur web `ctrl + maj + i` et l'onglet network. Quelle activité réseau remarquez vous lors de la lecture de la video et changez de piste audio pendant le stream ?

### Configuration HLS

Dans le fichier `conf/nginx.conf` ajouter dans le bloc http>server la configuration pour le HLS permettant de streamer les fichiers du dossier /opt/mp4/.

```yml
   location: /hls/ {
      vod: hls;
      alias: /opt/mp4/;
   }
```

_/!\ Redemarrez le serveur_

13/ Créez les requêtes localhost et publique pour streamer le fichier `content.mp4` en HLS pour les master.m3u8 et index.m3u8 (CF la documentation de nginx-vod).

   http://localhost:3030/...

   https//XXXXX.app.github.dev/...

Ouvrez la page https://timeline.fishtank.cloud, selectionnez HLS, entrez l'url publique de la playlist HLS pour streamer le fichier `content.mp4`.

14/ Decrivez le fichier m3u8.

15/ Ouvrez la console du navigateur web `ctrl + maj + i` et l'onglet network. Quelle activité réseau remarquez vous lors de la lecture de la video ?

## Adaptive bitrate streaming

Le streaming à débit adaptatif ajuste la qualité vidéo en fonction des conditions du réseau pour améliorer le streaming vidéo sur les réseaux HTTP. Ce processus rend la lecture aussi fluide que possible pour les spectateurs, quelque soient leur appareil, leur emplacement ou leur débit Internet.

A partir du fichier MP4/content.mp4, nous allons fabriquer des versions déclinées pour permettre un streaming à débit adaptatif.

_ffmpeg est disponible dans codespace._

Avec ffmpeg, séparez les essences audio et video dans des fichiers séparés avec `codec copy`.

16/ Générez la requete DASH permettant de streamer tous fichiers séparés dans le même stream. Analysez le manifest fabriqué.

17/ Générez la requete HLS permettant de streamer tous fichiers séparés dans le même stream. Analysez le m3u fabriqué.

A partir de l'essence video, declinez des versions HD 1080, 720 et SD 540 en H264.

18/ Générez la requete DASH permettant de streamer tous fichiers séparés dans le même stream. Analysez le manifest fabriqué.

19/ Générez la requete HLS permettant de streamer tous fichiers séparés dans le même stream. Analysez le m3u fabriqué.

20/ Analysez la structure de ce manifest https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps.mpd. 
 Combien contient t'il de déclinaisons video ? 
 Quelle est le codec et débit utilisés pour la video de plus haute qualité ? 
