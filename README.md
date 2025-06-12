-   References:
    -   [Bescherelle Conjugaison | Le conjugueur Bescherelle, la référence en conjugai&#x2026;](https://conjugaison.bescherelle.com)
    -   [Liste de tous les verbes français et leur conjugaison - digiSchool](https://www.digischool.fr/education/conjugaison/verbes)
    -   [GitHub - junegunn/fzf: :cherry<sub>blossom</sub>: A command-line fuzzy finder](https://github.com/junegunn/fzf)
    -   <man:fzf>
    -   <man:parallel>


# Bescherelle Org

Le site du [Bescherelle](https://conjugaison.bescherelle.com) nous offre les tables de conjugaisons en
ligne, mais le rendu dans EWW (Emacs) pour configuration ne semblait
pas coopérer avec le javascript de leur plateforme.  Cependant, la
richesse sémantique de leur XML rend la création d'une version locale
adaptée à mes besoins simplistes relativement facile.


## Pourquoi?

J'y ai vu une belle occasion de démontrer l'efficacité et la
versatilité d'un simple script POSIX, extensible aux outils standard de ligne de commande (grep, sed, awk, fzf, etc.).
D'une part, pour mettre en pratique des concepts récemment lus dans
les pages de manuel, d'autre part parce que j'abhore les applications web qui compliquent, au point d'y rendre inutilisable, la fonction première de leur application.


## Le script - Version 0.2.1

Mes besoins, vis-à-vis d'un Bescherelle, se résument bien souvent
 simplement à trouver la conjugaison d'un verbe donné. Conséquemment,
 le script fourni ci-dessous, sous sa plus simple forme se résume à:


### Usage le plus simple

```
   $0  <verbe>
```

```
   conjuge être
```

``` org

* INDICATIF

** Présent

je suis
tu es
il (elle) est
nous sommes
vous êtes
ils (elles) sont

** Imparfait

j’étais
tu étais
il (elle) était
nous étions
vous étiez
ils (elles) étaient

** Passé simple

je fus
tu fus
il (elle) fut
nous fûmes
vous fûtes
ils (elles) furent

** Futur simple

je serai
tu seras
il (elle) sera
nous serons
vous serez
ils (elles) seront

* CONDITIONNEL

** Présent

je serais
tu serais
il (elle) serait
nous serions
vous seriez
ils (elles) seraient

* SUBJONCTIF

** Présent

que je sois
que tu sois
qu’il (elle) soit
que nous soyons
que vous soyez
qu’ils (elles) soient

** Imparfait

que je fusse
que tu fusses
qu’il (elle) fût
que nous fussions
que vous fussiez
qu’ils (elles) fussent

* IMPÉRATIF

** Présent

sois
soyons
soyez

* INFINITIF

** Présent

être

* PARTICIPE

** Présent

étant

* INDICATIF

** Passé composé

j’ai été
tu as été
il (elle) a été
nous avons été
vous avez été
ils (elles) ont été

** Plus-que-parfait

j’avais été
tu avais été
il (elle) avait été
nous avions été
vous aviez été
ils (elles) avaient été

** Passé antérieur

j’eus été
tu eus été
il (elle) eut été
nous eûmes été
vous eûtes été
ils (elles) eurent été

** Futur antérieur

j’aurai été
tu auras été
il (elle) aura été
nous aurons été
vous aurez été
ils (elles) auront été

* CONDITIONNEL

** Passé

j’aurais été
tu aurais été
il (elle) aurait été
nous aurions été
vous auriez été
ils (elles) auraient été

* SUBJONCTIF

** Passé

que j’aie été
que tu aies été
qu’il (elle) ait été
que nous ayons été
que vous ayez été
qu’ils (elles) aient été

** Plus-que-parfait

que j’eusse été
que tu eusses été
qu’il (elle) eût été
que nous eussions été
que vous eussiez été
qu’ils (elles) eussent été

* IMPÉRATIF

** Passé

ayons été
ayez été

* INFINITIF

** Passé

avoir été

* PARTICIPE

** Passé

ayant été
été (invar.)

```

## Acquérir une liste de tous les verbes

Une méthode ou une autre, en autant que les verbes y sont. Quoiqu'il
en soit, à défault d'une méthode plus optimale (et après quelques
tentatives ridicules de Mr.GPT), j'ai opté pour un copié-collé de la
[Liste de tous les verbes français et leur conjugaison](https://www.digischool.fr/education/conjugaison/verbes)
dans un tampon Emacs sauvegardé sous le nom très recherché de `verbes`
Ensuite, une petite ligne de `sed` pour faire le ménage:

    cat ./verbes | grep -ivE "Verbes en " | sed -e 's/ - /\n/g' -e 's/^ *- *//; s/ *- *$//; s/^ *//; s/ *$//' | sed "/^$/d" | sed 's/[àáâä]/a/gI; s/[ÀÁÂÄ]/A/gI;s/[èéêë]/e/gI;s/[ÈÉÊË]/E/gI;s/[ìíîï]/i/gI;s/[ÌÍÎÏ]/I/gI;s/[òóôö]/o/gI;s/[ÒÓÔÖ]/O/gI;s/[ùúûü]/u/gI;s/[ÙÚÛÜ]/U/gI;s/[ç]/c/gI;s/[Ç]/C/gI;s/[œ]/oe/gI;s/[Œ]/OE/gI;' | tee ./verbes-na | wc -l ; head ./verbes-na ; tail ./verbes-na ;

    1976
    abaisser
    abandonner
    abasourdir
    abattre
    abetir
    abhorrer
    abimer
    abolir
    abonder
    abonner
    voleter
    vomir
    voter
    vouer
    vouloir
    vouter
    vouvoyer
    voyager
    zapper
    zezayer

cf. [verbes](./verbes)


## Générer les verbes

`GNU Parallel` optimise l'exécution des processus par parallélisation.
Il m'a semblé être le candidat idéal pour générer les 1976 verbes
précedemment acquis.

    (defvar org-babel-async-content nil)
    (use-package ob-async
      :ensure t
      :after org
      :config
      (require 'ob-async))

    ulimit -n ; ulimit -Hn

    ulimit -n 262144
    parallel -j0 --joblog ./conjuge.log conjuge -V {} -d ~/Templates/org-bescherelle/bescherelle -v :::: ~/Templates/org-bescherelle/verbes

    head ~/Templates/org-bescherelle/conjuge.log ; tail ~/Templates/org-bescherelle/conjuge.log ;
