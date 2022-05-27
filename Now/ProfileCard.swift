//
//  ProfileCard.swift
//  Now
//
//  Created by Guillaume Bisiaux on 27/05/2022.
//

import SwiftUI

enum CardAction {
	case hello, goodBye
}

struct ProfileCard: View {
	var profile: Profile
	@State var index: Int
	@Binding var currentIndex: Int
	
	@State private var photoIndex: Int = 0
	
	@State private var angle: Angle = .zero
	@State private var offset = CGSize.zero
	@State private var opacity: CGFloat = 1
	@Binding var action: CardAction
	
	var body: some View {
		content
			.onChange(of: currentIndex) { newValue in
				guard index == currentIndex - 1 else { return }
				if action == .hello {
					offset = CGSize(width: UIScreen.main.bounds.width * 2, height: 0)
					angle = .degrees(25)
					opacity = 0
				} else {
					offset = CGSize(width: -(UIScreen.main.bounds.width * 2), height: 0)
					angle = .degrees(-25)
					opacity = 0
				}
			}
	}
	
    var content: some View {
		ZStack(alignment: .bottom) {
			ZStack {
				ZStack {
					ForEach(profile.photos, id: \.self) { photo in
						AsyncImage(url: URL(string: photo)) { result in
							result
								.resizable()
								.aspectRatio(contentMode: .fill)
								.frame(width: UIScreen.main.bounds.width - 40, height: 450)
								.clipped()
						} placeholder: {
							ZStack {
								Color.gray
								ProgressView()
									.progressViewStyle(CircularProgressViewStyle())
							}
						}
						.opacity(profile.photos[photoIndex] == photo ? 1 : 0)

					}
				}
				
				HStack(spacing: 0) {
					Rectangle().fill(Color.red.opacity(0.00001))
						.onTapGesture {
							if photoIndex == 0 {
								photoIndex = profile.photos.count - 1
							} else {
								photoIndex -= 1
							}
						}
					Rectangle().fill(Color.red.opacity(0.00001))
						.onTapGesture {
							if profile.photos.count - 1 == photoIndex {
								photoIndex = 0
							} else {
								photoIndex += 1
							}
						}
				}
				
				VStack {
					HStack {
						ForEach(profile.photos.indices, id: \.self) { index in
							RoundedRectangle(cornerRadius: 4)
								.fill(Color.white.opacity(photoIndex == index ? 1 : 0.5))
						}
					}
					.frame(height: 6)
					Spacer()
				}
				.padding(.horizontal, 38)
				.padding(.vertical, 12)
				
				Color.black
					.opacity(withAnimation{
						currentIndex == index ? 0 : 0.25
					})
					
			}
			
			VStack(alignment: .leading) {
				Text(profile.firstName)
					.font(.title).bold()
				Text(profile.city + ", " + profile.country)
					.font(.body)
					.foregroundColor(.gray)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
			.background(Color.white)
			
		}
		.frame(maxHeight: 450)
		.clipped()
		.addBorder(Color.gray.opacity(0.25), cornerRadius: 20)
		.shadow(color: Color.gray.opacity(0.25), radius: 20, x: 0, y: 4)
		.padding(.horizontal, 20)
		.rotationEffect(angle)
		.offset(offset)
		.gesture(
			DragGesture()
				.onChanged { gesture in
					offset = gesture.translation
					angle = Angle(degrees: gesture.translation.width / 15)
				}
				.onEnded { _ in
					if offset.width > 100 {
						action = .hello
						currentIndex += 1
					} else if offset.width < 100 {
						action = .goodBye
						currentIndex += 1
					} else {
						offset = .zero
						angle = .zero
					}
				}
		)
		.animation(.spring(), value: offset)
		.opacity(opacity)
		.animation(.spring().delay(0.15), value: opacity)
    }
}


struct ProfileCard_Previews: PreviewProvider {
	static var previews: some View {
		ProfileCard(
			profile:
				Profile(
					id: 0,
					firstName: "Guillaume",
					lastName: "Bisiaux",
					city: "Lille",
					country: "France",
					isMatch: false,
					photos: ["https://assets.heroes.jobs/medias/6084/1637227535221.png",
							 "https://assets.heroes.jobs/social/Preview/404p.png",
							 "https://assets.heroes.jobs/social/Preview/88p.png"
							]
				),
			index: 0,
			currentIndex: .constant(0),
			action: .constant(.hello)
		)
		.padding()
		.previewLayout(.sizeThatFits)
    }
}

extension View {
	public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S : ShapeStyle {
		let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
		return clipShape(roundedRect)
			.overlay(roundedRect.strokeBorder(content, lineWidth: width))
	}
}
