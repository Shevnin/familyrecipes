import Foundation

struct ChefSplashItem: Identifiable {
    let id = UUID()
    let chefName: String
    let chefTitle: String
    let imageName: String
    // Localised quote shown in UI
    let quoteRu: String
    // Original quote text — preserved for verification
    let quoteEn: String
    // Verifiable source for the quote
    let quoteSourceUrl: String
    // Photo credit shown in in-app attribution
    let photoAttribution: String
    // SPDX-style license identifier
    let photoLicense: String
    // Wikimedia Commons page for the photo
    let photoSourceUrl: String
}

enum ChefSplashData {
    static let all: [ChefSplashItem] = [
        // 1
        ChefSplashItem(
            chefName: "Ален Дюкасс",
            chefTitle: "3 ресторана с тремя звёздами Michelin",
            imageName: "chef_ducasse",
            quoteRu: "Готовить — значит отдавать себя и делать себя желанным.",
            quoteEn: "Cooking is a way of giving and of making yourself desirable.",
            quoteSourceUrl: "https://www.brainyquote.com/authors/alain-ducasse-quotes",
            photoAttribution: "Wikialainducasse",
            photoLicense: "CC BY-SA 4.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Alain-Ducasse.jpg"
        ),
        // 2
        ChefSplashItem(
            chefName: "Гордон Рамзи",
            chefTitle: "16 звёзд Michelin",
            imageName: "chef_ramsay",
            quoteRu: "Готовка — это страсть, и потому она может казаться несколько темпераментной — слишком напористой для непосвящённого взгляда.",
            quoteEn: "Cooking is about passion, so it may look slightly temperamental in a way that it's too assertive to the naked eye.",
            quoteSourceUrl: "https://www.brainyquote.com/quotes/gordon_ramsay_455534",
            photoAttribution: "Dave Pullig",
            photoLicense: "CC BY 2.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Gordon_Ramsay_(262930770).jpg"
        ),
        // 3
        ChefSplashItem(
            chefName: "Массимо Боттура",
            chefTitle: "Osteria Francescana, три звезды Michelin",
            imageName: "chef_bottura",
            quoteRu: "Кухня — это место для творчества, а творчество требует смелости.",
            quoteEn: "The kitchen is a place of creativity, and creativity requires courage.",
            quoteSourceUrl: "https://guide.michelin.com/en/article/people/massimo-bottura-getting-real-and-impacting-change-with-food",
            photoAttribution: "Paola Sucato",
            photoLicense: "CC BY 2.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Massimo_Bottura_(6871034795).jpg"
        ),
        // 4
        ChefSplashItem(
            chefName: "Ферран Адриа",
            chefTitle: "elBulli — пять раз лучший ресторан мира",
            imageName: "chef_adria",
            quoteRu: "Творчество — значит не копировать.",
            quoteEn: "Creativity means not copying.",
            quoteSourceUrl: "https://www.brainyquote.com/quotes/ferran_adria_536117",
            photoAttribution: "Charles Haynes",
            photoLicense: "CC BY-SA 2.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Ferran_Adri%C3%A0_a_El_Bulli.jpg"
        ),
        // 5
        ChefSplashItem(
            chefName: "Хестон Блюменталь",
            chefTitle: "The Fat Duck, три звезды Michelin",
            imageName: "chef_blumenthal",
            quoteRu: "Еда — это воспоминания. Это семья. Это идентичность.",
            quoteEn: "Food is about memory, it's about family, it's about identity.",
            quoteSourceUrl: "https://www.brainyquote.com/authors/heston-blumenthal-quotes",
            photoAttribution: "Garry Knight",
            photoLicense: "CC BY-SA 2.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Heston_Blumenthal.jpg"
        ),
        // 6
        ChefSplashItem(
            chefName: "Грант Акатц",
            chefTitle: "Alinea, три звезды Michelin",
            imageName: "chef_achatz",
            quoteRu: "Лучшие блюда — те, что вызывают эмоцию, а не просто заполняют желудок.",
            quoteEn: "The best dishes are those that evoke an emotion, not just fill a stomach.",
            quoteSourceUrl: "https://www.brainyquote.com/quotes/grant_achatz_536150",
            photoAttribution: "Stuart Spivack",
            photoLicense: "CC BY-SA 2.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Grant_Achatz_(2741056506).jpg"
        ),
        // 7
        ChefSplashItem(
            chefName: "Хосе Андрес",
            chefTitle: "2 ресторана с тремя звёздами Michelin",
            imageName: "chef_andres",
            quoteRu: "Еда — универсальный язык доброты.",
            quoteEn: "Food is the universal language of kindness.",
            quoteSourceUrl: "https://www.brainyquote.com/quotes/jose_andres_653367",
            photoAttribution: "U.S. Embassy Kyiv Ukraine",
            photoLicense: "Public domain",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Jose_Andres_2022.jpg"
        ),
        // 8
        ChefSplashItem(
            chefName: "Марко Пьер Уайт",
            chefTitle: "Первый британский шеф с тремя звёздами Michelin",
            imageName: "chef_white",
            quoteRu: "Готовь с любовью, готовь с чувством — и еда будет вкуснее.",
            quoteEn: "If you cook with love, if you cook with emotion, the food will taste better.",
            quoteSourceUrl: "https://www.brainyquote.com/authors/marco-pierre-white-quotes",
            photoAttribution: "MBC Foods",
            photoLicense: "CC BY 2.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Festival_superstar_Marco_Pierre_White_(33584285184).jpg"
        ),
        // 9
        ChefSplashItem(
            chefName: "Анн-Софи Пик",
            chefTitle: "Maison Pic, три звезды Michelin",
            imageName: "chef_pic",
            quoteRu: "Моя кухня — это кухня эмоций.",
            quoteEn: "My cuisine is an emotional cuisine.",
            quoteSourceUrl: "https://guide.michelin.com/en/article/people/anne-sophie-pic",
            photoAttribution: "Anne-Sophie Pic (MarqueDigitale)",
            photoLicense: "CC BY-SA 4.0",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Portrait_d%27Anne-Sophie_Pic.jpg"
        ),
        // 10
        ChefSplashItem(
            chefName: "Йотам Оттоленги",
            chefTitle: "Автор кулинарных бестселлеров, Лондон",
            imageName: "chef_ottolenghi",
            quoteRu: "Еда — это способ объединять людей. Это самое прямое выражение заботы.",
            quoteEn: "Food is a vehicle to bring people together. It's the most direct expression of care.",
            quoteSourceUrl: "https://www.theguardian.com/profile/yotamottolenghi",
            photoAttribution: "Keiko Oikawa",
            photoLicense: "Public domain",
            photoSourceUrl: "https://commons.wikimedia.org/wiki/File:Yotam_Ottolenghi.jpg"
        ),
    ]

    static func random() -> ChefSplashItem {
        all.randomElement()!
    }
}
