//
//  CareersView.swift
//  MzansiAlert
//
//  Created by Assistant on 2025/10/07.
//

import SwiftUI

struct CareersView: View {
    @ObservedObject var jobStore: JobStore
    @State private var showingPostSheet = false
    @State private var searchText: String = ""
    
    private var filteredJobs: [Job] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return jobStore.jobs }
        return jobStore.jobs.filter { job in
            job.title.lowercased().contains(query)
            || job.company.lowercased().contains(query)
            || job.location.lowercased().contains(query)
            || job.description.lowercased().contains(query)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search jobs (title, company, location)", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    Button(action: { searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines) }) {
                        Text("Search")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.blue, in: Capsule())
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .padding(.horizontal)
                
                // Results
                Group {
                    if filteredJobs.isEmpty {
                        EmptyStateView()
                    } else {
                        List(filteredJobs, id: \.id) { job in
                            JobRow(job: job)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("Careers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingPostSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Post Job")
                }
            }
        }
        .sheet(isPresented: $showingPostSheet) {
            PostJobView(jobStore: jobStore)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct JobRow: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text(job.company)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Text(job.employmentType.rawValue)
                    .font(.caption)
                    .foregroundColor(job.employmentType.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(job.employmentType.color.opacity(0.12), in: Capsule())
            }
            
            Text(job.location)
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Text(job.description)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(3)
            
            HStack {
                Text(job.postedAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text(job.contactEmail)
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct PostJobView: View {
    @ObservedObject var jobStore: JobStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var company: String = ""
    @State private var location: String = ""
    @State private var description: String = ""
    @State private var contactEmail: String = ""
    @State private var employmentType: EmploymentType = .fullTime
    @State private var isSubmitting: Bool = false
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        contactEmail.contains("@")
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    GlassCard {
                        VStack(spacing: 12) {
                            CustomTextField(placeholder: "Job Title", text: $title, icon: "briefcase.fill")
                            CustomTextField(placeholder: "Company", text: $company, icon: "building.2.fill")
                            CustomTextField(placeholder: "Location", text: $location, icon: "mappin.and.ellipse")
                            CustomTextField(placeholder: "Contact Email", text: $contactEmail, icon: "envelope.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Employment Type")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(EmploymentType.allCases) { type in
                                            Button(action: { employmentType = type }) {
                                                Text(type.rawValue)
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(employmentType == type ? .white : type.color)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 8)
                                                    .background(
                                                        employmentType == type ? type.color : .secondary.opacity(0.1),
                                                        in: Capsule()
                                                    )
                                            }
                                            .animation(.spring(response: 0.3), value: employmentType)
                                        }
                                    }
                                }
                            }
                            
                            CustomTextEditor(placeholder: "Job Description", text: $description)
                                .frame(minHeight: 120)
                        }
                    }
                    
                    SubmitButton(isSubmitting: $isSubmitting, isDisabled: !isFormValid) {
                        isSubmitting = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            jobStore.postJob(
                                title: title,
                                company: company,
                                location: location,
                                description: description,
                                contactEmail: contactEmail,
                                employmentType: employmentType
                            )
                            isSubmitting = false
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Post a Job")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}


