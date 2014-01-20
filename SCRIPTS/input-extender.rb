=begin
  Input Ultimate 2.3 by Zeus81
  Free for non-commercial use
  
  Pour simplement régler les touches sans vouloir en savoir plus, aller ligne 1471.
  
REFERENCES
  Input :
    Constantes :
      REPEAT : Permet de régler la façon dont la méthode repeat? fonctionne, ligne 1417.
      PLAYERS_MAX : Le nombre de joueurs gérés par le script, à configurer ligne 1424.
      KEYS_MAX : Définit une limite pour optimiser la mémoire, ligne 1425.
      Players : La liste des contrôles joueurs.
      Gamepads : La liste des manettes détectées.
    Méthodes :
      Input.update : A appeler une fois par frame pour tout mettre à jour.
      Input.refresh : Détecte les manettes connectées au PC.
      Input[i] : Retourne le contrôle du joueur i (commence à 0).
                 Le premier Player est fusionné avec le module Input
                 Faire Input.trigger?(k) équivaut à faire Input[0].trigger?(k)
      
  Device :
      Base commune à Player, Gamepad, Keyboard et Mouse
    Propriétés :
      enabled : Permet d'activer ou désactiver un contrôle.
                Par exemple si on fait un jeu multijoueur mais qu'on joue en solo
                on peut désactiver les autres joueurs pour optimiser les perfs.
                Par défaut tous les contrôles sont activés sauf la souris et les
                manettes non utilisées.
      ntrigger_max : Option de la fonction ntrigger? décrite plus en dessous.
                     C'est ce qui est utilisé pour les doubles clics de la souris.
                     Par défaut cette option est désactivée (égale à 0) sauf
                     pour la souris où elle est égale à 3 (pour les triples clic).
                     Cette limite sert à faire boucler les clics, par exemple là
                     si je fais 5 clics ça sera considéré comme un triple clic
                     suivi d'un double clic.
      ntrigger_time : Temps en nombre de frames pouvant s'écouler entre deux
                      clics pour être considérés comme une série de clics.
                      Si on met 0 ce temps sera le même que dans Windows. (Défaut)
    Méthodes :
      press?(*a) : Retourne true si la touche est pressée sinon false.
                   La fonction peut être utilisée de plusieurs façons :
                    Input.press?(Input::C)
                    Input.press?(:C)
                    Input.press?('C')
                    Input.press?(13)
                    Input::C.press?
                   Tout ceci revient au même, cela dit en terme de performance
                    Input::C.press? est deux fois plus rapide que les autres.
                   On peut aussi mettre plusieurs touches à la fois :
                    Input.press?(:A, :B, :C) = :A or :B or :C
                   En regroupant des touches dans un tableaux on inverse or/and :
                    Input.press?([:A, :B, :C]) = :A and :B and :C
                   On peut mélanger les deux :
                    Input.press?(:A, [:B, :C]) = :A or (:B and :C)
                   Et mettre plusieurs niveaux de tableaux :
                    Input.press?([:A, [:B, :C]]) = :A and (:B or :C)
                   En plus des tableaux on peut aussi utiliser des Range :
                    Input.press?(:A..:C) = Input.press?([:A, :B, :C])
                    Input.press?(*:A..:C) = Input.press?(:A, :B, :C)
                   Oui je sais, tout ça ne servira absolument à rien.
      trigger?(*a) : Retourne true si la touche vient d'être pressée.
                     Pour les arguments fonctionne comme press?
      release?(*a) : Retourne true si la touche vient d'être relâchée.
                     Pour les arguments fonctionne comme press?
      repeat?(*a) : Retourne true ou false selon le schéma de REPEAT
                    Pour les arguments fonctionne comme press?
      ntrigger?(n,*a) : Retourne true si la touche vient d'être pressée comme
                        trigger? mais en comptant le nombre de fois.
                        Mouse.ntrigger?(2, :Left) retournera true uniquement si
                        on fait un double clic, si ensuite on fait un troisième
                        clic seul Mouse.ntrigger?(3, :Left) retournera true.
                        n doit être inférieur ou égal à ntrigger_max
                        Pour les arguments fonctionne comme press?
      count(k) : Retourne le temps en nombre de frames depuis quand la touche k
                 est pressée, 0 si elle n'est pas pressée.
                 Comme pour le reste k peut être égal à Input::C, :C, 'C', 13.
                 Et on peut aussi écrire Input::C.count
      key(i) : Retourne la touche Key ayant pour id i.
               Ici aussi i peut être un symbole, string, nombre (:C, 'C', 13).
      capture_key(*exclude) : Si jamais vous faites un menu pour configurer les
                              touches utilisez cette fonction pour attendre
                              que le joueur appuie comme ceci :
                                until key = Keyboard.capture_key || Input.gamepad.capture_key
                                  Graphics.update
                                  Input.update
                                end
                              key sera un Keyboard_Key ou Gamepad_Key, vous pouvez
                              bien entendu les séparer si vous ne voulez que l'un
                              ou l'autre.
                              Protip, avant d'appeler cette méthode utilisez un
                              release? plutôt qu'un trigger? pour éviter que la
                              touche soit capturée. De même il vaut mieux
                              ensuite attendre que la touche capturée soit
                              relâchée avant de continuer, ce qui donne :
                                if Input::C.release?
                                  until key = Keyboard.capture_key || Input.gamepad.capture_key
                                    Graphics.update
                                    Input.update
                                  end
                                  while key and key.push?
                                    Graphics.update
                                    Input.update
                                  end
                                end
                              Vous pouvez aussi mettre en arguments des touches
                              que vous désirez ignorer.
      
  Player < Device :
      Pour les jeux multijoueur on y accède en utilisant Input[i]
      Pour simplifier les jeux solo le premier Player est fusionné avec Input :
        Input.trigger?(*a) = Input[0].trigger?(*a)
    Constantes :
      A, B, C, etc... : Les touches du jeu virtuelles (à ne pas confondre avec
                        les touches du clavier), à configurer ligne 1433.
                        Ce ne sont pas des nombres mais des objets de type Player_Key
                        ce qui permet de faire des chose comme : Input::C.press?
                        Pour les jeux multijoueurs on peut aussi faire :
                          Input::C[i].press? où i est l'id du joueur.
    Propriétés :
      id : Id du joueur. (lecture seule)
      gamepad_id : Id du gamepad, par défaut égal à l'id du joueur.
                   Pour que le joueur n'ai pas de gamepad, mettre la valeur -1.
      gamepad : Contrôleur Gamepad associé au joueur. (lecture seule)
    Méthodes :
      setup(h) : Configure la relation entre les touches virtuelles du jeu et
                 les touches réelles des clavier/manettes.
                 Nécessite un format particulier, voir ligne 1471.
      dir4() : Retourne la direction pressée, format 4 directions.
      dir8() : Retourne la direction pressée, format 8 directions.
      dir360() : Retourne la direction pressée sous forme d'un angle et une
                 pression (pourcentage entre 0 et 1).
                  angle, power = Input.dir360
                 A la base créé pour les joysticks analogiques comme la fonction
                 analog? celle-ci retourne des valeurs aux extrémités si utilisé
                 sans manette analogique.
      dirXY() : Retourne la direction pressée sous forme de deux axes entre -1 et 1.
                  x, y = Input.dirXY
                Si le stick est orienté vers la gauche x = -1, vers la droite x = 1.
                Si le stick est orienté vers le bas y = -1, vers le haut y = 1.
                Par contre attention, la portée d'un joystick n'est pas carrée
                (ni ronde d'ailleurs, c'est plus un carré aux bords arrondis)
                de ce fait si on oriente le stick vers bas gauche par exemple
                on aura pas x, y = -1, -1 mais plus x, y = -0.8, -0.8
      
  Gamepad < Device :
      Il y a trois types de gamepad, Multimedia_Gamepad pour les manettes
      standard, XBox360_Gamepad spécialement pour les manettes Xbox et
      No_Gamepad quand on a aucune manette, toutes ont les mêmes fonctions.
      La classe No_Gamepad est là juste pour qu'on ait pas à se soucier de savoir
      si un pad est branché ou pas avant d'utiliser ses fonctions.
      Par exemple si on veut utiliser la fonction vibrate! on l'utilise, si une
      manette xbox est branchée ça vibrera sinon ça fera rien, pas d'erreur.
    Constantes :
      AXIS_PUSH : Les joysticks analogiques ont une valeur de pression entre
                  0 et 32768 par direction.
                  Cette variable contient la valeur au delà de laquelle ces
                  touches seront considérés comme pressés si on utilise la
                  fonction press? par exemple.
                  Par défaut 16384 (soit 50%), à configurer ligne 679.
      AXIS_DEADZONE : La position de repos d'un joystick analogique (au milieu)
                      n'est pas très stable, par conséquent si on utilise la
                      fonction analog? on obtient jamais 0, une zone morte est
                      établie au centre du joystick pour pallier à ça.
                      Par défaut 6666 (soit 10%), à configurer ligne 679.
      TRIGGER_PUSH : Les gâchettes LT et RT des manettes XBox360 ont une valeur
                     de pression entre 0 et 255.
                     Cette variable contient la valeur au delà de laquelle ces
                     touches seront considérés comme pressés si on utilise la
                     fonction press? par exemple.
                     Par défaut 0, à configurer ligne 679.
      Button1, Button2, etc.. : Les touches standard des manettes, liste ligne 681.
                                On les utilise uniquement lors du setup des Player.
                                  Gamepad::Button1
      LB, RB, etc... : Les touches des manettes xbox, liste ligne 689.
                       On les utilise uniquement lors du setup des Player.
                        XBox360_Gamepad::A
                       Ça revient au même que d'utiliser les touches standard
                       c'est juste l'écriture qui change, utilisez celle que
                       vous préférez.
      
    Propriétés :
      unplugged : Retourne true si la manette est débranchée. (lecture seule)
                  Ça peut être utilisé pour détecter une perte de manette soudaine.
                  Si on a pas de manette depuis le départ ce n'est pas considéré
                  comme une manette débranchée mais comme une manette de type
                  No_Gamepad avec unplugged = false
      vibration : Permet d'activer ou pas les vibrations.
    Méthodes :
      analog?(*a) : Retourne un pourcentage entre 0 et 1 si la touche pressée est
                    analogique (sticks des manettes et gâchettes LT RT pour les
                    pads xbox) sinon retourne 0 ou 1.
                    Cette fonction est là pour les manettes cela dit on écrira
                    jamais : Input.gamepad.analog?(XBox360_Gamepad::AxisLY_0)
                    Mais plutôt : Input.analog?(Input::DOWN)
                    Les touches de la manette étant liées au setup du Player.
                    Pour les arguments fonctionne comme press?.
      vibrate!(id, speed, fade_in, duration, fade_out) :
                  Fait vibrer la manette, ne fait rien si les vibrations
                  sont désactivées ou que ce n'est pas une manette XBox360.
                  id = 0 ou 1, pour les moteurs gauche ou droite.
                       Ou sinon 2 pour les deux en même temps.
                  speed = pourcentage entre 0 et 1
                  fade_in = durée de la transition entre le niveau de vibration
                            en cours et celui désiré.
                  duration = durée de la vibration.
                  fade_out = durée de la transition vers 0 à la fin du temps.
                  Exemple :
                    Input.gamepad.vibrate!(2, 0.5, 50, 200, 50)
                  Les deux moteurs vibreront à 50% sur en tout 300 frames.
                  
  Keyboard < Device :
      Attention normalement vous ne devriez jamais utiliser le clavier directement.
      Pour créer des jeux il est préférable d'utiliser des touches virtuelles
      qui peuvent correspondre à plusieurs touches du clavier + des manettes en
      même temps et éventuellement être configurable par le joueur,
      donc utilisation directe du clavier à éviter.
      Pour ce qui est de la saisie de texte la classe Text_Entry_Box est là.
    Constantes :
      Escape, Enter, etc... : Les touches du clavier, voir la liste ligne 862.
                              Ce ne sont pas des nombres mais des objets de type
                              Keyboard_Key ce qui permet de faire des chose comme :
                                Keyboard::Enter.push?
    Méthodes :
      setup(*a) : Si toutefois vous étiez amené pour une raison ou une autre à
                  devoir malgré tout utiliser directement le clavier, il faudra
                  d'abord lui dire quelles touches mettre à jour.
                  Par défaut aucune n'est mise à jour parce que ça prendrait du
                  temps pour rien.
                  Comme pour le reste plusieurs écritures sont supportées :
                    Keyboard.setup(Keyboard::Enter, :Escape, 'A'..'Z', 1)
                  Pour désactiver la mise à jour des touches :
                    Keyboard.setup()
                  A chaque setup toutes les touches envoyées remplacent les
                  anciennes, elles ne s'ajoutent pas.
                  Cependant vous n'avez besoin de faire ça que si vous désirez
                  utiliser les fonctions press?, trigger?, release?, repeat?,
                  ntrigger? et count, les fonctions push?, toggle?, push!, release!
                  et toggle! si dessous peuvent être utilisées sur n'importe
                  quelle touche en permanence.
      push?(*a) : Fonctionne exactement comme la fonction press? mais en regardant
                  directement l'état du matériel donc un peu plus lentement.
                  A n'utiliser que dans le cas cité précédemment, si vous voulez
                  l'état press d'une touche du clavier sans vouloir passer par
                  le setup, sinon il est préférable d'utiliser press?
                  Vous pouvez aussi l'utiliser sur les constantes Key du clavier :
                    Keyboard::Escape.push?
      toggle?(*a) : Retourne true si la touche est verrouillée sinon false.
                    Le vérouillage est ce qui est utilisé pour les touches
                    Verr. Num, Verr. Maj et Verr. Défil pour savoir si elles
                    sont sur On ou Off, mais vous pouvez l'utiliser sur n'importe
                    quelle touche en fait.
                    Comme push? cette fonction regarde directement l'état du
                    matériel et peut être utilisée sans setup.
                    Vous pouvez aussi l'utiliser sur les constantes Key du clavier :
                      Keyboard::CapsLock.toggle?
                    Pour les arguments fonctionne comme press?
      push!(*a) : Appuie sur les touches du clavier à la place du joueur.
                  Les signaux sont envoyés directement à Windows donc attention.
                  Vous pouvez par exemple forcer le passage en plein écran :
                    Keyboard.push!(:Alt, :Enter)
                  Vous pouvez aussi l'utiliser sur les constantes Key du clavier :
                    Keyboard::Space.push!
                  Pour les arguments fonctionne comme press?
      release!(*a) : Relâche les touches du clavier.
                     Après avoir appeler push! il faut appeler release! pour que
                     le système comprenne qu'elle n'est pas appuyée en permanence.
                     Ce n'est pas automatique !
                     Donc pour finaliser le passage en mode plein écran il faut faire :
                      Keyboard.push!(:Alt, :Enter)
                      Keyboard.release!(:Alt, :Enter)
                     Vous pouvez aussi l'utiliser sur les constantes Key du clavier :
                      Keyboard::Space.release!
                     Pour les arguments fonctionne comme press?
      toggle!(*a) : Change l'état de verrouillage d'une touche.
                    Vous pouvez aussi l'utiliser sur les constantes Key du clavier :
                      Keyboard::Space.release!
                    Pour les arguments fonctionne comme press?
      key_name(k) : Retourne le nom de la touche dans la langue du système.
                    Comme pour press?, k peut être égal à Keyboard::W, :W, 'W', 87.
                    Par exemple : Keyboard.key_name(:Escape) # => "ECHAP"
                    Cependant les noms de toutes les touches ne sont pas forcément
                    bienvenus donc il est peut être préférable de s'organiser
                    soi-même une liste de noms manuellement.
                    Vous pouvez aussi l'utiliser sur les constantes Key du clavier :
                      Keyboard::Escape.name
      
  Mouse < Device :
      Par défaut la souris est désactivée, pour l'activer faites :
        Mouse.enabled = true
    Constantes :
      Left, Middle, Right, X1, X2, WheelUp, WheelDown :
        Les touches de la souris, j'ai tout mis inutile d'aller voir la liste ligne 990.
        Ce ne sont pas des nombres mais des objets de type Mouse_Key ce qui
        permet de faire des chose comme : Mouse::Left.click?
        Left, Middle, Right sont les clics gauche, milieu, droit.
        X1 et X2 sont les boutons sur les côtés de la souris (si y'en a).
        WheelUp et WheelDown pour la roulette ne répondent malheureusement pas
        parfaitement, à éviter dans un jeu du coup, d'ailleurs pour que ça marche
        un tant soit peu il faut mettre le Input.update avant le Graphics.update
    Propriétés :
      click_max : alias de ntrigger_max
                  Contrairement aux autres contrôles le click_max/ntrigger_max
                  de la souris est par défaut égal à 3.
      click_time : alias de ntrigger_time
      cursor : Le curseur de la souris, c'est un Sprite classique donc vous
               pouvez utiliser toutes les fonctions des sprites.
               Pour modifier le curseur par défaut voir ligne 1024.
      x : Raccourci de cursor.x pour la lecture.
          Vous pouvez aussi modifier manuellement la position de la souris.
            Mouse.x = 123
          Attention Mouse.cursor.x = 123 ne fonctionne pas.
      y : Raccourci de cursor.y pour la lecture.
          Vous pouvez aussi modifier manuellement la position de la souris.
            Mouse.y = 456
          Attention Mouse.cursor.y = 456 ne fonctionne pas.
      drag : Le rectangle de sélection utilise aussi un Sprite mais a un
             fonctionnement particulier.
             Il apparait automatiquement quand on maintient un clic gauche et
             déplace la souris, cependant par défaut il est désactivé.
             Si vous désirez changer l'apparence du rectangle de sélection sachez
             que c'est un Bitmap de 1x1 pixels, par défaut il est bleu transparent
             voir ligne 1032, mais on peut le changer à tout moment :
              Mouse.drag.bitmap.set_pixel(0, 0, Color.new(255, 0, 0, 128))
      drag_enabled = Permet d'activer/désactiver la sélection, par défaut désactivée.
                     Pour l'activer : Mouse.drag_enabled = true
      drag_x : Raccourci de drag.x (Lecture seule)
      drag_y : Raccourci de drag.y (Lecture seule)
      drag_width : Largeur de la sélection, équivalent de drag.zoom_x.to_i (Lecture seule)
      drag_height : Hauteur de la sélection, équivalent de drag.zoom_y.to_i (Lecture seule)
      drag_rect : Retourne Rect.new(drag_x, drag_y, drag_width, drag_height) (Lecture seule)
      drag_auto_clear : Si activé la sélection s'effacera automatiquement
                        dès lors qu'on relâche le clic gauche.
      drag_start_size : Nombre de pixels dont on doit déplacer la souris pour
                        faire apparaître le rectangle de sélection, par défaut 10.
    Méthodes :
      icon(s=nil, ox=0, oy=0) : Permet de changer l'apparence du curseur,
                                l'image doit se trouver dans le dossier picture,
                                l'extension est facultative.
                                  Mouse.icon("croix")
                                On peut éventuellement préciser un décalage vers
                                le centre du curseur si nécessaire, en comptant
                                à partir du coin haut gauche de l'image.
                                  Mouse.icon("croix", 4, 4)
                                Si on veut remettre le curseur par défaut :
                                  Mouse.icon()
      clip(*a) : Définit la zone dans laquelle la souris est libre de se mouvoir.
                 Il y a quatre façons d'utiliser cette fonction :
                  Mouse.clip(i) : Si i = 0, aucune limitation, la souris peut
                                  voguer librement sur tout l'écran. (Défaut)
                                  Si i = 1, la souris est bloquée dans la fenêtre
                                  du jeu, càd surface de jeu + barre de titre.
                                  Si i = 2, la souris est bloquée dans la surface
                                  de jeu, on ne peut plus aller sur la barre de titre.
                                  Déconseillé vu qu'on ne peut plus réduire/fermer
                                  le jeu ce qui peut vite devenir pénible.
                  Mouse.clip() : Idem que Mouse.clip(0).
                  Mouse.clip(x, y, w, h) : Définit une zone manuellement,
                                           le point 0, 0 correspond au coin
                                           haut gauche de la surface de jeu.
                  Mouse.clip(rect) : Idem mais avec un objet de type Rect.
      on?(*a) : Retourne true si la souris est dans la zone demandée.
                Il y a cinq façons d'utiliser cette fonction :
                  Mouse.on?() : vérifie si le curseur est dans la surface de jeu.
                  Mouse.on?(x, y) : vérifie si le curseur est sur le point x y.
                  Mouse.on?(x, y, r) : vérifie si le curseur est dans le cercle
                                       de centre x y et de rayon r.
                  Mouse.on?(x, y, w, h) : vérifie si le curseur est dans le
                                          rectangle aux coordonnées spécifiées.
                  Mouse.on?(rect) : Idem mais avec un objet de type Rect.
      drag_on?(*a) : Retourne true si la sélection est en contact avec la zone donnée.
                     Il y a quatre façons d'utiliser cette fonction :
                      Mouse.drag_on?(x, y) : vérifie si le point x y est compris
                                             dans la sélection.
                      Mouse.drag_on?(x, y, r) : vérifie si le cercle de centre x y
                                                et de rayon r entre en contact
                                                avec la sélection.
                      Mouse.drag_on?(x, y, w, h) : vérifie si le rectangle entre
                                                   en contact avec la sélection.
                      Mouse.drag_on?(rect) : Idem mais avec un objet de type Rect.
      drag_clear() : Efface la sélection.
      dragging?() : Retourne true si une sélection est en cours.
      swap_button(b) : Si b = true, inverse les clics gauches et droits,
                       si b = false, les remet à la normale.
      click?(k=Left) : Simple clic, équivalent de ntrigger?(1, k).
                       L'argument est facultatif et est le clic gauche par défaut.
                       La différence entre click? et trigger? est que si on fait
                       un double clic par exemple lors du deuxième clic trigger?
                       renverra true alors que click? false (et dclick? true).
                       Vous pouvez aussi l'utiliser sur les constantes Key de la souris :
                        Mouse::Left.click?
      dclick?(k=Left) : Double clic, équivalent de ntrigger?(2, k).
                        Vous pouvez aussi l'utiliser sur les constantes Key de la souris :
                          Mouse::Left.dclick?
      tclick?(k=Left) : Triple clic, équivalent de ntrigger?(3, k).
                        Vous pouvez aussi l'utiliser sur les constantes Key de la souris :
                          Mouse::Left.tclick?
      
  Key :
      Il y en a quatre types : Player_Key, Gamepad_Key, Keyboard_Key et Mouse_Key
      Certaines possèdent des fonctions en plus.
    Méthodes :
      to_s() : Retourne le nom de la constante.
                Input::DOWN.to_s # => "DOWN"
      to_i() : Retourne l'id de la touche.
                Input::DOWN.to_i # => 2
      push?(), toggle?(), press?(), trigger?(), release?(), repeat?(), analog?(),
      ntrigger?(n), count() : Toutes les fonctions décrites précédemment sont
                              utilisables directement sur les touches pour plus
                              d'efficacité :
                                Input::DOWN.press?
                              Cependant inutile d'appeler ces fonctions sur les
                              touches Gamepad_Key, ça ne marchera pas.
      name(), push!(), release!(), toggle!() : Fonctions supplémentaires des Keyboard_Key
      click?(), dclick?(), tclick?() : Fonctions supplémentaires des Mouse_Key
      [i] : Fonction supplémentaire des Player_Key pour le jeu multijoueur :
              Input::DOWN[0].trigger? # joueur 1
              Input::DOWN[1].trigger? # joueur 2
      
  Text_Entry_Box < Sprite
      Cette classe permet de saisir du texte au clavier, la souris est aussi
      supportée pour la sélection de texte.
      Text_Entry_Box est dérivée de Sprite et son affichage est automatisé.
      Vous pouvez utiliser toutes les fonctions de Sprite cependant les fonctions
      zoom, angle, mirror, src_rect ne seront pas compatibles avec la souris.
      Si la souris est activée et survole une boite de texte, l’icône changera
      automatiquement, vous pouvez modifier son apparence ligne 1180.
    Propriétés :
      enabled : Permet d'activer ou désactiver une boite de texte.
                Une boite désactivée ne peut plus avoir le focus.
      focus : L'état de focus actuel, une seule boite peut l'avoir à la fois.
      text : Permet de récupérer le texte entré.
      back_color : La couleur du fond, valeur par défaut ligne 1195.
                   Elle peut être modifiée à tout moment mais il faut ensuite
                   appeler refresh() pour mettre à jour le bitmap.
                    text_entry_box.back_color = Color.new(255, 0, 0)
      select_color : Couleur de la sélection, idem que back_color.
      allow_c : Liste des caractères autorisés sous forme de string.
                  text_entry_box.allow_c = "abcABC123"
                Si la liste est vide tous les caractères sont autorisés. (Défaut)
      select : Permet d'activer ou désactiver les sélections que ce soit avec la
               souris ou en maintenant la touche Maj.
               Activé par défaut, pour le désactiver : text_entry_box.select = false
      mouse : Permet d'activer ou désactiver les fonctionnalités de la souris.
              Activé par défaut, pour le désactiver : text_entry_box.mouse = false
              Il faut aussi que la souris elle même soit activée sinon ça sert à rien.
      case : Casse de caractère :
              text_entry_box.case = 0 # normal, sensible à la casse (Défaut)
              text_entry_box.case = 1 # downcase, les majuscules deviennent minuscules.
              text_entry_box.case = 2 # upcase, les minuscules deviennent majuscules.
      size : Le nombre de caractères actuel. (lecture seule)
      size_max : Le nombre de caractères maximum autorisé.
                 Si 0, pas de limite.
      width : Raccourci pour text_entry_box.bitmap.width (lecture seule)
      width_max : La taille maximum autorisée en pixels.
                  Si 0, pas de limite.
      height : Raccourci pour text_entry_box.bitmap.height (lecture seule)
      font : Raccourci pour text_entry_box.bitmap.font
    Méthodes :
      Text_Entry_Box.new(width, height, viewport=nil) :
          Crée une nouvelle instance de Text_Entry_Box
          On est obligé de préciser width et height qui sont utilisés pour créer
          le bitmap, viewport est facultatif.
            text_entry_box = Text_Entry_Box.new(100, 20)
            
      dispose : Supprime le sprite et le bitmap.
      update : A appeler une fois par frame pour mettre à jour la saisie de texte.
      refresh : A appeler après avoir modifié les propriétés ou le font du bitmap
                pour forcer la mise à jour.
      hover? : Retourne true si la souris survole la boite texte.
      focus! : Donne le focus à la boite texte, une seule boite peut avoir le
               focus à la fois, il est automatiquement retiré des autres.
               Cette fonction est automatiquement appelée quand on clique sur la
               boite texte, si la souris est activée bien sûr.
=end

class Object
  remove_const(:Input)
  def singleton_attach_methods(o) class << self; self end.attach_methods(o) end
  def self.attach_methods(o)
    @attached_methods ||= []
    for m in o.public_methods-(instance_methods-@attached_methods)
      define_method(m, &o.method(m))
      @attached_methods << m unless @attached_methods.include?(m)
    end
  end
end

class String; alias getbyte [] end if RUBY_VERSION == '1.8.1'

module Input
  class Key
    include Comparable
    attr_reader :o, :i, :s, :hash, :to_sym
    alias to_i i
    alias to_s s
    def initialize(i,o)
      @o, self.i, self.s = o, i, "#{self.class.name.split('::')[-1]}_#{i}"
    end
    def o=(o) @o, @hash = o, @i.hash^o.hash  end
    def i=(i) @i, @hash = i, i.hash^@o.hash  end
    def s=(s) @s, @to_sym = s, s.to_sym      end
    def <=>(o)       @i <=> o.to_i           end
    def succ()       self.class.new(@i+1,@o) end
    def count()      @o.get_count(@i)        end
    def push?()      @o.get_push(@i)         end
    def toggle?()    @o.get_toggle(@i)       end
    def press?()     @o.get_press(@i)        end
    def trigger?()   @o.get_trigger(@i)      end
    def release?()   @o.get_release(@i)      end
    def repeat?()    @o.get_repeat(@i)       end
    def ntrigger?(n) @o.get_ntrigger(n,@i)   end
    def analog?()    @o.get_analog(@i)       end
  end
  class Gamepad_Key < Key
    def initialize(i,o=Gamepad) super        end
  end
  class Keyboard_Key < Key
    def initialize(i,o=Keyboard) super       end
    def name()       @o.get_key_name(@i)     end
    def push!()      @o.push!(@i)            end
    def release!()   @o.release!(@i)         end
    def toggle!()    @o.toggle!(@i)          end
  end
  class Mouse_Key < Key
    def initialize(i,o=Mouse) super          end
    def click?()     ntrigger?(1)            end
    def dclick?()    ntrigger?(2)            end
    def tclick?()    ntrigger?(3)            end
  end
  class Player_Key < Key
    def [](i)        @players_keys[i]        end
    def initialize(i,o=Players[0])
      super
      @players_keys = Players.map {|p| k = dup; k.o = p; k}
    end
  end
  
  class Device
    GetDoubleClickTime = Win32API.new('user32', 'GetDoubleClickTime', '', 'i')
    attr_accessor :enabled, :ntrigger_max, :ntrigger_time
    def initialize(max)
      @enabled, @count, @release, @keys = true, Array.new(max,0), [], []
      @ntrigger_count, @ntrigger_last, @ntrigger_max = @count.dup, @count.dup, 0
      self.ntrigger_time = 0
    end
    def update
      return unless @enabled
      update_keys
      update_ntrigger if @ntrigger_max != 0
    end
    def update_keys
      @release.clear
      for i in @keys
        if    get_push(i)   ; @count[i] += 1
        elsif @count[i] != 0; @count[i]  = 0; @release << i
        end
      end
    end
    def update_ntrigger
      f = Graphics.frame_count
      for i in @keys
        if @count[i] == 1
          @ntrigger_count[i] %= @ntrigger_max
          @ntrigger_count[i] += 1
          @ntrigger_last[i] = f + @ntrigger_time
        elsif @ntrigger_last[i] == f
          @ntrigger_count[i] = 0
        end
      end
    end
    def capture_key(*exclude)
      exclude = keyarrayize(*exclude) unless exclude.empty?
      (@count.size-1).downto(0) {|i| return key(i) if !exclude.include?(i) and get_push(i)}
      nil
    end
    def get_count(i)      @count[i]                                                            end
    def get_push(i)       false                                                                end
    def get_toggle(i)     false                                                                end
    def get_press(i)      @count[i] != 0                                                       end
    def get_trigger(i)    @count[i] == 1                                                       end
    def get_release(i)    @release.include?(i)                                                 end
    def get_repeat(i)     (j=@count[i])>0 and REPEAT.any? {|w,f| break(f>0 && j%f==0) if j>=w} end
    def get_ntrigger(n,i) get_trigger(i) and @ntrigger_count[i] == n                           end
    def get_analog(i)     get_push(i) ? 1.0 : 0.0                                              end
    def count(k)          get_count(k2i(k))                                                           end
    def push?(*a)         a.any?{|i| enum?(i) ? i.all?{|j| push?(*j)}       : get_push(k2i(i))}       end
    def toggle?(*a)       a.any?{|i| enum?(i) ? i.all?{|j| toggle?(*j)}     : get_toggle(k2i(i))}     end
    def press?(*a)        a.any?{|i| enum?(i) ? i.all?{|j| press?(*j)}      : get_press(k2i(i))}      end
    def trigger?(*a)      a.any?{|i| enum?(i) ? i.all?{|j| trigger?(*j)}    : get_trigger(k2i(i))}    end
    def release?(*a)      a.any?{|i| enum?(i) ? i.all?{|j| release?(*j)}    : get_release(k2i(i))}    end
    def repeat?(*a)       a.any?{|i| enum?(i) ? i.all?{|j| repeat?(*j)}     : get_repeat(k2i(i))}     end
    def ntrigger?(n,*a)   a.any?{|i| enum?(i) ? i.all?{|j| ntrigger?(n,*j)} : get_ntrigger(n,k2i(i))} end
    def analog?(*a)
      a.each do |i|
        d = if enum?(i)
          sum = size = 0
          i.each {|j| sum, size = sum+analog?(*j), size+1}
          sum == 0 ? 0 : sum / size
        else get_analog(k2i(i))
        end
        return d if d != 0
      end
      0.0
    end
    def ntrigger_time=(i) @ntrigger_time = (i==0 ? GetDoubleClickTime.call *
                          Graphics.frame_rate / 1000 : i)  end
    def key(o)            self.class.key(o)                end
    def k2i(o)            self.class.k2i(o)                end
  private
    def enum?(o)          o.is_a?(Array) or o.is_a?(Range) end
    def keyarrayize(*a)
      a.flatten!
      a.map! {|o| o.is_a?(Range) ? o.to_a : o}.flatten!
      a.compact!
      a.map! {|k| k2i(k)}.uniq!
      a
    end
    def self.key(o) o.is_a?(Key) || o.is_a?(Integer) ? const_get(:Keys)[o.to_i] : const_get(o) end
    def self.k2i(o) o.is_a?(Key) ? o.i : o.is_a?(Integer) ? o : const_get(o).i                 end
  end
  
  class Player < Device
    attr_reader :id, :gamepad, :gamepad_id
    def initialize(id)
      super(KEYS_MAX)
      @id, @gamepad_id, @gamepad, @map = id, id, No_Gamepad.new, @count.map{[]}
    end
    def setup(h)
      @keys.clear
      @count.fill(0)
      @map.fill([])
      for i,a in h
        a=@map[i=k2i(i)] = a[0].map {|j| Gamepad.key(j).dup} + a[1].map {|j| Keyboard.key(j)}
        @keys << i unless a.empty?
      end
      self.gamepad_id += 0
    end
    def gamepad_id=(i)
      vibration, @gamepad.enabled = @gamepad.vibration, false
      @gamepad = (@gamepad_id = i) >= 0 && Gamepads[i] || No_Gamepad.new
      @gamepad.vibration = vibration
      Players.each {|p| p.gamepad.enabled = true}
      @map.each {|a| a.each {|k| k.o = @gamepad if k.is_a?(Gamepad_Key)}}
    end
    def get_push(i)   @map[i].any? {|k| k.push?}                              end
    def get_toggle(i) @map[i].any? {|k| k.toggle?}                            end
    def get_analog(i) @map[i].each {|k| d=k.analog?; return d if d != 0}; 0.0 end
    def dirXY
      return 0.0, 0.0 unless @enabled
      return RIGHT.analog?-LEFT.analog?, UP.analog?-DOWN.analog?
    end
    def dir360
      x, y = *dirXY
      return 0.0, 0.0 if x == 0 and y == 0
      return Math.atan2(y,x)*180/Math::PI, (w=Math.hypot(x,y))>1 ? 1.0 : w
    end
    def dir8
      d = 5
      d -= 3 if DOWN.press?
      d -= 1 if LEFT.press?
      d += 1 if RIGHT.press?
      d += 3 if UP.press?
      d == 5 ? 0 : d
    end
    def dir4
      case d = dir8
      when 1; DOWN.trigger? == (@last_dir==2) ? 2 : 4
      when 3; DOWN.trigger? == (@last_dir==2) ? 2 : 6
      when 7; UP.trigger?   == (@last_dir==8) ? 8 : 4
      when 9; UP.trigger?   == (@last_dir==8) ? 8 : 6
      else    @last_dir = d
      end
    end
  end
  
  class Gamepad < Device
    ::Gamepad = self
    AXIS_PUSH, AXIS_DEADZONE, TRIGGER_PUSH = 16384, 6666, 0
    Keys = Array.new(48) {|i| Gamepad_Key.new(i)}
    Button1 , Button2 , Button3 , Button4 , Button5 , Button6 , Button7 ,
    Button8 , Button9 , Button10, Button11, Button12, Button13, Button14,
    Button15, Button16, Button17, Button18, Button19, Button20, Button21,
    Button22, Button23, Button24, Button25, Button26, Button27, Button28,
    Button29, Button30, Button31, Button32, Axis1_0 , Axis1_1 , Axis2_0 ,
    Axis2_1 , Axis3_0 , Axis3_1 , Axis4_0 , Axis4_1 , Axis5_0 , Axis5_1 ,
    Axis6_0 , Axis6_1 , PovUp   , PovRight, PovDown , PovLeft = *Keys
    XKeys = Array.new(48) {|i| Gamepad_Key.new(i)}
    A, B, X, Y, LB, RB, LT, RT, BACK, START, LS, RS,
    n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n, n,
    AxisLX_0, AxisLX_1, AxisLY_1, AxisLY_0, AxisRX_0, AxisRX_1, AxisRY_1, AxisRY_0,
    n, n, n, n, DPadUp, DPadRight, DPadDown, DPadLeft = *XKeys
    constants.each {|s| k = const_get(s);  k.s = s.to_s if k.is_a?(Key)}
    
    attr_accessor :vibration
    attr_reader   :unplugged
    def initialize(id=nil)
      super(48)
      @id, @unplugged, @map, @vibration = id, false, @count.map{[]}, true
    end
    def get_push(i)
      return false unless @enabled and !@unplugged
      j, k = *@map[i]
      case j
      when :button ; button(k)
      when :pov    ; k.include?(pov)
      when :axis_0 ; axis_raw(k) < -AXIS_PUSH
      when :axis_1 ; axis_raw(k) > AXIS_PUSH-1
      when :trigger; trig_raw(k) > TRIGGER_PUSH
      else           false
      end
    end
    def get_analog(i)
      return 0.0 unless @enabled and !@unplugged
      j, k = *@map[i]
      case j
      when :button, :pov; super
      when :axis_0 ; (k=axis_pct(k)) < 0 ? -k : 0.0
      when :axis_1 ; (k=axis_pct(k)) > 0 ?  k : 0.0
      when :trigger; trig_pct(k)
      else           0.0
      end
    end
    def vibrate!(id, speed, fade_in, duration, fade_out) end
  private
    def axis_pct(i)
      (i=axis_raw(i)).abs <= AXIS_DEADZONE ? 0.0 :
      (i<0 ? i+AXIS_DEADZONE : i-AXIS_DEADZONE+1) / (32768.0-AXIS_DEADZONE)
    end
    def trig_pct(i) trig_raw(i) / 255.0 end
    def axis_raw(i) 0                   end
    def trig_raw(i) 0                   end
    def pov()       0                   end
    def button(i)   false               end
      
    singleton_attach_methods(@o = new)
    
    class No_Gamepad < Gamepad
      ::No_Gamepad = Input::No_Gamepad = self
      def get_push(i)   false end
      def get_analog(i) 0.0   end
    end
    
    class Multimedia_Gamepad < Gamepad
      ::Multimedia_Gamepad = Input::Multimedia_Gamepad = self
      JoyGetDevCaps = Win32API.new('winmm', 'joyGetDevCaps', 'ipi', 'i')
      JoyGetPosEx   = Win32API.new('winmm', 'joyGetPosEx'  , 'ip' , 'i')
      def initialize(id)
        super
        JoyGetDevCaps.call(id, devcaps="\0"*404, 404)
        @caps = Array.new(7) {|i| i<2 or devcaps.getbyte(96)[i-2]==1}
        @buffer = [52,255,0,0,0,0,0,0,0,0,0,0,0].pack('L13')
        @state = @buffer.unpack('L13')
        for k,v in {            Button1 =>[:button, 0], Button2 =>[:button, 1],
        Button3 =>[:button, 2], Button4 =>[:button, 3], Button5 =>[:button, 4],
        Button6 =>[:button, 5], Button7 =>[:button, 6], Button8 =>[:button, 7],
        Button9 =>[:button, 8], Button10=>[:button, 9], Button11=>[:button,10],
        Button12=>[:button,11], Button13=>[:button,12], Button14=>[:button,13],
        Button15=>[:button,14], Button16=>[:button,15], Button17=>[:button,16],
        Button18=>[:button,17], Button19=>[:button,18], Button20=>[:button,19],
        Button21=>[:button,20], Button22=>[:button,21], Button23=>[:button,22],
        Button24=>[:button,23], Button25=>[:button,24], Button26=>[:button,25],
        Button27=>[:button,26], Button28=>[:button,27], Button29=>[:button,28],
        Button30=>[:button,29], Button31=>[:button,30], Button32=>[:button,31],
        Axis1_0 =>[:axis_0, 0], Axis1_1 =>[:axis_1, 0], Axis2_0 =>[:axis_0, 1],
        Axis2_1 =>[:axis_1, 1], Axis3_0 =>[:axis_0, 2], Axis3_1 =>[:axis_1, 2],
        Axis4_0 =>[:axis_0, 3], Axis4_1 =>[:axis_1, 3], Axis5_0 =>[:axis_0, 4],
        Axis5_1 =>[:axis_1, 4], Axis6_0 =>[:axis_0, 5], Axis6_1 =>[:axis_1, 5],
        PovUp   =>[:pov,[31500,    0, 4500]], PovRight=>[:pov,[ 4500, 9000,13500]],
        PovDown =>[:pov,[13500,18000,22500]], PovLeft =>[:pov,[22500,27000,31500]]}
          @map[k.i] = v
        end
        update
      end
      def update
        return unless @enabled and !@unplugged = JoyGetPosEx.call(@id, @buffer) != 0
        @state.replace(@buffer.unpack('L13'))
        super
      end
    private
      def button(i)   @state[8][i] == 1                end
      def pov()       @caps[6] ? @state[10] : 0        end
      def axis_raw(i) @caps[i] ? @state[2+i]-32768 : 0 end
    end
    
    class XBox360_Gamepad < Gamepad
      ::XBox360_Gamepad = Input::XBox360_Gamepad = self
      Keys = XKeys
      XInputGetState = (Win32API.new(DLL='xinput1_3'  , 'XInputGetState', 'ip', 'i') rescue
                        Win32API.new(DLL='xinput1_2'  , 'XInputGetState', 'ip', 'i') rescue
                        Win32API.new(DLL='xinput1_1'  , 'XInputGetState', 'ip', 'i') rescue
                        Win32API.new(DLL='xinput9_1_0', 'XInputGetState', 'ip', 'i') rescue
                        DLL=nil)
      XInputSetState =  Win32API.new(DLL              , 'XInputSetState', 'ip', 'i') if DLL
      def initialize(id)
        super
        @buffer = "\0"*16
        @state = @buffer.unpack('LSC2s4')
        @vibration_state = Array.new(2) {[0,0,0,0,0,false]}
        for k,v in {
        A        =>[:button,12], B       =>[:button,13], X       =>[:button,14],
        Y        =>[:button,15], LB      =>[:button, 8], RB      =>[:button, 9],
        LT       =>[:trigger,0], RT      =>[:trigger,1], BACK    =>[:button, 5],
        START    =>[:button, 4], LS      =>[:button, 6], RS      =>[:button, 7],
        AxisLX_0 =>[:axis_0, 0], AxisLX_1=>[:axis_1, 0], AxisLY_1=>[:axis_1, 1],
        AxisLY_0 =>[:axis_0, 1], AxisRX_0=>[:axis_0, 2], AxisRX_1=>[:axis_1, 2],
        AxisRY_1 =>[:axis_1, 3], AxisRY_0=>[:axis_0, 3], DPadUp  =>[:button, 0],
        DPadRight=>[:button, 3], DPadDown=>[:button, 1], DPadLeft=>[:button, 2]}
          @map[k.i] = v
        end
        update
      end
      def update
        return unless @enabled and !@unplugged = XInputGetState.call(@id, @buffer) != 0
        @state.replace(@buffer.unpack('LSC2s4'))
        super
        update_vibration if @vibration
      end
      def update_vibration
        vibrate = false
        @vibration_state.each do |v|
          next unless v[5]
          last_v0 = v[0]
          if    v[2]>0; v[0] = (v[0]*(v[2]-=1)+v[1]) / (v[2]+1.0)
          elsif v[3]>0; v[0], v[3] = v[1], v[3]-1
          elsif v[4]>0; v[0] = v[0]*(v[4]-=1) / (v[4]+1.0)
          else          v[0], v[5] = 0, false
          end
          vibrate = true if last_v0 != v[0]
        end
        set_vibration if vibrate
      end
      def vibration=(b) vibrate!(2,0,0,0,0); super end
      def vibrate!(id, speed, fade_in, duration, fade_out)
        case id
        when 0, 1; @vibration_state[id][1,5] = [speed, fade_in, duration, fade_out, true]
        when 2   ; 2.times {|i| vibrate!(i, speed, fade_in, duration, fade_out)}
        end
      end
    private
      def button(i)   @state[1][i] == 1 end
      def axis_raw(i) @state[4+i]       end
      def trig_raw(i) @state[2+i]       end
      def set_vibration
        return unless @enabled and @vibration and !@unplugged
        XInputSetState.call(@id, [@vibration_state[0][0]*0xFFFF,
                                  @vibration_state[1][0]*0xFFFF].pack('S2'))
      end
    end
    
  end
  
  class Keyboard < Device
    ::Keyboard = self
    GetKeyboardState    = Win32API.new('user32'  , 'GetKeyboardState'   , 'p'       , 'i')
    getKeyNameText      = Win32API.new('user32'  , 'GetKeyNameTextW'    , 'ipi'     , 'i')
    mapVirtualKey       = Win32API.new('user32'  , 'MapVirtualKey'      , 'ii'      , 'i')
    SendInput           = Win32API.new('user32'  , 'SendInput'          , 'ipi'     , 'i')
    ToUnicode           = Win32API.new('user32'  , 'ToUnicode'          , 'iippii'  , 'i')
    WideCharToMultiByte = Win32API.new('kernel32', 'WideCharToMultiByte', 'iipipipp', 'i')
  
    Keys = Array.new(256) {|i| Keyboard_Key.new(i)}
    None, MouseL, MouseR, Cancel, MouseM, MouseX1, MouseX2, n, Back, Tab,
    LineFeed, n, Clear, Enter, n, n, Shift, Control, Alt, Pause, CapsLock,
    KanaMode, n, JunjaMode, FinalMode, KanjiMode, n, Escape, IMEConvert,
    IMENonConvert, IMEAccept, IMEModeChange, Space, PageUp, PageDown, End, Home,
    Left, Up, Right, Down, Select, Print, Execute, PrintScreen, Insert, Delete,
    Help, D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, n, n, n, n, n, n, n, A, B, C,
    D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, LWin,
    RWin, Apps, n, Sleep, NumPad0, NumPad1, NumPad2, NumPad3, NumPad4, NumPad5,
    NumPad6, NumPad7, NumPad8, NumPad9, Multiply, Add, Separator, Subtract,
    Decimal, Divide, F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, F13,
    F14, F15, F16, F17, F18, F19, F20, F21, F22, F23, F24, n, n, n, n, n, n, n,
    n, NumLock, Scroll, n, n, n, n, n, n, n, n, n, n, n, n, n, n, LShift,
    RShift, LControl, RControl, LAlt, RAlt, BrowserBack, BrowserForward,
    BrowserRefresh, BrowserStop, BrowserSearch, BrowserFavorites, BrowserHome,
    VolumeMute, VolumeDown, VolumeUp, MediaNextTrack, MediaPreviousTrack,
    MediaStop, MediaPlayPause, LaunchMail, SelectMedia, LaunchApplication1,
    LaunchApplication2, n, n, OemSemicolon, OemPlus, OemComma, OemMinus,
    OemPeriod, OemQuestion, OemTilde, n, n, n, n, n, n, n, n, n, n, n, n, n, n,
    n, n, n, n, n, n, n, n, n, n, n, n, OemOpenBrackets, OemPipe,
    OemCloseBrackets, OemQuotes, Oem8, n, n, OemBackslash, n, n, ProcessKey,
    n, Packet, n, n, n, n, n, n, n, n, n, n, n, n, n, n, Attn, Crsel, Exsel,
    EraseEof, Play, Zoom, NoName, Pa1, OemClear, Unknown = *Keys
    constants.each {|s| k = const_get(s);  k.s = s.to_s if k.is_a?(Key)}
    
    SCAN_CODE = Array.new(256) {|i| mapVirtualKey.call(i, 0)}
    (BrowserBack..LaunchApplication2).each {|k| SCAN_CODE[k.i] = 0}
    for k,code in  {Pause  =>0x0045, PageUp     =>0x0149, PageDown=>0x0151,
    End   =>0x014F, Home   =>0x0147, Left       =>0x014B, Up      =>0x0148,
    Right =>0x014D, Down   =>0x0150, PrintScreen=>0x0137, Insert  =>0x0152,
    Delete=>0x0153, LWin   =>0x015B, RWin       =>0x015C, Apps    =>0x015D,
    Divide=>0x0135, NumLock=>0x0145, RControl   =>0x011D, RAlt    =>0x0138}
      SCAN_CODE[k.i] = code
    end
    
    KEYS_NAME = Array.new(256) do |i|
      if getKeyNameText.call(SCAN_CODE[i]<<16, utf16="\0"*256, 256) > 0
        WideCharToMultiByte.call(65001, 0, utf16, -1, utf8="\0"*256, 256, 0, 0)
        utf8.delete("\0")
      else Keys[i].to_s
      end
    end
    
    TEXT_KEYS = [Space.i] + (D0.i..D9.i).to_a + (A.i..Z.i).to_a +
                (NumPad0.i..Divide.i).to_a + (146..150).to_a +
                (OemSemicolon.i..OemTilde.i).to_a + (OemOpenBrackets.i..245).to_a
    
    TEXT_ENTRY_KEYS = TEXT_KEYS + [Back.i,Left.i,Up.i,Right.i,Down.i,Delete.i]
    
    DEAD_KEYS = {
        '`' => {'a'=>'à', 'e'=>'è', 'i'=>'ì', 'o'=>'ò', 'u'=>'ù',
      ' '=>'`', 'A'=>'À', 'E'=>'È', 'I'=>'Ì', 'O'=>'Ò', 'U'=>'Ù'},
      
        '´' => {'a'=>'á', 'e'=>'é', 'i'=>'í', 'o'=>'ó', 'u'=>'ú', 'y'=>'ý',
      ' '=>'´', 'A'=>'Á', 'E'=>'É', 'I'=>'Í', 'O'=>'Ó', 'U'=>'Ú', 'Y'=>'Ý'},
      
        '^' => {'a'=>'â', 'e'=>'ê', 'i'=>'î', 'o'=>'ô', 'u'=>'û',
      ' '=>'^', 'A'=>'Â', 'E'=>'Ê', 'I'=>'Î', 'O'=>'Ô', 'U'=>'Û'},
      
        '¨' => {'a'=>'ä', 'e'=>'ë', 'i'=>'ï', 'o'=>'ö', 'u'=>'ü', 'y'=>'ÿ',
      ' '=>'¨', 'A'=>'Ä', 'E'=>'Ë', 'I'=>'Ï', 'O'=>'Ö', 'U'=>'Ü', 'y'=>'Ÿ'},
      
        '~' => {'a'=>'ã', 'o'=>'õ', 'n'=>'ñ',
      ' '=>'~', 'A'=>'Ã', 'O'=>'Õ', 'N'=>'Ñ'},
    }
    
    def initialize()         super(256); @buffer = "\0"*256                        end
    def get_push(i)          @enabled and @buffer.getbyte(i)[7] == 1               end
    def get_toggle(i)        @enabled and @buffer.getbyte(i)[0] == 1               end
    def get_key_name(i)      i.between?(0, 255) ? KEYS_NAME[i].dup : ''            end
    def key_name(k)          get_key_name(k2i(k))                                  end
    def push!(*a)            set_state(a, true)                                    end
    def release!(*a)         set_state(a, false)                                   end
    def toggle!(*a)          set_state(a, true); set_state(a, false)               end
    def text_entry()         start_text_entry unless @text_entry; @text_entry.dup  end
    def start_text_entry()   (@text_entry = ''; setup(@keys)) unless @text_entry   end
    def stop_text_entry()    (@text_entry = nil; setup(@user_keys)) if @text_entry end
    def swap_mouse_button(b) MouseL.i, MouseR.i = b ? 2 : 1, b ? 1 : 2             end
    def setup(*a)
      @count.fill(0)
      @keys = keyarrayize(@text_entry ? [@user_keys=a, TEXT_ENTRY_KEYS] : a)
    end
    def update
      return unless @enabled
      GetKeyboardState.call(@buffer)
      super
      update_text_entry if @text_entry
    end
    def update_text_entry
      @text_entry = ''
      for i in TEXT_KEYS
        next if !get_repeat(i) or ToUnicode.call(i, 0, @buffer, utf16="\0"*16, 8, 0)==0
        j = ToUnicode.call(i, 0, @buffer, utf16, 8, 0)
        WideCharToMultiByte.call(65001, 0, utf16, 1, utf8="\0"*4, 4, 0, 0)
        utf8.delete!("\0")
        if @dead_key
          a = DEAD_KEYS[@dead_key]
          @text_entry, @dead_key = (a && a[utf8]) || (@dead_key + utf8)
        else j == -1 ? @dead_key=utf8 : @text_entry=utf8
        end
        return
      end
    end
  private
    def set_state(keys, state)
      keys, inputs = keyarrayize(keys), ''
      keys.each {|i| inputs << [1,i,0,state ? 0 : 2,0,0].pack('LSSLLLx8')}
      SendInput.call(keys.size, inputs, 28)
    end
    
    singleton_attach_methods(@o = new)
    Keys.each {|k| k.o = @o}
    def self.o() @o end
  end
  
  class Mouse < Device
    ::Mouse = self
    ClipCursor      = Win32API.new('user32', 'ClipCursor'     , 'p'      , 'i')
    createCursor    = Win32API.new('user32', 'CreateCursor'   , 'iiiiipp', 'i')
    findWindow      = Win32API.new('user32', 'FindWindow'     , 'pp'     , 'i')
    GetClientRect   = Win32API.new('user32', 'GetClientRect'  , 'ip'     , 'i')
    GetCursorPos    = Win32API.new('user32', 'GetCursorPos'   , 'p'      , 'i')
    GetWindowRect   = Win32API.new('user32', 'GetWindowRect'  , 'ip'     , 'i')
    MapWindowPoints = Win32API.new('user32', 'MapWindowPoints', 'iipi'   , 'i')
    PeekMessage     = Win32API.new('user32', 'PeekMessage'    , 'piiii'  , 'i')
    SetClassLong    = Win32API.new('user32', 'SetClassLong'   , 'iii'    , 'i')
    SetCursorPos    = Win32API.new('user32', 'SetCursorPos'   , 'ii'     , 'i')
    
    Keys = Array.new(7) {|i| Mouse_Key.new(i)}
    Left, Middle, Right, X1, X2, WheelUp, WheelDown = *Keys
    constants.each {|s| k = const_get(s);  k.s = s.to_s if k.is_a?(Key)}
    
    HWND = findWindow.call('RGSS Player', 0)
    BlankCursor = createCursor.call(0, 0, 0, 1, 1, "\xFF", "\x00")
    Cache = (defined? RPG::Cache) ? RPG::Cache : ::Cache
    
    alias click_max   ntrigger_max
    alias click_max=  ntrigger_max=
    alias click_time  ntrigger_time
    alias click_time= ntrigger_time=
    attr_accessor :drag_enabled, :drag_auto_clear, :drag_start_size
    attr_reader   :cursor, :drag
    def initialize
      super(7)
      @map = @count.map{[]}
      for k,v in {Left    => [:button, Keyboard::MouseL],
                  Middle  => [:button, Keyboard::MouseM],
                  Right   => [:button, Keyboard::MouseR],
                  X1      => [:button, Keyboard::MouseX1],
                  X2      => [:button, Keyboard::MouseX2],
                  WheelUp => [:wheel, 1], WheelDown => [:wheel, -1]}
        @map[k.i] = v
      end
      @enabled, @ntrigger_max, @buffer, @keys = false, 3, "\0"*28, (0...7).to_a
      @drag_enabled, @drag_auto_clear, @drag_start_size = false, false, 10
      clip
      initialize_sprites
    end
    def initialize_sprites
      return if @cursor and !@cursor.disposed?
      @cursor, @drag = Sprite.new, Sprite.new
      @cursor.z = @drag.z = 0x7FFFFFFF
      @cursor.visible, @drag.visible = @enabled, @enabled && @drag_enabled
      @cursor.bitmap = @default_icon = Bitmap.new(8,8)
      @cursor.bitmap.fill_rect(0, 0, 3, 7, c=Color.new(0,0,0))
      @cursor.bitmap.fill_rect(0, 0, 7, 3, c)
      @cursor.bitmap.fill_rect(5, 5, 3, 3, c)
      @cursor.bitmap.fill_rect(1, 1, 1, 5, c.set(255,255,255))
      @cursor.bitmap.fill_rect(1, 1, 5, 1, c)
      @cursor.bitmap.fill_rect(6, 6, 1, 1, c)
      @drag.bitmap = Bitmap.new(1,1)
      @drag.bitmap.set_pixel(0, 0, c.set(0,0,255,128))
      drag_clear
    end
    def enabled=(enabled)
      initialize_sprites
      drag_clear unless @enabled = enabled
      SetClassLong.call(HWND, -12, @enabled ? BlankCursor : 0)
      @cursor.visible, @drag.visible = @enabled, @enabled && @drag_enabled
    end
    def drag_enabled=(drag_enabled)
      initialize_sprites
      drag_clear unless @drag_enabled = drag_enabled
      @drag.visible = @enabled && @drag_enabled
    end
    def update
      return unless @enabled
      super
      initialize_sprites
      update_cursor
      update_drag
      update_clip
      update_wheel
    end
    def update_cursor
      GetCursorPos.call(@buffer)
      MapWindowPoints.call(0, HWND, @buffer, 1)
      @cursor.update
      @cursor.x, @cursor.y = *@buffer.unpack('ll')
    end
    def update_drag
      return unless @drag_enabled
      @drag.update
      if Left.trigger?
        drag_clear
        @drag_start_point = [@cursor.x, @cursor.y]
      elsif @drag_start_point and Left.press?
        x, y = *@drag_start_point
        w, h = @cursor.x-x, @cursor.y-y
        if w == 0 then w = 1 elsif w < 0 then x -= w *= -1 end
        if h == 0 then h = 1 elsif h < 0 then y -= h *= -1 end
        if dragging? or w > @drag_start_size or h > @drag_start_size
          @drag.x, @drag.y, @drag.zoom_x, @drag.zoom_y = x, y, w, h
        end
      elsif @drag_auto_clear and Left.release?
        drag_clear
      end
    end
    def update_clip
      ClipCursor.call(@buffer) if case @clip
      when String; MapWindowPoints.call(HWND, 0, @buffer.replace(@clip), 2)
      when      1; GetWindowRect.call(HWND, @buffer)
      when      2; GetClientRect.call(HWND, @buffer)
                   MapWindowPoints.call(HWND, 0, @buffer, 2)
      end
    end
    def update_wheel
      @wheel_state = PeekMessage.call(@buffer,HWND,0x020A,0x020A,0)>0 ?
                     @buffer.getbyte(11)==0 ? 1 : -1 : 0
    end
    def on?(x=nil, y=nil, w=nil, h=nil)
      if !@enabled; false
      elsif h; @cursor.x.between?(x, x+w) and @cursor.y.between?(y, y+h)
      elsif w; Math.hypot(x-@cursor.x, y-@cursor.y) <= w
      elsif y; @cursor.x == x and @cursor.y == y
      elsif x; on?(x.x, x.y, x.width, x.height)
      else     GetClientRect.call(HWND, @buffer); on?(*@buffer.unpack('l4'))
      end
    end
    def drag_on?(x, y=nil, w=nil, h=nil)
      if !@enabled or !@drag_enabled; false
      elsif h
        x < @drag.x+drag_width  and @drag.x < x+w and
        y < @drag.y+drag_height and @drag.y < y+h
      elsif w
        sw, sh = drag_width/2, drag_height/2
        x, y = (x-@drag.x-sw).abs, (y-@drag.y-sh).abs
        x<=sw+w and y<=sh+w and (x<=sw or y<=sh or Math.hypot(x-sw,y-sh)<=w)
      elsif y
        x.between?(@drag.x, @drag.x+drag_width) and
        y.between?(@drag.y, @drag.y+drag_height)
      else drag_on?(x.x, x.y, x.width, x.height)
      end
    end
    def icon(s=nil, ox=0, oy=0) @cursor.bitmap, @cursor.ox, @cursor.oy =
                                s ? Cache.picture(s) : @default_icon, ox, oy end
    def clip(x=0, y=nil, w=0, h=0)
      ClipCursor.call(0)
      if x.is_a?(Rect); clip(x.x, x.y, x.width, x.height)
      else @clip = y ? [x, y, w+x, h+y].pack('l4x12') : x
      end
    end
    def click?(k=Left)  get_ntrigger(1, k2i(k))                           end
    def dclick?(k=Left) get_ntrigger(2, k2i(k))                           end
    def tclick?(k=Left) get_ntrigger(3, k2i(k))                           end
    def swap_button(b)  Keyboard.swap_mouse_button(b)                     end
    def x()             @cursor.x                                         end
    def x=(x)           set_pos(x, y)                                     end
    def y()             @cursor.y                                         end
    def y=(y)           set_pos(x, y)                                     end
    def dragging?()     @drag.zoom_x != 0                                 end
    def drag_x()        @drag.x                                           end
    def drag_y()        @drag.y                                           end
    def drag_width()    @drag.zoom_x.to_i                                 end
    def drag_height()   @drag.zoom_y.to_i                                 end
    def drag_rect()     Rect.new(drag_x, drag_y, drag_width, drag_height) end
    def drag_clear
      @drag_start_point = nil
      @drag.x = @drag.y = @drag.zoom_x = @drag.zoom_y = 0
    end
    def get_push(i)
      return false unless @enabled
      j, k = *@map[i]
      case j
      when :button; k.push?
      when :wheel ; k == @wheel_state
      else          false
      end
    end
    def get_toggle(i)
      return false unless @enabled
      j, k = *@map[i]
      case j
      when :button; k.toggle?
      else          false
      end
    end
  private
    def set_pos(x, y)
      @cursor.x, @cursor.y = x, y
      MapWindowPoints.call(HWND, 0, s=[x,y].pack('ll'), 1)
      SetCursorPos.call(*s.unpack('ll'))
    end
    
    singleton_attach_methods(@o = new)
    Keys.each {|k| k.o = @o}
    def self.o() @o end
  end
  
  class Text_Entry_Box < Sprite
    ::Text_Entry_Box = self
    SPECIAL_CHARS_CASE = {
      'à'=>'À', 'è'=>'È', 'ì'=>'Ì', 'ò'=>'Ò', 'ù'=>'Ù',
      'á'=>'Á', 'é'=>'É', 'í'=>'Í', 'ó'=>'Ó', 'ú'=>'Ú', 'ý'=>'Ý',
      'â'=>'Â', 'ê'=>'Ê', 'î'=>'Î', 'ô'=>'Ô', 'û'=>'Û',
      'ä'=>'Ä', 'ë'=>'Ë', 'ï'=>'Ï', 'ö'=>'Ö', 'ü'=>'Ü', 'ÿ'=>'Ÿ',
      'ã'=>'Ã',                     'õ'=>'Õ',                     'ñ'=>'Ñ',
    }
    def self.initialize
      @@boxes, @@last_icon = [], nil
      @@icon = [Bitmap.new(9,20), 4, 0] # [bmp, ox, oy]
      @@icon[0].fill_rect(0,  0, 9,  3, c=Color.new(0,0,0))
      @@icon[0].fill_rect(0, 17, 9,  3, c)
      @@icon[0].fill_rect(3,  3, 3, 14, c)
      @@icon[0].fill_rect(1,  1, 3,  1, c.set(255,255,255))
      @@icon[0].fill_rect(5,  1, 3,  1, c)
      @@icon[0].fill_rect(1, 18, 3,  1, c)
      @@icon[0].fill_rect(5, 18, 3,  1, c)
      @@icon[0].fill_rect(4,  2, 1, 16, c)
    end
    initialize
    attr_accessor :enabled, :mouse, :focus, :back_color, :select_color,
                  :text, :allow_c, :select, :case, :size_max, :width_max
    def initialize(width, height, viewport=nil)
      super(viewport)
      @back_color, @select_color = Color.new(0,0,0,0), Color.new(0,0,255,128)
      @text, @text_width, @allow_c = '', [], ''
      @enabled = @mouse = @select = true
      @case = @size_max = @width_max = @pos = @sel = @off = 0
      @text_chars = [] if RUBY_VERSION == '1.8.1'
      width = 640 if width > 640 and RUBY_VERSION == '1.9.2'
      self.bitmap = Bitmap.new(width, height)
      self.class.initialize if @@icon[0].disposed?
      @@boxes.delete_if {|s| s.disposed?}
      @focus = @@boxes.empty?
      @@boxes << self
    end
    def width()  bitmap.width                                      end
    def height() bitmap.height                                     end
    def font()   bitmap.font                                       end
    def font=(f) bitmap.font = f                                   end
    def hover?() Mouse.on?(x-ox, y-oy, width, height)              end
    def focus!() @@boxes.each {|s| s.focus = false}; @focus = true end
    def dispose
      super
      @@boxes.delete_if {|s| s.disposed?}
      Keyboard.stop_text_entry
      bitmap.dispose
    end
    def update
      super
      return unless @enabled
      update_mouse if @mouse
      return unless @focus
      if update_text_entry
        refresh
      elsif @mouse and (Mouse::WheelDown.press? or Mouse::WheelUp.press?)
        @off = Mouse::WheelDown.press? ? [@off-16, 0].max :
               [@off+16, text_width(0, size)+1-width].min
        draw_text_box
      elsif Graphics.frame_count % 20 == 0
        draw_cursor(Graphics.frame_count % 40 == 0)
      end
    end
    def refresh
      tag = "#{font.name}#{font.size}#{font.bold}#{font.italic}"
      self.text, @last_font = @text, tag if @last_font != tag
      min = [text_width(0,@pos)+16-width, text_width(0,size)+1-width].min
      max = [text_width(0,@pos)-16, 0].max
      @off = [min, [@off, max].min].max
      @sel = 0 unless @select
      draw_text_box
    end
  private
    def update_mouse
      if hover = hover? and !@@last_icon
        @@last_icon = [Mouse.cursor.bitmap, Mouse.cursor.ox, Mouse.cursor.oy]
        Mouse.cursor.bitmap, Mouse.cursor.ox, Mouse.cursor.oy = *@@icon
      elsif @last_hover != hover and !@last_hover = hover and @@last_icon
        Mouse.cursor.bitmap, Mouse.cursor.ox, Mouse.cursor.oy = *@@last_icon
        @@last_icon = nil
      end
      if @mouse_select
        @sel, @mouse_select = @sel+@pos, Mouse::Left.press?
        @sel -= @pos = get_pos(Mouse.x-x+ox+@off, true)
      elsif Mouse::Left.trigger? and hover
        @pos, @sel, @mouse_select = get_pos(Mouse.x-x+ox+@off, true), 0, true
        Mouse.drag_clear
        focus!
      end
    end
    def update_text_entry
      if @mouse_select
        return false if @last_pos == @pos and @last_sel == @sel
        @last_pos, @last_sel = @pos, @sel
      elsif @sel != 0 and (Keyboard::Back.trigger? or Keyboard::Delete.trigger?)
        @pos -= @sel *= -1 if @sel < 0
        self[@pos, @sel], @sel = '', 0
      elsif @pos != 0 and Keyboard::Back.repeat?
        self[@pos -= 1, 1] = ''
      elsif @pos != size and Keyboard::Delete.repeat?
        self[@pos, 1] = ''
      elsif @pos != 0 and Keyboard::Up.trigger?
        @sel, @pos = @select && Keyboard::Shift.push? ? @sel+@pos : 0, 0
      elsif @pos != size and Keyboard::Down.trigger?
        @sel, @pos = @select && Keyboard::Shift.push? ? @sel+@pos-size : 0, size
      elsif @pos != 0 and Keyboard::Left.repeat?
        @pos, @sel = @pos-1, @select && Keyboard::Shift.push? ? @sel+1 : 0
      elsif @pos != size and Keyboard::Right.repeat?
        @pos, @sel = @pos+1, @select && Keyboard::Shift.push? ? @sel-1 : 0
      elsif !Keyboard.text_entry.empty?
        need_refresh, allowed_chars = false,
          @case==1 ? downcase(@allow_c) : @case==2 ? upcase(@allow_c) : @allow_c
        for c in Keyboard.text_entry.split(//)
          break if @size_max != 0 and @size_max <= size
          c = @case==1 ? downcase(c) : @case==2 ? upcase(c) : c
          next unless allowed_chars.empty? or allowed_chars.include?(c)
          _text, _pos, _sel = @text.dup, @pos, @sel if @width_max != 0
          @pos -= @sel *= -1 if @sel < 0
          self[@pos, @sel], @pos, @sel = c, @pos+1, 0
          if @width_max != 0 and text_width(0, size) > @width_max
            self.text, @pos, @sel = _text, _pos, _sel
            break
          end
          need_refresh = true
        end
        return need_refresh
      else return false
      end
      return true
    end
    def draw_text_box
      bitmap.fill_rect(bitmap.rect, @back_color)
      draw_selection if @sel != 0
      draw_text_entry
      draw_cursor(true)
    end
    def draw_selection
      pos, sel = @sel < 0 ? @pos+@sel : @pos, @sel.abs
      x, w, h = text_width(0,pos)-@off, text_width(pos,sel), font.size+2
      bitmap.fill_rect(x, (height-h)/2, w, h, @select_color)
    end
    def draw_cursor(blink)
      color = blink ? font.color : @back_color
      x, h = text_width(0, @pos)-@off, font.size+2
      bitmap.fill_rect(x, (height-h)/2, 1, h, color)
    end
    def draw_text_entry()
      bitmap.draw_text(-@off, 0, 0xFFFF, height, @text)
    end
    def downcase(str)
      str = str.downcase
      SPECIAL_CHARS_CASE.each {|d,u| str.gsub!(u, d)}
      str
    end
    def upcase(str)
      str = str.upcase
      SPECIAL_CHARS_CASE.each {|d,u| str.gsub!(d, u)}
      str
    end
    def text_width(i, j)
      @text_width[i] ||= bitmap.text_size(self[0, i]).width
      @text_width[i+j] ||= bitmap.text_size(self[0, i+j]).width
      @text_width[i+j] - @text_width[i]
    end
    def get_pos(x, round=false)
      return 0 if x <= 0
      return size if x >= text_width(0, size)
      size.times do |i|
        if (w = text_width(0,i+1)) > x
          return i unless round
          w -= text_width(i,1) / 2
          return w > x ? i : i+1
        end
      end
    end
    if RUBY_VERSION == '1.9.2'
      alias normal_draw_text_entry draw_text_entry
      def draw_text_entry
        if text_width(0, size) > 640
          a, b = get_pos(@off), get_pos(@off+width)
          b += 1 if b != size and text_width(a, b+1-a) <= 640
          a += 1 if text_width(a, b-a) > 640
          x = text_width(0,a)-@off
          bitmap.draw_text(x, 0, 0xFFFF, height, self[a, b-a])
        else normal_draw_text_entry
        end
      end
      def [](i, j) @text[i, j] end
      def []=(i, j, str)
        @text[i, j] = str
        @text_width[i, @text_width.size-i] = Array.new(size-i)
      end
    public
      def size()   @text.size  end
      def text=(str)
        str = @case==1 ? downcase(str) : @case==2 ? upcase(str) : str
        @text_width = Array.new(str.size)
        @text = str
      end
    else
      def [](i, j) @text_chars[i, j].join('') end
      def []=(i, j, str)
        @text_chars[i, j] = str.empty? ? nil : str
        @text_width[i, @text_width.size-i] = Array.new(size-i)
        @text.replace(@text_chars.join(''))
      end
    public
      def size()   @text_chars.size           end
      def text=(str)
        str = @case==1 ? downcase(str) : @case==2 ? upcase(str) : str
        @text_chars.replace(str.split(//))
        @text_width = Array.new(@text_chars.size)
        @text = str
      end
    end
  end
  
  def self.[](i) Players[i] end
  def self.update
    Keyboard.update
    Mouse.update
    Gamepads.each {|g| g.update}
    Players.each {|p| p.update}
  end
  def self.refresh
    Gamepads.clear
    x360_pads = XBox360_Gamepad::DLL ? Array.new(4) {|i| XBox360_Gamepad.new(i)} : []
    x360_pads.sort! {|a,b| (a.unplugged ? 1 : 0) <=> (b.unplugged ? 1 : 0)}
    devcaps = "\0"*404
    16.times do |i|
      Multimedia_Gamepad::JoyGetDevCaps.call(i, devcaps, 404)
      mid = devcaps.unpack('S')[0]
      if mid == 1118 and !x360_pads.empty?
        Gamepads << x360_pads.shift
      elsif mid != 0
        Gamepads << Multimedia_Gamepad.new(i)
      end
    end
    Gamepads.sort! {|a,b| (a.unplugged ? 1 : 0) <=> (b.unplugged ? 1 : 0)}
    Gamepads.each {|g| g.enabled = false}
    Players.each {|p| p.gamepad_id += 0}
  end
  
  # Le rythme de la fonction repeat? quand on maintient une touche appuyée.
  # La fonction repeat? est utilisée dans les menus pour bouger le curseur par exemple.
  f = Graphics.frame_rate
  REPEAT = [ # (se lit de bas en haut)
    #[f*4, 1],           # Après 4 secondes retourne toujours true.
    #[f*2, f*0.05],    # Après 2 secondes retourne true toutes les 0.05 secondes.
    [f*0.4, f*0.1], # Après 0.4 secondes retourne true toutes les 0.1 secondes.
    [2, 0],       # ...puis retourne false (à partir de la 2ème frame).
    [1, 1]      # Retourne true quand on vient d'appuyer (la 1ère frame)...
  ]
  PLAYERS_MAX = 1 # Le nombre de joueurs pour les jeux multijoueurs.
  KEYS_MAX = 30 # Nombre de touches, on peut mettre un très grand nombre si on
                # veut mais le limiter au minimum sert à optimiser la mémoire.
  
  Gamepads, Players = [], Array.new(PLAYERS_MAX) {|i| Player.new(i)}
  singleton_attach_methods(Players[0])
  class Player
    Keys = Array.new(KEYS_MAX) {|i| Player_Key.new(i)}
    # Les différentes touches du jeu (id entre 0 et KEYS_MAX-1).
    DOWN  = Keys[2]
    LEFT  = Keys[4]
    RIGHT = Keys[6]
    UP    = Keys[8]
    A     = Keys[11]
    B     = Keys[12]
    C     = Keys[13]
    X     = Keys[14]
    Y     = Keys[15]
    Z     = Keys[16]
    L     = Keys[17]
    R     = Keys[18]
    SHIFT = Keys[21]
    CTRL  = Keys[22]
    ALT   = Keys[23]
    F5    = Keys[25]
    F6    = Keys[26]
    F7    = Keys[27]
    F8    = Keys[28]
    F9    = Keys[29]
    
    constants.each {|s| Input.const_set(s,k=const_get(s)); k.s = s.to_s if k.is_a?(Key)}
  end
  
  # La config par défaut des touches.
  # En cas de jeu multijoueur il en faut une différente pour chaque joueur.
  # Liste des touches du clavier ligne 862.
  # Liste des touches XBox360 ligne 689, pour manette random ligne 681.
  # Mais inutile de mettre les deux, par exemple :A et :Button1 sont la même
  # touche, si moi j'utilise celles d'XBox c'est juste parce que ça me semble
  # plus logique de régler les touches par rapport à une config connue.
  # Le mieux étant de faire un menu où le joueur peut configurer lui même tout ça.
  # Le format est très simple, à gauche les touches virtuelles du jeu, à droite
  # un tableau des touches correspondantes séparé en deux, 1ère colonne les
  # touches de la manette, 2ème colonne les touches du clavier.
  # Pour les jeux multijoueurs la config des manettes se fait pareillement pour
  # tous, la différenciation des manettes se fait en interne.
  # Config du joueur 1 :
  Players[0].setup(
    :DOWN  => [ [:AxisLY_0, :DPadDown] , [:Down]                 ],
    :LEFT  => [ [:AxisLX_0, :DPadLeft] , [:Left]                 ],
    :RIGHT => [ [:AxisLX_1, :DPadRight], [:Right]                ],
    :UP    => [ [:AxisLY_1, :DPadUp]   , [:Up]                   ],
    :A     => [ [:X]                   , [:Z, :Shift]            ],
    :B     => [ [:Y]                   , [:X, :NumPad0, :Escape] ],
    :C     => [ [:A]                   , [:C, :Enter, :Space]    ],
    :X     => [ [:B]                   , [:A]                    ],
    :Y     => [ [:LT]                  , [:S]                    ],
    :Z     => [ [:RT]                  , [:D]                    ],
    :L     => [ [:LB]                  , [:Q, :PageUp]           ],
    :R     => [ [:RB]                  , [:W, :PageDown]         ],
    :SHIFT => [ []                     , [:Shift]                ],
    :CTRL  => [ []                     , [:Control]              ],
    :ALT   => [ []                     , [:Alt]                  ],
    :F5    => [ []                     , [:F5]                   ],
    :F6    => [ []                     , [:F6]                   ],
    :F7    => [ []                     , [:F7]                   ],
    :F8    => [ []                     , [:F8]                   ],
    :F9    => [ []                     , [:F9]                   ])
  
  refresh
  update
  Keyboard.release!(0...256) if Keyboard.push?(*0...256)
end