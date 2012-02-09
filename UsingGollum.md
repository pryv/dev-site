# Utiliser Gollum en local pour éditer la doc de l'API

## Pré-requis:

* Ruby v1.8.7+ (inclus avec OS X)
* Git (au cas où voir p.ex. http://guides.beanstalkapp.com/version-control/git-on-mac.html)

## Configuration

1. Installer Gollum: `[sudo] gem install gollum`
2. Corriger la version du gem RedCarpet (pour l'heure la dernière a un problème avec Gollum):
	1. `[sudo] gem uninstall redcarpet`
	2. `[sudo] gem install redcarpet --version=1.17.2`
3. Installer la dernière version du gem Grit (celle installée par défaut a un bug):
	1. `[sudo] gem uninstall grits`
	2. `ftp sgoumaz@s1.simpledata.ch:/home/wactiv/INSTALL/mojombo-grit-3fc864f/grit-2.4.1.gem`
	3. `[sudo] gem install grit-2.4.1.gem`
3. Cloner le repo Git de la doc dans un dossier ad-hoc (ici "wiki"): `git clone ssh://sgoumaz@s1.simpledata.ch/home/wactiv/git_repos/wiki.git wiki`
4. Lancer le front-end Gollum depuis le repo: `gollum [--port <port>]`

## Note d'utilisation

Le front-end Gollum se charge de l'édition des fichiers Markdown et des commits Git, mais les push Git sont évidemment à faire lorsque nécessaire.

## Pour référence

* Utilisation de Git: http://www-cs-students.stanford.edu/~blynn/gitmagic/intl/fr/index.html
* Syntaxe Markdown: http://daringfireball.net/projects/markdown/syntax