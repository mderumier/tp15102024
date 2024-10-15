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

Les grandes étapes du fichier `Dockerfiler` sont les suivantes :

```Dockerfile
ARG NGINX_VERSION
ARG VOD_MODULE_VERSION
#step 1
FROM redhat/ubi8

RUN yum install -y gcc-c++ \
				   gcc \
				   libgomp \
				   cmake3 \
				   make \
				   pcre pcre-devel \
				   curl libcurl-devel \
				   libxml2 libxml2-devel \
				   openssl openssl-devel \
				   diffutils file expat-devel \
				   libuuid libuuid-devel
#step 2
USER root
RUN mkdir /tmp/nginx /tmp/nginx-vod-module 
RUN curl -Ls -o - https://nginx.org/download/nginx-1.25.3.tar.gz | tar zxf - -C /tmp/nginx --strip-components 1
RUN curl -Ls -o - https://github.com/kaltura/nginx-vod-module/archive/refs/tags/1.33.tar.gz | tar zxf - -C /tmp/nginx-vod-module --strip-components 1
#step 3
WORKDIR /tmp/nginx
RUN ./configure --prefix=/usr/local/nginx --add-module=/tmp/nginx-vod-module --with-http_stub_status_module \
	--with-http_ssl_module --with-file-aio --with-threads --with-cc-opt="-O3"
RUN make -j4 && make install
RUN rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default /app /tmp/nginx /tmp/nginx-vod-module
#step 4
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
```

Etape 1 

- RUN yum install -> installation et lancement des différents ficheirs présents dans les dossiers. Ce sont surtout des libriaries.

Etape 2

Ensuite on créé un dossier nginx dans tmp, on charge les fichiers stockés aux URL renseignées avec la commande curl et on les enregistre dans le dossier indiqué en les décompressants (-o). 
On refait la même chose avec une autre page.

Etape 3

On définit le répertoire de travail et on créé le fichier de configuration suivant différents paramètres.
Ensuite, on lance la compilation et on supprime les fichiers d'installation.

Etape 4

Enfin on définit l'executable par défaut et les commandes associées.

4/ Quelles sont les options fournies à la compilation de Nginx avec Nginx-vod-module ?

Les options fournies à la compilation de Nginx avec Nginx-vod-module sont --prefix=/usr/local/nginx --add-module=/tmp/nginx-vod-module --with-http_stub_status_module --with-http_ssl_module --with-file-aio --with-threads --with-cc-opt="-O3".

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

Le fichier `docker-compose` renseigne sur les arguments à renseigner dans la commande. Cela comprends la version de nginx, de la version du module VOD, et de différents paramètres comme le port de communication.

Lancez le service de streaming dans le container

      docker compose up

6/ Detaillez ce qui s'affiche dans la console lors du lancement du container.

Lors du lancement du container on voit toutes les étapes dans le terminal. La commande permet de lancer automatiquement les fichiers de configurations et installe les fichiers nécessaires au lancement de l'application.
Quand tout est terminé on arrive sur une page web nous indiquant le succès de l'excecution.

7/ Dans un autre terminal executez les commandes `docker images` et `docker ps`. Que remontent ces commandes ? 

Ces commandes remontent les dernières manipulations effectuées. 
`docker images` -> Indique le chemin et les informations des de la dernière image créée.
`docker ps` -> Indique le dernier transfert réalisé.

Pour exposer publiquement le container hors de github codespace, lancez cette commande :

      gh codespace ports visibility 3030:public -c $CODESPACE_NAME

8/ Testez la connexion au serveur NGINX en local; Que retourne `curl http://localhost:3030`. 

Que retourne la commande curl ? 

La commande curl retourne un `{"status":"success"}`.

Quelle est l'url publique permettant d'accèder au serveur NGINX ?

L'URL publique est la suivante : [http://localhost:3030](https://congenial-space-capybara-xg6rqww995636v65-3030.app.github.dev/).

Le fichier de test que nous allons utiliser est `MP4/content.mp4`.

8/ Executez la commande `ffprobe MP4/content.mp4` et reportez les caratéristiques techniques des 'essences/stream' video et audio de ce fichier.

Les caractéristiques techniques sont les suivantes :

- Stream 1 : `(fra): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 317 kb/s`
- Stream 2 : `(eng): Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 317 kb/s`

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

`https://congenial-space-capybara-xg6rqww995636v65-3030.app.github.dev/dash/,content.mp4,.urlset/manifest.mpd`

11/ Descrivez le contenu du Manifest.

Le manifest contient de l'audio et de la vidéo, représentés par des couleurs différentes : bleu et vert.

12/ Ouvrez la console du navigateur web `ctrl + maj + i` et l'onglet network. Quelle activité réseau remarquez vous lors de la lecture de la video et changez de piste audio pendant le stream ?

On remarque un changement de segment.

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

   `https://congenial-space-capybara-xg6rqww995636v65-3030.app.github.dev/hls/,content.mp4,.urlset/master.m3u8`

Ouvrez la page https://timeline.fishtank.cloud, selectionnez HLS, entrez l'url publique de la playlist HLS pour streamer le fichier `content.mp4`.

14/ Decrivez le fichier m3u8.

Le fichier m3u8 contient les mêmes informations que le DASH mais présenté autrement (en ligne).

15/ Ouvrez la console du navigateur web `ctrl + maj + i` et l'onglet network. Quelle activité réseau remarquez vous lors de la lecture de la video ?

Lors de la lecture vidéo il n'y a aucun mouvement réseau. Tout est constant.

## Adaptive bitrate streaming

Le streaming à débit adaptatif ajuste la qualité vidéo en fonction des conditions du réseau pour améliorer le streaming vidéo sur les réseaux HTTP. Ce processus rend la lecture aussi fluide que possible pour les spectateurs, quelque soient leur appareil, leur emplacement ou leur débit Internet.

A partir du fichier MP4/content.mp4, nous allons fabriquer des versions déclinées pour permettre un streaming à débit adaptatif.

_ffmpeg est disponible dans codespace._

Avec ffmpeg, séparez les essences audio et video dans des fichiers séparés avec `codec copy`.

`ffmpeg -i content.mp4 -codec copy -map 0:v video-uhd.mp4 -map 0:a:0 audio-fr.mp4 -map 0:a:1 audio-en.mp4`

16/ Générez la requete DASH permettant de streamer tous fichiers séparés dans le même stream. Analysez le manifest fabriqué.

`https://congenial-space-capybara-xg6rqww995636v65-3030.app.github.dev/dash/,audio-fr.mp4,audio-en.mp4,video-uhd.mp4,.urlset/manifest.mpd`

Le manifest est similaire a celui d'avant.

17/ Générez la requete HLS permettant de streamer tous fichiers séparés dans le même stream. Analysez le m3u fabriqué.

`https://congenial-space-capybara-xg6rqww995636v65-3030.app.github.dev/hls/,video-uhd.mp4,audio-en.mp4,audio-fr.mp4,.urlset/master.m3u8`

A partir de l'essence video, declinez des versions HD 1080, 720 et SD 540 en H264.

On modifie la résolution de la vidéo en 1920:1080 :

`ffmpeg -i content.mp4 -vf scale=1920:1080 -map 0:v video-HD1080.mp4`

En 720 :

`ffmpeg -i video-uhd.mp4 -vf scale= -map 0:v video-720.mp4`

En 540 :

``

Et en H264 :

``


18/ Générez la requete DASH permettant de streamer tous fichiers séparés dans le même stream. Analysez le manifest fabriqué.

19/ Générez la requete HLS permettant de streamer tous fichiers séparés dans le même stream. Analysez le m3u fabriqué.

20/ Analysez la structure de ce manifest https://dash.akamaized.net/akamai/bbb_30fps/bbb_30fps.mpd. 
 Combien contient t'il de déclinaisons video ? 
 Quelle est le codec et débit utilisés pour la video de plus haute qualité ? 
