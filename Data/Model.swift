//
//  Model.swift
//  MzansiAlert
//
//  Created by Lubelihle Ndlovu on 2025/07/02.
//

import Foundation
import SwiftUI
import CoreLocation
import CoreData
import PhotosUI

// MARK: - Data Models
struct Incident: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let category: IncidentCategory
    let location: LocationData
    let timestamp: Date
    let photos: [String]
    var status: IncidentStatus
    let priority: Priority
}

struct LocationData: Codable {
    let latitude: Double
    let longitude: Double
    let address: String
}

enum IncidentCategory: String, CaseIterable, Codable {
    case safety = "Safety"
    case infrastructure = "Infrastructure"
    case environmental = "Environmental"
    case traffic = "Traffic"
    case crime = "Crime"
    case utilities = "Utilities"
    case incident = "incident"
    
    var icon: String {
        switch self {
        case .safety:
            return "shield.fill"
        case .infrastructure:
            return "hammer.fill"
        case .environmental:
            return "leaf.fill"
        case .traffic:
            return "car.fill"
        case .crime:
            return "exclamationmark.triangle.fill"
        case .utilities:
            return "bolt.fill"
        case .incident:
            return "car.side.rear.and.collision.and.car.side.front"
        }
    }
    
    var color: Color {
        switch self {
        case .safety:
            return .blue
        case .infrastructure:
            return .orange
        case .environmental:
            return .green
        case .traffic:
            return .purple
        case .crime:
            return .red
        case .utilities:
            return .yellow
        case .incident:
            return .cyan
        }
    }
}

enum IncidentStatus: String, CaseIterable, Codable {
    case reported = "Reported"
    case inProgress = "In Progress"
    case resolved = "Resolved"
    case dismissed = "Dismissed"
    
    var color: Color {
        switch self {
        case .reported:
            return .blue
        case .inProgress:
            return .orange
        case .resolved:
            return .green
        case .dismissed:
            return .gray
        }
    }
}

enum Priority: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .yellow
        case .high:
            return .orange
        case .critical:
            return .red
        }
    }
}

// MARK: - Core Data Stack
class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MzansiAlert")
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func save() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Core Data save error: \(error)")
            }
        }
    }
}

// MARK: - Database Service
@MainActor
class DatabaseService: ObservableObject {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let coreDataStack: CoreDataStack
    private let userDefaults = UserDefaults.standard
    private let migrationKey = "hasMigratedSampleData"
    
    init() {
        self.coreDataStack = CoreDataStack.shared
        Task {
            await loadIncidents()
            await migrateSampleDataIfNeeded()
        }
    }
    
    func loadIncidents() async {
        isLoading = true
        errorMessage = nil
        
        // For now, use in-memory storage
        // In a real app, this would fetch from Core Data
        incidents = getStoredIncidents()
        isLoading = false
    }
    
    func addIncident(_ incident: Incident) async {
        incidents.append(incident)
        saveIncidents()
    }
    
    func updateIncident(_ incident: Incident) async {
        if let index = incidents.firstIndex(where: { $0.id == incident.id }) {
            incidents[index] = incident
            saveIncidents()
        }
    }
    
    func deleteIncident(id: UUID) async {
        incidents.removeAll { $0.id == id }
        saveIncidents()
    }
    
    private func migrateSampleDataIfNeeded() async {
        guard !hasMigratedSampleData() else { return }
        
        let sampleIncidents = createSampleIncidents()
        for incident in sampleIncidents {
            await addIncident(incident)
        }
        
        markMigrationComplete()
    }
    
    private func hasMigratedSampleData() -> Bool {
        return userDefaults.bool(forKey: migrationKey)
    }
    
    private func markMigrationComplete() {
        userDefaults.set(true, forKey: migrationKey)
    }
    
    private func createSampleIncidents() -> [Incident] {
        return [
            Incident(
                title: "Pothole on Main Street",
                description: "Large pothole causing damage to vehicles near the intersection",
                category: .infrastructure,
                location: LocationData(latitude: -26.2041, longitude: 28.0473, address: "Main Street, Johannesburg"),
                timestamp: Date().addingTimeInterval(-3600),
                photos: [],
                status: .reported,
                priority: .medium
            ),
            Incident(
                title: "Street Light Out",
                description: "Street light has been out for 3 days, creating safety concerns",
                category: .utilities,
                location: LocationData(latitude: -26.2051, longitude: 28.0483, address: "Oak Avenue, Johannesburg"),
                timestamp: Date().addingTimeInterval(-7200),
                photos: [],
                status: .inProgress,
                priority: .high
            ),
            Incident(
                title: "Suspicious Activity",
                description: "Unusual activity reported in the area, multiple residents concerned",
                category: .crime,
                location: LocationData(latitude: -26.2031, longitude: 28.0463, address: "Park Street, Johannesburg"),
                timestamp: Date().addingTimeInterval(-1800),
                photos: [],
                status: .reported,
                priority: .critical
            )
        ]
    }
    
    private func getStoredIncidents() -> [Incident] {
        if let data = userDefaults.data(forKey: "stored_incidents"),
           let incidents = try? JSONDecoder().decode([Incident].self, from: data) {
            return incidents
        }
        return []
    }
    
    private func saveIncidents() {
        if let data = try? JSONEncoder().encode(incidents) {
            userDefaults.set(data, forKey: "stored_incidents")
        }
    }
}

// MARK: - Animation Service
class AnimationService: ObservableObject {
    @Published var animateStats = false
    @Published var animateButton = false
    @Published var cardOpacity = 0.0
    @Published var cardOffset = 50.0
    @Published var showFloatingButton = true
    
    func startHomeAnimations() {
        animateStats = true
        animateButton = true
    }
    
    func startFormAnimations() {
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            cardOpacity = 1.0
            cardOffset = 0
        }
    }
    
    func startFloatingButtonAnimation() {
        withAnimation(.easeInOut(duration: 1)) {
            showFloatingButton.toggle()
        }
    }
}

// MARK: - Incident Store
@MainActor
class IncidentStore: ObservableObject {
    @Published var incidents: [Incident] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let databaseService: DatabaseService
    
    init(databaseService: DatabaseService? = nil) {
        self.databaseService = databaseService ?? DatabaseService()
        
        // Bind to database service
        Task {
            await loadIncidents()
        }
    }
    
    // MARK: - Public Methods
    
    func loadIncidents() async {
        await databaseService.loadIncidents()
        incidents = databaseService.incidents
        isLoading = databaseService.isLoading
        errorMessage = databaseService.errorMessage
    }
    
    func addIncident(_ incident: Incident) {
        Task {
            await databaseService.addIncident(incident)
            await loadIncidents()
        }
    }
    
    func updateIncident(_ incident: Incident) {
        Task {
            await databaseService.updateIncident(incident)
            await loadIncidents()
        }
    }
    
    func deleteIncident(id: UUID) {
        Task {
            await databaseService.deleteIncident(id: id)
            await loadIncidents()
        }
    }
    
    func searchIncidents(query: String) async -> [Incident] {
        return incidents.filter { 
            $0.title.localizedCaseInsensitiveContains(query) || 
            $0.description.localizedCaseInsensitiveContains(query) 
        }
    }
    
    func fetchIncidents(by category: IncidentCategory) async -> [Incident] {
        return incidents.filter { $0.category == category }
    }
    
    func fetchIncidents(by status: IncidentStatus) async -> [Incident] {
        return incidents.filter { $0.status == status }
    }
    
    func fetchIncidents(by priority: Priority) async -> [Incident] {
        return incidents.filter { $0.priority == priority }
    }
    
    // MARK: - Statistics (Computed Properties)
    
    var totalIncidents: Int {
        incidents.count
    }
    
    var inProgressIncidents: Int {
        incidents.filter { $0.status == .inProgress }.count
    }
    
    var resolvedIncidents: Int {
        incidents.filter { $0.status == .resolved }.count
    }
    
    var highPriorityIncidents: Int {
        incidents.filter { $0.priority == .high || $0.priority == .critical }.count
    }
}

// MARK: - Form Components
struct GlassCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct IncidentDetailsSection: View {
    @Binding var title: String
    @Binding var description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(.blue)
                    .frame(width: 24, height: 24)
                Text("Incident Details")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                CustomTextField(
                    placeholder: "What happened?",
                    text: $title,
                    icon: "pencil"
                )
                
                CustomTextEditor(
                    placeholder: "Provide detailed description...",
                    text: $description
                )
            }
        }
    }
}

struct CategoryPrioritySection: View {
    @Binding var selectedCategory: IncidentCategory
    @Binding var selectedPriority: Priority
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(.orange)
                    .frame(width: 24, height: 24)
                Text("Category & Priority")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 16) {
                // Category Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Category")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                        ForEach(IncidentCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                }
                
                // Priority Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Priority Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            PriorityButton(
                                priority: priority,
                                isSelected: selectedPriority == priority
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedPriority = priority
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LocationSection: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var manualAddress: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24)
                Text("Location")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.green.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    if locationManager.currentLocation != nil {
                        Image(systemName: "location.fill")
                            .foregroundColor(.green)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(0.8)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let location = locationManager.currentLocation {
                        Text("Current Location")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fontDesign(.monospaced)
                    } else {
                        Text("Getting location...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Please enable location services")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(12)
            .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        // Manual address input
        VStack(alignment: .leading, spacing: 8) {
            Text("Address (optional)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField("Enter physical address", text: $manualAddress)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct PhotosSection: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "camera")
                    .foregroundColor(.purple)
                    .frame(width: 24, height: 24)
                Text("Photos")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(selectedPhotos.count)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.secondary.opacity(0.1), in: Capsule())
            }
            
            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 5,
                matching: .images
            ) {
                VStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundColor(.purple)
                    
                    Text("Add Photos")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Up to 5 images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 100)
                .background(.purple.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.purple.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
                )
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(16)
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
            }
            
            TextEditor(text: $text)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .scrollContentBackground(.hidden)
        }
        .frame(minHeight: 80)
        .background(.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct CategoryButton: View {
    let category: IncidentCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .foregroundColor(isSelected ? .white : category.color)
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? category.color : .secondary.opacity(0.1),
                in: RoundedRectangle(cornerRadius: 8)
            )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct PriorityButton: View {
    let priority: Priority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(priority.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : priority.color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? priority.color : .secondary.opacity(0.1),
                    in: Capsule()
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct SubmitButton: View {
    @Binding var isSubmitting: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                
                Text(isSubmitting ? "Submitting..." : "Submit Report")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .foregroundColor(.white)
            .shadow(
                color: isDisabled ? .clear : .blue.opacity(0.3),
                radius: 10,
                x: 0,
                y: 5
            )
        }
        .disabled(isDisabled || isSubmitting)
        .scaleEffect(isSubmitting ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isSubmitting)
    }
}

// MARK: - Tab Bar Components
struct TabBarView: View {
    @Binding var selectedTab: Int
    let tabAnimation: Namespace.ID
    
    private let tabItems = [
        TabItem(icon: "house.fill", title: "Home", tag: 0),
        TabItem(icon: "map.fill", title: "Map", tag: 1),
        TabItem(icon: "list.bullet", title: "Reports", tag: 2),
        TabItem(icon: "person.fill", title: "Profile", tag: 3)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \.tag) { item in
                TabBarButton(
                    item: item,
                    selectedTab: $selectedTab,
                    tabAnimation: tabAnimation
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 25)
        .background(
            // Glassmorphism effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .blur(radius: 0.5)
                )
                .mask(
                    RoundedRectangle(cornerRadius: 25)
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
}

struct TabBarButton: View {
    let item: TabItem
    @Binding var selectedTab: Int
    let tabAnimation: Namespace.ID
    
    var isSelected: Bool {
        selectedTab == item.tag
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                selectedTab = item.tag
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Background circle for selected state
                    if isSelected {
                        Circle()
                            .fill(Color.blue.gradient)
                            .frame(width: 50, height: 50)
                            .matchedGeometryEffect(id: "selectedTab", in: tabAnimation)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .gray)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                }
                
                Text(item.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .gray)
                    .opacity(isSelected ? 1 : 0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(TabButtonStyle())
    }
}

struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TabItem {
    let icon: String
    let title: String
    let tag: Int
}

// MARK: - Slide Data Model
struct SlideData {
    let title: String
    let subtitle: String
    let imageName: String
    let isAssetImage: Bool
    let backgroundColor: Color
    let accentColor: Color
}

struct FloatingActionButton: View {
    @Binding var showingReportSheet: Bool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            showingReportSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .orange]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: .red.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isPressed ? 45 : 0))
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .onLongPressGesture(minimumDuration: 0) { 
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
        } onPressingChanged: { pressing in
            if !pressing {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}