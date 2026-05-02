import React, { useMemo, useState } from "react";
import {
  Alert,
  Appearance,
  FlatList,
  Modal,
  Platform,
  Pressable,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View
} from "react-native";
import { Ionicons } from "@expo/vector-icons";
import * as Haptics from "expo-haptics";
import * as ImagePicker from "expo-image-picker";
import * as Notifications from "expo-notifications";
import * as Speech from "expo-speech";
import { StatusBar as ExpoStatusBar } from "expo-status-bar";

const C = {
  basil: "#1f6b45",
  mint: "#a8d5ba",
  tomato: "#c84b38",
  lemon: "#e9bd3d",
  blueberry: "#435a95",
  ink: "#111817",
  cream: "#f6f2e8",
  card: "rgba(255,255,255,0.84)",
  darkCard: "rgba(24,33,31,0.88)",
  line: "rgba(31,107,69,0.16)"
};

const locations = ["Fridge", "Freezer", "Pantry", "Spices"];
const scanModes = ["Fridge", "Pantry", "Freezer", "Receipt", "Barcode", "Label"];
const diets = ["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "High Protein"];
const allergens = ["Peanuts", "Tree Nuts", "Dairy", "Eggs", "Shellfish", "Soy", "Gluten"];

const initialInventory = [
  item("Baby Spinach", "Produce", "Fridge", 1, "bag", 1, 3.49, 25, 3),
  item("Greek Yogurt", "Dairy", "Fridge", 2, "cups", 2, 5.99, 130, 18),
  item("Firm Tofu", "Protein", "Fridge", 1, "block", 3, 3.49, 180, 20),
  item("Avocados", "Produce", "Fridge", 3, "each", 0, 5.99, 240, 3),
  item("Whole Milk", "Dairy", "Fridge", 0.5, "gallon", -1, 4.29, 150, 8),
  item("Eggs", "Protein", "Fridge", 8, "eggs", 6, 4.99, 70, 6),
  item("Chicken Thighs", "Protein", "Fridge", 1.5, "lb", 1, 8.75, 210, 24),
  item("Salmon Fillets", "Protein", "Freezer", 2, "fillets", 21, 13.99, 250, 30),
  item("Frozen Peas", "Frozen", "Freezer", 1, "bag", 60, 2.99, 80, 5),
  item("Frozen Berries", "Frozen", "Freezer", 1, "bag", 45, 4.99, 70, 1),
  item("Brown Rice", "Grains", "Pantry", 2, "lb", 120, 3.99, 216, 5),
  item("Jasmine Rice", "Grains", "Pantry", 1, "bag", 200, 4.49, 205, 4),
  item("Quinoa", "Grains", "Pantry", 1, "box", 90, 5.99, 222, 8),
  item("Pasta", "Grains", "Pantry", 1, "box", 75, 2.49, 200, 7),
  item("Canned Chickpeas", "Canned", "Pantry", 3, "cans", 365, 4.5, 210, 11),
  item("Black Beans", "Canned", "Pantry", 2, "cans", 365, 3.5, 220, 14),
  item("Crushed Tomatoes", "Canned", "Pantry", 2, "cans", 300, 3.99, 80, 3),
  item("Coconut Milk", "Canned", "Pantry", 1, "can", 180, 2.99, 150, 2),
  item("Rolled Oats", "Grains", "Pantry", 1, "canister", 110, 4.49, 150, 5),
  item("Sourdough Bread", "Bakery", "Pantry", 0.5, "loaf", 2, 5.49, 120, 4),
  item("Tortillas", "Bakery", "Pantry", 6, "wraps", 5, 3.99, 140, 4),
  item("Peanut Butter", "Condiment", "Pantry", 1, "jar", 90, 4.99, 190, 8),
  item("Tahini", "Condiment", "Pantry", 1, "jar", 120, 6.49, 180, 5),
  item("Soy Sauce", "Condiment", "Pantry", 1, "bottle", 300, 3.49, 10, 1),
  item("Miso Paste", "Condiment", "Fridge", 1, "tub", 40, 5.99, 35, 2),
  item("Cheddar", "Dairy", "Fridge", 1, "block", 4, 4.99, 115, 7),
  item("Mozzarella", "Dairy", "Fridge", 1, "ball", 1, 5.49, 85, 6),
  item("Mushrooms", "Produce", "Fridge", 1, "box", 2, 3.99, 20, 3),
  item("Bell Peppers", "Produce", "Fridge", 4, "each", 4, 5.5, 35, 1),
  item("Carrots", "Produce", "Fridge", 8, "each", 9, 2.99, 25, 1),
  item("Broccoli", "Produce", "Fridge", 2, "heads", 3, 4.49, 55, 4),
  item("Zucchini", "Produce", "Fridge", 3, "each", 2, 3.99, 30, 2),
  item("Cilantro", "Produce", "Fridge", 1, "bunch", 0, 1.49, 5, 0),
  item("Lemons", "Produce", "Fridge", 4, "each", 8, 2.49, 17, 0),
  item("Apples", "Produce", "Fridge", 5, "each", 14, 4.99, 95, 0),
  item("Bananas", "Produce", "Pantry", 5, "each", 2, 1.99, 105, 1),
  item("Garlic", "Produce", "Pantry", 2, "bulbs", 30, 1.5, 5, 0),
  item("Yellow Onions", "Produce", "Pantry", 5, "each", 20, 3.49, 44, 1),
  item("Cumin", "Spices", "Spices", 1, "jar", 500, 3.99, 8, 0),
  item("Smoked Paprika", "Spices", "Spices", 1, "jar", 500, 4.99, 6, 0),
  item("Turmeric", "Spices", "Spices", 1, "jar", 500, 4.49, 5, 0),
  item("Olive Oil", "Condiment", "Pantry", 1, "bottle", 180, 9.99, 120, 0)
];

const recipes = [
  recipe("Green Shakshuka", "Skillet eggs with spinach and yogurt", "Mediterranean", ["Vegetarian", "High Protein"], ["Baby Spinach", "Eggs", "Greek Yogurt", "Garlic", "Yellow Onions"], ["Soften onions and garlic.", "Wilt spinach with cumin.", "Crack in eggs and cover.", "Finish with yogurt and lemon."], 15, 430, 29),
  recipe("Avocado Chickpea Toast", "Fast lunch using ripe avocados", "American", ["Vegetarian", "High Protein"], ["Avocados", "Canned Chickpeas", "Sourdough Bread", "Lemons"], ["Toast bread.", "Mash chickpeas with avocado and lemon.", "Pile onto toast.", "Finish with paprika."], 8, 510, 19),
  recipe("Miso Mushroom Rice Bowl", "Savory bowl with freezer peas", "Japanese", ["Vegetarian"], ["Miso Paste", "Mushrooms", "Jasmine Rice", "Frozen Peas", "Soy Sauce"], ["Cook rice.", "Brown mushrooms.", "Stir miso with soy.", "Serve peas and mushrooms over rice."], 23, 560, 18),
  recipe("Sheet Pan Chicken Fajitas", "Uses peppers before they soften", "Mexican", ["High Protein"], ["Chicken Thighs", "Bell Peppers", "Yellow Onions", "Tortillas", "Cumin"], ["Slice chicken and vegetables.", "Toss with spices.", "Roast until browned.", "Serve in warm tortillas."], 29, 640, 38),
  recipe("Broccoli Cheddar Pasta", "Comfort pasta with a produce boost", "Italian", ["Vegetarian"], ["Broccoli", "Cheddar", "Pasta", "Whole Milk", "Garlic"], ["Boil pasta and broccoli.", "Make a garlic milk sauce.", "Melt cheddar.", "Toss until glossy."], 21, 690, 31),
  recipe("Coconut Chickpea Curry", "Pantry curry with fresh cilantro", "Indian", ["Vegan", "Dairy-Free"], ["Canned Chickpeas", "Coconut Milk", "Crushed Tomatoes", "Turmeric", "Cilantro"], ["Toast spices.", "Simmer tomatoes and coconut milk.", "Add chickpeas.", "Finish with cilantro."], 21, 540, 17),
  recipe("Salmon Rice Plates", "Freezer-friendly protein dinner", "Japanese", ["High Protein"], ["Salmon Fillets", "Jasmine Rice", "Soy Sauce", "Broccoli", "Lemons"], ["Cook salmon.", "Steam broccoli.", "Season rice.", "Serve with lemon."], 18, 610, 42),
  recipe("Tofu Veggie Stir-Fry", "High-protein vegetarian skillet", "Korean", ["Vegetarian", "High Protein", "Dairy-Free"], ["Firm Tofu", "Broccoli", "Carrots", "Soy Sauce", "Garlic"], ["Cube tofu.", "Sear until crisp.", "Stir-fry vegetables.", "Toss with soy sauce."], 21, 470, 28),
  recipe("Berry Yogurt Oat Bowl", "No-cook breakfast", "American", ["Vegetarian", "High Protein"], ["Greek Yogurt", "Frozen Berries", "Rolled Oats", "Peanut Butter"], ["Stir yogurt with oats.", "Warm berries.", "Top with peanut butter."], 6, 450, 26),
  recipe("Black Bean Tacos", "Budget pantry tacos", "Mexican", ["Vegan", "Dairy-Free"], ["Black Beans", "Tortillas", "Avocados", "Cilantro", "Cumin"], ["Warm beans.", "Char tortillas.", "Slice avocado.", "Build tacos."], 10, 520, 20)
];

function item(name, category, location, quantity, unit, expiryDays, price, calories, protein) {
  return {
    id: `${name}-${location}`,
    name,
    category,
    location,
    quantity,
    unit,
    expiryDays,
    price,
    calories,
    protein,
    status: "Available",
    confidence: 0.88
  };
}

function recipe(title, subtitle, cuisine, tags, ingredients, steps, minutes, calories, protein) {
  return { id: title, title, subtitle, cuisine, tags, ingredients, steps, minutes, calories, protein };
}

function risk(item) {
  if (item.expiryDays < 0) return { label: "Expired", color: C.tomato, score: 0 };
  if (item.expiryDays === 0) return { label: "Today", color: "#d97706", score: 1 };
  if (item.expiryDays <= 3) return { label: `${item.expiryDays}d`, color: C.lemon, score: 2 };
  if (item.expiryDays > 180) return { label: "Stable", color: C.blueberry, score: 4 };
  return { label: `${item.expiryDays}d`, color: C.basil, score: 3 };
}

function normalize(value) {
  return value.toLowerCase().replace(/-/g, " ").trim();
}

function matchRecipes(inventory, preferences) {
  const available = inventory.filter((x) => x.status === "Available");
  const names = available.map((x) => normalize(x.name));
  const expiring = new Set(available.filter((x) => x.expiryDays <= 3).map((x) => normalize(x.name)));

  return recipes
    .map((r) => {
      const matched = r.ingredients.filter((ing) => names.some((owned) => normalize(ing).includes(owned) || owned.includes(normalize(ing))));
      const missing = r.ingredients.filter((ing) => !matched.includes(ing));
      const urgent = r.ingredients.filter((ing) => expiring.has(normalize(ing)));
      let score = matched.length / Math.max(r.ingredients.length, 1);
      score += Math.min(urgent.length * 0.08, 0.22);
      if (r.tags.some((tag) => preferences.diets.includes(tag))) score += 0.05;
      score = Math.min(1, Math.max(0, score));
      return {
        ...r,
        matched,
        missing,
        urgent,
        score,
        explanation: urgent.length
          ? `Uses ${urgent.join(", ")} before it expires. You have ${matched.length} of ${r.ingredients.length} ingredients.`
          : missing.length
            ? `You have ${matched.length} ingredients. Add ${missing.slice(0, 2).join(" and ")} to make it tonight.`
            : `You have everything needed for this ${r.minutes}-minute meal.`
      };
    })
    .sort((a, b) => b.score - a.score || a.minutes - b.minutes);
}

function mockDetections(mode) {
  const map = {
    Fridge: [
      item("Baby Spinach", "Produce", "Fridge", 1, "bag", 1, 3.49, 25, 3),
      item("Greek Yogurt", "Dairy", "Fridge", 2, "cups", 5, 5.99, 130, 18),
      item("Avocados", "Produce", "Fridge", 3, "each", 0, 5.99, 240, 3),
      item("Mushrooms", "Produce", "Fridge", 1, "box", 2, 3.99, 20, 3)
    ],
    Pantry: [
      item("Canned Chickpeas", "Canned", "Pantry", 2, "cans", 365, 4.5, 210, 11),
      item("Brown Rice", "Grains", "Pantry", 1, "bag", 120, 3.99, 216, 5),
      item("Peanut Butter", "Condiment", "Pantry", 1, "jar", 90, 4.99, 190, 8)
    ],
    Freezer: [
      item("Salmon Fillets", "Protein", "Freezer", 2, "fillets", 30, 13.99, 250, 30),
      item("Frozen Peas", "Frozen", "Freezer", 1, "bag", 90, 2.99, 80, 5)
    ],
    Receipt: [
      item("Whole Milk", "Dairy", "Fridge", 1, "gallon", 7, 4.29, 150, 8),
      item("Eggs", "Protein", "Fridge", 12, "eggs", 18, 4.99, 70, 6),
      item("Bell Peppers", "Produce", "Fridge", 4, "each", 5, 5.5, 35, 1)
    ],
    Barcode: [item("Oat Milk", "Beverage", "Fridge", 1, "carton", 14, 4.99, 120, 3)],
    Label: [item("High Protein Granola", "Snack", "Pantry", 1, "bag", 150, 6.99, 260, 12)]
  };
  return (map[mode] || map.Fridge).map((x, index) => ({ ...x, id: `${x.id}-${Date.now()}-${index}`, confidence: 0.84 + index * 0.03 }));
}

export default function App() {
  const colorScheme = Appearance.getColorScheme();
  const dark = colorScheme === "dark";
  const styles = makeStyles(dark);
  const [tab, setTab] = useState("Home");
  const [inventory, setInventory] = useState(initialInventory);
  const [shopping, setShopping] = useState([
    { id: "Fresh basil", name: "Fresh basil", category: "Produce", source: "Pea Pesto Pasta", checked: false },
    { id: "Coffee", name: "Coffee", category: "Beverage", source: "Running low", checked: false }
  ]);
  const [analytics, setAnalytics] = useState({ saved: 39, wasted: 5, money: 146 });
  const [preferences, setPreferences] = useState({
    household: 2,
    diets: ["High Protein"],
    allergies: ["Peanuts"],
    largeCookingText: true,
    highContrast: false,
    notifications: true
  });
  const matches = useMemo(() => matchRecipes(inventory, preferences), [inventory, preferences]);
  const expiring = useMemo(
    () => inventory.filter((x) => x.status === "Available" && x.expiryDays <= 3).sort((a, b) => a.expiryDays - b.expiryDays),
    [inventory]
  );

  return (
    <SafeAreaView style={styles.safe}>
      <ExpoStatusBar style={dark ? "light" : "dark"} />
      <StatusBar barStyle={dark ? "light-content" : "dark-content"} />
      <View style={styles.shell}>
        {tab === "Home" && <Home styles={styles} matches={matches} expiring={expiring} inventory={inventory} analytics={analytics} setTab={setTab} addShopping={(items) => addMissing(items, setShopping)} cook={(m) => cookRecipe(m, setInventory, setAnalytics)} />}
        {tab === "Scan" && <Scan styles={styles} setInventory={setInventory} />}
        {tab === "Inventory" && <Inventory styles={styles} inventory={inventory} setInventory={setInventory} />}
        {tab === "Recipes" && <Recipes styles={styles} matches={matches} addShopping={(items) => addMissing(items, setShopping)} cook={(m) => cookRecipe(m, setInventory, setAnalytics)} />}
        {tab === "Shopping" && <Shopping styles={styles} shopping={shopping} setShopping={setShopping} setInventory={setInventory} />}
        {tab === "Analytics" && <Analytics styles={styles} inventory={inventory} analytics={analytics} />}
        {tab === "Settings" && <Settings styles={styles} preferences={preferences} setPreferences={setPreferences} expiring={expiring} />}
      </View>
      <TabBar styles={styles} tab={tab} setTab={setTab} />
    </SafeAreaView>
  );
}

function Home({ styles, matches, expiring, inventory, analytics, setTab, addShopping, cook }) {
  const top = matches[0];
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Header title="WasteLess Kitchen" subtitle="Cook expiring food first." />
      <Card styles={styles}>
        <Text style={styles.eyebrow}>COOK TONIGHT</Text>
        <Text style={styles.hero}>{top.title}</Text>
        <Text style={styles.muted}>{top.explanation}</Text>
        <View style={styles.rowWrap}>
          <Pill label={`${Math.round(top.score * 100)}% match`} color={C.basil} />
          <Pill label={`${top.minutes} min`} color={C.blueberry} />
          <Pill label={`${top.protein}g protein`} color={C.tomato} />
        </View>
        <View style={styles.buttonRow}>
          <Button label="Start cooking" icon="play" onPress={() => cook(top)} />
          <Button label="Shop gaps" icon="cart" variant="ghost" onPress={() => addShopping(top.missing)} disabled={!top.missing.length} />
        </View>
      </Card>
      <View style={styles.grid}>
        <Metric styles={styles} label="Expiring" value={expiring.length} icon="time" />
        <Metric styles={styles} label="Inventory" value={inventory.filter((x) => x.status === "Available").length} icon="file-tray-full" />
        <Metric styles={styles} label="Saved" value={`$${analytics.money}`} icon="cash" />
        <Metric styles={styles} label="Items saved" value={analytics.saved} icon="leaf" />
      </View>
      <SectionTitle title="Expiring Soon" />
      {expiring.map((x) => <InventoryMini key={x.id} styles={styles} item={x} />)}
      <Button label="Scan food" icon="camera" onPress={() => setTab("Scan")} />
    </ScrollView>
  );
}

function Scan({ styles, setInventory }) {
  const [mode, setMode] = useState("Fridge");
  const [detected, setDetected] = useState([]);

  async function demoScan() {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setDetected(mockDetections(mode));
  }

  async function pickPhoto() {
    if (Platform.OS === "web" && typeof document !== "undefined") {
      const input = document.createElement("input");
      input.type = "file";
      input.accept = "image/*";
      input.onchange = async () => {
        const file = input.files && input.files[0];
        if (!file) return;
        await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        setDetected(mockDetections(mode).map((x) => ({ ...x, confidence: Math.min(0.99, x.confidence + 0.04) })));
      };
      input.click();
      return;
    }

    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      Alert.alert("Photo access needed", "Allow photo access or use Demo scan.");
      return;
    }
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      quality: 0.7
    });
    if (!result.canceled) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      setDetected(mockDetections(mode).map((x) => ({ ...x, confidence: Math.min(0.99, x.confidence + 0.04) })));
    }
  }

  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Header title="Smart Scan" subtitle="Mock AI detection for fridge, pantry, receipt, barcode, and labels." />
      <Card styles={styles}>
        <Text style={styles.label}>Scan mode</Text>
        <View style={styles.rowWrap}>
          {scanModes.map((x) => <Chip key={x} label={x} selected={mode === x} onPress={() => setMode(x)} />)}
        </View>
        <View style={styles.buttonRow}>
          <Button label="Demo scan" icon="sparkles" onPress={demoScan} />
          <Button label="Pick photo" icon="image" variant="ghost" onPress={pickPhoto} />
        </View>
      </Card>
      {!!detected.length && (
        <>
          <SectionTitle title="Confirm Detected Items" />
          {detected.map((x) => <InventoryMini key={x.id} styles={styles} item={x} extra={`${Math.round(x.confidence * 100)}% confidence`} />)}
          <Button label={`Add ${detected.length} items`} icon="add-circle" onPress={() => {
            setInventory((old) => [...detected, ...old]);
            setDetected([]);
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
          }} />
        </>
      )}
    </ScrollView>
  );
}

function Inventory({ styles, inventory, setInventory }) {
  const [location, setLocation] = useState("Fridge");
  const [name, setName] = useState("");
  const visible = inventory.filter((x) => x.status === "Available" && x.location === location).sort((a, b) => a.expiryDays - b.expiryDays);
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Header title="Inventory" subtitle="Track location, quantity, expiry, and waste risk." />
      <View style={styles.rowWrap}>{locations.map((x) => <Chip key={x} label={x} selected={location === x} onPress={() => setLocation(x)} />)}</View>
      <Card styles={styles}>
        <TextInput value={name} onChangeText={setName} placeholder="Add item manually" placeholderTextColor="#7c8580" style={styles.input} />
        <Button label="Add item" icon="add" onPress={() => {
          if (!name.trim()) return;
          setInventory((old) => [item(name.trim(), "Other", location, 1, "item", 7, 3.99, 100, 3), ...old]);
          setName("");
        }} />
      </Card>
      {visible.map((x) => (
        <InventoryMini
          key={x.id}
          styles={styles}
          item={x}
          actions={
            <View style={styles.buttonRow}>
              <SmallButton label="Consumed" onPress={() => setInventory((old) => old.map((i) => i.id === x.id ? { ...i, status: "Consumed" } : i))} />
              <SmallButton label="Discard" danger onPress={() => setInventory((old) => old.map((i) => i.id === x.id ? { ...i, status: "Discarded" } : i))} />
            </View>
          }
        />
      ))}
    </ScrollView>
  );
}

function Recipes({ styles, matches, addShopping, cook }) {
  const [maxMinutes, setMaxMinutes] = useState(35);
  const visible = matches.filter((x) => x.minutes <= maxMinutes);
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Header title="Recipes" subtitle="Ranked by inventory match and expiring ingredients." />
      <Card styles={styles}>
        <Text style={styles.label}>Cook time filter</Text>
        <View style={styles.rowWrap}>
          {[15, 25, 35, 60].map((x) => <Chip key={x} label={`${x} min`} selected={maxMinutes === x} onPress={() => setMaxMinutes(x)} />)}
        </View>
      </Card>
      {visible.map((x) => <RecipeCard key={x.id} styles={styles} recipe={x} cook={() => cook(x)} shop={() => addShopping(x.missing)} />)}
    </ScrollView>
  );
}

function Shopping({ styles, shopping, setShopping, setInventory }) {
  const [name, setName] = useState("");
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Header title="Shopping" subtitle="Recipe gaps become categorized groceries." />
      <Card styles={styles}>
        <TextInput value={name} onChangeText={setName} placeholder="Add grocery item" placeholderTextColor="#7c8580" style={styles.input} />
        <Button label="Add to list" icon="cart" onPress={() => {
          if (!name.trim()) return;
          setShopping((old) => [{ id: `${name}-${Date.now()}`, name, category: "Other", source: "Manual", checked: false }, ...old]);
          setName("");
        }} />
      </Card>
      {shopping.map((x) => (
        <Pressable key={x.id} style={styles.listCard} onPress={() => setShopping((old) => old.map((i) => i.id === x.id ? { ...i, checked: !i.checked } : i))}>
          <Ionicons name={x.checked ? "checkmark-circle" : "ellipse-outline"} size={24} color={x.checked ? C.basil : "#7c8580"} />
          <View style={{ flex: 1 }}>
            <Text style={[styles.cardTitle, x.checked && { textDecorationLine: "line-through" }]}>{x.name}</Text>
            <Text style={styles.muted}>{x.category} - {x.source}</Text>
          </View>
        </Pressable>
      ))}
      <Button label="Move purchased to inventory" icon="download" onPress={() => {
        const purchased = shopping.filter((x) => x.checked);
        setInventory((old) => [...purchased.map((x) => item(x.name, x.category, x.category === "Frozen" ? "Freezer" : "Fridge", 1, "item", 7, 3.99, 100, 3)), ...old]);
        setShopping((old) => old.filter((x) => !x.checked));
      }} disabled={!shopping.some((x) => x.checked)} />
    </ScrollView>
  );
}

function Analytics({ styles, inventory, analytics }) {
  const available = inventory.filter((x) => x.status === "Available");
  const protein = available.reduce((sum, x) => sum + x.protein * x.quantity, 0);
  const categories = ["Produce", "Dairy", "Protein", "Grains", "Canned"].map((cat) => ({
    cat,
    count: inventory.filter((x) => x.category === cat && x.status === "Discarded").length
  }));
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Header title="Analytics" subtitle="Food saved, money saved, waste patterns, and nutrition." />
      <View style={styles.grid}>
        <Metric styles={styles} label="Food saved" value={analytics.saved} icon="leaf" />
        <Metric styles={styles} label="Money saved" value={`$${analytics.money}`} icon="cash" />
        <Metric styles={styles} label="Items wasted" value={analytics.wasted} icon="trash" />
        <Metric styles={styles} label="Protein" value={`${Math.round(protein)}g`} icon="barbell" />
      </View>
      <Card styles={styles}>
        <Text style={styles.cardTitle}>Weekly savings</Text>
        <View style={styles.chartRow}>
          {[32, 54, 38, 71, 62, 88, 76].map((h, i) => <View key={i} style={[styles.bar, { height: h }]} />)}
        </View>
      </Card>
      <Card styles={styles}>
        <Text style={styles.cardTitle}>Most wasted categories</Text>
        {categories.map((x) => <Text key={x.cat} style={styles.muted}>{x.cat}: {x.count}</Text>)}
      </Card>
    </ScrollView>
  );
}

function Settings({ styles, preferences, setPreferences, expiring }) {
  async function schedule() {
    await Notifications.requestPermissionsAsync();
    Alert.alert("Reminder preview", expiring.length ? `Use ${expiring.slice(0, 3).map((x) => x.name).join(", ")} today.` : "Nothing urgent today.");
  }
  return (
    <ScrollView contentContainerStyle={styles.content}>
      <Header title="Settings" subtitle="Diet, allergens, household, notifications, and accessibility." />
      <Card styles={styles}>
        <Text style={styles.cardTitle}>Household size: {preferences.household}</Text>
        <View style={styles.buttonRow}>
          <SmallButton label="-" onPress={() => setPreferences((p) => ({ ...p, household: Math.max(1, p.household - 1) }))} />
          <SmallButton label="+" onPress={() => setPreferences((p) => ({ ...p, household: Math.min(8, p.household + 1) }))} />
        </View>
      </Card>
      <Card styles={styles}>
        <Text style={styles.cardTitle}>Diets</Text>
        <View style={styles.rowWrap}>
          {diets.map((x) => <Chip key={x} label={x} selected={preferences.diets.includes(x)} onPress={() => toggleArray("diets", x, setPreferences)} />)}
        </View>
      </Card>
      <Card styles={styles}>
        <Text style={styles.cardTitle}>Allergens</Text>
        <View style={styles.rowWrap}>
          {allergens.map((x) => <Chip key={x} label={x} selected={preferences.allergies.includes(x)} onPress={() => toggleArray("allergies", x, setPreferences)} />)}
        </View>
      </Card>
      <Card styles={styles}>
        <SettingSwitch label="Large cooking text" value={preferences.largeCookingText} onValueChange={(v) => setPreferences((p) => ({ ...p, largeCookingText: v }))} />
        <SettingSwitch label="High contrast badges" value={preferences.highContrast} onValueChange={(v) => setPreferences((p) => ({ ...p, highContrast: v }))} />
        <SettingSwitch label="Expiry notifications" value={preferences.notifications} onValueChange={(v) => setPreferences((p) => ({ ...p, notifications: v }))} />
        <Button label="Preview reminder" icon="notifications" onPress={schedule} />
      </Card>
    </ScrollView>
  );
}

function RecipeCard({ styles, recipe, cook, shop }) {
  const [open, setOpen] = useState(false);
  return (
    <Card styles={styles}>
      <Pressable onPress={() => setOpen(true)}>
        <View style={styles.between}>
          <View style={{ flex: 1 }}>
            <Text style={styles.cardTitle}>{recipe.title}</Text>
            <Text style={styles.muted}>{recipe.subtitle}</Text>
          </View>
          <Text style={styles.score}>{Math.round(recipe.score * 100)}%</Text>
        </View>
        <Text style={styles.muted}>{recipe.explanation}</Text>
        <View style={styles.rowWrap}>
          <Pill label={`${recipe.minutes} min`} color={C.blueberry} />
          <Pill label={`${recipe.calories} cal`} color="#d97706" />
          <Pill label={`${recipe.protein}g protein`} color={C.tomato} />
          {!!recipe.urgent.length && <Pill label="Uses expiring" color="#d97706" />}
        </View>
      </Pressable>
      <View style={styles.buttonRow}>
        <Button label="Cook" icon="play" onPress={cook} />
        <Button label={recipe.missing.length ? `Add ${recipe.missing.length}` : "Complete"} icon="cart" variant="ghost" disabled={!recipe.missing.length} onPress={shop} />
      </View>
      <Modal visible={open} animationType="slide">
        <SafeAreaView style={styles.safe}>
          <ScrollView contentContainerStyle={styles.content}>
            <Header title={recipe.title} subtitle={recipe.explanation} />
            <SectionTitle title="Ingredients" />
            {recipe.ingredients.map((x) => <Text key={x} style={styles.listText}>{recipe.matched.includes(x) ? "Have" : "Need"} - {x}</Text>)}
            <SectionTitle title="Steps" />
            {recipe.steps.map((x, i) => <Text key={x} style={styles.listText}>{i + 1}. {x}</Text>)}
            <Button label="Start cooking mode" icon="play" onPress={() => { setOpen(false); cook(); }} />
            <Button label="Close" icon="close" variant="ghost" onPress={() => setOpen(false)} />
          </ScrollView>
        </SafeAreaView>
      </Modal>
    </Card>
  );
}

function cookRecipe(recipe, setInventory, setAnalytics) {
  let index = 0;
  function showStep() {
    const text = recipe.steps[index];
    Speech.speak(text);
    Alert.alert(
      `${recipe.title}: Step ${index + 1}/${recipe.steps.length}`,
      text,
      [
        { text: "Previous", onPress: () => { index = Math.max(0, index - 1); showStep(); } },
        { text: index === recipe.steps.length - 1 ? "Cooked" : "Next", onPress: () => {
          if (index === recipe.steps.length - 1) {
            setInventory((old) => old.map((x) => recipe.matched.includes(x.name) ? { ...x, quantity: Math.max(0, x.quantity - 1), status: x.quantity <= 1 ? "Consumed" : x.status } : x));
            setAnalytics((a) => ({ ...a, saved: a.saved + Math.max(1, recipe.urgent.length), money: a.money + 8 }));
            Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
          } else {
            index += 1;
            showStep();
          }
        } }
      ]
    );
  }
  showStep();
}

function addMissing(items, setShopping) {
  if (!items.length) return;
  setShopping((old) => [...items.map((name) => ({ id: `${name}-${Date.now()}`, name, category: "Recipe", source: "Recipe gap", checked: false })), ...old]);
  Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
}

function toggleArray(key, value, setPreferences) {
  setPreferences((p) => {
    const exists = p[key].includes(value);
    return { ...p, [key]: exists ? p[key].filter((x) => x !== value) : [...p[key], value] };
  });
}

function Header({ title, subtitle }) {
  return (
    <View style={{ marginBottom: 6 }}>
      <Text style={makeStatic.header}>{title}</Text>
      <Text style={makeStatic.subtitle}>{subtitle}</Text>
    </View>
  );
}

function Card({ styles, children }) {
  return <View style={styles.card}>{children}</View>;
}

function SectionTitle({ title }) {
  return <Text style={makeStatic.section}>{title}</Text>;
}

function Button({ label, icon, onPress, variant, disabled }) {
  return (
    <Pressable disabled={disabled} onPress={onPress} style={({ pressed }) => [makeStatic.button, variant === "ghost" && makeStatic.ghostButton, disabled && { opacity: 0.45 }, pressed && { transform: [{ scale: 0.98 }] }]}>
      <Ionicons name={icon} color={variant === "ghost" ? C.basil : "white"} size={18} />
      <Text style={[makeStatic.buttonText, variant === "ghost" && { color: C.basil }]}>{label}</Text>
    </Pressable>
  );
}

function SmallButton({ label, onPress, danger }) {
  return (
    <Pressable onPress={onPress} style={[makeStatic.smallButton, danger && { borderColor: C.tomato }]}>
      <Text style={[makeStatic.smallButtonText, danger && { color: C.tomato }]}>{label}</Text>
    </Pressable>
  );
}

function Chip({ label, selected, onPress }) {
  return (
    <Pressable onPress={onPress} style={[makeStatic.chip, selected && makeStatic.chipSelected]}>
      <Text style={[makeStatic.chipText, selected && { color: "white" }]}>{label}</Text>
    </Pressable>
  );
}

function Pill({ label, color }) {
  return <Text style={[makeStatic.pill, { color, backgroundColor: `${color}1f` }]}>{label}</Text>;
}

function Metric({ styles, label, value, icon }) {
  return (
    <Card styles={styles}>
      <Ionicons name={icon} size={24} color={C.basil} />
      <Text style={styles.metricValue}>{value}</Text>
      <Text style={styles.muted}>{label}</Text>
    </Card>
  );
}

function InventoryMini({ styles, item, extra, actions }) {
  const r = risk(item);
  return (
    <View style={styles.listCard}>
      <View style={{ flex: 1 }}>
        <Text style={styles.cardTitle}>{item.name}</Text>
        <Text style={styles.muted}>{item.quantity} {item.unit} - {item.location} - {item.category}</Text>
        {!!extra && <Text style={styles.muted}>{extra}</Text>}
        {actions}
      </View>
      <Text style={[makeStatic.risk, { backgroundColor: r.color, color: r.label === "1d" || r.label === "2d" || r.label === "3d" ? "#111" : "white" }]}>{r.label}</Text>
    </View>
  );
}

function SettingSwitch({ label, value, onValueChange }) {
  return (
    <View style={makeStatic.settingRow}>
      <Text style={makeStatic.settingText}>{label}</Text>
      <Switch value={value} onValueChange={onValueChange} trackColor={{ true: C.mint }} thumbColor={value ? C.basil : "#f5f5f5"} />
    </View>
  );
}

function TabBar({ styles, tab, setTab }) {
  const tabs = [
    ["Home", "home"],
    ["Scan", "camera"],
    ["Inventory", "file-tray-full"],
    ["Recipes", "restaurant"],
    ["Shopping", "cart"],
    ["Analytics", "analytics"],
    ["Settings", "settings"]
  ];
  return (
    <View style={styles.tabbar}>
      {tabs.map(([name, icon]) => (
        <Pressable key={name} onPress={() => setTab(name)} style={styles.tab}>
          <Ionicons name={tab === name ? icon : `${icon}-outline`} size={21} color={tab === name ? C.basil : "#7c8580"} />
          <Text style={[styles.tabText, tab === name && { color: C.basil }]}>{name}</Text>
        </Pressable>
      ))}
    </View>
  );
}

const makeStatic = StyleSheet.create({
  header: { fontSize: 32, lineHeight: 37, fontWeight: "800", color: C.ink },
  subtitle: { fontSize: 16, lineHeight: 22, color: "#66716b", marginTop: 4 },
  section: { fontSize: 21, fontWeight: "800", color: C.ink, marginTop: 8, marginBottom: 2 },
  button: { minHeight: 46, paddingHorizontal: 16, borderRadius: 8, backgroundColor: C.basil, flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 8, flex: 1 },
  ghostButton: { backgroundColor: "rgba(31,107,69,0.10)", borderWidth: 1, borderColor: C.line },
  buttonText: { color: "white", fontSize: 15, fontWeight: "800" },
  smallButton: { borderWidth: 1, borderColor: C.line, borderRadius: 8, paddingHorizontal: 12, paddingVertical: 8 },
  smallButtonText: { color: C.basil, fontWeight: "800" },
  chip: { borderRadius: 999, borderWidth: 1, borderColor: C.line, paddingHorizontal: 12, paddingVertical: 8, backgroundColor: "rgba(31,107,69,0.08)" },
  chipSelected: { backgroundColor: C.basil, borderColor: C.basil },
  chipText: { color: C.basil, fontWeight: "800", fontSize: 13 },
  pill: { overflow: "hidden", borderRadius: 999, paddingHorizontal: 10, paddingVertical: 6, fontSize: 12, fontWeight: "800" },
  risk: { overflow: "hidden", borderRadius: 999, paddingHorizontal: 10, paddingVertical: 7, fontSize: 12, fontWeight: "900" },
  settingRow: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 12, paddingVertical: 8 },
  settingText: { fontSize: 16, fontWeight: "700", color: C.ink }
});

function makeStyles(dark) {
  return StyleSheet.create({
    safe: { flex: 1, backgroundColor: dark ? "#08110f" : C.cream },
    shell: { flex: 1, backgroundColor: dark ? "#08110f" : C.cream },
    content: { padding: 16, paddingBottom: 108, gap: 12 },
    card: {
      backgroundColor: dark ? C.darkCard : C.card,
      borderWidth: 1,
      borderColor: dark ? "rgba(255,255,255,0.08)" : C.line,
      borderRadius: 8,
      padding: 16,
      gap: 10,
      shadowColor: "#000",
      shadowOpacity: 0.08,
      shadowRadius: 14,
      shadowOffset: { width: 0, height: 8 },
      elevation: 2
    },
    listCard: {
      backgroundColor: dark ? C.darkCard : "white",
      borderRadius: 8,
      borderWidth: 1,
      borderColor: dark ? "rgba(255,255,255,0.08)" : C.line,
      padding: 14,
      flexDirection: "row",
      alignItems: "center",
      gap: 12
    },
    hero: { fontSize: 31, lineHeight: 36, fontWeight: "900", color: dark ? "white" : C.ink },
    eyebrow: { fontSize: 12, fontWeight: "900", letterSpacing: 0.8, color: C.basil },
    cardTitle: { fontSize: 18, fontWeight: "850", color: dark ? "white" : C.ink },
    label: { fontSize: 15, fontWeight: "800", color: dark ? "white" : C.ink },
    muted: { color: dark ? "#b8c4be" : "#657069", fontSize: 14, lineHeight: 20 },
    rowWrap: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
    buttonRow: { flexDirection: "row", gap: 10, marginTop: 4 },
    grid: { flexDirection: "row", flexWrap: "wrap", gap: 12 },
    metricValue: { fontSize: 24, fontWeight: "900", color: dark ? "white" : C.ink },
    input: { minHeight: 44, borderWidth: 1, borderColor: C.line, borderRadius: 8, paddingHorizontal: 12, color: dark ? "white" : C.ink, backgroundColor: dark ? "#111a18" : "white" },
    between: { flexDirection: "row", justifyContent: "space-between", gap: 12 },
    score: { fontSize: 24, fontWeight: "900", color: C.basil },
    listText: { fontSize: 16, lineHeight: 24, color: dark ? "white" : C.ink, marginBottom: 8 },
    chartRow: { height: 100, flexDirection: "row", alignItems: "flex-end", gap: 10, paddingTop: 10 },
    bar: { flex: 1, backgroundColor: C.basil, borderRadius: 6 },
    tabbar: {
      position: "absolute",
      left: 0,
      right: 0,
      bottom: 0,
      paddingBottom: Platform.OS === "ios" ? 18 : 10,
      paddingTop: 10,
      paddingHorizontal: 6,
      backgroundColor: dark ? "rgba(8,17,15,0.96)" : "rgba(255,255,255,0.96)",
      borderTopWidth: 1,
      borderTopColor: dark ? "rgba(255,255,255,0.08)" : C.line,
      flexDirection: "row",
      justifyContent: "space-between"
    },
    tab: { alignItems: "center", justifyContent: "center", gap: 3, flex: 1 },
    tabText: { fontSize: 10, color: "#7c8580", fontWeight: "800" }
  });
}
