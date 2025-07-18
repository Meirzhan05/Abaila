//
//  FeedView.swift
//  Abaila
//
//  Created by Meirzhan Saparov on 6/27/25.
//

import SwiftUI

struct Post: Identifiable {
    let id = UUID()
    let username: String
    let profileImage: String
    let content: String
    let images: [String]
    var likes: Int
    var isLiked: Bool
    let comments: [Comment]
    let timestamp: Date
}

struct Comment: Identifiable {
    let id = UUID()
    let username: String
    let text: String
    let timestamp: Date
}

struct FeedView: View {
    @State private var posts: [Post] = [
        Post(
            username: "john_doe",
            profileImage: "person.circle.fill",
            content: "Beautiful sunset today! 🌅",
            images: ["sunset1", "sunset2"],
            likes: 24,
            isLiked: false,
            comments: [
                Comment(username: "jane_smith", text: "Amazing view!", timestamp: Date()),
                Comment(username: "mike_wilson", text: "Love this spot!", timestamp: Date())
            ],
            timestamp: Date()
        ),
        Post(
            username: "travel_lover",
            profileImage: "person.circle.fill",
            content: "Just finished an amazing hike! The views were absolutely breathtaking.",
            images: [],
            likes: 42,
            isLiked: true,
            comments: [
                Comment(username: "adventure_seeker", text: "Which trail was this?", timestamp: Date())
            ],
            timestamp: Date()
        )
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(posts.indices, id: \.self) { index in
                        PostView(post: $posts[index])
                            .background(Color(.systemBackground))
                    }
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PostView: View {
    @Binding var post: Post
    @State private var showComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: post.profileImage)
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(post.username)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(timeAgoString(from: post.timestamp))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            // Content
            Text(post.content)
                .font(.body)
                .padding(.horizontal)
            
            // Images
            if !post.images.isEmpty {
                TabView {
                    ForEach(post.images, id: \.self) { imageName in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(
                                Text("Image: \(imageName)")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 300)
            }
            
            // Action buttons
            HStack(spacing: 20) {
                Button(action: {
                    post.isLiked.toggle()
                    post.likes += post.isLiked ? 1 : -1
                }) {
                    HStack {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked ? .red : .primary)
                        Text("\(post.likes)")
                    }
                }
                
                Button(action: {
                    showComments.toggle()
                }) {
                    HStack {
                        Image(systemName: "message")
                        Text("\(post.comments.count)")
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bookmark")
                }
            }
            .padding(.horizontal)
            
            // Comments section
            if showComments {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    ForEach(post.comments) { comment in
                        HStack(alignment: .top) {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(comment.username)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    
                                    Text(timeAgoString(from: comment.timestamp))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                
                                Text(comment.text)
                                    .font(.caption)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    
                    // Add comment field
                    HStack {
                        TextField("Add a comment...", text: .constant(""))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Post") {}
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 8)
        
        Divider()
    }
    
    private func timeAgoString(from date: Date) -> String {
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }
}

#Preview {
    FeedView()
}
