-- -- -- -- -- -- -- -- -- -- -- --
-- -- -- Requetes simples :-- -- -- (5 requetes)
-- -- -- -- -- -- -- -- -- -- -- --

-->
-- Afficher le nom et le prenom des employe(e)s
-- dont leurs age est de 35 ans.
--> OK

SELECT E.Nom, E.Prenom
FROM Employe E
WHERE E.Age = 35
ORDER BY E.Nom;

-->
-- Afficher le nombre de personnes travaillant le jour.
--> OK

SELECT DISTINCT COUNT(E.Nom) as nombre_de_pers_de_jour
FROM Employe E
WHERE E.Horaires like "07H%";

-->
-- Afficher le nombre de magasin de type "proxi" par zone.
--> OK

SELECT M.Zone, COUNT(M.Zone) as nombre_de_magasin
FROM Magasin M
WHERE M.Taille like "Proxymité"
GROUP BY M.Zone;

-->
-- Afficher le nom et le prenom des employe(e)s dont leurs
-- contrat est de type "CDI".
--> OK

SELECT E.Nom, E.Prenom
FROM Employe E, Contrat C, Signe S
WHERE E.Matricule = S.Matricule
AND S.Numero_contrat = C.Numero_contrat
AND C.Type like "CDI"
ORDER BY E.Nom;

-->
-- Afficher la somme total, la date d'achat, et le
-- nombres de produit des paniers d achat effectue dans
-- un magasin de taille "hyper".
--> OK

SELECT P.date, P.Nombre_produit, P.Somme_total, M.Identifiant
FROM Panier P, Magasin M
WHERE P.Id_m = M.Identifiant
AND M.Taille like "Hypermarché"
ORDER BY P.Date;

-- -- -- -- -- -- -- -- -- -- -- --
-- --  Requetes ensemblistes  -- --
-- -- --  ou imbriquées :  -- -- -- (7 requetes)
-- -- -- -- -- -- -- -- -- -- -- --

-->
-- Afficher l adresse et la zone des magasins possedant un ou
-- des produits de marque "danette".
--> Ok

SELECT M.Zone, M.adresse
FROM Magasin M, Livraison L, Produit P
WHERE M.Identifiant = L.Id_mag
AND L.Produit_livre = P.EAN
AND P.Marque = "Danette"
ORDER BY M.Zone;

-->
-- Afficher l adresse et la zone des magasins commandant un ou
-- des produits de marque "danette".
--> OK

SELECT M.Zone, M.adresse
FROM Magasin M, Commande C, Produit P, Envoie Ev
WHERE M.Identifiant = Ev.Identifiant_magasin
AND Ev.Numero_commande = C.Numero_commande
AND C.Produit_demande = P.EAN
AND P.Marque = "Danette"
ORDER BY M.Zone;

-->
-- Affiche le nombre d'hommes et de femmes dans la société
--> Ok

SELECT DISTINCT COUNT(E.Matricule) as nbr_employe, 
(SELECT COUNT(E.Matricule) FROM Employe E WHERE E.Sexe = 'F') as nbr_femme, 
(SELECT COUNT(E.Matricule) FROM Employe E WHERE E.Sexe = 'M') as nbr_homme
FROM Employe E;

-->
-- Afficher le pourcentage de femme dans la societe.
--> Ok

SELECT DISTINCT ROUND(((SELECT COUNT(E.Matricule) FROM Employe E WHERE E.Sexe = 'F')/(SELECT COUNT(E.Matricule) FROM Employe E)*100), 2) AS pourcentage_de_femme
FROM Employe E;

-->
-- Afficher le nom et le prenom des
-- employe(e)s qui ne sont pas en CDD.
--> Ok

SELECT DISTINCT E.Nom, E.Prenom
FROM Employe E
WHERE E.Nom NOT IN
(
  SELECT E.nom
  FROM Employe E, Contrat C, Signe S
  WHERE E.matricule = S.matricule
  AND S.numero_contrat = C.numero_contrat
  AND C.type like "CDD"
)
ORDER BY E.Nom;

-->
-- Afficher le nom des fournisseurs ne possedant pas des produits alimentaires.
-- Ok
-->

SELECT F.Nom, P.Type
FROM Fournisseur F, Produit P
WHERE F.Nom NOT IN
(
  SELECT F.Nom
  FROM Fournisseur F, Produit P
  WHERE F.Identifiant = P.Id_f
  AND P.Type like "alimentaire"
)
AND P.Id_f = F.Identifiant
ORDER BY F.Nom;

-->
-- Afficher le nombre d'heure de travail de chaque employe(e)s,
-- un employe(e) doit travailler entre 3 et 13h.
-- Ok
-->

SELECT E.Horaires,
(CASE
WHEN SUBSTRING_INDEX(E.Horaires, '-', -1) like '00h'
THEN '24h' - SUBSTRING_INDEX(E.Horaires, '-', 1)
WHEN SUBSTRING_INDEX(E.Horaires, '-', -1) - SUBSTRING_INDEX(E.Horaires, '-', 1) < 0
THEN '24H' - SUBSTRING_INDEX(E.Horaires, '-', 1) + SUBSTRING_INDEX(E.Horaires, '-', -1)
ELSE SUBSTRING_INDEX(E.Horaires, '-', -1) - SUBSTRING_INDEX(E.Horaires, '-', 1)
END) AS temps_travail
FROM Employe E
ORDER BY temps_travail;

-->
-- Afficher les dalais entre la commande et la date d'arrive.
-- OK
-->

SELECT C.Date as Date_commande,
L.Date_arrivee,
C.Numero_commande,
L.Numero_livraison,
(CASE
WHEN SUBSTRING_INDEX(L.Date_arrivee, '/', 2) < SUBSTRING_INDEX(C.Date, '/', 2)
THEN 'erreur'
ELSE 'OK'
END) AS diff_mois
FROM Commande C, Livraison L, Fournisseur F, Est_envoye Ev
WHERE C.Numero_commande = Ev.Numero_commande
AND Ev.Id_f = F.Identifiant
AND F.Identifiant = L.Id_f
ORDER BY diff_mois;

-->
-- Afficher classement des regions en fonction de leur benefices.
-- OK
-->

SELECT b.Benefice, b.Zone, RANK() OVER (ORDER BY b.Benefice DESC) AS rang
FROM benefice_par_region b;