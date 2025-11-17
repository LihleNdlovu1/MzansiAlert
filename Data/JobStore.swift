//
//  JobStore.swift
//  MzansiAlert
//
//  Created by Assistant on 2025/10/07.
//

import Foundation
import Combine

final class JobStore: ObservableObject {
    @Published private(set) var jobs: [Job]
    private let storageURL: URL
    
    init(jobs: [Job] = []) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.storageURL = documents.appendingPathComponent("jobs.json")
        if let loaded = Self.load(from: storageURL) {
            self.jobs = loaded
        } else if jobs.isEmpty {
            // Seed with a sample to avoid empty state on first run
            self.jobs = [
                Job(
                    id: UUID(),
                    title: "Community Safety Officer",
                    company: "Mzansi Watch",
                    location: "Johannesburg, Gauteng",
                    description: "Work with local communities to coordinate safety initiatives and respond to incident reports.",
                    postedAt: Date().addingTimeInterval(-60 * 60 * 24),
                    contactEmail: "careers@mzansiwatch.org",
                    employmentType: .fullTime
                )
            ]
            Self.save(self.jobs, to: storageURL)
        } else {
            self.jobs = jobs
            Self.save(self.jobs, to: storageURL)
        }
    }
    
    func postJob(title: String, company: String, location: String, description: String, contactEmail: String, employmentType: EmploymentType) {
        let job = Job(
            id: UUID(),
            title: title,
            company: company,
            location: location,
            description: description,
            postedAt: Date(),
            contactEmail: contactEmail,
            employmentType: employmentType
        )
        jobs.insert(job, at: 0)
        Self.save(jobs, to: storageURL)
    }
    
    // MARK: - Persistence (JSON)
    private static func load(from url: URL) -> [Job]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Job].self, from: data) {
            return decoded
        }
        return nil
    }
    
    private static func save(_ jobs: [Job], to url: URL) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(jobs) {
            try? data.write(to: url, options: [.atomic])
        }
    }
}


