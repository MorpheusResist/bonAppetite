import Foundation

enum SampleData {
    static let allergyOptions = ["Peanuts", "Tree Nuts", "Dairy", "Eggs", "Shellfish", "Soy", "Gluten", "Sesame"]
    static let cuisineOptions = ["Mediterranean", "Japanese", "Mexican", "Indian", "Italian", "Korean", "Thai", "American"]
    static let equipmentOptions = ["Skillet", "Sheet Pan", "Air Fryer", "Instant Pot", "Blender", "Oven", "Rice Cooker", "Pot", "Toaster", "Microwave"]

    static func pantryItems() -> [PantryItem] {
        [
            item("Baby Spinach", .produce, .fridge, 1, "bag", 1, 3.49, 25, 2.8),
            item("Greek Yogurt", .dairy, .fridge, 2, "cups", 2, 5.99, 130, 18),
            item("Firm Tofu", .protein, .fridge, 1, "block", 3, 3.49, 180, 20),
            item("Avocados", .produce, .fridge, 3, "each", 0, 5.99, 240, 3),
            item("Whole Milk", .dairy, .fridge, 0.5, "gallon", -1, 4.29, 150, 8),
            item("Eggs", .protein, .fridge, 8, "eggs", 6, 4.99, 70, 6),
            item("Chicken Thighs", .protein, .fridge, 1.5, "lb", 1, 8.75, 210, 24),
            item("Salmon Fillets", .protein, .freezer, 2, "fillets", 21, 13.99, 250, 30),
            item("Frozen Peas", .frozen, .freezer, 1, "bag", 60, 2.99, 80, 5),
            item("Frozen Berries", .frozen, .freezer, 1, "bag", 45, 4.99, 70, 1),
            item("Brown Rice", .grains, .pantry, 2, "lb", 120, 3.99, 216, 5),
            item("Jasmine Rice", .grains, .pantry, 1, "bag", 200, 4.49, 205, 4),
            item("Quinoa", .grains, .pantry, 1, "box", 90, 5.99, 222, 8),
            item("Pasta", .grains, .pantry, 1, "box", 75, 2.49, 200, 7),
            item("Canned Chickpeas", .canned, .pantry, 3, "cans", 365, 4.50, 210, 11),
            item("Black Beans", .canned, .pantry, 2, "cans", 365, 3.50, 220, 14),
            item("Crushed Tomatoes", .canned, .pantry, 2, "cans", 300, 3.99, 80, 3),
            item("Coconut Milk", .canned, .pantry, 1, "can", 180, 2.99, 150, 2),
            item("Rolled Oats", .grains, .pantry, 1, "canister", 110, 4.49, 150, 5),
            item("Sourdough Bread", .bakery, .pantry, 0.5, "loaf", 2, 5.49, 120, 4),
            item("Tortillas", .bakery, .pantry, 6, "wraps", 5, 3.99, 140, 4),
            item("Peanut Butter", .condiment, .pantry, 1, "jar", 90, 4.99, 190, 8),
            item("Tahini", .condiment, .pantry, 1, "jar", 120, 6.49, 180, 5),
            item("Soy Sauce", .condiment, .pantry, 1, "bottle", 300, 3.49, 10, 1),
            item("Miso Paste", .condiment, .fridge, 1, "tub", 40, 5.99, 35, 2),
            item("Cheddar", .dairy, .fridge, 1, "block", 4, 4.99, 115, 7),
            item("Mozzarella", .dairy, .fridge, 1, "ball", 1, 5.49, 85, 6),
            item("Mushrooms", .produce, .fridge, 1, "box", 2, 3.99, 20, 3),
            item("Bell Peppers", .produce, .fridge, 4, "each", 4, 5.50, 35, 1),
            item("Carrots", .produce, .fridge, 8, "each", 9, 2.99, 25, 1),
            item("Broccoli", .produce, .fridge, 2, "heads", 3, 4.49, 55, 4),
            item("Zucchini", .produce, .fridge, 3, "each", 2, 3.99, 30, 2),
            item("Cilantro", .produce, .fridge, 1, "bunch", 0, 1.49, 5, 0),
            item("Lemons", .produce, .fridge, 4, "each", 8, 2.49, 17, 0),
            item("Apples", .produce, .fridge, 5, "each", 14, 4.99, 95, 0),
            item("Bananas", .produce, .pantry, 5, "each", 2, 1.99, 105, 1),
            item("Garlic", .produce, .pantry, 2, "bulbs", 30, 1.50, 5, 0),
            item("Yellow Onions", .produce, .pantry, 5, "each", 20, 3.49, 44, 1),
            item("Cumin", .spices, .spices, 1, "jar", 500, 3.99, 8, 0),
            item("Smoked Paprika", .spices, .spices, 1, "jar", 500, 4.99, 6, 0),
            item("Turmeric", .spices, .spices, 1, "jar", 500, 4.49, 5, 0),
            item("Olive Oil", .condiment, .pantry, 1, "bottle", 180, 9.99, 120, 0),
            item("Sparkling Water", .beverage, .pantry, 6, "cans", 90, 5.99, 0, 0)
        ]
    }

    static func recipes() -> [Recipe] {
        [
            recipe("Green Shakshuka", "Skillet eggs with spinach and yogurt", "Mediterranean", [.vegetarian, .highProtein], ["Spinach", "Eggs", "Greek Yogurt", "Garlic", "Yellow Onions"], ["Soften onions and garlic in olive oil.", "Wilt spinach with cumin and a pinch of salt.", "Crack in eggs, cover, and cook until just set.", "Spoon yogurt over the pan and finish with lemon."], [4, 4, 6, 1], ["Skillet"], 15, 430, 29, 6.2),
            recipe("Avocado Chickpea Toast", "Fast lunch using ripe avocados", "American", [.vegetarian, .highProtein], ["Avocados", "Canned Chickpeas", "Sourdough Bread", "Lemons"], ["Toast bread until crisp.", "Mash chickpeas with avocado, lemon, olive oil, and salt.", "Pile onto toast and finish with paprika."], [3, 4, 1], ["Toaster"], 8, 510, 19, 4.4),
            recipe("Miso Mushroom Rice Bowl", "Savory bowl with freezer peas", "Japanese", [.vegetarian], ["Miso Paste", "Mushrooms", "Jasmine Rice", "Frozen Peas", "Soy Sauce"], ["Cook rice or warm leftover rice.", "Brown mushrooms until deeply golden.", "Stir miso with soy and a splash of water.", "Fold peas into the pan and serve over rice."], [12, 7, 2, 2], ["Rice Cooker", "Skillet"], 23, 560, 18, 5.8),
            recipe("Sheet Pan Chicken Fajitas", "Uses peppers before they soften", "Mexican", [.highProtein], ["Chicken Thighs", "Bell Peppers", "Yellow Onions", "Tortillas", "Cumin"], ["Slice chicken, peppers, and onions.", "Toss with cumin, paprika, olive oil, and salt.", "Roast on a hot sheet pan until browned.", "Serve in warm tortillas with cilantro."], [6, 3, 18, 2], ["Sheet Pan", "Oven"], 29, 640, 38, 8.9),
            recipe("Broccoli Cheddar Pasta", "Comfort pasta with a produce boost", "Italian", [.vegetarian], ["Broccoli", "Cheddar", "Pasta", "Whole Milk", "Garlic"], ["Boil pasta and add broccoli for the last three minutes.", "Make a quick garlic milk sauce.", "Melt cheddar into the sauce.", "Toss pasta and broccoli until glossy."], [11, 5, 3, 2], ["Pot"], 21, 690, 31, 6.7),
            recipe("Coconut Chickpea Curry", "Pantry curry with fresh cilantro", "Indian", [.vegan, .dairyFree], ["Canned Chickpeas", "Coconut Milk", "Crushed Tomatoes", "Turmeric", "Cilantro"], ["Toast spices in oil.", "Simmer tomatoes and coconut milk.", "Add chickpeas and cook until creamy.", "Finish with cilantro and lemon."], [3, 12, 5, 1], ["Pot"], 21, 540, 17, 5.4),
            recipe("Salmon Rice Plates", "Freezer-friendly protein dinner", "Japanese", [.pescatarian, .highProtein], ["Salmon Fillets", "Jasmine Rice", "Soy Sauce", "Broccoli", "Lemons"], ["Roast or pan-sear salmon.", "Steam broccoli.", "Season rice with soy and lemon.", "Serve with extra lemon wedges."], [10, 5, 2, 1], ["Skillet", "Rice Cooker"], 18, 610, 42, 11.2),
            recipe("Tofu Veggie Stir-Fry", "High-protein vegetarian skillet", "Korean", [.vegetarian, .highProtein, .dairyFree], ["Firm Tofu", "Broccoli", "Carrots", "Soy Sauce", "Garlic"], ["Press and cube tofu.", "Sear tofu until crisp.", "Stir-fry vegetables with garlic.", "Toss everything with soy sauce."], [5, 8, 6, 2], ["Skillet"], 21, 470, 28, 6.0),
            recipe("Berry Yogurt Oat Bowl", "No-cook breakfast", "American", [.vegetarian, .highProtein], ["Greek Yogurt", "Frozen Berries", "Rolled Oats", "Peanut Butter"], ["Stir yogurt with oats.", "Warm berries until saucy.", "Top yogurt with berries and peanut butter."], [2, 3, 1], ["Microwave"], 6, 450, 26, 3.8),
            recipe("Black Bean Tacos", "Budget pantry tacos", "Mexican", [.vegan, .dairyFree], ["Black Beans", "Tortillas", "Avocados", "Cilantro", "Cumin"], ["Warm beans with cumin.", "Char tortillas.", "Slice avocado and chop cilantro.", "Build tacos with beans, avocado, and lemon."], [5, 2, 2, 1], ["Skillet"], 10, 520, 20, 4.6),
            recipe("Mozzarella Mushroom Toasts", "Use bread and cheese while fresh", "Italian", [.vegetarian], ["Mozzarella", "Mushrooms", "Sourdough Bread", "Garlic"], ["Toast bread.", "Saute mushrooms with garlic.", "Top toast with mozzarella and mushrooms.", "Broil until melted."], [3, 6, 3, 1], ["Oven", "Skillet"], 13, 490, 23, 5.1),
            recipe("Quinoa Crunch Salad", "Bright meal prep lunch", "Mediterranean", [.vegan, .glutenFree], ["Quinoa", "Carrots", "Lemons", "Cilantro", "Tahini"], ["Cook quinoa and cool slightly.", "Shave carrots.", "Whisk tahini with lemon and water.", "Toss everything with herbs."], [15, 4, 3, 1], ["Pot"], 23, 430, 14, 4.8),
            recipe("Pea Pesto Pasta", "Freezer peas become a sauce", "Italian", [.vegetarian], ["Frozen Peas", "Pasta", "Lemons", "Olive Oil", "Garlic"], ["Boil pasta and peas.", "Blend peas with lemon, garlic, and olive oil.", "Toss sauce with pasta water until silky."], [10, 4, 2], ["Blender", "Pot"], 16, 590, 21, 4.2),
            recipe("Stuffed Pepper Skillet", "No-fuss stuffed pepper flavors", "Mexican", [.glutenFree], ["Bell Peppers", "Black Beans", "Brown Rice", "Crushed Tomatoes", "Cheddar"], ["Cook peppers and onions.", "Stir in rice, beans, and tomatoes.", "Simmer until thick.", "Top with cheddar."], [6, 4, 8, 2], ["Skillet"], 20, 610, 25, 6.9),
            recipe("Carrot Ginger Soup", "Simple produce rescue soup", "Thai", [.vegan, .dairyFree, .glutenFree], ["Carrots", "Coconut Milk", "Yellow Onions", "Turmeric", "Lemons"], ["Soften onions and carrots.", "Add turmeric and water, then simmer.", "Blend with coconut milk.", "Finish with lemon."], [6, 15, 2, 1], ["Blender", "Pot"], 24, 360, 6, 4.0),
            recipe("Zucchini Egg Scramble", "Breakfast-for-dinner in minutes", "American", [.vegetarian, .highProtein], ["Zucchini", "Eggs", "Cheddar", "Cilantro"], ["Grate zucchini and squeeze lightly.", "Scramble eggs in a skillet.", "Fold in zucchini and cheddar.", "Finish with cilantro."], [4, 4, 2, 1], ["Skillet"], 11, 390, 27, 4.3),
            recipe("Chicken Avocado Rice Bowls", "High protein bowl with ripe avocado", "Mexican", [.highProtein, .glutenFree], ["Chicken Thighs", "Avocados", "Brown Rice", "Cilantro", "Lemons"], ["Season and sear chicken.", "Warm rice.", "Mash avocado with lemon.", "Assemble bowls with cilantro."], [12, 3, 2, 1], ["Skillet"], 18, 720, 44, 8.4),
            recipe("Miso Broccoli Tofu Soup", "Light soup with pantry umami", "Japanese", [.vegetarian, .dairyFree], ["Miso Paste", "Firm Tofu", "Broccoli", "Soy Sauce"], ["Simmer broccoli until tender.", "Add cubed tofu.", "Whisk miso into warm broth off heat.", "Season with soy sauce."], [6, 4, 2, 1], ["Pot"], 13, 310, 22, 4.9),
            recipe("Apple Peanut Oat Bake", "Cozy breakfast using apples", "American", [.vegetarian], ["Apples", "Rolled Oats", "Peanut Butter", "Whole Milk"], ["Dice apples.", "Mix oats, milk, peanut butter, and apples.", "Bake until set and golden.", "Cool briefly before serving."], [5, 4, 22, 2], ["Oven"], 33, 480, 17, 4.5),
            recipe("Spiced Chickpea Wraps", "Pantry wraps with crunchy carrots", "Mediterranean", [.vegan, .dairyFree], ["Canned Chickpeas", "Tortillas", "Carrots", "Tahini", "Smoked Paprika"], ["Crisp chickpeas with paprika.", "Shred carrots.", "Thin tahini with lemon and water.", "Fill tortillas and roll."], [8, 3, 2, 1], ["Skillet"], 14, 530, 18, 4.7)
        ]
    }

    static func shoppingItems() -> [ShoppingItem] {
        [
            ShoppingItem(name: "Fresh basil", category: .produce, quantity: 1, unit: "bunch", source: "Pea Pesto Pasta"),
            ShoppingItem(name: "Coffee", category: .beverage, quantity: 1, unit: "bag", source: "Running low"),
            ShoppingItem(name: "Dish soap", category: .other, quantity: 1, unit: "bottle", source: "Manual")
        ]
    }

    static func analyticsEntries() -> [AnalyticsEntry] {
        let categories: [FoodCategory] = [.produce, .dairy, .protein, .grains, .produce, .canned, .produce, .protein]
        return (0..<28).map { offset in
            AnalyticsEntry(
                date: Date.daysFromNow(-27 + offset),
                foodSavedCount: [2, 1, 3, 0, 4, 2, 5][offset % 7],
                wastedCount: [0, 1, 0, 2, 0, 1, 0][offset % 7],
                moneySaved: Double([6, 4, 11, 2, 14, 8, 15][offset % 7]),
                category: categories[offset % categories.count]
            )
        }
    }

    static func item(_ name: String, _ category: FoodCategory, _ location: FoodLocation, _ quantity: Double, _ unit: String, _ days: Int, _ price: Double, _ calories: Int, _ protein: Double) -> PantryItem {
        PantryItem(
            name: name,
            category: category,
            location: location,
            quantity: quantity,
            unit: unit,
            expiryDate: Date.daysFromNow(days),
            purchaseDate: Date.daysFromNow(-max(1, min(14, 20 - days))),
            priceEstimate: price,
            caloriesPerUnit: calories,
            proteinPerUnit: protein,
            confidence: 0.86 + Double(abs(days) % 12) / 100
        )
    }

    static func recipe(
        _ title: String,
        _ subtitle: String,
        _ cuisine: String,
        _ diets: [DietTag],
        _ ingredients: [String],
        _ steps: [String],
        _ minutes: [Int],
        _ equipment: [String],
        _ cookTime: Int,
        _ calories: Int,
        _ protein: Int,
        _ cost: Double
    ) -> Recipe {
        Recipe(
            title: title,
            subtitle: subtitle,
            cuisine: cuisine,
            dietTags: diets,
            allergyWarnings: ingredients.contains(where: { $0.localizedCaseInsensitiveContains("Peanut") }) ? ["Peanuts"] : [],
            ingredients: ingredients,
            steps: steps,
            stepMinutes: minutes,
            equipment: equipment,
            cookTimeMinutes: cookTime,
            calories: calories,
            protein: protein,
            estimatedCost: cost
        )
    }
}
