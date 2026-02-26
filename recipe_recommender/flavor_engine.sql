CREATE TABLE IF NOT EXISTS article_flavor_profile (
    article_id INTEGER PRIMARY KEY,

    -- SMAK
    slodki INTEGER DEFAULT 0,
    slony INTEGER DEFAULT 0,
    kwasny INTEGER DEFAULT 0,
    gorzki INTEGER DEFAULT 0,
    umami INTEGER DEFAULT 0,
    pikantny INTEGER DEFAULT 0,
    wytrawny INTEGER DEFAULT 0,

    -- TEKSTURA
    kremowy INTEGER DEFAULT 0,
    chrupiacy INTEGER DEFAULT 0,
    tlusty INTEGER DEFAULT 0,

    -- TYP BIAŁKA / DIETA
    miesny INTEGER DEFAULT 0,
    rybny INTEGER DEFAULT 0,
    nabial INTEGER DEFAULT 0,
    roslinne_bialko INTEGER DEFAULT 0,
    wegetarianski INTEGER DEFAULT 0,
    weganski INTEGER DEFAULT 0,

    -- MAKRO
    poziom_bialka INTEGER DEFAULT 0,
    wysokobialkowy INTEGER DEFAULT 0,

    -- TECHNIKA OBRÓBKI
    smazony INTEGER DEFAULT 0,
    pieczony INTEGER DEFAULT 0,
    gotowany INTEGER DEFAULT 0,
    grillowany INTEGER DEFAULT 0,

    -- TYP DANIA
    deser INTEGER DEFAULT 0,
    zupa INTEGER DEFAULT 0,
    salatka INTEGER DEFAULT 0,
    makaron INTEGER DEFAULT 0,
    danie_glowne INTEGER DEFAULT 0,

    -- CHARAKTER
    fastfood INTEGER DEFAULT 0,
    comfort_food INTEGER DEFAULT 0,
    zdrowy INTEGER DEFAULT 0,
    bezglutenowy INTEGER DEFAULT 0,

    -- KUCHNIA
    kuchnia_wloska INTEGER DEFAULT 0,
    kuchnia_azjatycka INTEGER DEFAULT 0,
    kuchnia_meksykanska INTEGER DEFAULT 0,
    kuchnia_polska INTEGER DEFAULT 0,

    -- KALORYCZNOŚĆ
    niskokaloryczny INTEGER DEFAULT 0,
    wysokokaloryczny INTEGER DEFAULT 0,

    FOREIGN KEY(article_id) REFERENCES articles(id)
);

INSERT OR IGNORE INTO article_flavor_profile (article_id)
SELECT id FROM articles;

UPDATE article_flavor_profile
SET 
    miesny = 0,
    wegetarianski = 0,
    weganski = 0,
    poziom_bialka = 0,
    wysokobialkowy = 0,
    smazony = 0,
    pieczony = 0,
    gotowany = 0,
    grillowany = 0;


UPDATE article_flavor_profile
SET miesny = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%kurczak%' OR
        LOWER(a.title) LIKE '%indyk%' OR
        LOWER(a.title) LIKE '%wołowin%' OR
        LOWER(a.title) LIKE '%wieprzowin%' OR
        LOWER(a.title) LIKE '%kaczka%' OR
        LOWER(a.title) LIKE '%baranin%' OR
        LOWER(a.title) LIKE '%cielęcin%' OR
        LOWER(a.title) LIKE '%boczek%' OR
        LOWER(a.title) LIKE '%szynk%' OR
        LOWER(a.title) LIKE '%kiełbas%' OR
        LOWER(a.title) LIKE '%salami%' OR
        LOWER(a.title) LIKE '%stek%' OR
        LOWER(a.title) LIKE '%burger%' OR
        LOWER(i.name) LIKE '%mięso%' OR
        LOWER(a.title) LIKE '%stek%'
    )
);

UPDATE article_flavor_profile
SET rybny = 1
WHERE EXISTS (
    SELECT 1 FROM articles a
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%łosoś%' OR
        LOWER(a.title) LIKE '%dorsz%' OR
        LOWER(a.title) LIKE '%tuńczyk%' OR
        LOWER(a.title) LIKE '%ryb%'
    )
);


UPDATE article_flavor_profile
SET wegetarianski = 1
WHERE miesny = 0;

UPDATE article_flavor_profile
SET nabial = 1
WHERE EXISTS (
    SELECT 1 FROM articles a
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%ser%' OR
        LOWER(a.title) LIKE '%mleko%' OR
        LOWER(a.title) LIKE '%śmietan%' OR
        LOWER(a.title) LIKE '%twaróg%'
    )
);

UPDATE article_flavor_profile
SET roslinne_bialko = 1
WHERE EXISTS (
    SELECT 1 FROM articles a
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%soczewic%' OR
        LOWER(a.title) LIKE '%ciecierzyc%' OR
        LOWER(a.title) LIKE '%fasol%' OR
        LOWER(a.title) LIKE '%tofu%'
    )
);

UPDATE article_flavor_profile
SET wegetarianski = 1
WHERE miesny = 0 AND rybny = 0;

UPDATE article_flavor_profile
SET weganski = 1
WHERE wegetarianski = 1
AND nabial = 0;


UPDATE article_flavor_profile
SET weganski = 1
WHERE NOT EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%kurczak%' OR
        LOWER(a.title) LIKE '%wołowin%' OR
        LOWER(a.title) LIKE '%jajk%' OR
        LOWER(a.title) LIKE '%mleko%' OR
        LOWER(a.title) LIKE '%śmietan%' OR
        LOWER(a.title) LIKE '%ser%' OR
        LOWER(a.title) LIKE '%masło%' OR
        LOWER(i.name) LIKE '%jajk%' OR
        LOWER(i.name) LIKE '%ser%' OR
        LOWER(i.name) LIKE '%mleko%'
    )
);


UPDATE article_flavor_profile
SET poziom_bialka = (
    SELECT MIN(COUNT(*) * 2, 10)
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%kurczak%' OR
        LOWER(a.title) LIKE '%tuńczyk%' OR
        LOWER(a.title) LIKE '%łosoś%' OR
        LOWER(a.title) LIKE '%jajk%' OR
        LOWER(a.title) LIKE '%twaróg%' OR
        LOWER(a.title) LIKE '%soczewic%' OR
        LOWER(i.name) LIKE '%tofu%' OR
        LOWER(i.name) LIKE '%fasol%'
    )
);



UPDATE article_flavor_profile
SET wysokobialkowy = 1
WHERE poziom_bialka >= 6;


UPDATE article_flavor_profile
SET smazony = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_tags at ON at.article_id = a.id
    LEFT JOIN tags t ON t.id = at.tag_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%smaż%' OR
        LOWER(a.keywords) LIKE '%smaż%' OR
        LOWER(a.og_description) LIKE '%smaż%' OR
        LOWER(t.name) LIKE '%smaż%'
    )
);


UPDATE article_flavor_profile
SET pieczony = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_tags at ON at.article_id = a.id
    LEFT JOIN tags t ON t.id = at.tag_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%pieczo%' OR
        LOWER(a.keywords) LIKE '%piekarnik%' OR
        LOWER(t.name) LIKE '%pieczo%'
    )
);



UPDATE article_flavor_profile
SET gotowany = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_tags at ON at.article_id = a.id
    LEFT JOIN tags t ON t.id = at.tag_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%gotow%' OR
        LOWER(a.keywords) LIKE '%gotow%' OR
        LOWER(t.name) LIKE '%gotow%'
    )
);



UPDATE article_flavor_profile
SET grillowany = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_tags at ON at.article_id = a.id
    LEFT JOIN tags t ON t.id = at.tag_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%grill%' OR
        LOWER(a.keywords) LIKE '%grill%' OR
        LOWER(t.name) LIKE '%grill%'
    )
);

UPDATE article_flavor_profile
SET slodki = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%ciasto%' OR
        LOWER(a.title) LIKE '%tort%' OR
        LOWER(a.title) LIKE '%deser%' OR
        LOWER(a.title) LIKE '%czekolad%' OR
        LOWER(a.title) LIKE '%karmel%' OR
        LOWER(a.title) LIKE '%miód%' OR
        LOWER(a.title) LIKE '%cukier%' OR
        LOWER(a.title) LIKE '%lody%' OR
        LOWER(a.title) LIKE '%budyń%' OR
        LOWER(i.name) LIKE '%cukier%' OR
        LOWER(i.name) LIKE '%czekolad%'
    )
);



UPDATE article_flavor_profile
SET slony = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%ser%' OR
        LOWER(a.title) LIKE '%bekon%' OR
        LOWER(a.title) LIKE '%szynk%' OR
        LOWER(i.name) LIKE '%sól%' OR
        LOWER(i.name) LIKE '%oliwk%'
    )
);

UPDATE article_flavor_profile
SET kwasny = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%cytryn%' OR
        LOWER(a.title) LIKE '%limonk%' OR
        LOWER(a.title) LIKE '%ocet%' OR
        LOWER(a.title) LIKE '%kiszon%' OR
        LOWER(i.name) LIKE '%cytryn%'
    )
);

UPDATE article_flavor_profile
SET pikantny = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%chili%' OR
        LOWER(a.title) LIKE '%ostry%' OR
        LOWER(a.title) LIKE '%jalapen%' OR
        LOWER(a.title) LIKE '%paprycz%' OR
        LOWER(i.name) LIKE '%pieprz%'
    )
);


UPDATE article_flavor_profile
SET umami = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%grzyb%' OR
        LOWER(a.title) LIKE '%parmezan%' OR
        LOWER(a.title) LIKE '%soja%' OR
        LOWER(a.title) LIKE '%bulion%' OR
        LOWER(i.name) LIKE '%grzyb%'
    )
);

UPDATE article_flavor_profile
SET kremowy = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%krem%' OR
        LOWER(a.title) LIKE '%śmietan%' OR
        LOWER(a.title) LIKE '%sos%' OR
        LOWER(i.name) LIKE '%śmietana%'
    )
);


UPDATE article_flavor_profile
SET chrupiacy = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%chrup%' OR
        LOWER(a.title) LIKE '%prażon%' OR
        LOWER(a.title) LIKE '%chips%'
    )
);

UPDATE article_flavor_profile
SET tlusty = 1
WHERE EXISTS (
    SELECT 1
    FROM articles a
    LEFT JOIN article_ingredients ai ON ai.article_id = a.id
    LEFT JOIN ingredients i ON i.id = ai.ingredient_id
    WHERE a.id = article_flavor_profile.article_id
    AND (
        LOWER(a.title) LIKE '%smażon%' OR
        LOWER(i.name) LIKE '%masło%' OR
        LOWER(i.name) LIKE '%olej%' OR
        LOWER(i.name) LIKE '%smalec%'
    )
);


UPDATE article_flavor_profile
SET poziom_bialka =
    (miesny * 4) +
    (rybny * 4) +
    (nabial * 2) +
    (roslinne_bialko * 2);

UPDATE article_flavor_profile
SET wysokobialkowy = 1
WHERE poziom_bialka >= 4;


UPDATE article_flavor_profile
SET deser = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%ciasto%');

UPDATE article_flavor_profile
SET zupa = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%zupa%');

UPDATE article_flavor_profile
SET salatka = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%sałat%');

UPDATE article_flavor_profile
SET makaron = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%makaron%');

UPDATE article_flavor_profile
SET danie_glowne = 1
WHERE deser = 0 AND zupa = 0;


UPDATE article_flavor_profile
SET fastfood = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%burger%');

UPDATE article_flavor_profile
SET comfort_food = 1
WHERE tlusty = 1 OR fastfood = 1;

UPDATE article_flavor_profile
SET zdrowy = 1
WHERE roslinne_bialko = 1 OR salatka = 1;

UPDATE article_flavor_profile
SET bezglutenowy = 1
WHERE NOT EXISTS (
    SELECT 1 FROM articles a
    WHERE a.id = article_flavor_profile.article_id
    AND LOWER(a.title) LIKE '%makaron%'
);

UPDATE article_flavor_profile
SET kuchnia_wloska = 1
WHERE makaron = 1;

UPDATE article_flavor_profile
SET kuchnia_azjatycka = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%ramen%');

UPDATE article_flavor_profile
SET kuchnia_meksykanska = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%taco%');

UPDATE article_flavor_profile
SET kuchnia_polska = 1
WHERE EXISTS (SELECT 1 FROM articles a
              WHERE a.id = article_flavor_profile.article_id
              AND LOWER(a.title) LIKE '%pierog%');

UPDATE article_flavor_profile
SET wysokokaloryczny = 1
WHERE tlusty = 1 OR fastfood = 1;

UPDATE article_flavor_profile
SET niskokaloryczny = 1
WHERE zdrowy = 1 AND wysokokaloryczny = 0;