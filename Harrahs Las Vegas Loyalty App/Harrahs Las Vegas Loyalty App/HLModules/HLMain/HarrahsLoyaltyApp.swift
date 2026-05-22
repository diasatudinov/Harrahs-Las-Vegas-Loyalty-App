//
//  HarrahsLoyaltyApp.swift
//  Harrahs Las Vegas Loyalty App
//
//


import SwiftUI
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - Theme

enum AppTheme {
    static let deepPurple = Color(hex: 0x1A0F2E)
    static let purple = Color(hex: 0x4A1A6E)
    static let accentPurple = Color(hex: 0x9C27B0)
    static let gold = Color(hex: 0xFFD700)
    static let red = Color(hex: 0xE31837)
    static let green = Color(hex: 0x00C853)
    static let amber = Color(hex: 0xFFB300)
    static let coral = Color(hex: 0xEF5350)
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [AppTheme.deepPurple, AppTheme.purple, .black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(AppTheme.gold.opacity(0.45), lineWidth: 1)
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                Capsule()
                    .fill(isDisabled ? Color.gray : AppTheme.red)
            )
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

// MARK: - Models

enum LoyaltyTier: Int, CaseIterable, Identifiable, Codable {
    case star = 0
    case legend = 1
    case icon = 2
    case x = 3
    case ultimate = 4

    var id: Int { rawValue }

    var icon: String {
        switch self {
        case .star: return "🥉"
        case .legend: return "🥈"
        case .icon: return "🥇"
        case .x: return "💎"
        case .ultimate: return "🌟"
        }
    }
    
    var image: String {
        switch self {
        case .star: return "starImage"
        case .legend: return "legendImage"
        case .icon: return "iconImage"
        case .x: return "xImage"
        case .ultimate: return "ultimateImage"
        }
    }

    var title: String {
        switch self {
        case .star: return "Star"
        case .legend: return "Legend"
        case .icon: return "Icon"
        case .x: return "X"
        case .ultimate: return "Ultimate"
        }
    }

    var requiredCredits: Int {
        switch self {
        case .star: return 0
        case .legend: return 1_000
        case .icon: return 5_000
        case .x: return 15_000
        case .ultimate: return 30_000
        }
    }

    var description: String {
        switch self {
        case .star:
            return "Entry level. Basic bonuses and offers."
        case .legend:
            return "Experienced member. Exclusive bonuses and priority registration."
        case .icon:
            return "Elite member. Personalized offers and dedicated support."
        case .x:
            return "Exclusive invite tier. Personal concierge and VIP access."
        case .ultimate:
            return "Brand legend. Lifetime privileges and unique experiences."
        }
    }

    var next: LoyaltyTier? {
        switch self {
        case .star: return .legend
        case .legend: return .icon
        case .icon: return .x
        case .x: return .ultimate
        case .ultimate: return nil
        }
    }

    static func current(for credits: Int) -> LoyaltyTier {
        LoyaltyTier.allCases
            .sorted { $0.requiredCredits > $1.requiredCredits }
            .first { credits >= $0.requiredCredits } ?? .star
    }
}

struct BonusOffer: Identifiable, Hashable {
    let id: Int
    let icon: String
    let title: String
    let cost: Int
    let shortRedeem: String
    let expiry: String
    let instruction: String

    static let samples: [BonusOffer] = [
        BonusOffer(
            id: 1,
            icon: "🎰",
            title: "50 Free Spins: Mardi Gras Magic Slot",
            cost: 450,
            shortRedeem: "Scan QR at any Mardi Gras Magic slot machine.",
            expiry: "14 days",
            instruction: """
            How to Redeem:
            1. Visit the casino floor at Harrah's Las Vegas.
            2. Find any Mardi Gras Magic slot machine.
            3. Scan this QR code at the loyalty reader.
            4. Your 50 free spins will be loaded automatically.

            Terms:
            • Valid for 14 days from activation.
            • One redemption per account.
            """
        ),
        BonusOffer(
            id: 2,
            icon: "💵",
            title: "$25 Slot Play Credit",
            cost: 300,
            shortRedeem: "Present QR at Casino Cashier or scan at Unity-enabled slots.",
            expiry: "7 days",
            instruction: """
            Your Bonus: $25 Slot Play Credit

            How to Redeem:
            1. Visit any slot floor at Harrah's Las Vegas.
            2. Locate a Unity-enabled slot machine or visit the Casino Cashier.
            3. Present this QR code to the attendant or scan at the machine's loyalty reader.
            4. Your $25 credit will be automatically loaded to your session.

            Terms:
            • Valid for 7 days from activation.
            • One redemption per account per day.
            • Valid only at Harrah's Las Vegas property.
            """
        ),
        BonusOffer(
            id: 3,
            icon: "🍹",
            title: "Complimentary Drink at Carnaval Court",
            cost: 125,
            shortRedeem: "Show QR at any Carnaval Court bar.",
            expiry: "30 days",
            instruction: """
            How to Redeem:
            1. Visit Carnaval Court.
            2. Show this QR code to the bartender.
            3. Receive one complimentary drink.

            Terms:
            • One drink per visit.
            • Valid for 30 days.
            """
        ),
        BonusOffer(
            id: 4,
            icon: "🔄",
            title: "Double Tier Credits: Weekend Boost",
            cost: 400,
            shortRedeem: "Activate before Friday 12:00 AM.",
            expiry: "Valid 2 days",
            instruction: """
            How to Redeem:
            1. Activate this offer before Friday 12:00 AM.
            2. Play Saturday and Sunday.
            3. Earn 2x Tier Credits on all eligible play.

            Terms:
            • Valid for one weekend only.
            """
        ),
        BonusOffer(
            id: 5,
            icon: "🍽",
            title: "Ruth's Chris: $20 Dining Credit",
            cost: 350,
            shortRedeem: "Present QR when paying at Ruth's Chris Steak House.",
            expiry: "60 days",
            instruction: """
            How to Redeem:
            1. Visit Ruth's Chris Steak House.
            2. Present this QR code when paying.
            3. $20 dining credit will be applied to your bill.

            Terms:
            • Valid for dinner only.
            • Valid for 60 days.
            """
        ),
        BonusOffer(
            id: 6,
            icon: "💰",
            title: "10% Cashback on Table Losses",
            cost: 500,
            shortRedeem: "Activate before playing. Cashback credited within 24h.",
            expiry: "7 days",
            instruction: """
            How to Redeem:
            1. Activate this cashback offer before table play.
            2. Play eligible table games.
            3. Cashback will be credited automatically within 24 hours.

            Terms:
            • Cashback up to $50.
            • Valid for 7 days.
            """
        ),
        BonusOffer(
            id: 7,
            icon: "⭐",
            title: "Priority Seating at Ramsay's Kitchen",
            cost: 300,
            shortRedeem: "Show QR to host upon arrival.",
            expiry: "30 days",
            instruction: """
            How to Redeem:
            1. Visit Ramsay's Kitchen.
            2. Show this QR code to the host.
            3. Receive priority seating for your party.

            Terms:
            • Valid for parties up to 4 guests.
            """
        ),
        BonusOffer(
            id: 8,
            icon: "🏆",
            title: "Free Entry: Weekly Poker Satellite",
            cost: 700,
            shortRedeem: "Register via QR at Poker Room desk.",
            expiry: "21 days",
            instruction: """
            How to Redeem:
            1. Visit the Poker Room desk.
            2. Show this QR code.
            3. Register for the weekly poker satellite tournament.

            Terms:
            • $75 tournament value included.
            """
        ),
        BonusOffer(
            id: 9,
            icon: "💆",
            title: "Spa Access: Massage Discount",
            cost: 600,
            shortRedeem: "Present QR at Spa Reception.",
            expiry: "90 days",
            instruction: """
            How to Redeem:
            1. Visit Spa Reception.
            2. Show this QR code.
            3. Receive 20% off any 60-minute massage service.

            Terms:
            • Valid for 90 days.
            """
        ),
        BonusOffer(
            id: 10,
            icon: "❓",
            title: "Mystery Bonus: Reveal for Surprise",
            cost: 275,
            shortRedeem: "Tap to reveal instant reward.",
            expiry: "Instant",
            instruction: """
            How to Redeem:
            1. Activate the mystery bonus.
            2. Show or scan the QR code.
            3. Receive a surprise reward.

            Possible rewards:
            • Free Spins
            • Slot Credits
            • Dining Discount
            """
        )
    ]
}

enum EventStatus: Hashable {
    case open
    case registrationOpen
    case waitlist
    case spotsLeft
    case preRegistration
    case inviteOnly
    case comingSoon
    case earlyBird

    var title: String {
        switch self {
        case .open: return "Open"
        case .registrationOpen: return "Registration Open"
        case .waitlist: return "Waitlist"
        case .spotsLeft: return "6 Spots Left"
        case .preRegistration: return "Pre-Registration"
        case .inviteOnly: return "Invite Only"
        case .comingSoon: return "Coming Soon"
        case .earlyBird: return "Early Bird Pricing"
        }
    }

    var icon: String {
        switch self {
        case .open: return "🔴"
        case .registrationOpen: return "🟢"
        case .waitlist: return "🟡"
        case .spotsLeft: return "🟢"
        case .preRegistration: return "🟡"
        case .inviteOnly: return "🔒"
        case .comingSoon: return "🟡"
        case .earlyBird: return "🟡"
        }
    }

    var color: Color {
        switch self {
        case .open, .registrationOpen, .spotsLeft:
            return AppTheme.green
        case .waitlist, .preRegistration, .comingSoon, .earlyBird:
            return AppTheme.amber
        case .inviteOnly:
            return AppTheme.coral
        }
    }

    var canRegister: Bool {
        switch self {
        case .inviteOnly, .comingSoon:
            return false
        default:
            return true
        }
    }
}

struct CasinoEvent: Identifiable, Hashable {
    let id: Int
    let name: String
    let type: String
    let date: Date
    let dateDisplay: String
    let location: String
    let cost: String
    let requiredTier: LoyaltyTier
    let description: String
    let status: EventStatus
    let emoji: String

    static let samples: [CasinoEvent] = [
        CasinoEvent(
            id: 1,
            name: "Mardi Gras Summer Party",
            type: "Party / Live Music",
            date: DateHelper.makeDate(year: 2026, month: 8, day: 15, hour: 20),
            dateDisplay: "Aug 15, 2026 • 8:00 PM",
            location: "Carnaval Court",
            cost: "Free + 150 Credits",
            requiredTier: .star,
            description: "Live brass band, Mardi Gras beads giveaway, signature cocktails. Best costume wins $250 slot credit.",
            status: .open,
            emoji: "event1Image"
        ),
        CasinoEvent(
            id: 2,
            name: "Harrah's Poker Open: Satellite Tournament",
            type: "Poker Tournament",
            date: DateHelper.makeDate(year: 2026, month: 8, day: 23, hour: 14),
            dateDisplay: "Aug 23, 2026 • 2:00 PM",
            location: "Poker Room",
            cost: "$75 + 200 Credits",
            requiredTier: .star,
            description: "Qualify for the main Harrah's Poker Open. $10,000 prize pool for satellite winners.",
            status: .registrationOpen,
            emoji: "event2Image"
        ),
        CasinoEvent(
            id: 3,
            name: "Big Elvis & Dueling Pianos Night",
            type: "Entertainment Show",
            date: DateHelper.makeDate(year: 2026, month: 9, day: 5, hour: 21),
            dateDisplay: "Sep 5, 2026 • 9:00 PM",
            location: "Piano Bar",
            cost: "$25 Entry + 100 Credits",
            requiredTier: .star,
            description: "Big Elvis tribute show followed by interactive dueling pianos. Includes one complimentary drink.",
            status: .waitlist,
            emoji: "event3Image"
        ),
        CasinoEvent(
            id: 4,
            name: "High Roller Blackjack Challenge",
            type: "Blackjack Tournament",
            date: DateHelper.makeDate(year: 2026, month: 9, day: 21, hour: 15),
            dateDisplay: "Sep 21, 2026 • 3:00 PM",
            location: "High Limit Lounge",
            cost: "$300 + 500 Credits",
            requiredTier: .legend,
            description: "$25,000 prize pool. Winner receives exclusive Harrah's Unity pin and $500 dining credit.",
            status: .spotsLeft,
            emoji: "event4Image"
        ),
        CasinoEvent(
            id: 5,
            name: "Halloween Masquerade: Voodoo Nights",
            type: "Party / Themed Event",
            date: DateHelper.makeDate(year: 2026, month: 10, day: 31, hour: 22),
            dateDisplay: "Oct 31, 2026 • 10:00 PM",
            location: "OMNIA Nightclub",
            cost: "$50 Entry",
            requiredTier: .star,
            description: "Voodoo-themed masquerade with live DJ, costume contest and midnight prize draw.",
            status: .preRegistration,
            emoji: "event5Image"
        ),
        CasinoEvent(
            id: 6,
            name: "Toby Keith's Country Night",
            type: "Concert / Live Music",
            date: DateHelper.makeDate(year: 2026, month: 10, day: 11, hour: 19),
            dateDisplay: "Oct 11, 2026 • 7:00 PM",
            location: "Toby Keith's I Love This Bar",
            cost: "Free for Unity Members",
            requiredTier: .star,
            description: "Live country music tribute, line dancing lessons and special menu items.",
            status: .open,
            emoji: "event6Image"
        ),
        CasinoEvent(
            id: 7,
            name: "Unity Member Appreciation Weekend",
            type: "Special Event",
            date: DateHelper.makeDate(year: 2026, month: 11, day: 1, hour: 10),
            dateDisplay: "Nov 1–2, 2026 • All Day",
            location: "Entire Property",
            cost: "Free",
            requiredTier: .star,
            description: "Double Tier Credits on all play, hourly prize draws and exclusive merch pop-up.",
            status: .open,
            emoji: "event7Image"
        ),
        CasinoEvent(
            id: 8,
            name: "Icon Exclusive: Chef's Table Experience",
            type: "VIP Dining",
            date: DateHelper.makeDate(year: 2026, month: 11, day: 12, hour: 19),
            dateDisplay: "Nov 12, 2026 • 7:00 PM",
            location: "Ramsay's Kitchen Private Room",
            cost: "Complimentary",
            requiredTier: .icon,
            description: "5-course tasting menu curated by executive chef. Limited to 10 guests.",
            status: .inviteOnly,
            emoji: "event8Image"
        ),
        CasinoEvent(
            id: 9,
            name: "Black Friday Slots Frenzy",
            type: "Slots Promotion",
            date: DateHelper.makeDate(year: 2026, month: 11, day: 28, hour: 0),
            dateDisplay: "Nov 28, 2026 • 12:00 AM–11:59 PM",
            location: "All Slot Floors",
            cost: "Free Entry",
            requiredTier: .star,
            description: "Hourly Mystery Bonus triggers on random machines. Guaranteed $50 prize for every 50th player.",
            status: .comingSoon,
            emoji: "event9Image"
        ),
        CasinoEvent(
            id: 10,
            name: "New Year's Eve: Vegas Countdown Spectacular",
            type: "Party / Concert",
            date: DateHelper.makeDate(year: 2026, month: 12, day: 31, hour: 21),
            dateDisplay: "Dec 31, 2026 • 9:00 PM–1:00 AM",
            location: "Main Stage & Casino Floor",
            cost: "$100 General / $250 VIP",
            requiredTier: .legend,
            description: "Live headliner performance, open bar for VIP, champagne toast at midnight and exclusive 2027 Unity chip.",
            status: .earlyBird,
            emoji: "event10Image"
        )
    ]
}

enum BonusTab: String, CaseIterable, Identifiable {
    case available = "🎁 Available"
    case active = "✅ Active"
    case history = "📜 History"

    var id: String { rawValue }
}

enum RedeemResult {
    case success(qr: String)
    case alreadyActivated
    case notEnoughCredits
}

enum RegistrationResult {
    case success(qr: String)
    case alreadyRegistered
    case tierTooLow
    case unavailable
}

// MARK: - Date Helper

enum DateHelper {
    static func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - ViewModel

final class HarrahsViewModel: ObservableObject {
    private enum Keys {
        static let isAuthenticated = "harrahs_isAuthenticated"
        static let username = "harrahs_username"
        static let notifications = "harrahs_notifications"
        static let tierCredits = "harrahs_tierCredits"
        static let rewardCredits = "harrahs_rewardCredits"
        static let activeBonusIDs = "harrahs_activeBonusIDs"
        static let historyBonusIDs = "harrahs_historyBonusIDs"
        static let bonusQRCodes = "harrahs_bonusQRCodes"
        static let registeredEventIDs = "harrahs_registeredEventIDs"
        static let eventQRCodes = "harrahs_eventQRCodes"
        static let scratchLastDate = "harrahs_scratchLastDate"
        static let lastScratchPrize = "harrahs_lastScratchPrize"
    }

    private static let defaults = UserDefaults.standard

    let bonuses = BonusOffer.samples
    let events = CasinoEvent.samples

    @Published var username: String = "Guest" {
        didSet {
            Self.defaults.set(username, forKey: Keys.username)
        }
    }

    @Published var isAuthenticated: Bool = false {
        didSet {
            Self.defaults.set(isAuthenticated, forKey: Keys.isAuthenticated)
        }
    }

    @Published var notificationsEnabled: Bool = true {
        didSet { Self.defaults.set(notificationsEnabled, forKey: Keys.notifications) }
    }

    @Published var tierCredits: Int = 1_200 {
        didSet { Self.defaults.set(tierCredits, forKey: Keys.tierCredits) }
    }

    @Published var rewardCredits: Int = 450 {
        didSet { Self.defaults.set(rewardCredits, forKey: Keys.rewardCredits) }
    }

    @Published var activeBonusIDs: Set<Int> = [] {
        didSet { Self.defaults.set(Array(activeBonusIDs), forKey: Keys.activeBonusIDs) }
    }

    @Published var historyBonusIDs: Set<Int> = [] {
        didSet { Self.defaults.set(Array(historyBonusIDs), forKey: Keys.historyBonusIDs) }
    }

    @Published var bonusQRCodes: [String: String] = [:] {
        didSet { Self.defaults.set(bonusQRCodes, forKey: Keys.bonusQRCodes) }
    }

    @Published var registeredEventIDs: Set<Int> = [] {
        didSet { Self.defaults.set(Array(registeredEventIDs), forKey: Keys.registeredEventIDs) }
    }

    @Published var eventQRCodes: [String: String] = [:] {
        didSet { Self.defaults.set(eventQRCodes, forKey: Keys.eventQRCodes) }
    }

    @Published var scratchLastDate: Date? = nil {
        didSet {
            if let scratchLastDate {
                Self.defaults.set(scratchLastDate, forKey: Keys.scratchLastDate)
            } else {
                Self.defaults.removeObject(forKey: Keys.scratchLastDate)
            }
        }
    }

    @Published var lastScratchPrize: String? = nil {
        didSet { Self.defaults.set(lastScratchPrize, forKey: Keys.lastScratchPrize) }
    }

    init() {
        isAuthenticated = Self.defaults.bool(forKey: Keys.isAuthenticated)
        username = Self.defaults.string(forKey: Keys.username) ?? "Guest"

        if Self.defaults.object(forKey: Keys.notifications) == nil {
            notificationsEnabled = true
        } else {
            notificationsEnabled = Self.defaults.bool(forKey: Keys.notifications)
        }

        if let savedTierCredits = Self.defaults.object(forKey: Keys.tierCredits) as? Int {
            tierCredits = savedTierCredits
        }

        if let savedRewardCredits = Self.defaults.object(forKey: Keys.rewardCredits) as? Int {
            rewardCredits = savedRewardCredits
        }

        let activeIDs = Self.defaults.array(forKey: Keys.activeBonusIDs) as? [Int] ?? []
        activeBonusIDs = Set(activeIDs)

        let historyIDs = Self.defaults.array(forKey: Keys.historyBonusIDs) as? [Int] ?? []
        historyBonusIDs = Set(historyIDs)

        bonusQRCodes = Self.defaults.dictionary(forKey: Keys.bonusQRCodes) as? [String: String] ?? [:]

        let eventIDs = Self.defaults.array(forKey: Keys.registeredEventIDs) as? [Int] ?? []
        registeredEventIDs = Set(eventIDs)

        eventQRCodes = Self.defaults.dictionary(forKey: Keys.eventQRCodes) as? [String: String] ?? [:]

        scratchLastDate = Self.defaults.object(forKey: Keys.scratchLastDate) as? Date
        lastScratchPrize = Self.defaults.string(forKey: Keys.lastScratchPrize)
    }

    var currentTier: LoyaltyTier {
        LoyaltyTier.current(for: tierCredits)
    }

    var nextTier: LoyaltyTier? {
        currentTier.next
    }

    var tierProgress: Double {
        guard let nextTier else { return 1 }

        let currentRequired = currentTier.requiredCredits
        let nextRequired = nextTier.requiredCredits
        let value = Double(tierCredits - currentRequired) / Double(nextRequired - currentRequired)

        return min(max(value, 0), 1)
    }

    var tierProgressText: String {
        guard let nextTier else {
            return "Maximum tier reached"
        }

        return "\(tierCredits) / \(nextTier.requiredCredits) Tier Credits to \(nextTier.title)"
    }

    var isScratchAvailable: Bool {
        guard let scratchLastDate else { return true }

        let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: scratchLastDate) ?? Date()
        return Date() >= nextDate
    }

    var scratchCooldownText: String {
        guard let scratchLastDate else { return "Available now" }

        let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: scratchLastDate) ?? Date()
        let components = Calendar.current.dateComponents([.day, .hour], from: Date(), to: nextDate)

        let days = max(components.day ?? 0, 0)
        let hours = max(components.hour ?? 0, 0)

        if days == 0 && hours == 0 {
            return "Available soon"
        }

        return "Next scratch in \(days)d \(hours)h"
    }

    func signIn(username: String, password: String) -> Bool {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanUsername.isEmpty, password.count >= 4 else {
            return false
        }

        isAuthenticated = true
        self.username = cleanUsername

        return true
    }

    func register(username: String, password: String) -> Bool {
        signIn(username: username, password: password)
    }

    func signOut() {
        isAuthenticated = false
        username = "Guest"
    }

    func redeem(_ bonus: BonusOffer) -> RedeemResult {
        if activeBonusIDs.contains(bonus.id) || historyBonusIDs.contains(bonus.id) {
            return .alreadyActivated
        }

        guard rewardCredits >= bonus.cost else {
            return .notEnoughCredits
        }

        rewardCredits -= bonus.cost
        activeBonusIDs.insert(bonus.id)

        let qr = "HARRAHS-BONUS-\(bonus.id)-\(UUID().uuidString)"
        bonusQRCodes["bonus_\(bonus.id)"] = qr

        return .success(qr: qr)
    }

    func bonusQR(for bonus: BonusOffer) -> String {
        bonusQRCodes["bonus_\(bonus.id)"] ?? "HARRAHS-BONUS-\(bonus.id)"
    }

    func markBonusUsed(_ bonus: BonusOffer) {
        activeBonusIDs.remove(bonus.id)
        historyBonusIDs.insert(bonus.id)
    }

    func register(for event: CasinoEvent) -> RegistrationResult {
        guard event.status.canRegister else {
            return .unavailable
        }

        guard currentTier.rawValue >= event.requiredTier.rawValue else {
            return .tierTooLow
        }

        if registeredEventIDs.contains(event.id) {
            return .alreadyRegistered
        }

        registeredEventIDs.insert(event.id)

        let qr = "HARRAHS-EVENT-\(event.id)-\(UUID().uuidString)"
        eventQRCodes["event_\(event.id)"] = qr

        return .success(qr: qr)
    }

    func eventQR(for event: CasinoEvent) -> String {
        eventQRCodes["event_\(event.id)"] ?? "HARRAHS-EVENT-\(event.id)"
    }

    func revealScratchCard() -> String {
        guard isScratchAvailable else {
            return lastScratchPrize ?? "Come back next week"
        }

        let prizes: [(title: String, credits: Int)] = [
            ("50 Reward Credits", 50),
            ("75 Reward Credits", 75),
            ("100 Reward Credits", 100),
            ("Free Drink Voucher", 0),
            ("Priority Seating Badge", 0),
            ("Mystery Bonus Token", 0)
        ]

        let prize = prizes.randomElement() ?? ("50 Reward Credits", 50)

        rewardCredits += prize.credits
        lastScratchPrize = prize.title
        scratchLastDate = Date()

        return prize.title
    }

    func addTierCredits(_ amount: Int) -> String? {
        let oldTier = currentTier
        tierCredits += amount
        let newTier = currentTier

        guard newTier != oldTier else { return nil }

        return "Congratulations! You're now a Unity \(newTier.title). Enjoy your new perks!"
    }
}

// MARK: - Sign In

struct SignInView: View {
    @ObservedObject var viewModel: HarrahsViewModel

    @State private var username = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var errorText: String?

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Harrah's")
                        .font(.system(size: 42, weight: .black))
                        .foregroundColor(AppTheme.gold)

                    Text("LAS VEGAS")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))

                    Text("Play Hard. Stay Lucky. Unity Rewards.")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }

                GlassCard {
                    VStack(spacing: 16) {
                        Text("🎭 Sign In")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        TextField("Username / Email", text: $username)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(14)
                            .foregroundColor(.white)

                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .foregroundColor(.white)
                            } else {
                                SecureField("Password", text: $password)
                                    .foregroundColor(.white)
                            }

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(AppTheme.gold)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(14)

                        if let errorText {
                            Text(errorText)
                                .font(.caption)
                                .foregroundColor(AppTheme.coral)
                        }

                        Button {
                            let success = viewModel.signIn(username: username, password: password)

                            if !success {
                                errorText = "Enter username and password with at least 4 characters."
                            }
                        } label: {
                            Text("🎭 Sign In")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Main Tab

struct MainTabView: View {
    @ObservedObject var viewModel: HarrahsViewModel
    @State var selectedTab = 0
        private let tabs = ["Bonuses", "Events", "About", "Profile"]
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                BonusesView(viewModel: viewModel)
                    .tag(0)
                
                EventsView(viewModel: viewModel)
                    .tag(1)
                
                AboutCasinoView()
                    .tag(2)
                
                SettingsView(viewModel: viewModel)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .tint(AppTheme.gold)
            
            customTabBar
        }
        .background(
            AppBackground()
        )
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    selectedTab = index
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: icon(for: index))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 24)
                            .foregroundStyle(selectedTab == index ? AppTheme.gold : .white.opacity(0.5))
                        
                        Text(tabs[index])
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(selectedTab == index ? AppTheme.gold : .white.opacity(0.5))
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [AppTheme.deepPurple, AppTheme.purple, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(AppTheme.gold.opacity(0.45), lineWidth: 1)
        )
        .padding(16)
        .padding(.bottom, 15)
    }
    
    private func icon(for index: Int) -> String {
        switch index {
        case 0: return "gift.fill"
        case 1: return "calendar"
        case 2: return "building.2.fill"
        case 3: return "person.crop.circle.fill"
            
        default: return ""
        }
    }
    
    private func selectedIcon(for index: Int) -> String {
        switch index {
        case 0: return "tab1IconSelectedFP"
        case 1: return "tab2IconSelectedFP"
        case 2: return "tab3IconSelectedFP"
        case 3: return "tab4IconSelectedFP"
        default: return ""
        }
    }
}

// MARK: - Shared Header

struct HeaderView: View {
    @ObservedObject var viewModel: HarrahsViewModel

    var body: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Harrah's Las Vegas")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(viewModel.currentTier.icon) \(viewModel.currentTier.title)")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.gold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(viewModel.rewardCredits)")
                        .font(.title3.monospacedDigit().bold())
                        .foregroundColor(.white)

                    Text("Reward Credits")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

// MARK: - Bonuses

struct BonusRedemptionSheet: Identifiable {
    let id = UUID()
    let bonus: BonusOffer
    let qr: String
}

struct BonusesView: View {
    @ObservedObject var viewModel: HarrahsViewModel

    @State private var selectedTab: BonusTab = .available
    @State private var pendingBonus: BonusOffer?
    @State private var redemptionSheet: BonusRedemptionSheet?
    @State private var errorMessage: String?
    @State private var showError = false

    private var visibleBonuses: [BonusOffer] {
        switch selectedTab {
        case .available:
            return viewModel.bonuses.filter {
                !viewModel.activeBonusIDs.contains($0.id) &&
                !viewModel.historyBonusIDs.contains($0.id)
            }
        case .active:
            return viewModel.bonuses.filter { viewModel.activeBonusIDs.contains($0.id) }
        case .history:
            return viewModel.bonuses.filter { viewModel.historyBonusIDs.contains($0.id) }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        
                        Text("Bonuses")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(.logoHL)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        
                        HeaderView(viewModel: viewModel)

                        ScratchCardView(viewModel: viewModel)

                        Picker("Bonuses", selection: $selectedTab) {
                            ForEach(BonusTab.allCases) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(.segmented)

                        if visibleBonuses.isEmpty {
                            EmptyStateView(
                                icon: "🎁",
                                title: "No bonuses here",
                                subtitle: "Check another tab or come back later."
                            )
                        } else {
                            ForEach(visibleBonuses) { bonus in
                                BonusCardView(
                                    bonus: bonus,
                                    isActive: viewModel.activeBonusIDs.contains(bonus.id),
                                    isHistory: viewModel.historyBonusIDs.contains(bonus.id),
                                    onRedeem: {
                                        pendingBonus = bonus
                                    },
                                    onViewQR: {
                                        redemptionSheet = BonusRedemptionSheet(
                                            bonus: bonus,
                                            qr: viewModel.bonusQR(for: bonus)
                                        )
                                    },
                                    onMarkUsed: {
                                        viewModel.markBonusUsed(bonus)
                                    }
                                )
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 150)
                }
            }
            .alert(
                "Redeem Bonus?",
                isPresented: Binding(
                    get: { pendingBonus != nil },
                    set: { newValue in
                        if !newValue {
                            pendingBonus = nil
                        }
                    }
                )
            ) {
                Button("Cancel", role: .cancel) {
                    pendingBonus = nil
                }

                Button("Redeem") {
                    guard let bonus = pendingBonus else { return }

                    switch viewModel.redeem(bonus) {
                    case .success(let qr):
                        redemptionSheet = BonusRedemptionSheet(bonus: bonus, qr: qr)
                    case .alreadyActivated:
                        errorMessage = "This bonus is already activated."
                        showError = true
                    case .notEnoughCredits:
                        errorMessage = "Not enough Reward Credits."
                        showError = true
                    }

                    pendingBonus = nil
                }
            } message: {
                if let pendingBonus {
                    Text("Cost: \(pendingBonus.cost) Reward Credits")
                }
            }
            .alert("Message", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
            .sheet(item: $redemptionSheet) { sheet in
                QRInstructionView(
                    title: sheet.bonus.title,
                    subtitle: "Bonus QR Code",
                    qrText: sheet.qr,
                    instruction: sheet.bonus.instruction,
                    primaryButtonTitle: "📋 Copy Instructions",
                    primaryAction: {
                        UIPasteboard.general.string = sheet.bonus.instruction
                    }
                )
            }
        }
    }
}

struct ScratchCardView: View {
    @ObservedObject var viewModel: HarrahsViewModel

    @State private var prize: String?
    @State private var dragCount = 0

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🎁 Weekly Scratch Card")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Text(viewModel.isScratchAvailable ? "Available" : "Used")
                        .font(.caption.bold())
                        .foregroundColor(viewModel.isScratchAvailable ? AppTheme.green : AppTheme.amber)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.accentPurple, AppTheme.deepPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: 8) {
                        if let prize {
                            Text("You won")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))

                            Text(prize)
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.gold)
                        } else if viewModel.isScratchAvailable {
                            Text("Swipe to reveal")
                                .font(.title3.bold())
                                .foregroundColor(.white)

                            Text("You can scratch this card once per week.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.75))
                        } else {
                            Text(viewModel.lastScratchPrize ?? "Already scratched")
                                .font(.title3.bold())
                                .foregroundColor(AppTheme.gold)

                            Text(viewModel.scratchCooldownText)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.75))
                        }
                    }
                    .padding()
                }
                .frame(height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppTheme.gold.opacity(0.8), lineWidth: 1)
                )
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .onChanged { _ in
                            guard viewModel.isScratchAvailable, prize == nil else { return }
                            dragCount += 1
                        }
                        .onEnded { _ in
                            guard viewModel.isScratchAvailable, prize == nil else { return }

                            if dragCount >= 1 {
                                prize = viewModel.revealScratchCard()
                            }

                            dragCount = 0
                        }
                )
            }
        }
    }
}

struct BonusCardView: View {
    let bonus: BonusOffer
    let isActive: Bool
    let isHistory: Bool
    let onRedeem: () -> Void
    let onViewQR: () -> Void
    let onMarkUsed: () -> Void

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    Text(bonus.icon)
                        .font(.system(size: 44))
                        .frame(width: 60, height: 60)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(bonus.title)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(bonus.shortRedeem)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))

                        Text("Expiry: \(bonus.expiry)")
                            .font(.caption)
                            .foregroundColor(AppTheme.gold)
                    }

                    Spacer()
                }

                HStack {
                    Label("\(bonus.cost) Credits", systemImage: "creditcard.fill")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.85))

                    Spacer()

                    if isHistory {
                        Text("Used")
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.7))
                    } else if isActive {
                        Button("Show QR") {
                            onViewQR()
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.gold)

                        Button("Mark Used") {
                            onMarkUsed()
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.7))
                    } else {
                        Button("🔓 Redeem") {
                            onRedeem()
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.gold)
                    }
                }
            }
        }
    }
}

// MARK: - Events

struct EventTicketSheet: Identifiable {
    let id = UUID()
    let event: CasinoEvent
    let qr: String
}

struct EventsView: View {
    @ObservedObject var viewModel: HarrahsViewModel

    @State private var selectedMonth = DateHelper.makeDate(year: 2026, month: 8, day: 1, hour: 0)
    @State private var ticketSheet: EventTicketSheet?

    var body: some View {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("Events")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HeaderView(viewModel: viewModel)

                        EventCalendarView(
                            events: viewModel.events,
                            selectedMonth: $selectedMonth
                        )

                        ForEach(viewModel.events) { event in
                            NavigationLink {
                                EventDetailView(
                                    viewModel: viewModel,
                                    event: event,
                                    ticketSheet: $ticketSheet
                                )
                            } label: {
                                EventRowView(
                                    event: event,
                                    isRegistered: viewModel.registeredEventIDs.contains(event.id)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                    .padding(.bottom, 150)
                }
            }
            .sheet(item: $ticketSheet) { sheet in
                QRInstructionView(
                    title: sheet.event.name,
                    subtitle: "Your Entry QR Code",
                    qrText: sheet.qr,
                    instruction: """
                    How to Enter:
                    1. Arrive at Harrah's Las Vegas before the event starts.
                    2. Proceed to \(sheet.event.location).
                    3. Show this QR code to the event staff for check-in.
                    4. Receive your event wristband or entry confirmation.

                    Important:
                    • Valid Unity Loyalty membership required.
                    • Event: \(sheet.event.dateDisplay)
                    • Location: \(sheet.event.location)
                    """,
                    primaryButtonTitle: "📋 Copy Event Details",
                    primaryAction: {
                        UIPasteboard.general.string = "\(sheet.event.name)\n\(sheet.event.dateDisplay)\n\(sheet.event.location)"
                    }
                )
            }
        
    }
}

struct EventCalendarView: View {
    let events: [CasinoEvent]
    @Binding var selectedMonth: Date

    private let calendar = Calendar.current

    var body: some View {
        GlassCard {
            VStack(spacing: 14) {
                HStack {
                    Button {
                        moveMonth(-1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppTheme.gold)
                    }

                    Spacer()

                    Text(monthTitle(selectedMonth))
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        moveMonth(1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppTheme.gold)
                    }
                }

                let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption.bold())
                            .foregroundColor(.white.opacity(0.65))
                    }

                    ForEach(calendarCells(), id: \.self) { day in
                        if day == 0 {
                            Color.clear
                                .frame(height: 34)
                        } else {
                            VStack(spacing: 3) {
                                Text("\(day)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)

                                Circle()
                                    .fill(hasEvent(on: day) ? AppTheme.gold : Color.clear)
                                    .frame(width: 5, height: 5)
                            }
                            .frame(height: 34)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(hasEvent(on: day) ? Color.white.opacity(0.13) : Color.white.opacity(0.04))
                            )
                        }
                    }
                }
            }
        }
    }

    private func moveMonth(_ value: Int) {
        selectedMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth) ?? selectedMonth
    }

    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func calendarCells() -> [Int] {
        guard
            let range = calendar.range(of: .day, in: .month, for: selectedMonth),
            let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let blanks = firstWeekday - 1

        return Array(repeating: 0, count: blanks) + Array(range)
    }

    private func hasEvent(on day: Int) -> Bool {
        let selectedComponents = calendar.dateComponents([.year, .month], from: selectedMonth)

        return events.contains { event in
            let components = calendar.dateComponents([.year, .month, .day], from: event.date)
            return components.year == selectedComponents.year &&
            components.month == selectedComponents.month &&
            components.day == day
        }
    }
}

struct EventRowView: View {
    let event: CasinoEvent
    let isRegistered: Bool

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    
                    Image(event.emoji)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            Image("ramka")
                                .resizable()
                                .scaledToFill()
                                .padding(-15)
                        }

                    
                }
                

                HStack {
                    Text("\(event.status.icon) \(event.status.title)")
                        .font(.caption.bold())
                        .foregroundColor(event.status.color)

                    Spacer()

                    if isRegistered {
                        Text("Registered")
                            .font(.caption.bold())
                            .foregroundColor(AppTheme.gold)
                    }
                }
                .padding(.top, 10)

                Text(event.location)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

struct EventDetailView: View {
    @ObservedObject var viewModel: HarrahsViewModel
    let event: CasinoEvent
    @Binding var ticketSheet: EventTicketSheet?

    @State private var showConfirm = false
    @State private var message: String?
    @State private var showMessage = false

    private var isRegistered: Bool {
        viewModel.registeredEventIDs.contains(event.id)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.deepPurple, AppTheme.accentPurple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        VStack(spacing: 10) {
                            Image(event.emoji)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 22))

                            Text(event.name)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("\(event.status.icon) \(event.status.title)")
                                .font(.caption.bold())
                                .foregroundColor(event.status.color)
                        }
                        .padding()
                    }
                    .frame(height: 240)

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            DetailLine(title: "Type", value: event.type)
                            DetailLine(title: "Date", value: event.dateDisplay)
                            DetailLine(title: "Location", value: event.location)
                            DetailLine(title: "Cost", value: event.cost)
                            DetailLine(title: "Required Tier", value: "\(event.requiredTier.icon) \(event.requiredTier.title)+")
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(event.description)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    if isRegistered {
                        Button {
                            ticketSheet = EventTicketSheet(
                                event: event,
                                qr: viewModel.eventQR(for: event)
                            )
                        } label: {
                            Text("📱 Show Entry QR")
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    } else {
                        Button {
                            showConfirm = true
                        } label: {
                            Text(event.status == .waitlist ? "✅ Join Waitlist" : "✅ Register")
                        }
                        .buttonStyle(PrimaryButtonStyle(isDisabled: !event.status.canRegister))
                        .disabled(!event.status.canRegister)
                    }
                }
                .padding()
            }
        }
        .alert("Register for Event?", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) {}

            Button("Register") {
                switch viewModel.register(for: event) {
                case .success(let qr):
                    ticketSheet = EventTicketSheet(event: event, qr: qr)
                case .alreadyRegistered:
                    message = "You are already registered."
                    showMessage = true
                case .tierTooLow:
                    message = "Your loyalty tier is too low for this event."
                    showMessage = true
                case .unavailable:
                    message = "Registration is not available for this event."
                    showMessage = true
                }
            }
        } message: {
            Text(event.name)
        }
        .alert("Message", isPresented: $showMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message ?? "")
        }
    }
}

struct DetailLine: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(.white.opacity(0.65))
                .frame(width: 110, alignment: .leading)

            Text(value)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.subheadline)
    }
}

// MARK: - About Casino

struct AboutCasinoView: View {
    private let photoTitles = [
        "Casino Floor", "Hotel Room", "Pool", "Restaurant", "Lobby",
        "Suite", "Piano Bar", "Ramsay's Kitchen", "Carnaval Court", "High Limit Lounge"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("About Casino")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("🏨 About Harrah's Las Vegas")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(photoTitles, id: \.self) { title in
                                ZStack(alignment: .bottomLeading) {
                                    
                                    Image(title)
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(RoundedRectangle(cornerRadius: 18))

                                    Text(title)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                        .padding(10)
                                }
                                .frame(height: 110)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(AppTheme.gold.opacity(0.4), lineWidth: 1)
                                )
                            }
                        }

                        AboutSection(
                            title: "📜 History",
                            text: """
                            Originally opened in 1973 as the Holiday Casino, the property was renamed Harrah's in 1992 in honor of the company's founder. A major renovation in 1997 replaced the riverboat theme with the vibrant Mardi Gras and carnival theme seen today.
                            """
                        )

                        AboutSection(
                            title: "🎰 Casino Floor",
                            text: """
                            • Gaming Area: Approximately 95,000 square feet
                            • Slot Machines: Over 1,200 latest video and classic reel slots
                            • Table Games: Blackjack, roulette, craps, baccarat and more
                            • Poker Room: Cash games and tournaments
                            • High Limit Lounge: Private area for high-stakes players
                            """
                        )

                        AboutSection(
                            title: "🍽 Dining & Bars",
                            text: """
                            • Ruth's Chris Steak House
                            • Toby Keith's I Love This Bar & Grill
                            • Fulton Street Food Hall
                            • Ramsay's Kitchen
                            • Carnaval Court
                            • Piano Bar
                            """
                        )

                        AboutSection(
                            title: "🏊 Recreation & Wellness",
                            text: """
                            • Outdoor heated pool deck
                            • Full-service spa
                            • Fitness center
                            • Cabanas and poolside service
                            """
                        )

                        AboutSection(
                            title: "📍 Location & Access",
                            text: """
                            Address: 3475 Las Vegas Boulevard South, Las Vegas, Nevada 89109

                            Nearby Attractions:
                            • The LINQ Promenade
                            • High Roller Observation Wheel
                            • Flamingo Wildlife Habitat
                            """
                        )

                        AboutSection(
                            title: "ℹ️ Guest Services",
                            text: """
                            • 24/7 Front Desk & Concierge
                            • Unity Loyalty Program enrollment and support
                            • Valet parking and self-parking options
                            • ADA accessible facilities throughout the property
                            """
                        )
                    }
                    .padding()
                    .padding(.bottom, 150)
                }
            }
        }
    }
}

struct AboutSection: View {
    let title: String
    let text: String

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.gold)

                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Settings

struct SettingsView: View {
    @ObservedObject var viewModel: HarrahsViewModel

       @State private var isAuthSheetPresented = false
       @State private var levelUpMessage: String?
       @State private var showLevelUp = false

       var body: some View {
           NavigationStack {
               ZStack {
                   AppBackground()

                   ScrollView {
                       VStack(spacing: 16) {
                           
                           Text("Profile")
                               .font(.largeTitle)
                               .foregroundColor(.white)
                               .frame(maxWidth: .infinity, alignment: .leading)
                           
                           profileHeader

                           if viewModel.isAuthenticated {
                               authenticatedSettings
                           } else {
                               guestSettings
                           }

                           loyaltyStatusCard

                           if viewModel.isAuthenticated {
                               Button {
                                   viewModel.signOut()
                               } label: {
                                   Text("Log Out")
                                       .foregroundColor(.white)
                                       .frame(maxWidth: .infinity)
                                       .padding()
                                       .background(Color.white.opacity(0.12))
                                       .cornerRadius(18)
                               }
                           }
                       }
                       .padding()
                       .padding(.bottom, 150)
                   }
               }
               .sheet(isPresented: $isAuthSheetPresented) {
                   
                   AuthModalView(viewModel: viewModel)
               }
               .alert("Level Up!", isPresented: $showLevelUp) {
                   Button("Great", role: .cancel) {}
               } message: {
                   Text(levelUpMessage ?? "")
               }
           }
       }

       private var profileHeader: some View {
           GlassCard {
               VStack(spacing: 14) {
                   ZStack {

                       Image(viewModel.isAuthenticated ? "isAuthenticated" : "notAuthenticated")
                           .resizable()
                           .scaledToFit()
                           .frame(height: 110)
                   }

                   Text(viewModel.username)
                       .font(.title3.bold())
                       .foregroundColor(.white)

                   Text(viewModel.isAuthenticated ? "Unity Rewards Member" : "Guest Mode")
                       .font(.subheadline)
                       .foregroundColor(.white.opacity(0.7))
               }
               .frame(maxWidth: .infinity)
           }
       }

       private var guestSettings: some View {
           GlassCard {
               VStack(alignment: .leading, spacing: 14) {
                   Text("Guest Mode")
                       .font(.headline)
                       .foregroundColor(.white)

                   Text("You can explore bonuses, events and casino information as a guest. Sign in or register to personalize your profile.")
                       .font(.subheadline)
                       .foregroundColor(.white.opacity(0.75))

                   Button {
                       isAuthSheetPresented = true
                   } label: {
                       Text("🎭 Sign In / Register")
                   }
                   .buttonStyle(PrimaryButtonStyle())
               }
           }
       }

       private var authenticatedSettings: some View {
           GlassCard {
               VStack(alignment: .leading, spacing: 14) {
                   Text("👤 Profile")
                       .font(.headline)
                       .foregroundColor(.white)

                   TextField("Username", text: .constant(viewModel.username))
                       .disabled(true)
                       .padding()
                       .background(Color.white.opacity(0.1))
                       .cornerRadius(14)
                       .foregroundColor(.white)
               }
           }
       }

       private var loyaltyStatusCard: some View {
           GlassCard {
               VStack(alignment: .leading, spacing: 14) {
                   HStack {
                       VStack(alignment: .leading, spacing: 4) {
                           Text("Loyalty Status")
                               .font(.headline)
                               .foregroundColor(.white)

                       }

                       Spacer()
                   }
                   
                   VStack {
                       Image(viewModel.currentTier.image)
                           .resizable()
                           .scaledToFit()
                           .frame(height: 100)
                       
                       Text("\(viewModel.currentTier.title)")
                           .font(.title2.bold())
                           .foregroundColor(AppTheme.gold)
                       
                   }
                   .frame(maxWidth: .infinity, alignment: .center)

                   ProgressView(value: viewModel.tierProgress)
                       .tint(AppTheme.gold)

                   Text(viewModel.tierProgressText)
                       .font(.caption)
                       .foregroundColor(.white.opacity(0.75))

                   Text(viewModel.currentTier.description)
                       .font(.subheadline)
                       .foregroundColor(.white.opacity(0.8))

                   Button {
                       if let message = viewModel.addTierCredits(60) {
                           levelUpMessage = message
                           showLevelUp = true
                       }
                   } label: {
                       Text("Simulate Play: +60 Tier Credits")
                   }
                   .buttonStyle(PrimaryButtonStyle())
               }
           }
       }
   }

// MARK: - QR View

struct QRInstructionView: View {
    let title: String
    let subtitle: String
    let qrText: String
    let instruction: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(spacing: 18) {
                    Text(title)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.gold)

                    QRCodeView(text: qrText)
                        .frame(width: 220, height: 220)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(24)

                    GlassCard {
                        Text(instruction)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.85))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        primaryAction()
                    } label: {
                        Text(primaryButtonTitle)
                    }
                    .buttonStyle(PrimaryButtonStyle())

                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
            }
        }
    }
}

struct QRCodeView: View {
    let text: String

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        Image(uiImage: generateQRCode(from: text))
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    }

    private func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)

            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        GlassCard {
            VStack(spacing: 10) {
                Text(icon)
                    .font(.system(size: 44))

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct AuthModalView: View {
    @ObservedObject var viewModel: HarrahsViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: AuthMode = .signIn
    @State private var username = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var isPasswordVisible = false
    @State private var errorText: String?

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 44, height: 5)
                    .padding(.top, 8)

                Text("Unity Account")
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Image(.logoHL)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                Picker("Mode", selection: $selectedMode) {
                    ForEach(AuthMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                GlassCard {
                    VStack(spacing: 16) {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white.opacity(0.12))
                            .cornerRadius(14)
                            .foregroundColor(.white)

                        HStack {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                                    .foregroundColor(.white)
                            } else {
                                SecureField("Password", text: $password)
                                    .foregroundColor(.white)
                            }

                            Button {
                                isPasswordVisible.toggle()
                            } label: {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(AppTheme.gold)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(14)

                        if selectedMode == .register {
                            SecureField("Repeat Password", text: $repeatPassword)
                                .padding()
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(14)
                                .foregroundColor(.white)
                        }

                        if let errorText {
                            Text(errorText)
                                .font(.caption)
                                .foregroundColor(AppTheme.coral)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            submit()
                        } label: {
                            Text(selectedMode.buttonTitle)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }

                Button {
                    dismiss()
                } label: {
                    Text("Continue as Guest")
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()
            }
            .padding()
        }
    }

    private func submit() {
        errorText = nil

        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !cleanUsername.isEmpty else {
            errorText = "Enter username."
            return
        }

        guard cleanUsername.count >= 3 else {
            errorText = "Username must contain at least 3 characters."
            return
        }

        guard password.count >= 4 else {
            errorText = "Password must contain at least 4 characters."
            return
        }

        if selectedMode == .register {
            guard password == repeatPassword else {
                errorText = "Passwords do not match."
                return
            }

            let success = viewModel.register(username: cleanUsername, password: password)

            if success {
                dismiss()
            } else {
                errorText = "Registration failed."
            }
        } else {
            let success = viewModel.signIn(username: cleanUsername, password: password)

            if success {
                dismiss()
            } else {
                errorText = "Sign in failed."
            }
        }
    }
}

enum AuthMode: String, CaseIterable, Identifiable {
    case signIn
    case register

    var id: String { rawValue }

    var title: String {
        switch self {
        case .signIn:
            return "Sign In"
        case .register:
            return "Register"
        }
    }

    var buttonTitle: String {
        switch self {
        case .signIn:
            return "🎭 Sign In"
        case .register:
            return "🎭 Create Account"
        }
    }
}
