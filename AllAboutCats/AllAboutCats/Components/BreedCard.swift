//  BreedCard.swift

import SwiftUI

struct BreedCard: View {
   let breed: CatBreed
   let width: CGFloat

   private var imageHeight: CGFloat { width * 0.85 }

   var body: some View {
       VStack(alignment: .leading, spacing: 0) {

           AsyncImage(url: breed.resolvedImageURL) { phase in
               Group {
                   switch phase {
                   case .success(let img):
                       img
                           .resizable()
                           .scaledToFill()
                   case .empty:
                       Color(.systemGray5)
                           .overlay(
                               ProgressView()
                                   .tint(Color(.systemGray3))
                           )
                   default:
                       Color(.systemGray5)
                           .overlay(
                               Image(systemName: "pawprint")
                                   .foregroundStyle(Color(.systemGray3))
                           )
                   }
               }
               .frame(width: width, height: imageHeight)
               .clipped()
           }
           .frame(width: width, height: imageHeight)
           .clipped()

           VStack(alignment: .leading, spacing: 3) {
               Text(breed.name)
                   .font(.subheadline.weight(.semibold))
                   .foregroundStyle(.primary)
                   .lineLimit(1)
                   .truncationMode(.tail)

               Text(breed.origin ?? "Unknown")
                   .font(.caption)
                   .foregroundStyle(.secondary)
                   .lineLimit(1)
                   .truncationMode(.tail)
           }
           .frame(width: width, alignment: .leading)
           .padding(.horizontal, 10)
           .padding(.top, 8)
           .padding(.bottom, 10)
       }
       .frame(width: width)
       .background(Color(.secondarySystemBackground))
       .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
       .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 3)
   }
}
