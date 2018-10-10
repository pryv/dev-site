## greppin various

    Hello,
    
    Merci j’ai pu créer mon compte. Par contre y’a plusieurs soucis qui ressortent
    Quand je crée un stream depuis l’interface pour tester, j’obtiens l’erreur : Ahem... something went wrong. We've been automatically notified, but you can always help us improve your experience by posting an error report.
    L’onglet « Connect apps » est blanc et vide. Que puis-je faire ?
    Le « Request help » pointe sur rien
    Et quand je vais dans les settings et que je clique sur le bouton « Connect more apps » il se passe rien n’en plus.
    Peux-tu alors m’expliquer quelle est la procédure afin que je puisse utiliser votre application? Il faudrait des events personnalisés. Comment puis-je faire cela ? Faut-il que je définisse un « schéma » pour la validation de mes events ?
    Sinon j’avais encore une question technique…Est-ce possible de rendre la page d’inscription visible uniquement en « local » ?  L’idée serait que l’inscription ne soit pas disponible à n’importe qui.
    Merci d’avance de tes réponses.

Salut Christophe,



L'app dashboard (servie par un browser quand on ouvre http(s)://USERNAME.happy-kinntek.com) qu'on a livrée avec le produit n'a pour but que comme outil de debug, nous ne la maintenons plus depuis 2015. Elle a donc quelques incompatibilités avec le backend.

1. Le payload des appels POST que fait l'app contient des champs en trop. Par défaut Pryv IO ne les tolère plus, il est possible de les tolèrer en modifiant le champ updates.ignoreProtectedFields de la configuration de core dans pryv/core/conf/core.json. Il faut mettre la valeur de ce champ à true. Cela est déconseillé, mais des anciennes apps telles que le dashboard en ont besoin pour fonctionner.
2. L'onglet connect apps charge les apps qui sont intégrées avec la plateforme de demo pryv.me. Il est vide sur la plateforme happy-kinntek.com, car nous ne distribuons pas ces intégrations avec Pryv IO.
3. Similaire à 2.
4. Similaire à 2.



Pour utiliser Pryv IO, il faut commencer par définir la structure des données (arbre de streams + types des events) que tu souhaite utiliser.

Je te propose de relire la partie Events and Stream structure du document "Pryv IO patterns and examples" que j'ai envoyé à Elisa, tu le trouveras ci-joint.

Je te conseille de créer une liste aussi exhaustive que possible des types de données que tu souhaite stocker. Avec cela, tu pourras construire l'arbre de streams et event types de ton application. Je te propose de le revoir avec toi dès que tu as défini les données que tu souhaites stocker.

Pour ce qui est des events spécifiques à hAPPy ou ceux qui ne sont pas dans la liste des types par défaut (https://api.pryv.com/event-types), leur champ content n'est validé contre aucun schema. Je reviens vers toi avec plus d'informations sur comment définir son propre schéma ou étendre celui existant.

Dès que tu auras défini les données que tu souhaites stocker, je te propose de tester les calls API pour les créer. Pour développer contre l'API, je te propose d'utiliser un token de type app à cette URL: https://api.pryv.com/app-web-access/?pryv-reg=reg.happy-kinntek.com. Check l'option "master token", il crée un access à toutes les données Streams et Events.

Pour ce qui est de limiter l'inscription à la plateforme, il n'est actuellement pas possible de la limiter à une utilisation locale. 

Le call pour créer un utilisateur contient un secret qui est actuellement envoyé par défaut dans l'app, de création de user: https://sw.happy-kinntek.com/access/register.html. dans le payload de la requête POST, il y a un champ invitationtoken. Il est possible de l'enlever de la page par défaut et d'obliger l'utilisateur à le fournir.

On peut s'appeler si tu as besoin de plus d'informations.



## download your own data

how do you download all your data?

perki's guide: https://obpm-riva.github.io/app-web-auth2/obpmprod.ch/downloadProc/



## prerequisites for Pryv IO installation -> probably add to deployment design doc?

### covers: domain name, NS, SSL cert

Tu trouveras ci-attaché le document de deployment design. Dès la page 8, tu as la partie "system requirements" qui définit les spécifications machines.



En dehors de ça, il faut prévoir un nom de domaine pour la plateforme, par exemple [sempryv-hes.io](http://sempryv-hes.io/), auquel les apps s'adresseront. 

Le provider auprès duquel tu achètes le nom de domaine doit pouvoir modifier les name servers, le composant "Registry" contient un serveur DNS qui devra être définit comme name server.

Il faudra obtenir un certificat SSL wildcard pour le domaine: *.DOMAIN, eg. *.[sempryv-hes.io](http://sempryv-hes.io/)

### part2

Le service informatique de la HES est en train de regarder pour la faisabilité du wildcard DNS. Juste pour être sûr, il s'agit bien de mettre en place une entrée **NS** pour *.[pryv.hevs.ch](http://pryv.hevs.ch/) dans leur DNS ? Parce que eux l'ont compris pour l'instant comme étant que n'importe quel sous domaine de [pryv.hevs.ch](http://pryv.hevs.ch/) est **résolu** sur l'adresse IP de la VM registry, avec un CNAME A. Or, si j'ai bien compris, il s'agit de **rediriger** la requête DNS avec un NS.

C'est bien juste, pas que je leur demande quelque chose de faux :) ?

```

Tu l'as bien compris. La VM register est bien le name server du domaine *.pryv.hevs.ch. Les requêtes DNS pour ce domaine doivent être dirigées vers la VM register.
Je crois juste qu'il faut définir une entrée A pour la machine register car les entrées NS ne peuvent pas pointer directement vers une IP. 

Le but étant que le DNS qui tourne sur register serve toutes les requêtes DNS du domain pryv.hevs.ch.

Nous aurions donc dans le DNS hevs.ch:
pryv.hevs.ch TTL_SECONDS IN NS NAME_SERVER_HEVS_CH_1
pryv.hevs.ch TTL_SECONDS IN NS NAME_SERVER_HEVS_CH_2
...
pryv.hevs.ch TTL_SECONDS IN NS NAME_SERVER_HEVS_CH_N

ns-pryv-hevs-ch TTL_SECONDS IN A IP_ADDRESS_REGISTER_MACHINE

Je viens de me relire et ait constaté des erreurs concernant la zone DNS de hevs.ch (celle qu'ils doivent modifier). Il faut ajouter les entrées suivantes:

ns1-pryv-hevs-ch TTL_SECONDS IN A IP_ADRESS_REGISTER_MACHINE_1
ns2-pryv-hevs-ch TTL_SECONDS IN A IP_ADRESS_REGISTER_MACHINE_2

pryv.hevs.ch TTL_SECONDS IN NS ns1-pryv-hevs-ch
pryv.hevs.ch TTL_SECONDS IN NS ns2-pryv-hevs-ch

Si on ne déploie qu'une seule VM register, il faut que les 2 entrées A pointent vers la même IP, mais il faut toutefois avoir 2 entrées NS pointant vers des alias différents.
Cela ressemblerait donc à ça (la 2e entrée A pointe vers la même adresse IP que la 1ere):

ns1-pryv-hevs-ch TTL_SECONDS IN A IP_ADRESS_REGISTER_MACHINE_1
ns2-pryv-hevs-ch TTL_SECONDS IN A IP_ADRESS_REGISTER_MACHINE_1

pryv.hevs.ch TTL_SECONDS IN NS ns1-pryv-hevs-ch
pryv.hevs.ch TTL_SECONDS IN NS ns2-pryv-hevs-ch
```



## account per customer or per doctor/institution

J'ai discuté avec Pierre-Mikael au sujet de la question que tu m'avais posée concernant le cas où un chercheur/médecin doit collecter les données de plusieurs patients une seule fois.



Pour des questions de compliance, il faut utiliser un compte Pryv IO par patient. Stocker les patients sous un même compte ignore le méchanisme de consentement présent dans Pryv, le processus de création d'Access oAuth-like. S'il n'y a pas besoin du consentement du patient, il n'y a pas de raison d'utiliser Pryv IO pour stocker ces données.



## CORS related issues

there should be some stuff



## various issues: user account creation, access sharing, data model

Pryv-io-patterns.pdf



## docker login - seems to be a docker issue

\# docker login [pryvsa-docker-release.bintray.io](http://pryvsa-docker-release.bintray.io/)

error getting credentials - err: exit status 1, out: `Cannot autolaunch D-Bus without X11 $DISPLAY`

 

Pour info :

\# docker -v

Docker version 17.12.1-ce, build 7390fc6

\# docker-compose -v

docker-compose version 1.18.0, build 8dd22a9

> https://github.com/docker/docker-credential-helpers/issues/102



## how to customise registration, login, password reset pages

Forker le repository <https://github.com/pryv/app-web-auth2/>, créer un symlink nommé [happy-kinntek.com](http://happy-kinntek.com/) qui pointe vers le dossier v2/ comme tu peux le voir ici <https://github.com/pryv/app-web-auth2/tree/gh-pages> et modifier la config NGINX (pryv/nginx/conf/site.conf):

changer la ligne 62 de:

​      proxy_pass        <https://pryv.github.io/app-web-auth2/happy-kinntek.com/>;

en 

​      proxy_pass        [https://CUSTOMER-ACCOUNT.github.io/app-web-auth2/happy-kinntek.com/](https://customer-account.github.io/app-web-auth2/happy-kinntek.com/);



## registration call

J’ai une petite question. Je teste la création de compte en méthode post sur <https://reg.happy-kinntek.com/user>

Que dois-je mettre dans le paramètre « hosting » ? Car j’ai l’erreur suivante : INVALID_HOSTING

```
Le hosting que tu dois fournir est disponible sur https://reg.happy-kinntek.com/hostings

Par défaut, on le nomme "pilot". Ton payload aura le format suivant:

curl -i -X POST -H 'Content-Type: application/json' -d '{"hosting":"pilot","username": "testuser1","password": "testuser1", "email": "testuser1@bogus.tk","appid":"pryv-standalone","invitationtoken":"enjoy"}' "https://reg.happy-kinntek.com/user/"

Donc, édite les champs username, password et email à ta convenance.
```

## /auth/login call

### part1

J’essaie de faire un POST à <https://happy.happy-kinntek.com/auth/login>

Ce json :

{"username": "happy","password": "happy123", "appId": "happy-web-app-access"}

Et j’optiens ceci :

{

​    "error": {

​        "id": "invalid-credentials",

​        "message": "The app id (\"appId\") is either missing or not trusted."

​    },

​    "meta": {

​        "apiVersion": "1.2.18",

​        "serverTime": 1531830525.911

​    }

}

Tu arrives me dire ce qu’il y a de faux ?

```
Les méthodes flaggées "trusted apps only" font un check sur le header "origin" contre le champ auth:trustedApps de la config de core.
Il faut donc mettre un header origin de la forme https://quimporte.happy-kinntek.com:

curl -i -X POST -H 'Origin: https://quimporte.happy-kinntek.com' -H 'Content-Type: application/json' -d '{"username": "happy","password": "happy123", "appId": "happy-web-app-access"}' "https://happy.happy-kinntek.com/auth/login"
```

### part2

J’ai testé depuis CURL et en effet pas de soucis. Par contre au niveau du client Angular, la librairie http.js m’empêche de setter le header « Origin » car c’est considéré comme unsafe. Y’a-t-il possibilité de désactivé ce paramètre pour que j’aie pas de soucis pour le dév ?

```
Ce header ne peut être manipulé depuis le browser, c'est principalement pour éviter des attaques phishing que cette limitation existe.
Pour développer vers une API Pryv, tu peux soit ajouter "*@http://localhost*, *@https://localhost*" à la config de core, dans le champ auth:trustedApps, puis redémarrer le container core:
- docker stop CORE_CONTAINER_NAME
- ./run-pryv

Soit si tu souhaites tester le HTTPS, utiliser notre certificate SSL rec.la (https://yarnpkg.com/en/package/rec-la).
```

## should i use /auth/login on a mobile app

```
Dans une situation "normale" il ne faut pas directement faire de "login" depuis une app mobile. En effet le "token" obtenu est de type "personal" et équivaut a être "root" sur un compte utilisateur. De plus les token de type "personal" expirent  contrairement a ceux de type "app" qui conviennent aux Applications mobiles.

Il faut utiliser un token personal, de manière temporaire et lorsqu’on a besoin de manipuler d’autres types d’accès, comme par exemple donner son consentement pour un partage ou le retirer.  

Meme si  ce n’est pas recommandé, il est possible d'effectuer un "login" depuis une app mobile, il suffit de manipuler le header "Origin:" 

Pour les App, il faut suivre le process suivant: 
http://pryv.github.io/reference/#authentication
Avec un exemple ici:
http://pryv.github.io/getting-started/pryvme/#use-your-own-implementation


Dans ce process, on ouvre une fenêtre qui elle obtient un token personal et se charge d’effectuer la demande de création d’accès pour l’App.

Le code source de cette petite App Web se trouve https://github.com/pryv/app-web-auth2 et est fait pour être ajusté au besoin. 

Je suis à votre disposition si vous avez des questions. 

#####

J’attire votre attention, sur deux points essentiels.
- Les "personal token" doivent être utilisés de manière transitoire dans un environnement contrôlé 
- Les "app token" sont le résultat de l’expression du consentement de l’utilisateur et constituent un contrat 

Ce sont ces étapes qui permettent par la suite d’établir des relations 1-1 entre acteurs et de fournir un audit des interactions.
```

## why should i use auth request

```
La différence entre ce que vous désirez faire et ce qui se passe dans l’app web auth est le "flow" ci-dessous.

1- LOGIN http://pryv.github.io/reference-full/#login-user -> obtention d’un personal token
2- Verification de l’autorisation de l’APP http://pryv.github.io/reference-full/#check-app-authorization (en utilisant, le personal token)
3- Affichage du contenu du résultat de "check-app-access" à l’utilisateur et obtention de son accord ou non.
4- Creation d’un app access http://pryv.github.io/reference-full/#create-access (en utilisant le personal token)
5- Retour à l’application en fournissant un App token

Ce sont ces étapes qui permettent ensuite d’insérer un message lié aux "streams" partagés. Lors de cette étape, les actions de l’utilisateur sont gardées pour fournir un audit sur la phase de consentement. C’est pourquoi elle ne peut être "shuntée". 

Afin de vous éviter de développer ces étapes à chaque fois, elles sont préparées dans app-web-auth2 pour être adaptées à chaque plateforme.
(Dans un premier temps, cela peut se simplifier au simple changement de logo et de titre)

Si d’un premier abord, utiliser "LOGIN" et obtenir un personal token permettant de "tout faire" parais plus simple, vous pouvez le voir comme un accès "root" dans un environnement UNIX. Il permet aussi de tout faire et semble plus simple et rapide, mais la bonne pratique est de maximiser l’utilisation en "espace utilisateur".

Afin de vous accompagner dans et vous permettre de tirer le meilleur parti de Pryv.io vous pouvez compter sur moi pour vous fournir les informations nécessaires. Néanmoins et c’est le cas sur c’est le cas sur ce point de vous mettre en garde sur une utilisation dégradée du système.

Nous avons 3 options, à disposition pour obtenir un "App token"
1- utiliser un des SDK Pryv, javascript, ios ou android (java) 
     (je ne connais pas assez bien cordova)
2- implémenter vous-même ce qui se fait dans les SDK (ce qui est relativement simple)
     en suivant http://pryv.github.io/getting-started/pryvme/#use-your-own-implementation
     en 2 étapes (POST, OPEN WEB PAGE, LOOP)
3- en utilisant  LOGIN puis les autres étapes décrites au début de ce mail
 
Pour les deux premières, je vous ai donné les indications détaillées dans mes mails précédents.

Si vous désirez implémenter la solution 3, je rajouterai file://   dans les headers acceptés par Pryv.io  (ce sont ceux émis par Cordova) et vous enverrait l’ensemble détaillé du "flow" a reproduire.
```



## how to host web pages/apps under the same domain as the platform

```
En effet, nous avons plusieurs fois utilisé NGINX pour servir une app web en proxy.

Il faut cependant faire attention à une chose:
- Si vous définissez un sous-domaine pour cela, je vous conseille de choisir un nom de moins de 5 charactères, car sinon cela pourrait entrer en conflit avec un nom d'utilisateur.
- Sinon, utiliser un path sous le sous-domaine sw.happy-kinntek.com

####

J’appuie la recommandation d’Ilia, par défaut les installations de pryv.io utilise "sw.{domain}" pour le contenu "Static Web" 

####

Il faut ajouter ce bout de config dans pryv/nginx/conf/site.conf dans la partie server de static web:
location /MON_SITE/ {
    proxy_pass            URL_DE_MON_SITE_AVEC_PROTOCOLE;
    proxy_set_header      X-Real-IP $remote_addr;
    proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_buffering       off;
  }
Comme exemple, vous pouvez regarder comment est défini le proxy pour app-web-auth2:

# Static Web
server {
  listen               443;
  server_name          sw.DOMAIN;
  
  //...

  location /access/ {
      proxy_pass        https://pryv.github.io/app-web-auth2/DOMAIN/;
      proxy_set_header  X-Real-IP $remote_addr;
      proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
      proxy_buffering   off;
  }
}

```

## kinntek batch

Ma question pour vous serait la suivante: serait-il possible de générer un ID patient ou de le copier du dossier afin de créer par exemple dans un champ vide du dossier médical un lien sur le RMS de Kinntek ? Ainsi ça ne prendrait que 2 secondes au médecin pour créer un ID et donc pour vous un nouvel utilisateur (droits d'accès, id, mot de passe, infos etc) pour chaque patient dans le RMS et un lien web qui permettrait de consulter le dossier Kinntek du patient et d'y entrer des infos en temps réel. De plus dès qu'un  lien serait créé pour un nouveau patient le physio ou ergo traitant pourrait également consulter le RMS et y partager des infos avec le médecin et/ou le patient. Finalement comme le médecin a très souvent le dossier médical informatisé sous les yeux il pourrait accéder en un click sur le RMS pour consulter le rapport de progression ou commencer à prendre des mesures automatisées.

```
Tout d’abord, oui, il est possible de créer un utilisateur de façon automatique depuis un autre applicatif. L’implémentation est a discuter avec le concepteur de l’applicatif. (exemple mediway) Nous pouvons aussi partager avec toi un démonstrateur que tu pourras customiser. 

Pour le deuxième point, si j’ai bien compris, tu nous demandes comment permettre un accès en 1 clic sur le RMS de Kinntek par un médecin ou physio depuis un logiciel de type Mediway?

Sur Pryv cela se matérialise par le fait de connaitre le "UserID" et d’avoir un "token" qui permet d’accéder à la donnée. Il faut aussi une application capable d’utiliser ces deux éléments pour faire une requête et obtenir les données.

La technique d’intégration avec des outils extérieure est bien maitrisée. Cela permet d’insérer ou donner accès aux données "en temps" réel au  moyen d’un lien ou d’une interface.

Il faut noter que les droits et l’audit sur les données se fait en fonction du "token". C à d que dans un cas idéal, il existe un token par relation "patient <-> professionnel". Cela permet de contrôler de façon "fine" les accès en permettant de les donner ou le retirer par dossier patient pour chaque professionnel individuellement. 

Les "token" peuvent être créés de 2 façons (obtention des droits d’accès)
1. Lorsque le patient donne sont consentement à travers une interface graphique ou une app
2. Lorsqu’un système automatique génère un "token" selon des règles. Par exemple en vérifiant que le docteur a bien les droits nécessaires.

Nous avons quelques démos pour montrer des exemples de ces deux variantes. Certaines pouvant même être réutilisées et complétées. 

Pour te proposer des solutions plus précises, j’aurai besoin de bien comprendre le "flow" qui permet à un docteur d’obtenir le droit d’accès. Est-ce que l’on pourrait organiser un petit workshop sur le sujet?
```



## how is Pryv IO installed

1. Create a suitable configuration on the machine. This is a series of folders and configuration files. 
2. Launch the chosen Pryv release by running a docker-compose file provided by Pryv. This will install several docker images and run them in concert.

## on what cloud offerings can Pryv IO be installed

Pryv can be installed on any cloud offering that runs at least Docker 1.12.6. The real consideration here is compliance and the security of the data storage. 

## PrYv requires SSL certificates. Do they need to be signed by publicly trusted CA or can we use Swiss Re's internal PKI (so kind of self-signed certificates)?

All devices that interact with the Pryv installation must be able to verify the certificates and thus see/trust the CA, even if it is internal. In this project, that would involve: the mobile application, all machines that perform analytics and display of the data collected, ... 

So yes with a caveat. 

## SSL certificates are mentioned to be wildcard ones. Are we able to define all the subdomains beforehand and rather create SSL with SANs?

Pryv uses a subdomain per user account that is created. So no, you cannot use SAN certificates unless you're able to know the possible user base ahead of time.

## what are the security measures you took in order to harden NodeJS?

Security is part of our development process, since one of our primary concerns is user privacy. That said, some of the measures we've implemented: 

- No nodejs processes are exposed to WAN directly; instead we proxy through nginx. 
- Development is driven by writing tests. 
- All code is reviewed before becoming part of a release candidate. 
- We have performed external security audits of our product. 

@Ilia: Maybe we should point to some document here? 

## What constraints should be considered when choosing a host

where (in what countries legislation) the data is stored. should be HIPPA/EU DPD compliant…

## How do you address encryption of the data at rest? As medical records will be stored in the MongoDB, are you using DB encryption or some other application specific encryption?

Pryv offers three options here:

- Application-level end-to-end encryption: The application(s) that access Pryv encrypt the data that is stored in Pryv on creation and decrypt it after reading it back. Pryv provides a data type for this usage. See: <http://api.pryv.com/event-types/#encrypted>
- MongoDB encryption: We can provide you with a recent release of MongoDB that will allow you to set up EAR: <https://docs.mongodb.com/manual/core/security-encryption-at-rest/>
- Disk encryption: Linux has a solid story of disk encryption. If stored on such a disk, Pryv data is encrypted at rest as well.

My take on this is that the last option will probably the easiest to implement for you. It offers good protection against disks being stolen from the datacenter, while not increasing overall system complexity by much.



## how to debug issues

\- Show running containers: "docker ps", if the container exited, you can use "docker ps -a". This will allow to find the name of the container.

\- Display logs for a container using "docker logs CONTAINER_NAME", you can use the "-f" option which works similarly as for "tail", displaying the newly written logs. It might be useful to keep a screen or tmux process with logs of each container running in different tabs.



The issue is most probably with NGINX, which crashes if it cannot find the SSL certificate files. You can see this if its container doesn't appear when running "docker ps" and shows the file path related error when running "docker logs NGINX_CONTAINER_NAME".

If your configuration files (folder "core" and files "core.yml", "run-core" and "restart-core") have been unarchived into /var/pryv/[biovotion.swissre.com](http://biovotion.swissre.com/), then $PRYV_CONF_ROOT should point there.



We can look into this together if you wish, I will be available tomorrow from 13:00 until 18:00 or Friday between 10:00 and 18:00.



Regarding logs, they are enabled by default, displaying REST API call information such as route, HTTP response status, and request processing time.

For MongoDB, we display the logs generated by the mongod process.

## what access to use when and how to obtain them

### User creation

Users repositories can be either generated manually by the user or a supervisor through a form such as sw.biovotion.swissre.com/access/register.html, or dynamically by sending data into a data bridge such as the one we are currently working.
We have a use case with a customer who creates its user repositories by sending data from a device with specific credentials, if those are new the user repository is created and the credentials can be transmitted to the user through another communication channel.

### Accesses

Overview of Accesses: http://api.pryv.com/concepts/#accesses

Please note that these access generation can be extended with additional authentication steps such as SMS, email, LDAP, ... 

#### Personnal access:

This is the 1st party authentication with a direct call containing the username/password pair.

- How to obtain: https://api.pryv.com/reference-full/#login-user
- Scope: full: streams, events, accesses, followedSlices (https://api.pryv.com/reference-full/#followed-slices), account, profile
- Accessible by: authorized apps list provided in the configuration files of core

#### Use cases:

- Account supervisor uses this type of token to manage a user's account or else.
- User logs into 1st party app to manage his data and account details

#### App access 

This is used by 3rd party apps to obtain a token with specific requirements. This is implemented with the OAuth2-three-legged-style process, but classic OAuth2 (2-legged style) will be available in the short term.

- How to obtain: https://api.pryv.com/reference-full/#authorizing-your-app
- Detailed flow description: https://api.pryv.com/app-access/
- Scope: to define in the "requestedPermissions" object (http://pryv.github.io/reference-full/#auth-request)
- Accessible by: authorized app-ids in register's configuration file.

#### Use cases

- Research institute makes a request to access a subset of data, provides an URL to its users where they enter username/password which provides them with an access token for the requested subset of data.
- Users wish to plug in a new device or web service to their repository. They enter their credentials which gives the 3P device or service right to contribute data to the user's repository
- Most used access token for developers: https://api.pryv.com/app-web-access/?pryv-reg=reg.biovotion.swissre.com

#### Shared access

Access generated by personal or app tokens (limited to this token's scope) by API call. Transferred to the recipient by the channel of his choice.

- How to obtain: http://api.pryv.com/reference/#create-access
- When used: key generated with personal or app access, provided to recipient over different communication channel depending on use case.
- Scope: defined by "permissions" array during creation/update: http://pryv.github.io/reference-full/#data-structure-access
- Accessible by: personal and app tokens: dynamic

#### Use cases:

- User wishes to share his data with an external person
- User wishes to include his data in someone else's repository using the "Follwed slices" mechanism

#### Followed slices:

This is a way to save shared accessses from other repositories into a user's account.

- Structure: http://pryv.github.io/reference-full/#data-structure-followed-slice
- API methods: http://pryv.github.io/reference-full/#followed-slices



## various by Karlen

From what I understand is pryv data mainly organized by user. How are users grouped to specific studies or organizations? How can researchers and clinicians access other peoples data, i.e study participants?

Finally do you have a test setup where this could be tested?

```
Pryv IO platforms are user centric, each account accessible through the https://USERNAME.DOMAIN (eg.: https://iliakebets.pryv.me) URL endpoint, the username doesn't have to be identifying. These can be stored in different locations depending on the number of core machines that are deployed in the platform, core machines are the ones actually storing the data.

Access to people's data is done in multiple ways. When authentifying with username/email & password on a trusted app (the owner of the platform defines this), using the obtained token the user can create accesses to any subset of his/her data depending on a streams/tags matrix.
It is possible to develop "3rd party" apps whose authentification process is oAuth-like, which prompts the user with the request to give access to the said app for the requested streams. The obtained access token can be used to create accesses whose scope are subsets of itself.
For either way, to give access to people's data to researchers and clinicians, the created tokens need to be stored by a service accessible to them.

Accesses definition

The information regarding a user's study or organization belonging can be accessible through such a service as well, with each user's organization(s) & study(ies) stored either there or on the user's Pryv IO account.

You can try out Pryv IO, using our demo platform pryv.me: https://pryv.com/pryvlab/
```



### Yband

```
wir haben die Entwicklung unserer Algorithmen Applikation bereits gestartet und haben ein paar Fragen in Zusammenhang mit pryv.io. Wir hoffen du hast ein paar best practices für uns. Gerne können wir auch skypen, wenn es per Mail zu kompliziert wird.

Das Szenario bei uns sieht ungefähr so aus:
Die Mobil-Applikation registriert einen neuen Nutzer (name, password, email). Der Nutzer würde direkt etwas bestätigen, dass seine Daten auf dem Server verarbeitet werden dürfen (damit gibt er rechtlich dem AlgoServer das OK). Im UI sollten keine weiteren popups über access requests kommen.

Wie bekommt der AlgoServer nun mit, welchen neuen Stream er abonnieren muss?
Und wie kommt der AlgoServer an das entsprechende Token?
```

see answer in Kaspar's mail "Re: Pryv.io Fragen zu authorisierung der Algo-application" from October 3rd 2018

### Optional email

Hide field, use username@PryvDomain

### can't read NGINX

```
En effet "docker ps" n'affiche pas le container nginx, ce qui implique qu'il n'est pas en marche.
Il est possible de regarder ses logs de la manière suivante:
"docker ps -a" affiche tous les containers sur la machine, cela permet de récupérer le CONTAINER ID du nginx, qui devrait s'appeler pryvio_nginx_1.
Puis il est possible d'afficher ses logs avec "docker logs pryvio_nginx_1".
```

2018/02/07 14:13:08 [emerg] 1#1: open() "/app/conf/nginx.conf" failed (13: Permission denied) in /etc/nginx/nginx.conf:5
nginx: [emerg] open() "/app/conf/nginx.conf" failed (13: Permission denied) in /etc/nginx/nginx.conf:5

> Un quickfix serait de changer ces droits avec "chown -R 9999:9999 pryv/nginx/log". Le user avec l'id 9999 est celui qu'on utilise pour lancer les process dans nos containers.

### utilisation de certificat self-signed

doesn't work. Buy it (~100.-/year) or use let's encrypt - automatic renewal coming soon

### Problèmes avec attachment

- formattage avec client JMeter, faire le call avec `curl -v` qui imprime le contenu de la requête.

### Reset data

Avant de commencer le test de charge, est-ce que vous avez une procédure pour revenir à l'état initial, au cas où il y aurait un problème durant le test et que nous devrions recommencer ?

```
pour réinitialiser les données sur la plateforme, il suffit d'arrêter les services et effacer les bases de données, elles seront initialisées au redémarrage des services.
```

Sur la machine reg-master (register01):

- `cd /var/pryv`

- `./stop-containers`
- `rm -rf /var/pryv/reg-master/redis/data/*`
- `./run-reg-master`

Sur la machine core01:

- `cd /var/pryv`

- `./stop-containers`
- `rm -rf /var/pryv/core-v1.3/core/data/*`
- `rm -rf /var/pryv/core-v1.3/mongodb/data/*`
- `./run-core-v1.3`

Sur la machine queue01:

- `cd /var/pryv`

- `./stop-containers`
- `rm -rf /var/pryv/hook/api/data/*`
- `./run-hook`

### User creation bug

User can't be created although username.DOMAIN replies name not resolved.

-> use other username

### Utilisateurs existants

https://reg.pryv-n4a.ch/admin/users?auth=REG_ADMIN_KEY_1

