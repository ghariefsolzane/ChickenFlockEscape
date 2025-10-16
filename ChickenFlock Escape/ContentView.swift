

import SwiftUI
import Combine

// MARK: - Main App Structure
struct ContentView: View {
    @StateObject private var gameManager = GameManager()
    @State private var currentView: AppView = .mainMenu
    @State private var showTutorial = true
    
    var body: some View {
        ZStack {
            switch currentView {
            case .mainMenu:
                MainMenuView(currentView: $currentView, gameManager: gameManager)
            case .levelSelect:
                LevelSelectView(currentView: $currentView, gameManager: gameManager)
            case .chickenSelect:
                ChickenSelectView(currentView: $currentView, gameManager: gameManager)
            case .game:
                ChickenEscapeGameView(gameManager: gameManager, currentView: $currentView)
            }
            
            // Tutorial Overlay
            if showTutorial && currentView == .mainMenu {
                TutorialView(showTutorial: $showTutorial)
            }
        }
    }
}

enum AppView {
    case mainMenu, levelSelect, chickenSelect, game
}

// MARK: - Modern Main Menu View
struct MainMenuView: View {
    @Binding var currentView: AppView
    @ObservedObject var gameManager: GameManager
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Modern Background with Image - FIXED SCALING
            GeometryReader { geometry in
                Image("menu_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.6),
                                Color.purple.opacity(0.4),
                                Color.black.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .ignoresSafeArea()
            
            // Animated Floating Elements
            VStack {
                HStack {
                    FloatingElement(size: 80, delay: 0)
                    Spacer()
                    FloatingElement(size: 120, delay: 0.3)
                }
                Spacer()
                HStack {
                    FloatingElement(size: 100, delay: 0.6)
                    Spacer()
                    FloatingElement(size: 60, delay: 0.9)
                }
            }
            .padding()
            
            // ScrollView Added for Better Responsiveness
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    // Modern Header with Logo
                    VStack(spacing: 20) {
                        // Main Logo
                        Image("farmer")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 200)
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 8) {
                            Text("ChickenFlock\nEscape")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                                .scaleEffect(isAnimating ? 1.05 : 1.0)
                            
                            Text("Rescue the Flock!")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .italic()
                        }
                    }
                    .padding(.top, 40)
                    
                    // Modern Glassy Action Cards
                    VStack(spacing: 20) {
                        ModernMenuCard(
                            title: "Start New Chicken Flock",
                            subtitle: "Begin fresh rescue mission",
                            icon: "chicken1",
                            gradient: [Color.green, Color.blue],
                            action: {
                                gameManager.resetGameData()
                                currentView = .levelSelect
                            }
                        )
                        
                        ModernMenuCard(
                            title: "Continue Chicken Flock",
                            subtitle: "Resume your progress",
                            icon: "chicken1",
                            gradient: [Color.blue, Color.purple],
                            action: {
                                currentView = .levelSelect
                            }
                        )
                    }
                    .padding(.horizontal, 25)
                    
                    // Modern Score Display
                    VStack(spacing: 15) {
                        Text("Total Rescue Score")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        
                        ZStack {
                            // Score Background
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.yellow.opacity(0.3),
                                            Color.orange.opacity(0.2)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            HStack(spacing: 15) {
                                Image(systemName: "trophy.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.yellow, .orange]),
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Score")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("\(gameManager.totalScore)")
                                        .font(.system(size: 28, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.yellow)
                            }
                            .padding(.horizontal, 25)
                        }
                        .padding(.horizontal, 25)
                    }
                   .padding(.top, 20)
                }
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// Modern Glassy Menu Card
struct ModernMenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Icon with Gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: gradient),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(icon)
                        .resizable()
                        .frame(width: 38,height:45)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Animated Arrow
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
                    .scaleEffect(isHovered ? 1.2 : 1.0)
            }
            .padding(25)
            .background(
                // Glass Morphism Effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .scaleEffect(isHovered ? 1.02 : 1.0)
        }
        .pressEvents {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = false
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// Floating Background Element
struct FloatingElement: View {
    let size: CGFloat
    let delay: Double
    
    @State private var isFloating = false
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.yellow.opacity(0.1),
                        Color.orange.opacity(0.05)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: size/2
                )
            )
            .frame(width: size, height: size)
            .offset(y: isFloating ? -20 : 20)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 3.0)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    isFloating = true
                }
            }
    }
}

// MARK: - Tutorial View
struct TutorialView: View {
    @Binding var showTutorial: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            
            ScrollView {
            VStack(spacing: 20) {
                Text("🐔 Chicken Flock 🐔")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 12) {
                    TutorialStep(icon: "hand.tap", text: "Select a chicken to control")
                    TutorialStep(icon: "arrow.left.arrow.right", text: "Move left/right on the road")
                    TutorialStep(icon: "arrow.up", text: "Jump to avoid vehicles")
                    TutorialStep(icon: "arrow.down", text: "Move down towards jungle")
                    TutorialStep(icon: "figure.run", text: "Farmer will chase your chickens")
                    TutorialStep(icon: "dollarsign.circle", text: "Collect coins for points")
                    TutorialStep(icon: "heart.fill", text: "Each chicken has 3 lives")
                    TutorialStep(icon: "leaf.fill", text: "Push chickens DOWN to reach the GREEN JUNGLE area")
                    TutorialStep(icon: "arrow.down.circle.fill", text: "Look for arrows pointing down when near jungle")
                    TutorialStep(icon: "checkmark.circle.fill", text: "Green tick = Escaped chicken")
                    TutorialStep(icon: "xmark.circle.fill", text: "Red X = Dead chicken")
                    TutorialStep(icon: "exclamationmark.triangle", text: "Look for 'PUSH ME' tag when chicken is on road")
                }
                
                // Visual demonstration of jungle area
                VStack(spacing: 8) {
                    Text("Jungle Area is at the BOTTOM")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green.opacity(0.3))
                        .frame(height: 40)
                        .overlay(
                            HStack {
                                Image(systemName: "leaf.fill")
                                Text("Safe Jungle Zone")
                                Image(systemName: "leaf.fill")
                            }
                                .foregroundColor(.white)
                        )
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                Button("Let's Play!") {
                    withAnimation(.spring()) {
                        showTutorial = false
                    }
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(Color.green)
                .cornerRadius(20)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(.systemBackground))
            )
            .padding(25)
            
            
            
        }
        }
    }
}

struct TutorialStep: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.blue)
                .frame(width: 25)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}



// MARK: - Level Select View - UPDATED
struct LevelSelectView: View {
    @Binding var currentView: AppView
    @ObservedObject var gameManager: GameManager
    
    let levels = [
        Level(id: 1, name: "Easy Meadow", coinsPerRow: 3, requiredCoins: 9, color: .green, multiplier: 1),
        Level(id: 2, name: "Busy Road", coinsPerRow: 4, requiredCoins: 12, color: .orange, multiplier: 2),
        Level(id: 3, name: "City Traffic", coinsPerRow: 6, requiredCoins: 18, color: .red, multiplier: 3),
        Level(id: 4, name: "Highway Chaos", coinsPerRow: 8, requiredCoins: 24, color: .purple, multiplier: 5)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.6), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        currentView = .mainMenu
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text("Select Level")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible placeholder for balance
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.clear)
                        .padding()
                }
                .padding(.horizontal)
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(levels) { level in
                            LevelCard(
                                level: level,
                                gameManager: gameManager,
                                action: {
                                    gameManager.selectedLevel = level
                                    currentView = .chickenSelect
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct LevelCard: View {
    let level: Level
    @ObservedObject var gameManager: GameManager
    let action: () -> Void
    
    @State private var cardSize: CGSize = .zero
    
    private var levelProgress: Double {
        let levelData = gameManager.levelData[level.id] ?? LevelData()
        return Double(levelData.coinsCollected) / Double(level.requiredCoins)
    }
    
    private var isUnlocked: Bool {
        if level.id == 1 { return true }
        let previousLevelData = gameManager.levelData[level.id - 1] ?? LevelData()
        
        // ORIGINAL LOGIC: Next level unlock ke liye previous level ke SAARE coins collect karne hain
        let previousLevel = gameManager.getLevel(level.id - 1)
        return previousLevelData.coinsCollected >= previousLevel.requiredCoins
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Level Number Circle
                ZStack {
                    Circle()
                        .fill(level.color)
                        .frame(width: 50, height: 50)
                    
                    Text("\(level.id)")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                }
                .layoutPriority(1)
                
                // Level Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(level.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.8)
                        .lineLimit(1)
                    
                    Text("\(level.coinsPerRow) coins • \(level.multiplier)x")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    // Progress Bar with flexible width
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(level.color)
                                .frame(width: geometry.size.width * CGFloat(levelProgress), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(gameManager.levelData[level.id]?.coinsCollected ?? 0)/\(level.requiredCoins) coins")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    // Unlock requirement text
                    if !isUnlocked && level.id > 1 {
                        let previousLevel = gameManager.getLevel(level.id - 1)
                        let collected = gameManager.levelData[level.id - 1]?.coinsCollected ?? 0
                        let required = previousLevel.requiredCoins
                        
                        Text("Complete Level \(level.id - 1) with \(required) coins")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.yellow)
                            .padding(.top, 2)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                }
                .layoutPriority(2)
                
                Spacer(minLength: 8)
                
                // Status Section - Fixed width to prevent stretching
                VStack(spacing: 6) {
                    if isUnlocked {
                        VStack(spacing: 2) {
                            Image(systemName: "lock.open.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.green)
                            
                            Text("PLAY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.green)
                        }
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                            
                            Text("LOCKED")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.red)
                            
                            // Show progress for unlocking
                            if level.id > 1 {
                                let previousLevel = gameManager.getLevel(level.id - 1)
                                let collected = gameManager.levelData[level.id - 1]?.coinsCollected ?? 0
                                let required = previousLevel.requiredCoins
                                
                                Text("\(collected)/\(required)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    
                    Text("\(gameManager.levelData[level.id]?.highScore ?? 0)")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.yellow)
                        .padding(.top, 4)
                }
                .frame(width: 60) // Fixed width for status section
                .layoutPriority(3)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
            )
        }
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}


struct Level: Identifiable {
    let id: Int
    let name: String
    let coinsPerRow: Int
    let requiredCoins: Int
    let color: Color
    let multiplier: Int
}

// MARK: - Chicken Select View
struct ChickenSelectView: View {
    @Binding var currentView: AppView
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.6), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        currentView = .levelSelect
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Text("Select Chickens")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        if !gameManager.selectedChickenIds.isEmpty {
                            currentView = .game
                        }
                    }) {
                        Text("Start")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(gameManager.selectedChickenIds.isEmpty ? Color.gray : Color.green)
                            )
                    }
                    .disabled(gameManager.selectedChickenIds.isEmpty)
                }
                .padding(.horizontal)
                
                Text("Select chickens for Level \(gameManager.selectedLevel?.id ?? 1)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(gameManager.allChickens) { chicken in
                            ChickenSelectionCard(
                                chicken: chicken,
                                isSelected: gameManager.selectedChickenIds.contains(chicken.id),
                                action: {
                                    gameManager.toggleChickenSelection(chicken.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Text("Selected: \(gameManager.selectedChickenIds.count)/8 chickens")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
            }
        }
    }
}

struct ChickenSelectionCard: View {
    let chicken: Chicken
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    // Chicken Image
                    Image(chicken.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .opacity(isSelected ? 1.0 : 0.6)
                    
                    // Selection Indicator
                    Circle()
                        .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
                        .frame(width: 90, height: 90)
                    
                    // Checkmark
                    if isSelected {
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                                    .background(Circle().fill(Color.white))
                            }
                            Spacer()
                        }
                        .frame(width: 90, height: 90)
                    }
                }
                
                Text(chicken.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Total: \(chicken.totalCoins) coins")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.yellow)
                
                Text("Lives: \(chicken.lives)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Game Models
struct Chicken: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isEscaped: Bool = false
    var isCaught: Bool = false
    var isAlive: Bool = true
    var isSelected: Bool = false
    var imageName: String
    var coinsCollected: Int = 0
    var isOnRoad: Bool = false
    var direction: CGFloat = 1.0
    var isJumping: Bool = false
    var scale: Double = 1.0
    var rotation: Double = 0
    var lives: Int = 3
    var isHit: Bool = false
    var hasReachedJungle: Bool = false
    var showRoadTag: Bool = false
    var name: String
    var totalCoins: Int = 0
}

struct Farmer {
    var position: CGPoint
    var isChasing: Bool = false
    var isAlive: Bool = true
    var targetChickenId: UUID?
    var speed: Double = 3.0
    var coins: Int = 0
    var scale: Double = 1.0
}

struct Vehicle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var speed: Double
    var imageName: String
    var lane: Int
}

struct Coin: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isCollected: Bool = false
    var value: Int = 1
    var rotation: Double = 0
}

// Toast Message System
struct ToastMessage: Identifiable {
    let id = UUID()
    let message: String
    let type: ToastType
    let value: Int
}

enum ToastType {
    case coinCollected
    case lifeLost
    case chickenDied
    case chickenEscaped
    case alreadyEscaped
    case alreadyDead
    case levelComplete
    case farmerCaught
    case noChickenSelected
}

struct GameConstants {
    static let chickenImages = ["chicken1", "chicken2", "chicken3", "chicken4", "chicken5", "chicken6", "chicken7", "chicken8"]
    static let vehicleImages = ["sports_car", "pickup_truck", "delivery_van", "motorcycle"]
    static let farmerImage = "farmer"
}

struct LevelData {
    var highScore: Int = 0
    var coinsCollected: Int = 0
    var chickensUsed: [UUID: Int] = [:] // Chicken ID to coins collected
    var isCompleted: Bool = false
}

// MARK: - Main Game Manager
class GameManager: ObservableObject {
    @Published var selectedLevel: Level?
    @Published var selectedChickenIds: Set<UUID> = []
    @Published var levelData: [Int: LevelData] = [:]
    @Published var allChickens: [Chicken] = []
    
    var totalScore: Int {
        levelData.values.reduce(0) { $0 + $1.highScore }
    }
    
    init() {
        setupChickens()
        initializeLevelData()
    }
    
    private func setupChickens() {
        let chickenNames = ["Clucky", "Feathers", "Pecker", "Wingston", "Henrietta", "BokBok", "Eggbert", "Nugget"]
        
        allChickens = chickenNames.enumerated().map { index, name in
            Chicken(
                position: CGPoint.zero, // Will be set in game
                imageName: GameConstants.chickenImages[index],
                name: name,
                totalCoins: 0
            )
        }
    }
    
    private func initializeLevelData() {
        for levelId in 1...4 {
            levelData[levelId] = LevelData()
        }
    }
    
    func toggleChickenSelection(_ chickenId: UUID) {
        if selectedChickenIds.contains(chickenId) {
            selectedChickenIds.remove(chickenId)
        } else if selectedChickenIds.count < 8 {
            selectedChickenIds.insert(chickenId)
        }
    }
    
    func getSelectedChickens() -> [Chicken] {
        return allChickens.filter { selectedChickenIds.contains($0.id) }
    }

    func updateLevelProgress(levelId: Int, coinsCollected: Int, chickenCoins: [UUID: Int], allChickensEscaped: Bool = false) {
            guard var data = levelData[levelId] else { return }
            
            // Update coins collected (highest value)
            data.coinsCollected = max(data.coinsCollected, coinsCollected)
            
            // Update chicken coins
            for (chickenId, coins) in chickenCoins {
                data.chickensUsed[chickenId] = max(data.chickensUsed[chickenId] ?? 0, coins)
            }
            
            // Calculate score with multiplier
            let level = getLevel(levelId)
            let score = coinsCollected * level.multiplier * 10
            
            if score > data.highScore {
                data.highScore = score
            }
            
            // MARK LEVEL AS COMPLETED IF:
            // 1. All chickens escaped, OR
            // 2. All coins collected
            if allChickensEscaped || coinsCollected >= level.requiredCoins {
                data.isCompleted = true
            }
            
            levelData[levelId] = data
            
            // Update chicken total coins
            for (chickenId, coins) in chickenCoins {
                if let index = allChickens.firstIndex(where: { $0.id == chickenId }) {
                    allChickens[index].totalCoins += coins
                }
            }
            
            print("Level \(levelId) Progress Updated:")
            print("- Coins Collected: \(coinsCollected)/\(level.requiredCoins)")
            print("- Level Completed: \(data.isCompleted)")
            print("- High Score: \(data.highScore)")
        }
    
    func getLevel(_ levelId: Int) -> Level {
        let coinsPerRow: Int
        switch levelId {
        case 1: coinsPerRow = 3
        case 2: coinsPerRow = 4
        case 3: coinsPerRow = 6
        case 4: coinsPerRow = 8
        default: coinsPerRow = 3
        }
        
        return Level(
            id: levelId,
            name: "Level \(levelId)",
            coinsPerRow: coinsPerRow,
            requiredCoins: coinsPerRow * 3,
            color: [.green, .orange, .red, .purple][levelId - 1],
            multiplier: levelId
        )
    }
    
    func resetGameData() {
        selectedChickenIds.removeAll()
        levelData.removeAll()
        initializeLevelData()
        
        // Reset chicken coins
        for i in 0..<allChickens.count {
            allChickens[i].totalCoins = 0
        }
    }
    
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        if levelId == 1 { return true }
        let previousLevelData = levelData[levelId - 1] ?? LevelData()
        let previousLevel = getLevel(levelId - 1)
        
        // Level unlock ke liye previous level COMPLETE hona chahiye
        // Ya to saare coins collect kar lo, ya level win kar lo
        return previousLevelData.isCompleted || previousLevelData.coinsCollected >= previousLevel.requiredCoins
    }
}

// MARK: - Level Game Manager
class LevelGameManager: ObservableObject {
    @Published var chickens: [Chicken] = []
    @Published var farmer = Farmer(position: CGPoint(x: 200, y: 300))
    @Published var vehicles: [Vehicle] = []
    @Published var coins: [Coin] = []
    @Published var playerCoins = 0
    @Published var gameState: GameState = .playing
    @Published var successfulEscape: Chicken?
    @Published var toastMessages: [ToastMessage] = []
    @Published var coinsCollected = 0
    @Published var showJungleSuccess = false
    @Published var showLevelComplete = false
    
    var chickenCoins: [UUID: Int] = [:]
    let mainGameManager: GameManager
    
    private var timer: Timer?
    private var continuousSpawningTimer: Timer?
    public var selectedChickenId: UUID?
    
    var remainingChickens: Int {
        chickens.filter { $0.isAlive && !$0.isCaught && !$0.hasReachedJungle }.count
    }
    
    var escapedChickens: Int {
        chickens.filter { $0.hasReachedJungle }.count
    }
    
    var totalChickens: Int {
        chickens.count
    }
    
    var allCoinsCollected: Bool {
        coins.allSatisfy { $0.isCollected }
    }
    
    init(gameManager: GameManager) {
        self.mainGameManager = gameManager
        setupGame()
        startGameTimer()
    }
    
    private func setupGame() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Setup initial chickens for fallback
        let initialPositions = [
            CGPoint(x: screenWidth * 0.2, y: screenHeight * 0.1),
            CGPoint(x: screenWidth * 0.35, y: screenHeight * 0.08),
            CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.12),
            CGPoint(x: screenWidth * 0.65, y: screenHeight * 0.09),
            CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.15),
            CGPoint(x: screenWidth * 0.45, y: screenHeight * 0.13),
            CGPoint(x: screenWidth * 0.55, y: screenHeight * 0.17),
            CGPoint(x: screenWidth * 0.7, y: screenHeight * 0.14)
        ]
        
        // Create default chickens if none selected
        chickens = initialPositions.enumerated().map { index, position in
            Chicken(
                position: position,
                imageName: GameConstants.chickenImages[index % GameConstants.chickenImages.count],
                name: "Chicken \(index + 1)",
                totalCoins: 0
            )
        }
        
        // Initialize farmer
        farmer = Farmer(position: CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.12))
        
        // Setup coins for default level
        setupCoinsForLevel()
        
        // Initialize vehicles
        spawnVehicles()
        
        // Reset game state
        gameState = .playing
        playerCoins = 0
        coinsCollected = 0
        chickenCoins.removeAll()
        showJungleSuccess = false
        showLevelComplete = false
    }
    
    func setupLevelGame() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Get selected chickens from main game manager
        let selectedChickens = mainGameManager.getSelectedChickens()
        
        // Position chickens in farm area
        let initialPositions = [
            CGPoint(x: screenWidth * 0.2, y: screenHeight * 0.1),
            CGPoint(x: screenWidth * 0.35, y: screenHeight * 0.08),
            CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.12),
            CGPoint(x: screenWidth * 0.65, y: screenHeight * 0.09),
            CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.15),
            CGPoint(x: screenWidth * 0.45, y: screenHeight * 0.13),
            CGPoint(x: screenWidth * 0.55, y: screenHeight * 0.17),
            CGPoint(x: screenWidth * 0.7, y: screenHeight * 0.14)
        ]
        
        chickens = selectedChickens.enumerated().map { index, chicken in
            var newChicken = chicken
            newChicken.position = initialPositions[index]
            newChicken.coinsCollected = 0
            newChicken.isSelected = false
            newChicken.isCaught = false
            newChicken.hasReachedJungle = false
            newChicken.isOnRoad = false
            newChicken.showRoadTag = false
            newChicken.isHit = false
            newChicken.lives = 3
            return newChicken
        }
        
        // Initialize farmer
        farmer = Farmer(position: CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.12))
        
        // Setup coins based on level
        setupCoinsForLevel()
        
        // Initialize vehicles
        spawnVehicles()
        
        // Reset game state
        gameState = .playing
        playerCoins = 0
        coinsCollected = 0
        chickenCoins.removeAll()
        showJungleSuccess = false
        showLevelComplete = false
    }
    
    private func setupCoinsForLevel() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let roadTop = screenHeight * 0.25
        let roadHeight = screenHeight * 0.15
        let laneHeight = roadHeight / 3
        
        // Get level or use default level 1
        let level = mainGameManager.selectedLevel ?? mainGameManager.getLevel(1)
        let coinsPerRow = level.coinsPerRow
        
        coins.removeAll()
        
        for lane in 0..<3 {
            let y = roadTop + laneHeight * 0.5 + CGFloat(lane) * laneHeight
            for i in 0..<coinsPerRow {
                let x = screenWidth * CGFloat(i + 1) / CGFloat(coinsPerRow + 1)
                let coinValue = Int.random(in: 10...50) * level.id // Higher values in higher levels
                coins.append(Coin(
                    position: CGPoint(x: x, y: y),
                    value: coinValue
                ))
            }
        }
    }
    
    
    // FIXED VEHICLE SPAWNING SYSTEM
    private func spawnVehicles() {
        let screenHeight = UIScreen.main.bounds.height
        let roadTop = screenHeight * 0.25
        let roadHeight = screenHeight * 0.15
        let laneHeight = roadHeight / 3
        
        // Clear existing vehicles
        vehicles.removeAll()
        
        let vehicleTypes = [
            (image: "sports_car", speed: 3.0, lane: 0),
            (image: "pickup_truck", speed: 2.5, lane: 1),
            (image: "delivery_van", speed: 2.0, lane: 2),
            (image: "motorcycle", speed: 3.5, lane: 0)
        ]
        
        // Spawn initial vehicles with delays
        for i in 0..<6 {
            let type = vehicleTypes[i % vehicleTypes.count]
            let y = roadTop + laneHeight * 0.5 + Double(type.lane) * laneHeight
            
            // Add delay based on lane to prevent overlapping
            let baseDelay = Double(type.lane) * 2.0
            let randomDelay = Double.random(in: 1.0...4.0)
            let totalDelay = baseDelay + randomDelay + Double(i) * 0.5
            
            DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay) { [weak self] in
                guard let self = self else { return }
                
                // Check if there's already a vehicle too close in the same lane
                let isTooClose = self.vehicles.contains { vehicle in
                    vehicle.lane == type.lane && vehicle.position.x < 200
                }
                
                if !isTooClose {
                    let newVehicle = Vehicle(
                        position: CGPoint(x: -100, y: y),
                        speed: type.speed + Double.random(in: -0.5...0.5),
                        imageName: type.image,
                        lane: type.lane
                    )
                    self.vehicles.append(newVehicle)
                }
            }
        }
        
        // Start continuous vehicle spawning
        startContinuousVehicleSpawning()
    }


    
    
    private func startContinuousVehicleSpawning() {
        continuousSpawningTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let screenHeight = UIScreen.main.bounds.height
            let roadTop = screenHeight * 0.25
            let roadHeight = screenHeight * 0.15
            let laneHeight = roadHeight / 3
            
            let vehicleTypes = [
                (image: "sports_car", speed: 3.0, lane: 0),
                (image: "pickup_truck", speed: 2.5, lane: 1),
                (image: "delivery_van", speed: 2.0, lane: 2),
                (image: "motorcycle", speed: 3.5, lane: 0)
            ]
            
            for type in vehicleTypes {
                // 40% chance to spawn in each lane
                if Bool.random(withProbability: 0.4) {
                    let y = roadTop + laneHeight * 0.5 + Double(type.lane) * laneHeight
                    
                    // Check if there's enough space in this lane
                    let vehiclesInLane = self.vehicles.filter { $0.lane == type.lane }
                    let hasSpace = vehiclesInLane.allSatisfy { $0.position.x > 300 || $0.position.x < -50 }
                    
                    if hasSpace {
                        let newVehicle = Vehicle(
                            position: CGPoint(x: -100, y: y),
                            speed: type.speed + Double.random(in: -0.5...0.5),
                            imageName: type.image,
                            lane: type.lane
                        )
                        self.vehicles.append(newVehicle)
                    }
                }
            }
        }
    }
    
    // FIXED VEHICLE MOVEMENT WITH COLLISION AVOIDANCE
    private func updateVehicles() {
        let screenWidth = UIScreen.main.bounds.width
        
        // Use indices to safely iterate and modify
        var indicesToRemove: [Int] = []
        
        for i in vehicles.indices {
            var adjustedSpeed = vehicles[i].speed
            
            // Look for vehicles ahead in the same lane
            for j in vehicles.indices {
                if i != j && vehicles[j].lane == vehicles[i].lane {
                    let otherVehicle = vehicles[j]
                    if otherVehicle.position.x > vehicles[i].position.x &&
                       otherVehicle.position.x - vehicles[i].position.x < 150 {
                        // Slow down to avoid collision
                        adjustedSpeed = min(adjustedSpeed, otherVehicle.speed * 0.8)
                        break
                    }
                }
            }
            
            vehicles[i].position.x += adjustedSpeed
            
            // Mark vehicles that are far off screen for removal
            if vehicles[i].position.x > screenWidth + 200 {
                indicesToRemove.append(i)
            }
        }
        
        // Remove marked vehicles (in reverse order to maintain indices)
        for index in indicesToRemove.sorted(by: >) {
            if index < vehicles.count {
                vehicles.remove(at: index)
            }
        }
    }
    
    
    
    
    

    
    
    private func startGameTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func updateGame() {
        updateVehicles()
        updateChickens()
        updateFarmer()
        checkCollisions()
        checkGameOver()
        checkWinCondition()
        checkLevelCompletion()
    }
    
    
    
    private func updateChickens() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let roadTop = screenHeight * 0.25
        let roadBottom = screenHeight * 0.4
        let jungleTop = screenHeight * 0.65

        for i in 0..<chickens.count {
            let wasOnRoad = chickens[i].isOnRoad
            chickens[i].isOnRoad = chickens[i].position.y >= roadTop && chickens[i].position.y <= roadBottom
            
            if chickens[i].isOnRoad && !wasOnRoad && chickens[i].isAlive && !chickens[i].isCaught && !chickens[i].hasReachedJungle {
                chickens[i].showRoadTag = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    self?.chickens[i].showRoadTag = false
                }
            }
            
            if chickens[i].isSelected && chickens[i].isAlive && !chickens[i].isCaught && !chickens[i].hasReachedJungle {
                if chickens[i].isOnRoad {
                    chickens[i].position.x += chickens[i].direction * 3.0
                    
                    // Collect coins
                    for j in 0..<coins.count {
                        if !coins[j].isCollected {
                            let distance = sqrt(
                                pow(chickens[i].position.x - coins[j].position.x, 2) +
                                pow(chickens[i].position.y - coins[j].position.y, 2)
                            )
                            
                            if distance < 20 {
                                coins[j].isCollected = true
                                chickens[i].coinsCollected += coins[j].value
                                playerCoins += coins[j].value
                                coinsCollected += 1
                                
                                // Update chicken coins tracking
                                chickenCoins[chickens[i].id, default: 0] += coins[j].value
                                
                                showToast("+\(coins[j].value) Coin", type: .coinCollected, value: coins[j].value)
                                
                                withAnimation(.spring()) {
                                    chickens[i].scale = 1.2
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.spring()) {
                                        self.chickens[i].scale = 1.0
                                    }
                                }
                            }
                        }
                    }
                    
                    // Boundary check
                    if chickens[i].position.x > screenWidth - 20 {
                        chickens[i].position.x = screenWidth - 20
                        chickens[i].direction = -1
                        chickens[i].rotation = -10
                    } else if chickens[i].position.x < 20 {
                        chickens[i].position.x = 20
                        chickens[i].direction = 1
                        chickens[i].rotation = 10
                    } else {
                        chickens[i].rotation = 0
                    }
                }
                
                // Check if chicken reached jungle
                if chickens[i].position.y >= jungleTop && !chickens[i].hasReachedJungle {
                    chickens[i].hasReachedJungle = true
                    chickens[i].isSelected = false
                    chickens[i].showRoadTag = false
                    successfulEscape = chickens[i]
                    
                    // Show jungle success popup
                    showJungleSuccess = true
                    
                    showToast("\(chickens[i].name) Escaped! +\(chickens[i].coinsCollected) Coins",
                             type: .chickenEscaped,
                             value: chickens[i].coinsCollected)
                    
                    // Auto-hide success popup
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        self?.showJungleSuccess = false
                    }
                }
            }
        }
    }
    
    private func updateFarmer() {
        guard farmer.isAlive, farmer.isChasing, let targetId = farmer.targetChickenId,
              let targetIndex = chickens.firstIndex(where: { $0.id == targetId }),
              chickens[targetIndex].isAlive && !chickens[targetIndex].isCaught && !chickens[targetIndex].hasReachedJungle else {
            return
        }
        
        let targetPosition = chickens[targetIndex].position
        let directionX = targetPosition.x - farmer.position.x
        let directionY = targetPosition.y - farmer.position.y
        let distance = sqrt(directionX * directionX + directionY * directionY)
        
        if distance > 15 {
            farmer.position.x += directionX / distance * farmer.speed
            farmer.position.y += directionY / distance * farmer.speed
        }
        
        // Farmer collects coins
        for i in 0..<coins.count {
            if !coins[i].isCollected {
                let distance = sqrt(
                    pow(farmer.position.x - coins[i].position.x, 2) +
                    pow(farmer.position.y - coins[i].position.y, 2)
                )
                
                if distance < 25 {
                    coins[i].isCollected = true
                    farmer.coins += coins[i].value
                    
                    withAnimation(.spring()) {
                        farmer.scale = 1.3
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring()) {
                            self.farmer.scale = 1.0
                        }
                    }
                }
            }
        }
    }

    private func checkCollisions() {
        let screenHeight = UIScreen.main.bounds.height
        let roadTop = screenHeight * 0.25
        let roadBottom = screenHeight * 0.4
        
        // Chicken-vehicle collisions
        for i in 0..<chickens.count {
            if chickens[i].isOnRoad && chickens[i].isAlive && !chickens[i].isJumping && !chickens[i].hasReachedJungle {
                for vehicle in vehicles { // Use for-in instead of indices for safety
                    let distance = sqrt(
                        pow(chickens[i].position.x - vehicle.position.x, 2) +
                        pow(chickens[i].position.y - vehicle.position.y, 2)
                    )
                    
                    if distance < 25 && !chickens[i].isHit {
                        chickens[i].lives -= 1
                        chickens[i].isHit = true
                        
                        showToast("Life Lost! \(chickens[i].lives) left", type: .lifeLost)
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            chickens[i].scale = 1.3
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                            self?.chickens[i].isHit = false
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self?.chickens[i].scale = 1.0
                            }
                        }
                        
                        // Check if chicken died
                        if chickens[i].lives <= 0 {
                            chickens[i].isAlive = false
                            chickens[i].showRoadTag = false
                            playerCoins = max(0, playerCoins - 5)
                            
                            showToast("Chicken Died! -5 Coins", type: .chickenDied)
                            
                            withAnimation(.easeIn(duration: 0.5)) {
                                chickens[i].scale = 0.1
                                chickens[i].rotation = 180
                            }
                        }
                    }
                }
            }
        }
        
        // Rest of the collision code remains the same...
        // Farmer-vehicle collisions
        if farmer.isAlive && farmer.position.y > roadTop && farmer.position.y < roadBottom {
            for vehicle in vehicles {
                let distance = sqrt(
                    pow(farmer.position.x - vehicle.position.x, 2) +
                    pow(farmer.position.y - vehicle.position.y, 2)
                )
                
                if distance < 35 {
                    farmer.isAlive = false
                    playerCoins = max(0, playerCoins - 10)
                    
                    withAnimation(.easeIn(duration: 0.3)) {
                        farmer.scale = 0.1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                        guard let self = self else { return }
                        self.farmer.isAlive = true
                        self.farmer.position = CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.12)
                        self.farmer.isChasing = false
                        
                        withAnimation(.spring()) {
                            self.farmer.scale = 1.0
                        }
                    }
                }
            }
        }
        
        // Farmer-chicken collisions
        if farmer.isAlive && farmer.isChasing {
            for i in 0..<chickens.count {
                if let targetId = farmer.targetChickenId, chickens[i].id == targetId {
                    let distance = sqrt(
                        pow(farmer.position.x - chickens[i].position.x, 2) +
                        pow(farmer.position.y - chickens[i].position.y, 2)
                    )
                    
                    if distance < 25 && chickens[i].isAlive && !chickens[i].isCaught && !chickens[i].hasReachedJungle {
                        catchChicken(chickenIndex: i)
                    }
                }
            }
        }
    }
    
    private func catchChicken(chickenIndex: Int) {
        chickens[chickenIndex].isCaught = true
        chickens[chickenIndex].isSelected = false
        chickens[chickenIndex].showRoadTag = false
        farmer.isChasing = false
        farmer.targetChickenId = nil
        playerCoins += 15
        
        showToast("Farmer Caught Chicken! +15 Coins", type: .farmerCaught, value: 15)
        
        withAnimation(.spring()) {
            chickens[chickenIndex].scale = 0.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let initialPositions = [
                CGPoint(x: screenWidth * 0.2, y: screenHeight * 0.1),
                CGPoint(x: screenWidth * 0.35, y: screenHeight * 0.08),
                CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.12),
                CGPoint(x: screenWidth * 0.65, y: screenHeight * 0.09),
                CGPoint(x: screenWidth * 0.3, y: screenHeight * 0.15),
                CGPoint(x: screenWidth * 0.45, y: screenHeight * 0.13),
                CGPoint(x: screenWidth * 0.55, y: screenHeight * 0.17),
                CGPoint(x: screenWidth * 0.7, y: screenHeight * 0.14)
            ]
            
            self.chickens[chickenIndex].position = initialPositions[chickenIndex]
            self.chickens[chickenIndex].isCaught = false
            self.chickens[chickenIndex].isEscaped = false
            self.chickens[chickenIndex].coinsCollected = 0
            self.chickens[chickenIndex].isOnRoad = false
            self.chickens[chickenIndex].showRoadTag = false
            self.chickens[chickenIndex].lives = 3
            
            withAnimation(.spring()) {
                self.chickens[chickenIndex].scale = 1.0
            }
        }
    }
    
     func checkGameOver() {
        let aliveChickens = chickens.filter { $0.isAlive }
        let escapedChickens = chickens.filter { $0.hasReachedJungle }
        
        // Agar koi chicken alive nahi hai AUR koi chicken escape nahi hui
        if aliveChickens.isEmpty && escapedChickens.isEmpty {
            gameState = .gameOver
        }
        
        // Agar koi chicken alive nahi hai LEKIN kuch chickens escape ho chuki hain
        else if aliveChickens.isEmpty && !escapedChickens.isEmpty {
            // Check if all chickens have escaped
            checkWinCondition()
        }
    }

     func checkWinCondition() {
        let escapedCount = chickens.filter { $0.hasReachedJungle }.count
        
        // Only show the win condition if we haven't already won
        if escapedCount >= chickens.count && gameState != .win {
            gameState = .win
            showToast("All Chickens Escaped! Level Complete! 🎉", type: .levelComplete)
            
            // Automatically save progress when level is won
            let levelId = mainGameManager.selectedLevel?.id ?? 1
            
            mainGameManager.updateLevelProgress(
                levelId: levelId,
                coinsCollected: coinsCollected,
                chickenCoins: chickenCoins,
                allChickensEscaped: true
            )
        }
    }

     func checkLevelCompletion() {
        // Check if all chickens escaped AND all coins collected
        let allEscaped = chickens.allSatisfy { $0.hasReachedJungle }
        let allCoinsCollected = coins.allSatisfy { $0.isCollected }
        
        // Only show level complete if we haven't already shown it
        if allEscaped && allCoinsCollected && !showLevelComplete && gameState == .win {
            showLevelComplete = true
            
            let levelId = mainGameManager.selectedLevel?.id ?? 1
            let level = mainGameManager.getLevel(levelId)
            
            showToast("Perfect! All \(level.requiredCoins) coins collected!", type: .levelComplete)
            
            // Extra bonus for perfect completion
            playerCoins += 50 // Bonus points
            showToast("+50 Perfect Completion Bonus!", type: .coinCollected, value: 50)
        }
    }
    
    // MARK: - Toast System
     func showToast(_ message: String, type: ToastType, value: Int = 0) {
        let toast = ToastMessage(message: message, type: type, value: value)
        toastMessages.append(toast)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.toastMessages.removeAll { $0.id == toast.id }
        }
    }
    
    // MARK: - Public Methods
    func selectChicken(_ chickenId: UUID) {
        guard let index = chickens.firstIndex(where: { $0.id == chickenId }) else { return }
        
        // Check if chicken is already escaped
        if chickens[index].hasReachedJungle {
            showToast("This chicken already escaped!", type: .alreadyEscaped)
            return
        }
        
        // Check if chicken is dead
        if !chickens[index].isAlive {
            showToast("This chicken is dead!", type: .alreadyDead)
            return
        }
        
        // Deselect all chickens first
        for i in 0..<chickens.count {
            chickens[i].isSelected = false
        }
        
        // Select the chosen chicken
        chickens[index].isSelected = true
        selectedChickenId = chickenId
        
        withAnimation(.spring()) {
            chickens[index].scale = 1.1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) {
                self.chickens[index].scale = 1.0
            }
        }
    }
    
    // NEW: MOVE CHICKEN DOWN FUNCTION
    func moveChickenDown() {
        guard let selectedId = selectedChickenId,
              let index = chickens.firstIndex(where: { $0.id == selectedId }),
              chickens[index].isAlive && !chickens[index].isCaught && !chickens[index].hasReachedJungle else {
            
            // Show toast if no chicken is selected
            if selectedChickenId == nil {
                showToast("Please select a chicken first!", type: .noChickenSelected)
            }
            return
        }
        
        let screenHeight = UIScreen.main.bounds.height
        let jungleTop = screenHeight * 0.65
        
        // Only allow moving down if not too close to jungle yet
        if chickens[index].position.y < jungleTop - 50 {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                chickens[index].position.y += 20 // Move down
            }
        } else {
            showToast("Chicken is close to jungle! Keep going!", type: .chickenEscaped)
        }
    }
    
    func moveSelectedChicken() {
        guard let selectedId = selectedChickenId,
              let index = chickens.firstIndex(where: { $0.id == selectedId }),
              chickens[index].isAlive && !chickens[index].isCaught && !chickens[index].hasReachedJungle else {
            
            if selectedChickenId == nil {
                showToast("Please select a chicken first!", type: .noChickenSelected)
            }
            return
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            chickens[index].position.y += 10
        }
    }
    
    func chaseSelectedChicken() {
        guard let selectedId = selectedChickenId,
              let index = chickens.firstIndex(where: { $0.id == selectedId }),
              chickens[index].isAlive && !chickens[index].isCaught && !chickens[index].hasReachedJungle else {
            
            if selectedChickenId == nil {
                showToast("Please select a chicken first!", type: .noChickenSelected)
            }
            return
        }
        
        farmer.isChasing = true
        farmer.targetChickenId = selectedId
        
        withAnimation(.spring()) {
            farmer.scale = 1.2
        }
    }
    
    func catchSelectedChicken() {
        guard let selectedId = selectedChickenId else {
            showToast("Please select a chicken first!", type: .noChickenSelected)
            return
        }
        
        if farmer.isChasing, let targetId = farmer.targetChickenId {
            farmer.speed += 1.0
            
            withAnimation(.spring()) {
                farmer.scale = 1.3
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.farmer.speed = 3.0
                withAnimation(.spring()) {
                    self?.farmer.scale = 1.0
                }
            }
        }
    }
    
    func moveChickenLeft() {
        guard let selectedId = selectedChickenId,
              let index = chickens.firstIndex(where: { $0.id == selectedId }),
              chickens[index].isOnRoad && !chickens[index].hasReachedJungle else { return }
        
        chickens[index].direction = -1
        chickens[index].rotation = -15
    }
    
    func moveChickenRight() {
        guard let selectedId = selectedChickenId,
              let index = chickens.firstIndex(where: { $0.id == selectedId }),
              chickens[index].isOnRoad && !chickens[index].hasReachedJungle else { return }
        
        chickens[index].direction = 1
        chickens[index].rotation = 15
    }
    
    func jumpChicken() {
        guard let selectedId = selectedChickenId,
              let index = chickens.firstIndex(where: { $0.id == selectedId }),
              chickens[index].isOnRoad && !chickens[index].hasReachedJungle else { return }
        
        chickens[index].isJumping = true
        
        withAnimation(.easeOut(duration: 0.3)) {
            chickens[index].scale = 1.3
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.chickens[index].isJumping = false
            withAnimation(.easeIn(duration: 0.3)) {
                self?.chickens[index].scale = 1.0
            }
        }
    }
    
    func resetGame() {
        // Invalidate existing timers
        continuousSpawningTimer?.invalidate()
        timer?.invalidate()
        
        setupLevelGame()
        startGameTimer()
    }
    
    deinit {
        timer?.invalidate()
        continuousSpawningTimer?.invalidate()
    }
}

// MARK: - Game Views
struct ChickenEscapeGameView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var currentView: AppView
    @StateObject private var levelManager: LevelGameManager
    
    init(gameManager: GameManager, currentView: Binding<AppView>) {
        self.gameManager = gameManager
        self._currentView = currentView
        self._levelManager = StateObject(wrappedValue: LevelGameManager(gameManager: gameManager))
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.1, green: 0.3, blue: 0.6), Color(red: 0.3, green: 0.5, blue: 0.9)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Back Button
                HStack {
                    Button(action: {
                        currentView = .chickenSelect
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("Back")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.4))
                        )
                    }
                    
                    Spacer()
                    
                    Text("Level \(gameManager.selectedLevel?.id ?? 1)")
                        .font(.system(size: 20, weight: .black))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Level Info
                    VStack(spacing: 2) {
                        Text("\(levelManager.coinsCollected)/\(gameManager.selectedLevel?.requiredCoins ?? 9)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                        
                        Text("Coins")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.4))
                    )
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Game Area
                CompactGameAreaView(gameManager: levelManager)
                    .frame(maxHeight: .infinity)
                
                // Controls
                CompactControlPanelView(
                    gameManager: levelManager,
                    showJungleSuccess: $levelManager.showJungleSuccess,
                    successfulChicken: $levelManager.successfulEscape
                )
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            
            
            
            // Overlays for game states
            if levelManager.gameState == .gameOver {
                ModernGameOverView(gameManager: levelManager) {
                    levelManager.resetGame()
                } onExit: {
                    currentView = .chickenSelect
                }
            }
            
            
            // Toast Messages
            VStack {
                ForEach(levelManager.toastMessages) { toast in
                    ToastView(toast: toast)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
                Spacer()
            }
            .padding(.top, 50)
            
            // Jungle Success Popup
            if levelManager.showJungleSuccess, let chicken = levelManager.successfulEscape {
                ModernJungleSuccessView(
                    chicken: chicken,
                    showJungleSuccess: $levelManager.showJungleSuccess
                )
            }
            
            // Level Complete Popup
            if levelManager.showLevelComplete {
                ModernLevelCompleteView(
                    gameManager: levelManager,
                    showLevelComplete: $levelManager.showLevelComplete,
                    onContinue: {
                        currentView = .levelSelect
                    }
                )
            }
        }
        .onAppear {
            levelManager.setupLevelGame()
        }
    }
}

// MARK: - Compact Game Views
struct CompactHeaderView: View {
    @ObservedObject var gameManager: LevelGameManager
    
    var body: some View {
        HStack {
            // Player Stats
            HStack(spacing: 12) {
                StatItem(icon: "dollarsign.circle.fill", value: "\(gameManager.playerCoins)", color: .yellow)
                StatItem(icon: "figure.walk", value: "\(gameManager.remainingChickens)", color: .green)
                StatItem(icon: "leaf.fill", value: "\(gameManager.escapedChickens)", color: .blue)
            }
            
            Spacer()
            
            // Farmer Stats
            StatItem(icon: "shield.fill", value: "\(gameManager.farmer.coins)", color: .red)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.4))
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
        )
    }
}

struct CompactGameAreaView: View {
    @ObservedObject var gameManager: LevelGameManager
    
    var body: some View {
        ZStack {
            // Parallax Background
            ParallaxBackgroundView()
            
            // Game Zones
            VStack(spacing: 0) {
                // Farm Area
                CompactFarmAreaView()
                    .frame(height: 60)
            
                // Road Area
                CompactRoadAreaView(gameManager: gameManager)
                    .frame(height: 120)
                
                // Jungle Area
                CompactJungleAreaView()
                    .frame(height: 60)
            }
            
            // Game Objects
            CompactGameObjectsView(gameManager: gameManager)
        }
        .clipped()
    }
}

struct ParallaxBackgroundView: View {
    @State private var cloudOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Sky Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.8, blue: 1.0),
                    Color(red: 0.4, green: 0.7, blue: 1.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Animated Clouds
            ForEach(0..<3) { index in
                Image(systemName: "cloud.fill")
                    .font(.system(size: CGFloat(60 + index * 40)))
                    .foregroundColor(.white.opacity(0.8))
                    .position(
                        x: CGFloat(100 + index * 150) + cloudOffset,
                        y: CGFloat(80 + index * 40)
                    )
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 30).repeatForever(autoreverses: false)) {
                cloudOffset = -UIScreen.main.bounds.width
            }
        }
    }
}

struct CompactFarmAreaView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            HStack {
                Image(systemName: "house.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.brown)
                    .padding(.leading, 20)
                
                Spacer()
                
                Image(systemName: "tree.fill")
                    .font(.system(size: 25))
                    .foregroundColor(.green)
                    .padding(.trailing, 20)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.brown, lineWidth: 4)
        )
    }
}

struct CompactRoadAreaView: View {
    @ObservedObject var gameManager: LevelGameManager
    @State private var dashPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            HStack(spacing: 30) {
                ForEach(0..<6) { _ in
                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: 15, height: 3)
                }
            }
            .offset(x: dashPhase)
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    dashPhase = -60
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.brown)
                .frame(width: 60, height: 4)
                .position(x: UIScreen.main.bounds.width / 2, y: 0)
        )
    }
}

struct CompactJungleAreaView: View {
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Jungle background with gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green.opacity(0.8),
                    Color.green.opacity(0.6),
                    Color.green.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Jungle pattern
            HStack(spacing: 20) {
                ForEach(0..<4) { index in
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.green.opacity(0.7))
                            .rotationEffect(.degrees(Double.random(in: -30...30)))
                        
                        Image(systemName: "tree.fill")
                            .font(.system(size: 18))
                            .foregroundColor(Color.green.opacity(0.8))
                    }
                }
            }
            
            // Pulsing target indicator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("🏁 JUNGLE")
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.green.opacity(0.9))
                                .scaleEffect(pulse ? 1.1 : 0.9)
                        )
                    Spacer()
                }
                .padding(.bottom, 8)
            }
        }
        .overlay(
            // Thick border to indicate jungle boundary
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.green, .yellow, .green]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 6
                )
        )
        .overlay(
            // Arrow indicators pointing to jungle
            VStack {
                Spacer()
                HStack {
                    ForEach(0..<3) { _ in
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .opacity(pulse ? 1.0 : 0.5)
                    }
                }
                .padding(.bottom, 2)
            }
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                pulse.toggle()
            }
        }
    }
}

struct CompactGameObjectsView: View {
    @ObservedObject var gameManager: LevelGameManager
    
    var body: some View {
        ZStack {
            // Coins
            ForEach(gameManager.coins) { coin in
                if !coin.isCollected {
                    CompactCoinView(coin: coin)
                        .position(coin.position)
                }
            }
            
            // Chickens
            ForEach(gameManager.chickens) { chicken in
                if chicken.isAlive && !chicken.isCaught && !chicken.hasReachedJungle {
                    CompactChickenView(chicken: chicken)
                        .position(chicken.position)
                    
                    // Road Tag - Show blinking "PUSH ME" text when chicken is on road
                    if chicken.showRoadTag && chicken.isOnRoad {
                        RoadTagView()
                            .position(x: chicken.position.x, y: chicken.position.y - 40)
                    }
                    
                    // Jungle direction indicator when chicken is close to jungle
                    if chicken.position.y > UIScreen.main.bounds.height * 0.5 {
                        JungleDirectionIndicator(chicken: chicken)
                            .position(x: chicken.position.x, y: chicken.position.y - 50)
                    }
                }
            }
            
            // Farmer
            if gameManager.farmer.isAlive {
                CompactFarmerView(farmer: gameManager.farmer)
                    .position(gameManager.farmer.position)
            }
            
            // Vehicles
            ForEach(gameManager.vehicles) { vehicle in
                CompactVehicleView(vehicle: vehicle)
                    .position(vehicle.position)
            }
        }
    }
}

struct JungleDirectionIndicator: View {
    let chicken: Chicken
    @State private var bounce = false
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.green)
                .offset(y: bounce ? 2 : -2)
            
            Text("Go Down!")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color.green.opacity(0.8))
                )
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                bounce.toggle()
            }
        }
    }
}

struct RoadTagView: View {
    @State private var isBlinking = false
    
    var body: some View {
        Text("PUSH ME")
            .font(.system(size: 12, weight: .black))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color.red.opacity(0.8))
            )
            .scaleEffect(isBlinking ? 1.1 : 0.9)
            .opacity(isBlinking ? 1.0 : 0.6)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                    isBlinking = true
                }
            }
    }
}

struct CompactCoinView: View {
    let coin: Coin
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    gradient: Gradient(colors: [.yellow, .orange]),
                    center: .center,
                    startRadius: 3,
                    endRadius: 8
                ))
                .frame(width: 16, height: 16)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            Text("$")
                .font(.system(size: 8, weight: .black))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct CompactChickenView: View {
    let chicken: Chicken
    @State private var bounceOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Chicken Image
            Image(chicken.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 45, height: 45)
                .scaleEffect(x: chicken.direction > 0 ? 1 : -1)
                .rotationEffect(.degrees(chicken.rotation))
                .offset(y: bounceOffset)
                .scaleEffect(chicken.scale)
                .overlay(
                    chicken.isHit ? Color.red.opacity(0.5) : Color.clear
                )
            
            if chicken.isSelected {
                Circle()
                    .stroke(Color.yellow, lineWidth: 3)
                    .frame(width: 50, height: 50)
            }
            
            if chicken.isJumping {
                Circle()
                    .stroke(Color.blue, lineWidth: 2)
                    .frame(width: 45, height: 45)
                    .opacity(0.7)
            }
            
            // Lives indicator
            if chicken.isAlive && chicken.lives > 0 {
                HStack(spacing: 2) {
                    ForEach(0..<chicken.lives, id: \.self) { _ in
                        Image(systemName: "heart.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.red)
                    }
                }
                .offset(y: -30)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                bounceOffset = -4
            }
        }
    }
}

struct CompactFarmerView: View {
    let farmer: Farmer
    @State private var isWalking = false
    
    var body: some View {
        ZStack {
            // Farmer Image
            Image(GameConstants.farmerImage)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 100)
                .scaleEffect(farmer.scale)
                .offset(x: isWalking ? 1 : -1)
            
            if farmer.isChasing {
                Circle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: 55, height: 55)
                    .opacity(0.7)
            }
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                isWalking = farmer.isChasing
            }
        }
    }
}

struct CompactVehicleView: View {
    let vehicle: Vehicle
    
    var body: some View {
        Image(vehicle.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: getVehicleWidth(), height: getVehicleHeight())
            .scaleEffect(x: vehicle.speed > 0 ? 1 : -1)
    }
    
    private func getVehicleWidth() -> CGFloat {
        switch vehicle.imageName {
        case "motorcycle": return  55
        case "sports_car": return 80
        case "pickup_truck": return 110
        case "delivery_van": return 120
        default: return 60
        }
    }
    
    private func getVehicleHeight() -> CGFloat {
        switch vehicle.imageName {
        case "motorcycle": return 40
        case "sports_car": return 60
        case "pickup_truck": return 80
        case "delivery_van": return 80
        default: return 30
        }
    }
}

// UPDATED CONTROL PANEL WITH DOWN MOVEMENT
struct CompactControlPanelView: View {
    @ObservedObject var gameManager: LevelGameManager
    @Binding var showJungleSuccess: Bool
    @Binding var successfulChicken: Chicken?
    
    var body: some View {
        VStack(spacing: 12) {
            // Chicken Selection
            CompactChickenSelectionView(gameManager: gameManager)
            
            // Road Controls
            if let selectedChicken = gameManager.chickens.first(where: {
                $0.isSelected && $0.isOnRoad && $0.isAlive && !$0.isCaught && !$0.hasReachedJungle
            }) {
                CompactRoadControlsView(gameManager: gameManager, selectedChicken: selectedChicken)
            }
            
            // Action Buttons
            CompactActionButtons(gameManager: gameManager)
        }
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.4))
        )
    }
}

struct CompactChickenSelectionView: View {
    @ObservedObject var gameManager: LevelGameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECT CHICKEN")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(.white.opacity(0.8))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(gameManager.chickens) { chicken in
                        CompactChickenCard(
                            chicken: chicken,
                            isSelected: chicken.isSelected,
                            action: { gameManager.selectChicken(chicken.id) }
                        )
                    }
                }
            }
            .frame(height: 60)
        }
        .padding(.horizontal, 12)
    }
}

struct CompactChickenCard: View {
    let chicken: Chicken
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                ZStack {
                    Image(chicken.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .opacity(chicken.isAlive && !chicken.isCaught && !chicken.hasReachedJungle ? 1.0 : 0.5)
                        .overlay(
                            chicken.isHit ? Color.red.opacity(0.3) : Color.clear
                        )
                    
                    Circle()
                        .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 2)
                        .frame(width: 40, height: 40)
                    
                    // Status indicators
                    if chicken.hasReachedJungle {
                        // Green tick for escaped chickens
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                    } else if !chicken.isAlive {
                        // Red X for dead chickens
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    } else if chicken.isCaught {
                        Image(systemName: "lock.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                
                // Show coins and lives
                VStack(spacing: 1) {
                    Text("\(chicken.coinsCollected)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                    
                    if chicken.isAlive && !chicken.hasReachedJungle {
                        HStack(spacing: 2) {
                            ForEach(0..<chicken.lives, id: \.self) { _ in
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 6))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
            )
        }
        .disabled(!chicken.isAlive || chicken.isCaught || chicken.hasReachedJungle)
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

struct CompactRoadControlsView: View {
    @ObservedObject var gameManager: LevelGameManager
    let selectedChicken: Chicken
    
    private var canMoveOnRoad: Bool {
        selectedChicken.isOnRoad &&
        selectedChicken.isAlive &&
        !selectedChicken.isCaught &&
        !selectedChicken.hasReachedJungle
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text("ROAD CONTROLS")
                .font(.system(size: 12, weight: .black))
                .foregroundColor(canMoveOnRoad ? .white : .gray)
            
            HStack(spacing: 20) {
                RoadControlButton(
                    icon: "arrow.left.circle.fill",
                    color: canMoveOnRoad ? .blue : .gray,
                    action: {
                        if canMoveOnRoad {
                            gameManager.moveChickenLeft()
                        } else {
                            gameManager.showToast("Chicken is not on road!", type: .alreadyDead)
                        }
                    }
                )
                
                RoadControlButton(
                    icon: "arrow.up.circle.fill",
                    color: canMoveOnRoad ? .red : .gray,
                    action: {
                        if canMoveOnRoad {
                            gameManager.jumpChicken()
                        } else {
                            gameManager.showToast("Chicken is not on road!", type: .alreadyDead)
                        }
                    }
                )
                
                RoadControlButton(
                    icon: "arrow.right.circle.fill",
                    color: canMoveOnRoad ? .blue : .gray,
                    action: {
                        if canMoveOnRoad {
                            gameManager.moveChickenRight()
                        } else {
                            gameManager.showToast("Chicken is not on road!", type: .alreadyDead)
                        }
                    }
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.5))
            )
        }
    }
}

struct RoadControlButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(color)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// UPDATED ACTION BUTTONS WITH DOWN MOVEMENT AND VALIDATION
struct CompactActionButtons: View {
    @ObservedObject var gameManager: LevelGameManager
    
    public var hasSelectedChicken: Bool {
        gameManager.selectedChickenId != nil
    }
    
    public  var selectedChicken: Chicken? {
        guard let selectedId = gameManager.selectedChickenId else { return nil }
        return gameManager.chickens.first { $0.id == selectedId }
    }
    
    public  var canMove: Bool {
        guard let chicken = selectedChicken else { return false }
        return chicken.isAlive && !chicken.isCaught && !chicken.hasReachedJungle
    }
    
    var body: some View {
        HStack(spacing: 8) {

            
            // UP Movement Button
            CompactActionButton(
                icon: "arrow.down.circle.fill",
                color: canMove ? .orange : .gray,
                action: {
                    if hasSelectedChicken {
                        gameManager.moveSelectedChicken()
                    } else {
                        gameManager.showToast("Please select a chicken first!", type: .noChickenSelected)
                    }
                }
            )
            
            // Chase Button
            CompactActionButton(
                icon: "figure.run",
                color: canMove ? .red : .gray,
                action: {
                    if hasSelectedChicken {
                        gameManager.chaseSelectedChicken()
                    } else {
                        gameManager.showToast("Please select a chicken first!", type: .noChickenSelected)
                    }
                }
            )
            
            // Catch Button
            CompactActionButton(
                icon: "hand.raised.fill",
                color: canMove ? .green : .gray,
                action: {
                    if hasSelectedChicken {
                        gameManager.catchSelectedChicken()
                    } else {
                        gameManager.showToast("Please select a chicken first!", type: .noChickenSelected)
                    }
                }
            )
        }
        .padding(.horizontal, 12)
    }
}

struct CompactActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color)
                        .scaleEffect(isPressed ? 0.9 : 1.0)
                )
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: ToastMessage
    @State private var offset: CGFloat = -100
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundColor(iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(toast.message)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                if toast.value > 0 {
                    Text("Value: \(toast.value)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
        .offset(y: offset)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                offset = 0
            }
        }
    }
    
    private var iconName: String {
        switch toast.type {
        case .coinCollected:
            return "dollarsign.circle.fill"
        case .lifeLost:
            return "heart.slash.fill"
        case .chickenDied:
            return "xmark.circle.fill"
        case .chickenEscaped:
            return "leaf.fill"
        case .alreadyEscaped:
            return "checkmark.circle.fill"
        case .alreadyDead:
            return "xmark.circle.fill"
        case .levelComplete:
            return "trophy.fill"
        case .farmerCaught:
            return "hand.raised.fill"
        case .noChickenSelected:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var iconColor: Color {
        switch toast.type {
        case .coinCollected:
            return .yellow
        case .lifeLost:
            return .red
        case .chickenDied:
            return .red
        case .chickenEscaped:
            return .green
        case .alreadyEscaped:
            return .green
        case .alreadyDead:
            return .red
        case .levelComplete:
            return .yellow
        case .farmerCaught:
            return .blue
        case .noChickenSelected:
            return .orange
        }
    }
    
    private var backgroundColor: Color {
        switch toast.type {
        case .coinCollected:
            return Color.green.opacity(0.9)
        case .lifeLost:
            return Color.orange.opacity(0.9)
        case .chickenDied:
            return Color.red.opacity(0.9)
        case .chickenEscaped:
            return Color.blue.opacity(0.9)
        case .alreadyEscaped:
            return Color.green.opacity(0.9)
        case .alreadyDead:
            return Color.red.opacity(0.9)
        case .levelComplete:
            return Color.purple.opacity(0.9)
        case .farmerCaught:
            return Color.blue.opacity(0.9)
        case .noChickenSelected:
            return Color.orange.opacity(0.9)
        }
    }
}

// MARK: - Jungle Success View
struct ModernJungleSuccessView: View {
    let chicken: Chicken
    @Binding var showJungleSuccess: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 70, height: 70)
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 35))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 10) {
                Text("Chicken Escaped!")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.green)
                
                Text("\(chicken.name) reached jungle safely! 🎉")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("+\(chicken.coinsCollected) coins collected")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.yellow)
            }
            
            Button("Awesome!") {
                withAnimation(.spring()) {
                    showJungleSuccess = false
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 10)
            .background(Color.blue)
            .cornerRadius(20)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.9))
        )
        .padding(30)
    }
}

// MARK: - Level Complete View
struct ModernLevelCompleteView: View {
    @ObservedObject var gameManager: LevelGameManager
    @Binding var showLevelComplete: Bool
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            }
            
            VStack(spacing: 10) {
                Text("Level Complete!")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.green)
                
                Text("All chickens escaped safely! 🎉")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 8) {
                    Text("Total Coins: \(gameManager.coinsCollected)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("Final Score: \(gameManager.playerCoins)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                    
                    if let level = gameManager.mainGameManager.selectedLevel {
                        Text("Multiplied Score: \(gameManager.playerCoins * level.multiplier)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Button("Continue to Levels") {
                withAnimation(.spring()) {
                    showLevelComplete = false
                    onContinue()
                }
            }
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 30)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(20)
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.9))
        )
        .padding(30)
    }
}

// MARK: - Game Over View
struct ModernGameOverView: View {
    @ObservedObject var gameManager: LevelGameManager
    let onRetry: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ModernOverlayView(
            title: "GAME OVER",
            subtitle: "All chickens have been lost!\n\nCoins Collected: \(gameManager.coinsCollected)\nFinal Score: \(gameManager.playerCoins)",
            buttonTitle: "TRY AGAIN",
            secondaryButtonTitle: "EXIT",
            color: .red,
            action: onRetry,
            secondaryAction: onExit
        )
    }
}

// MARK: - Win View
struct ModernWinView: View {
    @ObservedObject var gameManager: LevelGameManager
    let onNext: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ModernOverlayView(
            title: "LEVEL COMPLETE!",
            subtitle: "All chickens reached safety!\n\nCoins Collected: \(gameManager.coinsCollected)\nFinal Score: \(gameManager.playerCoins)\nMultiplied Score: \(gameManager.playerCoins * (gameManager.mainGameManager.selectedLevel?.multiplier ?? 1))",
            buttonTitle: "PLAY AGAIN",
            secondaryButtonTitle: "LEVEL SELECT",
            color: .green,
            action: onNext,
            secondaryAction: onExit
        )
    }
}

// MARK: - Modern Overlay View
struct ModernOverlayView: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let secondaryButtonTitle: String
    let color: Color
    let action: () -> Void
    let secondaryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 32, weight: .black))
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            
            VStack(spacing: 12) {
                Button(buttonTitle) {
                    withAnimation(.spring()) {
                        action()
                    }
                }
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(color)
                .cornerRadius(20)
                
                Button(secondaryButtonTitle) {
                    withAnimation(.spring()) {
                        secondaryAction()
                    }
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(20)
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.9))
        )
        .padding(40)
    }
}

// MARK: - Game State
enum GameState {
    case playing
    case gameOver
    case win
}

// MARK: - Press Events Modifier
struct PressEvents: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressEvents(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Helper Extension for Random Bool with Probability
extension Bool {
    static func random(withProbability probability: Double) -> Bool {
        return Double.random(in: 0...1) < probability
    }
}
