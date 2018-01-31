Level.create(start: "reword", target:"reward", path: ["reword", "reward"], limit: 2, hint: [3])
Level.create(start: "date", target:"fate", path: ["date", "fate"], limit: 2, hint: [0])
Level.create(start: "mad", target:"hat", path: ["mad", "had", "hat"], limit: 3, hint: [0,2])
Level.create(start: "this", target:"that", path: ["this", "thin", "than", "that"], limit:4, hint: [3])
Level.create(start: "lead", target:"gold", path: ["lead", "load", "goad", "gold"], limit: 6, hint: [1])
Level.create(start: "body", target:"mind", path: ["body", "bony", "bond", "bind", "mind"], limit: 6)
Level.create(start: "hand", target:"feet", path: ["hand", "band", "bend", "fend", "feed", "feet"], limit: 6)
Level.create(start: "fret", target:"calm", path:["fret", "feet", "felt", "fell", "fall", "call", "calm"],  limit: 10)
Level.create(start: "black", target:"white", path:["black","clack","click","chick","chink","chine","whine","white"],  limit: 12)
Level.create(start: "tooth", target:"teeth", path:["tooth", "booth", "boots", "boats", "beats", "bents", "tents", "tenth", "teeth"], limit: 13)


# ["easy", "east", "hast", "hart", "hard"]
# ["good", "gook", "look", "lock", "luck"]
# ["hand", "band", "bend", "fend", "feed", "feet"]
#Level.create(start: "hide", target:"seek", path: ["hide", "hied", "heed", "seed", "seek"], limit: 7)
#Level.create(start: "rock", target:"roll", path: ["rock", "rick", "rice", "rile", "rill", "roll"], limit: 9)
# Level.create(start: "deep", target:"wide", path:["deep", "deed", "heed", "hied", "hide", "wide"], limit: 10)

Level.create(start: "eat", target: "ate", path: ["eat", "ate"], limit: 2, hint: [-1])
Level.create(start: "bear", target: "hare", path: ["bear", "bare", "hare"], limit: 3, hint: [0,-1])
Level.create(start: "real", target: "fake", path: ["real", "rear", "rare", "fare", "fake"], limit: 5, hint: [3])
Level.create(start: "song", target:"poem", path: ["song", "sons", "sops", "mops", "mope", "poem"], limit: 10, hint: [3])
Level.create(start: "play", target:"work", path: ["play", "pray", "prey", "pyre", "pore", "pork", "work"], limit: 10, hint: [1])
Level.create(start: "poor", target:"rich", path:["poor", "door", "doer", "rode", "ride", "rice", "rich"], limit: 10)
Level.create(start: "four", target:"five", path:["four", "sour", "ours", "furs", "firs", "fire", "five"],  limit: 10)
Level.create(start: "north", target:"south", path:["north", "thorn", "shorn", "short", "shout", "south"],  limit: 10)
# Level.create(start: "duck", target:"swan", path:["duck","puck","punk","puns","spun","span","swan"],  limit: 10)
Level.create(start: "fable", target:"story", path:["fable", "sable", "bales", "tales", "stale", "stole", "store", "story"],  limit: 10)


Level.create(start: "noisy", target:"quiet", path:["noisy", "noise", "poise", "prise", "spire", "spite", "suite", "quite", "quiet"], limit: 13)
# Level.create(start: "light", target:"speed", path:["light", "night", "thing", "thins", "shins", "shies", "shied", "spied", "speed"], limit: 13)



Level.create(start: "fool", target:"wise", path:["fool", "pool", "poll", "pole", "pile", "wile", "wise"], limit: 10)
Level.create(start: "slave", target:"ruler", path:["slave", "vales", "males", "mules", "rules", "ruler"], limit: 10)
Level.create(start: "alone", target:"bonds", path:["alone", "atone", "stone", "tones", "bones", "bonds"], limit: 10)
Level.create(start: "love", target:"sigh", path:["love", "live", "line", "ling", "sing", "sign", "sigh"], limit: 10)
Level.create(start: "money", target:"paper", path:["money", "boney", "boner", "borer", "barer", "parer", "paper"], limit: 10)
Level.create(start: "birth", target:"death", path:["birth","girth","right","night","thing","thine","thane","neath","death"], limit: 12) #quite simple?
Level.create(start: "study", target:"teach", path:["study", "studs", "stuns", "stunt", "stent", "tents", "tenth", "tench", "teach"], limit: 13) #realtively simple, but ok
Level.create(start: "power", target:"greed", path:["power", "cower", "coder", "ceder", "creed", "greed"], limit: 10) #hard
Level.create(start: "sinned", target:"repent", path:["sinned", "tinned", "tinted", "tented", "tensed", "tenser", "resent", "repent"], limit: 12) #good difficulty
Level.create(start: "grief", target:"peace", path:["grief", "brief", "bries", "tries", "trees", "terse", "tease", "pease", "peace"], limit: 12) #good

Level.create(start: "june", target:"july", path:["june", "rune", "rube", "ruby", "bury", "jury", "july"], limit: 10)
Level.create(start: "thrive", target:"wither", path:["thrive", "shrive", "shrine", "shiner", "whiner", "whiter", "wither"], limit: 12)
Level.create(start: "month", target:"years", path:["month", "mouth", "south", "shout", "short", "shore", "share", "hears", "years"], limit: 13)
Level.create(start: "child", target:"elder", path:["child","chile","chine","shine","shire","hires","hides","hider","eider","elder"], limit: 15)
Level.create(start: "fresh", target:"decay", path:["fresh", "flesh", "shelf", "sheaf", "shear", "hears", "dears", "deary", "decry", "decay"], limit: 15)
Level.create(start: "clean", target:"dirty", path:["clean", "clear", "blear", "baler", "barer", "darer", "dares", "darts", "dirts", "dirty"], limit: 15)
Level.create(start: "seven", target:"eight", path:["seven","sever","sewer","resew","reset","beset","besot","begot","bigot","bight","eight"], limit: 15)
Level.create(start: "faith", target:"waver", path:["faith", "saith", "smith", "smite", "spite", "spate", "pates", "paves", "waves", "waver"], limit: 15)
Level.create(start: "summer", target:"winter", path:["summer", "hummer", "hammer", "hammed", "harmed", "warmed", "warned", "wander", "winder", "winter"], limit: 17)
Level.create(start: "depart", target:"alight", path:["depart", "parted", "pasted", "hasted", "hasten", "thanes", "thanks", "thinks", "things", "nights", "lights", "slight", "alight"], limit: 19)


Level.create(start: "spades", target:"hearts", path:["spades","spaces","spacer","capers","caters","haters","hearts"], limit: 11)
Level.create(start: "dealer", target:"player", path:["dealer", "sealer", "staler", "stayer", "slayer", "player"], limit: 11)
Level.create(start: "losses", target:"reward", path:["losses", "posses", "passes", "parses", "parsed", "parred", "warred", "reward"], limit: 12)
Level.create(start: "angel", target:"devil", path:["angel", "glean", "clean", "lance", "dance", "caned", "caved", "laved", "lived", "devil"], limit: 15)
Level.create(start: "right", target:"wrong", path:["right", "night", "thing", "thine", "shine", "shone", "phone", "prone", "prong", "wrong"], limit: 15)
Level.create(start: "guile", target:"cheat", path:["guile", "guide", "glide", "elide", "elite", "elate", "plate", "pleat", "cleat", "cheat"], limit: 15)
Level.create(start: "royal", target:"flush", path:["royal", "riyal", "lairy", "hairy", "hairs", "heirs", "hears", "shear", "sheaf", "shelf", "flesh", "flush"], limit: 18)
Level.create(start: "horses", target:"racing", path: ["horses", "hordes", "shored", "snored", "snared", "sander", "pander", "panier", "rapine", "raping", "racing"], limit: 17)
Level.create(start: "invest", target:"return", path:["invest", "ingest", "tinges", "binges", "binged", "bunged", "bugged", "bugger", "burger", "burner", "turner", "return"], limit: 18)
Level.create(start: "winning", target:"lottery", path:["winning", "binning", "binding", "bending", "beading", "bearing", "searing", "gainers", "garners", "garters", "barters", "batters", "patters", "potters", "pottery", "lottery"], limit: 20)

Chapter.create!(name: "beginnings")
Chapter.create!(name: "onwards")
Chapter.create!(name: "life")
Chapter.create!(name: "time")
Chapter.create!(name: "fortune")
