//
//  AddTaskView.swift
//  Taskly
//
//  Created by Ritika Joshi on 10/16/25.
//


import SwiftUI
import SwiftData
import MapKit

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var existingTask: Task?

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate = false
    @State private var dueAt: Date = .now.addingTimeInterval(86400)
    @State private var location: String = ""
    @State private var subtasks: [Subtask] = []

    // Map state
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var showingMap = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Task
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Task")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        TextField("Title", text: $title)
                            .tint(Color.tasklyPlum)

                        TextField("Notes (optional)", text: $notes, axis: .vertical)
                            .lineLimit(1...3)
                            .tint(Color.tasklyPlum)

                        Divider()
                    }

                    // MARK: Due Date
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Due Date")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Toggle("Add due date", isOn: $hasDueDate)
                            .tint(Color.tasklyLavender)

                        if hasDueDate {
                            DatePicker("Due", selection: $dueAt, displayedComponents: [.date])
                                .tint(Color.tasklyPlum)
                        }

                        Divider()
                    }

                    // MARK: Location
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Location")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            TextField("Add a location (optional)", text: $location)
                                .tint(Color.tasklyPlum)
                            Button {
                                showingMap = true
                            } label: {
                                Image(systemName: "map.fill")
                                    .imageScale(.large)
                                    .foregroundStyle(Color.tasklyPlum)
                            }
                        }
                        Divider()
                    }

                    // MARK: Subtasks
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subtasks")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        ForEach(subtasks.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    TextField("Subtask title", text: $subtasks[index].title)
                                    Button {
                                        subtasks.remove(at: index)
                                    } label: {
                                        Image(systemName: "trash")
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                    .foregroundStyle(.red)
                                    .buttonStyle(.plain)
                                }

                                DatePicker(
                                    "Due Date",
                                    selection: Binding(
                                        get: { subtasks[index].dueAt ?? .now },
                                        set: { subtasks[index].dueAt = $0 }
                                    ),
                                    displayedComponents: [.date]
                                )
                                .tint(Color.tasklyLavender)
                            }
                            .padding(12)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
                        }

                        Button {
                            subtasks.append(Subtask(title: ""))
                        } label: {
                            Label("Add Subtask", systemImage: "plus.circle.fill")
                        }
                        .tint(Color.tasklyPlum)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .background(Color.tasklyBackground)
            .navigationTitle(existingTask == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.tasklyPlum)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(existingTask == nil ? "Add" : "Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                    .foregroundStyle(Color.tasklyPlum)
                }
            }
            .onAppear {
                if let task = existingTask {
                    title = task.title
                    notes = task.notes ?? ""
                    if let date = task.dueAt {
                        dueAt = date
                        hasDueDate = true
                    }
                    location = task.location ?? ""
                    subtasks = task.subtasks
                }
            }
            
            
            .sheet(isPresented: $showingMap) {
                ZStack {
                    // Map View (modern iOS 17 API)
                    Map(initialPosition: .region(region)) {
                        if let coordinate = selectedLocation {
                            Marker("Selected Location", coordinate: coordinate)
                                .tint(.purple)
                        }
                    }
                    .ignoresSafeArea()
                    .onTapGesture {
                        selectedLocation = region.center
                        reverseGeocode(coordinate: region.center) // 👈 get readable name
                    }

                    // Top bar (search + Done)
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)

                            TextField("Search location…", text: $location)
                                .textFieldStyle(.plain)
                                .onSubmit {
                                    searchForLocation(location)
                                }

                            Button("Done") {
                                showingMap = false
                            }
                            .font(.headline)
                            .foregroundColor(Color.tasklyPlum)
                        }
                        .padding(10)
                        .background(Color.white.opacity(0.95))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.top, 60)
                        .padding(.horizontal, 20)

                        Spacer()
                    }
                }
            }

            
            
            
        }
    }

    // MARK: - Helper: Search for location
    private func searchForLocation(_ query: String) {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            
            guard let c = response?.mapItems.first?.location.coordinate else { return }

            withAnimation {
                region.center = c
                selectedLocation = c
            }
        }
    }
    
    
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        // Use CLGeocoder for compatibility with iOS 17 & 18
        let geocoder = CLGeocoder()
        let locationObject = CLLocation(latitude: coordinate.latitude,
                                        longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(locationObject) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                return
            }

            if let place = placemarks?.first {
                if let name = place.name {
                    location = name
                } else if let area = place.locality ?? place.subLocality {
                    location = area
                } else {
                    location = "Unknown Location"
                }
            }
        }
    }


    
    

    // MARK: - Save Task
    private func saveTask() {
        if let task = existingTask {
            task.title = title
            task.notes = notes.isEmpty ? nil : notes
            task.dueAt = hasDueDate ? dueAt : nil
            task.location = location.isEmpty ? nil : location
            task.subtasks.removeAll()
            for sub in subtasks {
                let newSub = Subtask(title: sub.title, isDone: sub.isDone, dueAt: sub.dueAt)
                context.insert(newSub)
                task.subtasks.append(newSub)
            }
        } else {
            let newTask = Task(
                title: title.trimmingCharacters(in: .whitespaces),
                notes: notes.isEmpty ? nil : notes,
                dueAt: hasDueDate ? dueAt : nil,
                location: location.isEmpty ? nil : location
            )
            for sub in subtasks {
                let newSub = Subtask(title: sub.title, isDone: sub.isDone, dueAt: sub.dueAt)
                context.insert(newSub)
                newTask.subtasks.append(newSub)
            }
            context.insert(newTask)
        }
        try? context.save()
        dismiss()
    }
}

// MARK: - Annotation model
struct LocationAnnotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}
